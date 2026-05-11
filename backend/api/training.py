from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from sqlalchemy.orm import Session
import shutil
import os
import uuid
from database.config import get_db
from database.models import TrainingJob, User
from worker.tasks import train_model_task
from ml.inference import inference_engine
from .auth import get_current_admin

router = APIRouter(prefix="/training", tags=["Training"])

DATASET_DIR = "/app/storage/datasets"

from pydantic import BaseModel

class TrainingStart(BaseModel):
    dataset_name: str
    num_epochs: int = 3

@router.post("/start")
async def start_training(
    payload: TrainingStart = None, 
    file: UploadFile = File(None), 
    db: Session = Depends(get_db), 
    current_admin: User = Depends(get_current_admin)
):
    if file:
        if not file.filename.endswith(".zip"):
            raise HTTPException(status_code=400, detail="Only .zip datasets are allowed")
        
        file_name = f"{uuid.uuid4()}.zip"
        file_path = os.path.join(DATASET_DIR, file_name)
        
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        display_name = file.filename
    elif payload:
        file_name = f"{payload.dataset_name}.zip"
        file_path = os.path.join(DATASET_DIR, file_name)
        
        if not os.path.exists(file_path):
            raise HTTPException(status_code=404, detail=f"Dataset file {file_name} not found in storage/datasets")
        
        display_name = payload.dataset_name
    else:
        raise HTTPException(status_code=400, detail="Either file upload or dataset_name JSON is required")
    
    new_job = TrainingJob(dataset_name=display_name, status="pending")
    db.add(new_job)
    db.commit()
    db.refresh(new_job)
    
    # Trigger background task
    epochs = payload.num_epochs if payload else 15
    train_model_task.delay(new_job.id, file_path, epochs)
    
    return {"message": "Training started", "job_id": new_job.id}

@router.post("/start-local")
async def start_training_local(
    payload: TrainingStart, 
    db: Session = Depends(get_db), 
    current_admin: User = Depends(get_current_admin)
):
    file_name = f"{payload.dataset_name}.zip"
    # Map the container path correctly
    file_path = os.path.join(DATASET_DIR, file_name)
    
    if not os.path.exists(file_path):
        raise HTTPException(
            status_code=404, 
            detail=f"Dataset file {file_name} not found. Make sure it is in storage/datasets/"
        )
    
    new_job = TrainingJob(dataset_name=payload.dataset_name, status="pending")
    db.add(new_job)
    db.commit()
    db.refresh(new_job)
    
    # Trigger background task
    train_model_task.delay(new_job.id, file_path, payload.num_epochs)
    
    return {"message": "Local training started", "job_id": new_job.id}

@router.get("/status/{job_id}")
def get_training_status(job_id: int, db: Session = Depends(get_db)):
    job = db.query(TrainingJob).filter(TrainingJob.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    return job

@router.get("/jobs")
def list_jobs(db: Session = Depends(get_db)):
    return db.query(TrainingJob).order_by(TrainingJob.created_at.desc()).all()

@router.post("/deploy/{job_id}")
async def deploy_model(
    job_id: int, 
    db: Session = Depends(get_db), 
    current_admin: User = Depends(get_current_admin)
):
    # 1. Verify job exists and is completed
    job = db.query(TrainingJob).filter(TrainingJob.id == job_id).first()
    if not job or job.status != "completed":
        raise HTTPException(status_code=400, detail="Job not found or not completed")
    
    # 2. Update database flags
    db.query(TrainingJob).update({TrainingJob.is_deployed: False})
    job.is_deployed = True
    db.commit()
    
    # 3. Copy model to production path
    model_dir = "/app/storage/models"
    src_path = os.path.join(model_dir, f"job_{job_id}.pth")
    dest_path = os.path.join(model_dir, "production_model.pth")
    
    if os.path.exists(src_path):
        import shutil
        shutil.copy2(src_path, dest_path)
        
        # 4. Reload inference engine
        success = inference_engine.load_model(dest_path)
        if not success:
            raise HTTPException(status_code=500, detail="Failed to reload model in inference engine")
            
        return {"message": f"Model from job {job_id} deployed to production successfully"}
    else:
        raise HTTPException(status_code=404, detail="Model file not found")

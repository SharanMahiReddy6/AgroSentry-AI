from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, Form
from sqlalchemy.orm import Session
import shutil
import os
import uuid
import zipfile
import random
from database.config import get_db
from database.models import TrainingJob, User
from worker.tasks import train_model_task
from ml.inference import inference_engine
from .auth import get_current_admin

router = APIRouter(prefix="/training", tags=["Training"])

from core.config import DATASET_DIR, MODEL_DIR

from pydantic import BaseModel

class TrainingStart(BaseModel):
    dataset_name: str
    num_epochs: int = 3

@router.post("/upload-dataset")
async def upload_dataset(
    file: UploadFile = File(...),
    crop_name: str = Form(...),
    disease_name: str = Form(None),
    is_full_dataset: bool = Form(...),
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin)
):
    if not file.filename.endswith(".zip"):
        raise HTTPException(status_code=400, detail="Only .zip datasets are allowed")
    
    if is_full_dataset:
        # Save directly as crop_name_training.zip
        file_name = f"{crop_name}_training.zip"
        file_path = os.path.join(DATASET_DIR, file_name)
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        return {"message": f"Successfully uploaded full dataset for {crop_name}", "dataset": file_name}
    else:
        if not disease_name:
            raise HTTPException(status_code=400, detail="disease_name is required for new disease class")
            
        temp_dir = os.path.join(DATASET_DIR, f"temp_{uuid.uuid4()}")
        os.makedirs(temp_dir, exist_ok=True)
        temp_zip_path = os.path.join(temp_dir, "upload.zip")
        
        with open(temp_zip_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        extract_dir = os.path.join(temp_dir, "extracted")
        os.makedirs(extract_dir, exist_ok=True)
        
        with zipfile.ZipFile(temp_zip_path, 'r') as zip_ref:
            zip_ref.extractall(extract_dir)
            
        # Find all images
        images = []
        for root, dirs, files in os.walk(extract_dir):
            for f in files:
                if f.lower().endswith(('.png', '.jpg', '.jpeg')):
                    images.append(os.path.join(root, f))
                    
        if not images:
            shutil.rmtree(temp_dir)
            raise HTTPException(status_code=400, detail="No images found in the uploaded zip")
            
        random.shuffle(images)
        split_idx = int(len(images) * 0.8)
        train_images = images[:split_idx]
        valid_images = images[split_idx:]
        
        # Create new zip
        # E.g. apple_Apple_NewDisease_training.zip
        safe_disease = disease_name.replace(" ", "_")
        new_zip_name = f"{crop_name}_{safe_disease}_training.zip"
        new_zip_path = os.path.join(DATASET_DIR, new_zip_name)
        
        with zipfile.ZipFile(new_zip_path, 'w') as zipf:
            for i, img_path in enumerate(train_images):
                ext = os.path.splitext(img_path)[1]
                arcname = f"train/{disease_name}/img_{i}{ext}"
                zipf.write(img_path, arcname)
                
            for i, img_path in enumerate(valid_images):
                ext = os.path.splitext(img_path)[1]
                arcname = f"valid/{disease_name}/img_{i}{ext}"
                zipf.write(img_path, arcname)
                
        # Clean up
        shutil.rmtree(temp_dir)
        return {"message": f"Successfully created new dataset class {disease_name} for {crop_name}", "dataset": new_zip_name}


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
            # Fallback to suffix _training.zip
            file_name = f"{payload.dataset_name}_training.zip"
            file_path = os.path.join(DATASET_DIR, file_name)
            
        if not os.path.exists(file_path):
            raise HTTPException(
                status_code=404, 
                detail=f"Dataset file {payload.dataset_name}.zip or {payload.dataset_name}_training.zip not found in storage/datasets"
            )
        
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
    file_path = os.path.join(DATASET_DIR, file_name)
    
    if not os.path.exists(file_path):
        # Fallback to suffix _training.zip
        file_name = f"{payload.dataset_name}_training.zip"
        file_path = os.path.join(DATASET_DIR, file_name)
        
    if not os.path.exists(file_path):
        raise HTTPException(
            status_code=404, 
            detail=f"Dataset file {payload.dataset_name}.zip or {payload.dataset_name}_training.zip not found. Make sure it is in storage/datasets/"
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

@router.get("/available-datasets")
def get_available_datasets():
    datasets = set(["apple", "blueberry", "cherry", "corn", "grape", "orange", "peach", "pepper", "potato", "strawberry", "tomato"])
    if os.path.exists(DATASET_DIR):
        for f in os.listdir(DATASET_DIR):
            if f.endswith("_training.zip"):
                crop = f.split("_")[0]
                datasets.add(crop)
    return sorted(list(datasets))

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
    model_dir = MODEL_DIR
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

@router.get("/estimates")
def get_training_estimates(db: Session = Depends(get_db)):
    datasets = set(["corn", "grape", "orange", "peach", "pepper", "potato", "strawberry", "tomato"])
    if os.path.exists(DATASET_DIR):
        for f in os.listdir(DATASET_DIR):
            if f.endswith("_training.zip"):
                datasets.add(f.split("_")[0])
    remaining = sorted(list(datasets))
    estimates = []
    
    for ds in remaining:
        zip_name = f"{ds}_training.zip"
        zip_path = os.path.join(DATASET_DIR, zip_name)
        if os.path.exists(zip_path):
            size_mb = os.path.getsize(zip_path) / (1024 * 1024)
            # Standard transfer learning benchmark: ~10 images per MB, 0.03 seconds per image per epoch on CPU
            estimated_images = int(size_mb * 10)
            epochs = 5
            est_time_seconds = int(estimated_images * epochs * 0.03)
            
            minutes = est_time_seconds // 60
            seconds = est_time_seconds % 60
            est_str = f"{minutes}m {seconds}s" if minutes > 0 else f"{seconds}s"
            
            estimates.append({
                "dataset": ds,
                "file_size_mb": round(size_mb, 1),
                "estimated_images": estimated_images,
                "epochs": epochs,
                "estimated_duration": est_str,
                "duration_seconds": est_time_seconds
            })
        else:
            estimates.append({
                "dataset": ds,
                "file_size_mb": 0.0,
                "estimated_images": 0,
                "epochs": 0,
                "estimated_duration": "Dataset file missing",
                "duration_seconds": 0
            })
    return estimates


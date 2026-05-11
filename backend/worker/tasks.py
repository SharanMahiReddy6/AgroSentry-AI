from .celery_app import celery_app
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import zipfile
import shutil
from database.config import SessionLocal
from database.models import TrainingJob
from datetime import datetime

@celery_app.task(name="train_model_task")
def train_model_task(job_id: int, dataset_path: str, num_epochs: int = 3):
    db = SessionLocal()
    job = db.query(TrainingJob).filter(TrainingJob.id == job_id).first()
    
    if not job:
        return "Job not found"

    try:
        job.status = "training"
        db.commit()

        # Simulate dataset extraction and training
        # 1. Extract ZIP
        extract_path = dataset_path.replace(".zip", "")
        with zipfile.ZipFile(dataset_path, 'r') as zip_ref:
            zip_ref.extractall(extract_path)

        # 2. Start Real Training
        from ml.training_pipeline import train_model
        model_save_path = f"/app/storage/models/job_{job_id}.pth"
        classes, accuracy = train_model(
            dataset_path=extract_path,
            model_save_path=model_save_path,
            num_epochs=num_epochs
        )
        
        # 3. Mark as completed
        job.status = "completed"
        job.accuracy = accuracy
        job.completed_at = datetime.utcnow()
        # Save model path to job metadata or similar if needed
        db.commit()

        # Clean up extracted files
        shutil.rmtree(extract_path)
        
        return f"Training completed for job {job_id}"

    except Exception as e:
        job.status = "failed"
        job.error_message = str(e)
        db.commit()
        return f"Training failed: {str(e)}"
    finally:
        db.close()

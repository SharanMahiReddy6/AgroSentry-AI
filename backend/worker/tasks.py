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

        # 1. Extract ALL ZIP datasets to train a unified global model
        from core.config import DATASET_DIR
        import glob
        
        extract_path = os.path.join(DATASET_DIR, f"temp_job_{job_id}")
        if os.path.exists(extract_path):
            shutil.rmtree(extract_path)
        os.makedirs(extract_path, exist_ok=True)
        
        print(f"Extracting all dataset ZIPs to unified directory: {extract_path}")
        all_zips = glob.glob(os.path.join(DATASET_DIR, "*_training.zip"))
        
        for zip_path in all_zips:
            try:
                # We need to extract each zip. Some zips contain 'train'/'valid' at the root,
                # some contain a subfolder first. We will extract them to a temporary subfolder,
                # then merge their 'train' and 'valid' folders into the main extract_path.
                temp_zip_extract = os.path.join(extract_path, f"temp_{os.path.basename(zip_path)}")
                os.makedirs(temp_zip_extract, exist_ok=True)
                
                with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                    zip_ref.extractall(temp_zip_extract)
                
                # Locate train/valid in the extracted temp folder
                train_src = os.path.join(temp_zip_extract, 'train')
                val_src = os.path.join(temp_zip_extract, 'valid')
                
                if not os.path.exists(train_src):
                    subdirs = [d for d in os.listdir(temp_zip_extract) if os.path.isdir(os.path.join(temp_zip_extract, d))]
                    for sd in subdirs:
                        if os.path.exists(os.path.join(temp_zip_extract, sd, 'train')):
                            train_src = os.path.join(temp_zip_extract, sd, 'train')
                            val_src = os.path.join(temp_zip_extract, sd, 'valid')
                            break
                            
                if os.path.exists(train_src):
                    # Merge classes into the main extract_path
                    for phase, src_dir in [('train', train_src), ('valid', val_src)]:
                        if not os.path.exists(src_dir): continue
                        main_phase_dir = os.path.join(extract_path, phase)
                        os.makedirs(main_phase_dir, exist_ok=True)
                        
                        classes = [c for c in os.listdir(src_dir) if os.path.isdir(os.path.join(src_dir, c))]
                        for cls in classes:
                            cls_src = os.path.join(src_dir, cls)
                            cls_dest = os.path.join(main_phase_dir, cls)
                            os.makedirs(cls_dest, exist_ok=True)
                            
                            # Move files to merge
                            for f in os.listdir(cls_src):
                                shutil.move(os.path.join(cls_src, f), os.path.join(cls_dest, f))
                                
                # Cleanup temp zip extract
                shutil.rmtree(temp_zip_extract)
            except Exception as e:
                print(f"Error processing {zip_path}: {e}")

        # 2. Start Real Training
        # Define epoch callback to update database progress
        def on_epoch_end(epoch, accuracy):
            from database.config import SessionLocal as CB_SessionLocal
            cb_db = CB_SessionLocal()
            try:
                cb_job = cb_db.query(TrainingJob).filter(TrainingJob.id == job_id).first()
                if cb_job:
                    progress_pct = int(((epoch + 1) / num_epochs) * 100)
                    cb_job.progress = min(100, max(0, progress_pct))
                    cb_job.accuracy = int(accuracy)
                    cb_db.commit()
                    print(f"DATABASE UPDATE: Job {job_id} Epoch {epoch+1} progress={progress_pct}%, accuracy={int(accuracy)}%")
            except Exception as e:
                print(f"Error updating training job progress: {e}")
            finally:
                cb_db.close()

        from ml.training_pipeline import train_model
        from core.config import MODEL_DIR
        model_save_path = os.path.join(MODEL_DIR, f"job_{job_id}.pth")
        classes, accuracy = train_model(
            dataset_path=extract_path,
            model_save_path=model_save_path,
            num_epochs=num_epochs,
            on_epoch_end=on_epoch_end
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

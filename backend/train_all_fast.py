import os
import sys
import zipfile
import shutil
import glob
from datetime import datetime

# Set up path so we can import backend packages
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import text
from database.config import SessionLocal
from database.models import TrainingJob
from core.config import DATASET_DIR, MODEL_DIR
from ml.training_pipeline import train_model

def main():
    db = SessionLocal()
    print("AgroSentry Unified Fast Training Automation Script")
    print(f"Dataset directory: {DATASET_DIR}")
    print(f"Model directory: {MODEL_DIR}")
    print("-" * 50)

    # Fix sequence issue just in case
    try:
        db.execute(text("SELECT setval(pg_get_serial_sequence('training_jobs', 'id'), coalesce(max(id),0) + 1, false) FROM training_jobs;"))
        db.commit()
    except Exception as e:
        db.rollback()
        pass

    # Create one unified database training job record
    job = TrainingJob(
        dataset_name="Unified_Global_Model",
        status="training",
        progress=0,
        is_deployed=True
    )
    db.add(job)
    db.commit()
    db.refresh(job)
    print(f"Database Job Created - ID: {job.id}, Dataset Name: {job.dataset_name}")
    
    extract_path = os.path.join(DATASET_DIR, f"temp_extract_unified_{job.id}")
    subset_path = os.path.join(DATASET_DIR, f"temp_subset_unified_{job.id}")
    
    try:
        # Clean any old remnants
        for path in [extract_path, subset_path]:
            if os.path.exists(path):
                shutil.rmtree(path)
        
        os.makedirs(extract_path, exist_ok=True)
        os.makedirs(subset_path, exist_ok=True)
        
        # Merge all available ZIP files
        all_zips = glob.glob(os.path.join(DATASET_DIR, "*_training.zip"))
        if not all_zips:
            print("No datasets found to train!")
            return

        print(f"Extracting {len(all_zips)} dataset ZIPs to {extract_path}...")
        for zip_path in all_zips:
            try:
                temp_zip_extract = os.path.join(extract_path, f"temp_{os.path.basename(zip_path)}")
                os.makedirs(temp_zip_extract, exist_ok=True)
                
                with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                    zip_ref.extractall(temp_zip_extract)
                
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
                    for phase, src_dir in [('train', train_src), ('valid', val_src)]:
                        if not os.path.exists(src_dir): continue
                        main_phase_dir = os.path.join(subset_path, phase)
                        os.makedirs(main_phase_dir, exist_ok=True)
                        
                        classes = [c for c in os.listdir(src_dir) if os.path.isdir(os.path.join(src_dir, c))]
                        for cls in classes:
                            cls_src = os.path.join(src_dir, cls)
                            cls_dest = os.path.join(main_phase_dir, cls)
                            os.makedirs(cls_dest, exist_ok=True)
                            
                            files = [f for f in os.listdir(cls_src) if os.path.isfile(os.path.join(cls_src, f))]
                            # Take all files for detailed training
                            for f in files:
                                shutil.copy2(os.path.join(cls_src, f), os.path.join(cls_dest, f))
                                
                shutil.rmtree(temp_zip_extract)
            except Exception as e:
                print(f"Error processing {zip_path}: {e}")

        # Execute training on the unified dataset
        print("Starting unified detailed transfer learning model training (5 epochs)...")
        model_save_path = os.path.join(MODEL_DIR, f"job_{job.id}.pth")
        
        classes, accuracy = train_model(
            dataset_path=subset_path,
            model_save_path=model_save_path,
            num_epochs=5
        )
        
        # Deploy as production model automatically
        production_model_path = os.path.join(MODEL_DIR, "production_model.pth")
        shutil.copy2(model_save_path, production_model_path)
        print(f"Unified model deployed to {production_model_path}")
        
        # Update database to completed
        job.status = "completed"
        job.progress = 100
        job.accuracy = int(accuracy)
        job.completed_at = datetime.now()
        db.commit()
        print(f"Training Successful! Model saved to {model_save_path}")
        print(f"Final Accuracy: {int(accuracy)}% with classes: {classes}")
        
    except Exception as e:
        print(f"Unified Training Failed: {e}")
        job.status = "failed"
        job.error_message = str(e)
        db.commit()
        
    finally:
        # Clean up temporary folders
        print("Cleaning up temporary folders...")
        for path in [extract_path, subset_path]:
            if os.path.exists(path):
                try:
                    shutil.rmtree(path)
                except Exception as clean_err:
                    print(f"Warning: Failed to delete {path}: {clean_err}")
                    
    db.close()
    print("\nAll training tasks finished!")

if __name__ == "__main__":
    main()

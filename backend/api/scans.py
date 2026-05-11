from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, Form
from sqlalchemy.orm import Session
import shutil
import os
import uuid
from database.config import get_db
from database.models import User, ScanRecord
from ml.inference import inference_engine
from .auth import get_current_user

router = APIRouter(prefix="/scans", tags=["Scans"])

UPLOAD_DIR = "/app/storage/uploads"
HEATMAP_DIR = "/app/storage/heatmaps"

# Ensure directories exist
os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(HEATMAP_DIR, exist_ok=True)


@router.post("/upload")
async def upload_scan(
    file: UploadFile = File(...), 
    crop_type: str = Form(None), 
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user)
):
    print(f"DEBUG: Upload request received for file: {file.filename}, Crop: {crop_type}")
    
    file_ext = file.filename.split(".")[-1]
    file_name = f"{uuid.uuid4()}.{file_ext}"
    file_path = os.path.join(UPLOAD_DIR, file_name)
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    # Perform inference with target crop
    result = inference_engine.predict(file_path, target_crop=crop_type)
    
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
    
    # Save to database
    new_scan = ScanRecord(
        image_url=f"/storage/uploads/{file_name}",
        crop_type=crop_type or result["basic_details"]["crop_type"],
        heatmap_url=result["visuals"]["heatmap_url"],
        prediction=result["basic_details"]["disease_name"],
        confidence=result["basic_details"]["confidence"],
        severity=result["basic_details"]["severity"],
        infected_area_percent=result["basic_details"]["infection_percentage"],
        user_id=current_user.id,
        recommendation=result["basic_details"]["summary"]
    )
    db.add(new_scan)
    db.commit()
    db.refresh(new_scan)
    
    return {
        "status": "success",
        "scan_id": new_scan.id,
        "results": result,
        "created_at": new_scan.created_at
    }

@router.get("/history")
def get_history(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return db.query(ScanRecord).filter(ScanRecord.user_id == current_user.id).order_by(ScanRecord.created_at.desc()).all()

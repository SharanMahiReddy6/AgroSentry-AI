from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, Form
from sqlalchemy.orm import Session
import shutil
import os
import uuid
from database.config import get_db
from database.models import User, ScanRecord, TrainingJob
from ml.inference import inference_engine
from .auth import get_current_user

router = APIRouter(prefix="/scans", tags=["Scans"])

from core.config import UPLOAD_DIR, HEATMAP_DIR, MODEL_DIR

# Ensure directories exist
os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(HEATMAP_DIR, exist_ok=True)
os.makedirs(MODEL_DIR, exist_ok=True)

@router.post("/upload")
async def upload_scan(
    file: UploadFile = File(...), 
    crop_type: str = Form(None), 
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user)
):
    print(f"DEBUG: Scan upload request received. File: {file.filename}, Selected Crop: {crop_type}")
    
    file_ext = file.filename.split(".")[-1]
    file_name = f"{uuid.uuid4()}.{file_ext}"
    file_path = os.path.join(UPLOAD_DIR, file_name)
    
    # Save the uploaded file to disk
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    # Use the unified global model for all predictions to enable cross-crop verification
    result = inference_engine.predict(file_path, target_crop=crop_type, model_path=None)
    
    if not result.get("success"):
        # Clean up uploaded file immediately on rejection to save disk space
        if os.path.exists(file_path):
            os.remove(file_path)
        raise HTTPException(status_code=400, detail=result.get("message", "Analysis failed."))
    
    # Extract details for database persistence
    basic = result["results"]["basic_details"]
    visuals = result["results"]["visuals"]
    
    new_scan = ScanRecord(
        image_url=f"/storage/uploads/{file_name}",
        crop_type=crop_type or basic["crop_type"],
        heatmap_url=visuals["heatmap_url"],
        prediction=basic["disease_name"],
        confidence=basic["confidence"],
        severity=basic["severity"],
        infected_area_percent=basic["infection_percentage"],
        user_id=current_user.id,
        recommendation=basic["summary"]
    )
    db.add(new_scan)
    db.commit()
    db.refresh(new_scan)
    
    # Return the exact JSON structure requested by the user, augmented with scan ID for history compatibility
    return {
        "success": True,
        "message": result["message"],
        "scan_id": new_scan.id,
        "data": result["data"],
        "results": result["results"],
        "scan_record": {
            "id": new_scan.id,
            "image_url": new_scan.image_url,
            "heatmap_url": new_scan.heatmap_url,
            "crop_type": new_scan.crop_type,
            "prediction": new_scan.prediction,
            "confidence": new_scan.confidence,
            "severity": new_scan.severity,
            "created_at": new_scan.created_at.isoformat() if new_scan.created_at else None
        }
    }

@router.get("/")
@router.get("")
@router.get("/history")
def get_history(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return db.query(ScanRecord).filter(ScanRecord.user_id == current_user.id).order_by(ScanRecord.created_at.desc()).all()

@router.get("/diseases")
def get_diseases(db: Session = Depends(get_db)):
    # Return all disease knowledge for the library
    from ml.knowledge_base import get_all_diseases
    return get_all_diseases(db)


@router.get("/{scan_id}")
def get_scan_details(scan_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    scan = db.query(ScanRecord).filter(ScanRecord.id == scan_id, ScanRecord.user_id == current_user.id).first()
    if not scan:
        raise HTTPException(status_code=404, detail="Scan not found")
        
    from ml.knowledge_base import DISEASE_KNOWLEDGE, get_disease_info
    
    severity = scan.severity or "Medium"
    # Find matching class in DISEASE_KNOWLEDGE
    matched_class = None
    target_common = scan.prediction.lower().strip()
    target_crop = scan.crop_type.lower().strip()
    
    for class_name, info in DISEASE_KNOWLEDGE.items():
        info_common = info.get("common_name", "").lower().strip()
        info_crop = info.get("crop_type", "").lower().strip()
        
        if info_common == target_common and info_crop == target_crop:
            matched_class = class_name
            break
            
    if not matched_class:
        # Try harder to match just by common_name if exact crop + common_name fails
        for class_name, info in DISEASE_KNOWLEDGE.items():
            if info.get("common_name", "").lower().strip() == target_common:
                matched_class = class_name
                break

    if not matched_class:
        # Reconstruct dynamic class name as last resort
        matched_class = f"{scan.crop_type.title()}___{scan.prediction.replace(' ', '_')}"
        
    info = get_disease_info(matched_class, severity)
    
    # Map symptoms image list
    symptoms_mapped = []
    for sym in info["symptoms"]:
        snake_title = sym["title"].lower().replace(" ", "_")
        symptoms_mapped.append({
            "title": sym["title"],
            "description": sym["description"],
            "imageUrl": f"/storage/symptoms/{snake_title}.png"
        })

    severity_message = "Moderate infection detected. Immediate treatment recommended preventing spread."
    if severity == "High":
        severity_message = "Severe infection detected. Immediate aggressive treatment is required to prevent total crop loss."
    elif severity == "Low":
        severity_message = "Mild infection detected. Monitor the plant closely and remove any spotted leaves to prevent spread."

    response_data = {
        "diagnosisId": f"DG{str(scan.id).zfill(5)}",
        "plant": {
            "name": f"{info['crop_type']} Plant",
            "captureDate": scan.created_at.strftime("%Y-%m-%d")
        },
        "disease": {
            "name": info["common_name"],
            "scientificName": info["scientific_name"],
            "description": info["overview"]
        },
        "analysis": {
            "confidence": scan.confidence,
            "infectionArea": scan.infected_area_percent,
            "severity": "Medium" if severity == "Moderate" else severity,
            "severityMessage": severity_message
        },
        "causes": info["causes"],
        "symptoms": symptoms_mapped,
        "highlight": {
            "overlayImageUrl": scan.heatmap_url,
            "opacity": 60
        },
        "treatment": {
            "organic": info["organic_treatment"],
            "chemical": info["chemical_treatment"],
            "preventive": info["prevention"]
        }
    }
    
    return {
        "success": True,
        "scan_id": scan.id,
        "data": response_data,
        "scan_record": {
            "id": scan.id,
            "image_url": scan.image_url,
            "heatmap_url": scan.heatmap_url,
            "crop_type": scan.crop_type,
            "prediction": scan.prediction,
            "confidence": scan.confidence,
            "severity": scan.severity,
            "created_at": scan.created_at.isoformat() if scan.created_at else None
        }
    }

@router.delete("/{scan_id}")
def delete_scan(scan_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    scan = db.query(ScanRecord).filter(ScanRecord.id == scan_id, ScanRecord.user_id == current_user.id).first()
    if not scan:
        raise HTTPException(status_code=404, detail="Scan not found")
    db.delete(scan)
    db.commit()
    return {"success": True, "message": "Scan deleted successfully"}


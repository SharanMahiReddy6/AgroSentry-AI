from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database.config import get_db
from database.models import QuickTip, User
from .auth import get_current_user, get_current_admin
from pydantic import BaseModel
from typing import List, Optional

router = APIRouter(prefix="/tips", tags=["Quick Tips"])

class TipCreate(BaseModel):
    title: str
    category: str
    content: str
    detailed_content: Optional[str] = None

class TipResponse(BaseModel):
    id: int
    title: str
    category: str
    read_time: str
    content: str
    detailed_content: Optional[str]
    author: str
    is_approved: bool

    class Config:
        from_attributes = True

@router.get("", response_model=List[TipResponse])
def get_approved_tips(db: Session = Depends(get_db)):
    return db.query(QuickTip).filter(QuickTip.is_approved == True).order_by(QuickTip.created_at.desc()).all()

@router.post("/submit", response_model=TipResponse)
def submit_tip(tip_in: TipCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    # Standard users submit unapproved tips, admins submit pre-approved tips
    is_approved = current_user.is_admin
    read_time = f"{max(1, len(tip_in.content.split()) // 60)} min read"
    author_name = current_user.full_name or current_user.email.split("@")[0].title()
    
    new_tip = QuickTip(
        title=tip_in.title,
        category=tip_in.category,
        read_time=read_time,
        content=tip_in.content,
        detailed_content=tip_in.detailed_content,
        author=author_name,
        is_approved=is_approved
    )
    db.add(new_tip)
    db.commit()
    db.refresh(new_tip)
    return new_tip

@router.get("/pending", response_model=List[TipResponse])
def get_pending_tips(db: Session = Depends(get_db), current_admin: User = Depends(get_current_admin)):
    return db.query(QuickTip).filter(QuickTip.is_approved == False).order_by(QuickTip.created_at.desc()).all()

@router.post("/{tip_id}/approve", response_model=TipResponse)
def approve_tip(tip_id: int, db: Session = Depends(get_db), current_admin: User = Depends(get_current_admin)):
    tip = db.query(QuickTip).filter(QuickTip.id == tip_id).first()
    if not tip:
        raise HTTPException(status_code=404, detail="Tip not found")
    tip.is_approved = True
    db.commit()
    db.refresh(tip)
    return tip

@router.delete("/{tip_id}")
def delete_tip(tip_id: int, db: Session = Depends(get_db), current_admin: User = Depends(get_current_admin)):
    tip = db.query(QuickTip).filter(QuickTip.id == tip_id).first()
    if not tip:
        raise HTTPException(status_code=404, detail="Tip not found")
    db.delete(tip)
    db.commit()
    return {"success": True, "message": "Tip deleted successfully"}

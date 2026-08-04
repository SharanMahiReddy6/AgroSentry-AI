from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database.config import get_db
from database.models import Notification, User
from .auth import get_current_user, get_current_admin
from pydantic import BaseModel
from typing import List, Optional
from sqlalchemy import or_

# Firebase is optional — app starts fine without it, push notifications are skipped
try:
    import firebase_admin
    from firebase_admin import messaging
    FIREBASE_AVAILABLE = True
except ImportError:
    FIREBASE_AVAILABLE = False
    print("WARNING: firebase_admin not installed. Push notifications will be disabled.")

router = APIRouter(prefix="/notifications", tags=["Notifications"])

class NotificationCreate(BaseModel):
    title: str
    message: str
    user_id: Optional[int] = None  # Nullable for broadcast to all users

class NotificationResponse(BaseModel):
    id: int
    title: str
    message: str
    user_id: Optional[int]
    is_read: bool
    created_at: str

    class Config:
        from_attributes = True

@router.get("", response_model=List[NotificationResponse])
def get_my_notifications(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    # Retrieve user specific notifications or broadcast notifications (where user_id is null)
    notifications = db.query(Notification).filter(
        or_(Notification.user_id == current_user.id, Notification.user_id == None)
    ).order_by(Notification.created_at.desc()).all()
    
    # We serialize datetime to string for response consistency
    res = []
    for n in notifications:
        res.append(NotificationResponse(
            id=n.id,
            title=n.title,
            message=n.message,
            user_id=n.user_id,
            is_read=n.is_read,
            created_at=n.created_at.strftime("%Y-%m-%d %H:%M:%S")
        ))
    return res

@router.post("", response_model=NotificationResponse)
def create_notification(notif_in: NotificationCreate, db: Session = Depends(get_db), current_admin: User = Depends(get_current_admin)):
    new_notif = Notification(
        title=notif_in.title,
        message=notif_in.message,
        user_id=notif_in.user_id,
        is_read=False
    )
    db.add(new_notif)
    db.commit()
    db.refresh(new_notif)
    
    # Try sending FCM Push Notification
    try:
        if FIREBASE_AVAILABLE:
            users_query = db.query(User).filter(User.fcm_token.isnot(None))
            if notif_in.user_id:
                users_query = users_query.filter(User.id == notif_in.user_id)
                
            tokens = [u.fcm_token for u in users_query.all() if u.fcm_token]
            
            if tokens:
                if not firebase_admin._apps:
                    print(f"MOCK FCM SEND to {len(tokens)} devices: {notif_in.title}")
                else:
                    msg = messaging.MulticastMessage(
                        notification=messaging.Notification(
                            title=notif_in.title,
                            body=notif_in.message
                        ),
                        tokens=tokens
                    )
                    messaging.send_each_for_multicast(msg)
        else:
            print(f"FCM skipped (firebase_admin not installed): {notif_in.title}")
    except Exception as e:
        print(f"Failed to send FCM push: {e}")
    
    return NotificationResponse(
        id=new_notif.id,
        title=new_notif.title,
        message=new_notif.message,
        user_id=new_notif.user_id,
        is_read=new_notif.is_read,
        created_at=new_notif.created_at.strftime("%Y-%m-%d %H:%M:%S")
    )

@router.put("/{notif_id}/read")
def mark_as_read(notif_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    notif = db.query(Notification).filter(
        Notification.id == notif_id,
        or_(Notification.user_id == current_user.id, Notification.user_id == None)
    ).first()
    if not notif:
        raise HTTPException(status_code=404, detail="Notification not found")
    notif.is_read = True
    db.commit()
    return {"success": True, "message": "Notification marked as read"}

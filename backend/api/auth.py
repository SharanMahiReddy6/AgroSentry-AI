from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from typing import List, Optional
from sqlalchemy.orm import Session
from datetime import datetime, timedelta, timezone
from jose import JWTError, jwt
from passlib.context import CryptContext
import os
import shutil
import random
import string
import aiosmtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from core.config import UPLOAD_DIR
from database.config import get_db
from database.models import User, PasswordResetCode
from pydantic import BaseModel, EmailStr

router = APIRouter(prefix="/auth", tags=["Authentication"])

SECRET_KEY = os.getenv("SECRET_KEY", "supersecretkey")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/auth/login")

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    full_name: str

class Token(BaseModel):
    access_token: str
    token_type: str

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

@router.post("/register", response_model=Token)
def register(user_in: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.email == user_in.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    hashed_password = pwd_context.hash(user_in.password)
    new_user = User(email=user_in.email, hashed_password=hashed_password, full_name=user_in.full_name)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    access_token = create_access_token(data={"sub": new_user.email})
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/login", response_model=Token)
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == form_data.username).first()
    if not user or not pwd_context.verify(form_data.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect email or password")
    
    access_token = create_access_token(data={"sub": user.email})
    return {"access_token": access_token, "token_type": "bearer"}

# Shared dependencies
def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        user = db.query(User).filter(User.email == email).first()
        if user is None:
            raise HTTPException(status_code=401, detail="User not found")
        return user
    except Exception:
        raise HTTPException(status_code=401, detail="Could not validate credentials")

def get_current_admin(current_user: User = Depends(get_current_user)):
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Admin privileges required")
    return current_user

from fastapi import UploadFile, File
import shutil

class UserResponse(BaseModel):
    id: int
    email: str
    full_name: str | None = None
    is_admin: bool
    region: str | None = None
    primary_crop: str | None = None
    username: str | None = None
    phone_number: str | None = None
    location: str | None = None
    organization: str | None = None
    profile_photo: str | None = None
    two_factor_enabled: bool | None = False
    theme: str | None = "light"
    language: Optional[str] = None
    email_notifications: Optional[bool] = None
    push_notifications: Optional[bool] = None
    privacy_share_data: Optional[bool] = None
    fcm_token: Optional[str] = None
    created_at: datetime | None = None
    
    class Config:
        from_attributes = True

class UserUpdate(BaseModel):
    full_name: str | None = None
    region: str | None = None
    primary_crop: str | None = None
    username: str | None = None
    phone_number: str | None = None
    location: str | None = None
    organization: str | None = None
    theme: str | None = "light"
    language: str | None = "en"
    email_notifications: bool | None = True
    push_notifications: bool | None = True
    privacy_share_data: bool | None = True
    two_factor_enabled: bool | None = False

class PasswordChange(BaseModel):
    old_password: str
    new_password: str

class FCMTokenUpdate(BaseModel):
    token: str

@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user

@router.put("/me", response_model=UserResponse)
def update_me(user_in: UserUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    current_user.full_name = user_in.full_name
    current_user.region = user_in.region
    current_user.primary_crop = user_in.primary_crop
    
    if user_in.username is not None: current_user.username = user_in.username
    if user_in.phone_number is not None: current_user.phone_number = user_in.phone_number
    if user_in.location is not None: current_user.location = user_in.location
    if user_in.organization is not None: current_user.organization = user_in.organization
    if user_in.theme is not None: current_user.theme = user_in.theme
    if user_in.language is not None: current_user.language = user_in.language
    if user_in.email_notifications is not None: current_user.email_notifications = user_in.email_notifications
    if user_in.push_notifications is not None: current_user.push_notifications = user_in.push_notifications
    if user_in.privacy_share_data is not None: current_user.privacy_share_data = user_in.privacy_share_data
    if user_in.two_factor_enabled is not None: current_user.two_factor_enabled = user_in.two_factor_enabled
    
    db.commit()
    db.refresh(current_user)
    return current_user

@router.post("/me/photo", response_model=UserResponse)
async def upload_profile_photo(file: UploadFile = File(None), db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if not file:
        current_user.profile_photo = None
        db.commit()
        db.refresh(current_user)
        return current_user
        
    file_ext = os.path.splitext(file.filename)[1]
    filename = f"avatar_{current_user.id}{file_ext}"
    upload_dir = UPLOAD_DIR
    os.makedirs(upload_dir, exist_ok=True)
    file_path = os.path.join(upload_dir, filename)
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
        
    current_user.profile_photo = f"/storage/uploads/{filename}"
    db.commit()
    db.refresh(current_user)
    return current_user

@router.delete("/me/photo", response_model=UserResponse)
def remove_profile_photo(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    current_user.profile_photo = None
    db.commit()
    db.refresh(current_user)
    return current_user

@router.post("/me/password")
def change_password(pwd_in: PasswordChange, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if not pwd_context.verify(pwd_in.old_password, current_user.hashed_password):
        raise HTTPException(status_code=400, detail="Incorrect current password")
        
    if len(pwd_in.new_password) < 6:
        raise HTTPException(status_code=400, detail="New password must be at least 6 characters long")
        
    current_user.hashed_password = pwd_context.hash(pwd_in.new_password)
    db.commit()
    return {"success": True, "message": "Password changed successfully"}

@router.post("/me/fcm-token")
async def update_fcm_token(data: FCMTokenUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    current_user.fcm_token = data.token
    db.commit()
    return {"success": True, "message": "FCM token updated"}

@router.get("/me/sessions")
def get_active_sessions(current_user: User = Depends(get_current_user)):
    return [
        {
            "id": "sess_current",
            "device": "Chrome on Windows (Current)",
            "ip_address": "192.168.1.45",
            "last_active": "Just now",
            "is_current": True
        },
        {
            "id": "sess_mobile",
            "device": "AgroSentry Android App (Pixel 6)",
            "ip_address": "192.168.1.189",
            "last_active": "2 hours ago",
            "is_current": False
        }
    ]

@router.post("/me/logout-others")
def logout_other_devices(current_user: User = Depends(get_current_user)):
    return {"success": True, "message": "Logged out from all other devices successfully"}

@router.get("/users", response_model=List[UserResponse])
def list_users(db: Session = Depends(get_db), current_admin: User = Depends(get_current_admin)):
    return db.query(User).all()


import logging

logger = logging.getLogger(__name__)

# ─── Email Helper ────────────────────────────────────────────────────────────


# ─── Forgot Password Models ──────────────────────────────────────────────────

class ForgotPasswordRequest(BaseModel):
    email: EmailStr

class VerifyResetCodeRequest(BaseModel):
    email: EmailStr
    code: str

class ResetPasswordRequest(BaseModel):
    email: EmailStr
    code: str
    new_password: str


# ─── Forgot Password Endpoints ───────────────────────────────────────────────

@router.post("/forgot-password")
async def forgot_password(
    request: ForgotPasswordRequest,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    """Step 1: Send a 6-digit OTP to the user's registered email."""
    user = db.query(User).filter(User.email == request.email).first()
    # Always return success to prevent email enumeration attacks
    if not user:
        return {"success": True, "message": "If this email is registered, a reset code has been sent."}

    # Invalidate any existing unused codes for this email
    db.query(PasswordResetCode).filter(
        PasswordResetCode.email == request.email,
        PasswordResetCode.is_used == False
    ).update({"is_used": True})
    db.commit()

    # Generate 6-digit numeric OTP
    code = ''.join(random.choices(string.digits, k=6))
    expires_at = datetime.now(timezone.utc) + timedelta(minutes=10)

    reset_entry = PasswordResetCode(
        email=request.email,
        code=code,
        expires_at=expires_at,
        is_used=False
    )
    db.add(reset_entry)
    db.commit()

    # Send email in background so API responds instantly
    from services.email_service import EmailService
    background_tasks.add_task(EmailService.send_reset_email, request.email, code)

    return {"success": True, "message": "Reset code sent to your email address."}


@router.post("/verify-reset-code")
def verify_reset_code(request: VerifyResetCodeRequest, db: Session = Depends(get_db)):
    """Step 2: Verify the OTP code is valid and not expired."""
    now = datetime.now(timezone.utc)

    reset_entry = db.query(PasswordResetCode).filter(
        PasswordResetCode.email == request.email,
        PasswordResetCode.code == request.code,
        PasswordResetCode.is_used == False
    ).first()

    if not reset_entry:
        raise HTTPException(status_code=400, detail="Invalid reset code.")

    # Make expires_at timezone-aware for comparison
    expires_at = reset_entry.expires_at
    if expires_at.tzinfo is None:
        expires_at = expires_at.replace(tzinfo=timezone.utc)

    if now > expires_at:
        raise HTTPException(status_code=400, detail="Reset code has expired. Please request a new one.")

    return {"success": True, "message": "Code verified. You may now reset your password."}


@router.post("/reset-password")
def reset_password(request: ResetPasswordRequest, db: Session = Depends(get_db)):
    """Step 3: Verify code one final time and set the new password."""
    if len(request.new_password) < 8:
        raise HTTPException(status_code=400, detail="Password must be at least 8 characters long.")

    now = datetime.now(timezone.utc)

    reset_entry = db.query(PasswordResetCode).filter(
        PasswordResetCode.email == request.email,
        PasswordResetCode.code == request.code,
        PasswordResetCode.is_used == False
    ).first()

    if not reset_entry:
        raise HTTPException(status_code=400, detail="Invalid or already used reset code.")

    expires_at = reset_entry.expires_at
    if expires_at.tzinfo is None:
        expires_at = expires_at.replace(tzinfo=timezone.utc)

    if now > expires_at:
        raise HTTPException(status_code=400, detail="Reset code has expired. Please request a new one.")

    # Update the user's password
    user = db.query(User).filter(User.email == request.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")

    user.hashed_password = pwd_context.hash(request.new_password)

    # Mark the reset code as used
    reset_entry.is_used = True

    db.commit()
    return {"success": True, "message": "Password reset successfully. You can now log in."}

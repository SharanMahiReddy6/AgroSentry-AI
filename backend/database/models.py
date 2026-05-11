from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from .config import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    full_name = Column(String)
    is_active = Column(Boolean, default=True)
    is_admin = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    scans = relationship("ScanRecord", back_populates="owner")

class ScanRecord(Base):
    __tablename__ = "scans"

    id = Column(Integer, primary_key=True, index=True)
    image_url = Column(String, nullable=False)
    crop_type = Column(String)
    heatmap_url = Column(String)
    prediction = Column(String, nullable=False)
    confidence = Column(Integer)  # Percentage
    severity = Column(String)  # Low, Moderate, High
    infected_area_percent = Column(Integer, default=0)
    recommendation = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    user_id = Column(Integer, ForeignKey("users.id"))

    owner = relationship("User", back_populates="scans")

class TrainingJob(Base):
    __tablename__ = "training_jobs"

    id = Column(Integer, primary_key=True, index=True)
    status = Column(String, default="pending")  # pending, training, completed, failed
    dataset_name = Column(String)
    accuracy = Column(Integer)
    is_deployed = Column(Boolean, default=False)
    error_message = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    completed_at = Column(DateTime(timezone=True))

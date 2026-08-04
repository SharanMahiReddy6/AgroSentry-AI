from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os
from api import auth, scans, training, tips, notifications
from fastapi.staticfiles import StaticFiles
from database.init_db import init_db
from core.config import STORAGE_ROOT, ensure_storage_dirs

app = FastAPI(title="AgroAI API", version="1.0.0")

# Initialize database on startup
@app.on_event("startup")
async def startup_event():
    init_db()
    ensure_storage_dirs()
    print("Storage directories verified and ready.")

# Configure CORS for both Web and Mobile access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(auth.router, prefix="/api")
app.include_router(scans.router, prefix="/api")
app.include_router(training.router, prefix="/api")
app.include_router(tips.router, prefix="/api")
app.include_router(notifications.router, prefix="/api")


# Serve storage directory for images and heatmaps
STORAGE_DIR = STORAGE_ROOT
ensure_storage_dirs()

app.mount("/storage", StaticFiles(directory=STORAGE_DIR), name="storage")

@app.get("/")
async def root():
    return {"message": "Welcome to AgroAI API", "status": "running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

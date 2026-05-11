import os
from pathlib import Path

# === Storage Paths ===
STORAGE_ROOT = os.getenv("STORAGE_ROOT", "/app/storage")
UPLOAD_DIR = os.path.join(STORAGE_ROOT, "uploads")
HEATMAP_DIR = os.path.join(STORAGE_ROOT, "heatmaps")
MODEL_DIR = os.path.join(STORAGE_ROOT, "models")
DATASET_DIR = os.path.join(STORAGE_ROOT, "datasets")

# === Auth ===
SECRET_KEY = os.getenv("SECRET_KEY", "supersecretkey")
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30"))

# === ML ===
CONFIDENCE_THRESHOLD = 45          # Below this → irrelevant image warning
INFECTION_LOW_THRESHOLD = 15       # 0-15 % → Low severity
INFECTION_HIGH_THRESHOLD = 40      # >40 % → High severity

# === Supported Crops (for the mobile app's crop picker) ===
SUPPORTED_CROPS = [
    {
        "id": "Apple",
        "display_name": "Apple",
        "scientific_name": "Malus domestica",
        "icon": "🍎",
        "status": "trained",
        "diseases_count": 4
    },
    {
        "id": "Blueberry",
        "display_name": "Blueberry",
        "scientific_name": "Vaccinium corymbosum",
        "icon": "🫐",
        "status": "coming_soon",
        "diseases_count": 2
    },
    {
        "id": "Cherry",
        "display_name": "Cherry",
        "scientific_name": "Prunus avium",
        "icon": "🍒",
        "status": "coming_soon",
        "diseases_count": 2
    },
    {
        "id": "Corn",
        "display_name": "Corn (Maize)",
        "scientific_name": "Zea mays",
        "icon": "🌽",
        "status": "coming_soon",
        "diseases_count": 4
    },
    {
        "id": "Grape",
        "display_name": "Grape",
        "scientific_name": "Vitis vinifera",
        "icon": "🍇",
        "status": "coming_soon",
        "diseases_count": 4
    },
    {
        "id": "Peach",
        "display_name": "Peach",
        "scientific_name": "Prunus persica",
        "icon": "🍑",
        "status": "coming_soon",
        "diseases_count": 2
    },
    {
        "id": "Pepper",
        "display_name": "Pepper (Bell)",
        "scientific_name": "Capsicum annuum",
        "icon": "🫑",
        "status": "coming_soon",
        "diseases_count": 2
    },
    {
        "id": "Potato",
        "display_name": "Potato",
        "scientific_name": "Solanum tuberosum",
        "icon": "🥔",
        "status": "coming_soon",
        "diseases_count": 3
    },
    {
        "id": "Raspberry",
        "display_name": "Raspberry",
        "scientific_name": "Rubus idaeus",
        "icon": "🍓",
        "status": "coming_soon",
        "diseases_count": 1
    },
    {
        "id": "Soybean",
        "display_name": "Soybean",
        "scientific_name": "Glycine max",
        "icon": "🫘",
        "status": "coming_soon",
        "diseases_count": 1
    },
    {
        "id": "Squash",
        "display_name": "Squash",
        "scientific_name": "Cucurbita pepo",
        "icon": "🎃",
        "status": "coming_soon",
        "diseases_count": 1
    },
    {
        "id": "Strawberry",
        "display_name": "Strawberry",
        "scientific_name": "Fragaria × ananassa",
        "icon": "🍓",
        "status": "coming_soon",
        "diseases_count": 2
    },
    {
        "id": "Tomato",
        "display_name": "Tomato",
        "scientific_name": "Solanum lycopersicum",
        "icon": "🍅",
        "status": "coming_soon",
        "diseases_count": 10
    }
]


def get_latest_model_path() -> str:
    """Returns the path to the most recently created trained model file."""
    if not os.path.exists(MODEL_DIR):
        return None
    models = sorted(
        [f for f in os.listdir(MODEL_DIR) if f.endswith(".pth")],
        key=lambda f: os.path.getmtime(os.path.join(MODEL_DIR, f)),
        reverse=True
    )
    if models:
        return os.path.join(MODEL_DIR, models[0])
    return None


def ensure_storage_dirs():
    """Ensures all necessary storage directories exist."""
    for d in [UPLOAD_DIR, HEATMAP_DIR, MODEL_DIR, DATASET_DIR]:
        os.makedirs(d, exist_ok=True)

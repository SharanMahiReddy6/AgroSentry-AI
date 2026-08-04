from .config import engine, Base, SessionLocal
from .models import User, ScanRecord, TrainingJob, QuickTip, Notification
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def init_db():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    
    try:
        # 1. Keep scan records and user accounts (no longer dropping them on startup)
        print("Bypassed scans and user accounts reset on startup.")
        
        # 2. Setup Admin Account ONLY if it does not already exist
        admin_email = "mahiworkmail6@gmail.com"
        existing_admin = db.query(User).filter(User.email == admin_email).first()
        if not existing_admin:
            hashed_pwd = pwd_context.hash("Mahi@Admin6")
            admin_user = User(
                email=admin_email,
                hashed_password=hashed_pwd,
                full_name="Mahi",
                is_admin=True
            )
            db.add(admin_user)
            db.commit()
            print(f"Admin account created successfully with email {admin_email}.")
        else:
            print(f"Admin account {admin_email} already exists. Skipping recreation.")
            
        # 2.5 Seed/Register pre-existing Model checkpoints in the database
        from datetime import datetime
        pre_existing_jobs = [
            {"id": 5, "dataset_name": "apple", "status": "completed", "accuracy": 94, "is_deployed": True},
            {"id": 6, "dataset_name": "blueberry", "status": "completed", "accuracy": 98, "is_deployed": True},
            {"id": 7, "dataset_name": "cherry", "status": "completed", "accuracy": 96, "is_deployed": True}
        ]
        for job_data in pre_existing_jobs:
            existing_job = db.query(TrainingJob).filter(TrainingJob.id == job_data["id"]).first()
            if not existing_job:
                new_job = TrainingJob(
                    id=job_data["id"],
                    dataset_name=job_data["dataset_name"],
                    status=job_data["status"],
                    accuracy=job_data["accuracy"],
                    is_deployed=job_data["is_deployed"],
                    completed_at=datetime.utcnow()
                )
                db.add(new_job)
        db.commit()
        print("Pre-existing model training jobs successfully seeded in database.")
        
        # 3. Seed Default Quick Tips
        default_tips = [
            {
                "title": "Watering Schedule",
                "category": "General",
                "read_time": "2 min read",
                "content": "Water your tomato plants early in the morning to allow leaves to dry during the day, preventing fungal spores from germinating.",
                "detailed_content": "Watering overhead late in the evening leaves foliage wet overnight, creating a highly conducive environment for leaf spots and mildews to manifest. Drip irrigation or watering directly at the soil line is strongly recommended to protect foliage.",
                "author": "AgroSentry Agronomist",
                "is_approved": True
            },
            {
                "title": "Proper Spacing",
                "category": "General",
                "read_time": "3 min read",
                "content": "Ensure at least 24 inches between tomato plants to promote airflow, which significantly reduces the risk of Leaf Mold.",
                "detailed_content": "Stagnant humidity in tight canopies acts as an incubator for pathogens. Pruning lower leaves up to the first fruit cluster and keeping crops appropriately spaced allows breeze to carry away moisture, protecting your crops naturally.",
                "author": "AgroSentry Agronomist",
                "is_approved": True
            },
            {
                "title": "Early Detection",
                "category": "General",
                "read_time": "2 min read",
                "content": "Inspect the undersides of lower leaves weekly. Early blights usually start from the bottom of the plant.",
                "detailed_content": "Fungal spores often splash up from the soil onto lower limbs first. Routine scouting of lower vegetation helps isolate infestations before they climb. Cut off infected limbs immediately and disinfect shears with rubbing alcohol.",
                "author": "AgroSentry Agronomist",
                "is_approved": True
            },
            {
                "title": "Organic Spray",
                "category": "Potato",
                "read_time": "3 min read",
                "content": "A mixture of baking soda and neem oil acts as a powerful preventative organic fungicide for potato late blight.",
                "detailed_content": "Mix 1 tablespoon of baking soda, 1 teaspoon of liquid dish soap, and 1 tablespoon of neem oil in a gallon of water. Spray this fine mist on leaves every 7-10 days during cool, humid spells to shield leaves before spores attach.",
                "author": "AgroSentry Agronomist",
                "is_approved": True
            },
            {
                "title": "Crop Rotation",
                "category": "General",
                "read_time": "4 min read",
                "content": "Never plant Solanaceae crops (tomatoes, potatoes, peppers) in the same soil consecutively.",
                "detailed_content": "Fungal pathogens such as Alternaria solani (Early Blight) can overwinter in soil debris for years. Rotate nightshades with nitrogen-fixing cover crops or brassicas every 3 seasons to naturally starve out localized pathogens.",
                "author": "AgroSentry Agronomist",
                "is_approved": True
            },
            {
                "title": "Soil Enrichment",
                "category": "General",
                "read_time": "3 min read",
                "content": "Feed soil with aged compost and bone meal to strengthen plant immune cell walls.",
                "detailed_content": "Calcium deficiency makes cell walls fragile and highly susceptible to blossom end rot and pathogen entry. Boosting calcium and organic matter early in spring builds a physical defense system in the plant's leaves and stems.",
                "author": "AgroSentry Agronomist",
                "is_approved": True
            }
        ]
        
        tip_count = db.query(QuickTip).count()
        if tip_count == 0:
            for t in default_tips:
                new_tip = QuickTip(**t)
                db.add(new_tip)
            db.commit()
            print("Successfully seeded initial Quick Tips.")
            
    except Exception as e:
        db.rollback()
        print(f"Error seeding database: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    init_db()


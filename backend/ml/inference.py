import torch
import time
import torchvision.transforms as transforms
from PIL import Image
import os
import cv2
import numpy as np
import uuid
from .models import DiseaseClassifier
from .knowledge_base import get_disease_info

class InferenceEngine:
    def __init__(self):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model_dir = "/app/storage/models"
        self.production_model_path = os.path.join(self.model_dir, "production_model.pth")
        self.fallback_model_path = os.path.join(self.model_dir, "job_1.pth")
        self.transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
        ])
        self.classes = []
        self.model = None
        self.load_model()

    def load_model(self, path=None):
        try:
            os.makedirs(self.model_dir, exist_ok=True)
            target_path = path or self.production_model_path
            
            # Smart Fallback: If production model is missing, look for the latest job model
            if not os.path.exists(target_path):
                model_files = [f for f in os.listdir(self.model_dir) if f.startswith("job_") and f.endswith(".pth")]
                if model_files:
                    # Sort by job ID (e.g., job_5.pth > job_4.pth)
                    model_files.sort(key=lambda x: int(x.split("_")[1].split(".")[0]), reverse=True)
                    target_path = os.path.join(self.model_dir, model_files[0])
                    print(f"Production model missing. Falling back to latest trained: {target_path}")
                
            if os.path.exists(target_path):
                print(f"Loading model from: {target_path}")
                checkpoint = torch.load(target_path, map_location=self.device)
                self.classes = checkpoint['classes']
                self.model = DiseaseClassifier(num_classes=len(self.classes))
                self.model.load_state_dict(checkpoint['model_state_dict'])
                self.model.to(self.device)
                self.model.eval()
                print(f"Model loaded successfully with {len(self.classes)} classes")
                return True
            else:
                print("No model files found in storage/models. Please train a model first.")
                return False
        except Exception as e:
            print(f"Error loading model: {e}")
            return False

    def generate_heatmap(self, image_path, heatmap_tensor, output_path):
        try:
            img = cv2.imread(image_path)
            if img is None: return False
            img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
            h, w, _ = img.shape
            
            heatmap = heatmap_tensor.numpy()
            heatmap = cv2.resize(heatmap, (w, h))
            
            # 1. Spot Detection (Thresholding high-confidence infected areas)
            thresh = np.uint8(heatmap * 255)
            _, binary = cv2.threshold(thresh, 140, 255, cv2.THRESH_BINARY)
            
            # 2. Find Contours of the sick spots
            contours, _ = cv2.findContours(binary, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            
            # 3. Draw Precision Highlights (Glowing Circles)
            overlay = img.copy()
            for cnt in contours:
                if cv2.contourArea(cnt) < 50: continue # Filter noise
                (x, y), radius = cv2.minEnclosingCircle(cnt)
                center = (int(x), int(y))
                radius = int(radius)
                
                # Draw a yellow glow circle around the spot
                cv2.circle(overlay, center, radius + 10, (255, 255, 0), 5) 
                # Draw a solid red spot core
                cv2.circle(overlay, center, radius, (255, 0, 0), -1) 
                
            # Combine original and overlay with transparency
            alpha = 0.4
            final_img = cv2.addWeighted(overlay, alpha, img, 1 - alpha, 0)
            
            cv2.imwrite(output_path, cv2.cvtColor(final_img.astype(np.uint8), cv2.COLOR_RGB2BGR))
            return True
        except Exception as e:
            print(f"Spot highlighting error: {e}")
            return False

    def predict(self, image_path, target_crop=None):
        start_time = time.perf_counter()
        if self.model is None:
            if not self.load_model():
                return {"error": "Model not loaded. Please train a model first."}

        try:
            image = Image.open(image_path).convert('RGB')
            input_tensor = self.transform(image).unsqueeze(0).to(self.device)
            
            # Hooks for Grad-CAM
            features = []
            def hook_feature(module, input, output): features.append(output)
            gradients = []
            def hook_gradient(module, grad_input, grad_output): gradients.append(grad_output[0])

            target_layer = self.model.get_last_conv_layer()
            handle_f = target_layer.register_forward_hook(hook_feature)
            handle_g = target_layer.register_full_backward_hook(hook_gradient)
            
            outputs = self.model(input_tensor)
            _, predicted = torch.max(outputs, 1)
            confidence_vals = torch.nn.functional.softmax(outputs, dim=1)[0]
            class_idx = predicted.item()
            class_name = self.classes[class_idx]
            confidence_pct = int(confidence_vals[class_idx].item() * 100)

            self.model.zero_grad()
            outputs[0, class_idx].backward()
            
            pooled_gradients = torch.mean(gradients[0], dim=[0, 2, 3])
            for i in range(features[0].shape[1]):
                features[0][:, i, :, :] *= pooled_gradients[i]
            
            heatmap_tensor = torch.mean(features[0], dim=1).squeeze().detach().cpu()
            heatmap_tensor = torch.relu(heatmap_tensor)
            if heatmap_tensor.max() > 0:
                heatmap_tensor = (heatmap_tensor - heatmap_tensor.min()) / (heatmap_tensor.max() - heatmap_tensor.min() + 1e-8)
            
            handle_f.remove()
            handle_g.remove()
            
            heatmap_filename = f"highlight_{uuid.uuid4()}.png"
            heatmap_path = os.path.join("/app/storage/heatmaps", heatmap_filename)
            self.generate_heatmap(image_path, heatmap_tensor, heatmap_path)
            
            infected_pixels = (heatmap_tensor > 0.35).sum().item()
            infected_percentage = int((infected_pixels / heatmap_tensor.numel()) * 100)

            # Severity Mapping
            severity = "Low"
            if infected_percentage > 45: severity = "High"
            elif infected_percentage > 15: severity = "Moderate"

            info = get_disease_info(class_name, severity)
            
            return {
                "status": "success",
                "basic_details": {
                    "disease_name": info["common_name"],
                    "scientific_name": info["scientific_name"],
                    "crop_type": info["crop_type"],
                    "confidence": confidence_pct,
                    "severity": severity,
                    "infection_percentage": infected_percentage,
                    "summary": info["overview"]
                },
                "diagnostic_details": {
                    "symptoms": info["symptoms"],
                    "causes": info["causes"],
                    "prevention": info["prevention"]
                },
                "treatment_plan": {
                    "organic": info["organic_treatment"],
                    "chemical": info["chemical_treatment"]
                },
                "visuals": {
                    "heatmap_url": f"/storage/heatmaps/{heatmap_filename}"
                },
                "ai_metadata": {
                    "model": "AgroSentry-V2-Production",
                    "latency": f"{int((time.perf_counter() - start_time) * 1000)}ms"
                }
            }
        except Exception as e:
            print(f"Inference error: {e}")
            return {"error": str(e)}

inference_engine = InferenceEngine()


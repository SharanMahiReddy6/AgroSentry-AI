import torch
import time
import torchvision.transforms as transforms
from PIL import Image
import os
import cv2
import numpy as np
import uuid
from datetime import datetime
from .models import DiseaseClassifier
from .knowledge_base import get_disease_info, clean_crop_name
from core.config import MODEL_DIR, HEATMAP_DIR

def check_hsv_color_relevance(image_path):
    try:
        img = cv2.imread(image_path)
        if img is None:
            return False
        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        
        # Define plant color ranges in HSV (green, yellow, brown)
        # Green range
        lower_green = np.array([30, 20, 20])
        upper_green = np.array([85, 255, 255])
        
        # Yellow/Brown range
        lower_yellow_brown = np.array([10, 20, 20])
        upper_yellow_brown = np.array([30, 255, 255])
        
        mask_green = cv2.inRange(hsv, lower_green, upper_green)
        mask_yellow_brown = cv2.inRange(hsv, lower_yellow_brown, upper_yellow_brown)
        
        total_pixels = img.shape[0] * img.shape[1]
        plant_pixels = cv2.countNonZero(mask_green) + cv2.countNonZero(mask_yellow_brown)
        
        percentage = (plant_pixels / total_pixels) * 100
        print(f"DEBUG: HSV plant pixel percentage = {percentage:.2f}%")
        
        # Lowered to 3% — real-world field photos may have mixed backgrounds, dried
        # leaves, or dark lighting that reduces apparent green pixel count
        return percentage >= 3.0
    except Exception as e:
        print(f"ERROR: HSV Relevance Check failed: {e}")
        return True # Fallback to True

def is_plant_or_leaf(image_path):
    """
    Relevance guard: ONLY rejects when the image is POSITIVELY identified as a
    clearly non-plant object (human, animal, vehicle, household item, etc).
    
    Key design principle: This guard should NOT require the image to positively 
    look like a plant. A leaf on a grey/dark/outdoor background may score low on
    plant keywords — that does NOT mean it's not a leaf. We only block images that 
    the model is SURE are something else entirely.
    
    If uncertain → PASS (the ResNet disease classifier will decide).
    """
    try:
        import torchvision.models as _tv_models
        import re
        weights = _tv_models.MobileNet_V3_Small_Weights.DEFAULT
        mobilenet = _tv_models.mobilenet_v3_small(weights=weights)
        mobilenet.eval()
        
        img = Image.open(image_path).convert('RGB')
        _transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
        ])
        tensor = _transform(img).unsqueeze(0)
        
        with torch.no_grad():
            outputs = mobilenet(tensor)
            softmax_out = torch.nn.functional.softmax(outputs, dim=1)[0]
            top5_vals, top5_indices = torch.topk(softmax_out, 5)
            top5_classes = [weights.meta["categories"][idx.item()].lower() for idx in top5_indices]
            top5_probs = [v.item() for v in top5_vals]
        
        top1_class = top5_classes[0]
        top1_prob = top5_probs[0]
        print(f"DEBUG: Relevance Guard top-5: {list(zip(top5_classes, [f'{p:.2f}' for p in top5_probs]))}")
        
        # These are DEFINITIVE non-plant categories.
        # We only reject if the model is CONFIDENT (>55%) about one of these.
        # A leaf on a grey background might score lower on plant keywords — that's fine.
        definitive_non_plant = [
            'person', 'suit', 'face', 'groom', 'bride', 'dress', 'jean',
            'jersey', 'shirt', 'jacket', 'kimono', 'pajama',
            'man', 'woman', 'child', 'boy', 'girl', 'baby',
            'dog', 'cat', 'horse', 'cow', 'sheep', 'pig', 'lion', 'tiger', 'bear',
            'car', 'truck', 'bus', 'bicycle', 'motorcycle', 'airplane', 'boat', 'train',
            'laptop', 'computer', 'keyboard', 'mouse', 'phone', 'television', 'monitor',
            'chair', 'desk', 'table', 'sofa', 'bed', 'cabinet',
            'bottle', 'cup', 'glass', 'plate', 'bowl',
            'watch', 'clock', 'bag', 'backpack', 'shoe', 'boot', 'hat',
            'ballplayer', 'athlete', 'player', 'stadium',
            'snake', 'lizard', 'frog', 'turtle',
        ]
        
        # Insects that contain plant words (e.g. 'leaf beetle') — special compound check
        definitive_insects = ['beetle', 'cockroach', 'dragonfly', 'grasshopper', 'ladybug',
                               'cricket', 'caterpillar', 'centipede', 'scorpion', 'spider']
        
        top1_words = set(re.findall(r'\b\w+\b', top1_class))
        
        # ONLY reject if top-1 is confidently a non-plant (>55% probability)
        if top1_prob > 0.55:
            if any(kw in top1_words for kw in definitive_non_plant):
                print(f"DEBUG: REJECTED — top-1='{top1_class}' ({top1_prob:.0%}) is a non-plant object")
                return False
            if any(kw in top1_words for kw in definitive_insects):
                print(f"DEBUG: REJECTED — top-1='{top1_class}' ({top1_prob:.0%}) is an insect")
                return False
        
        # Also reject if ALL top-5 predictions are non-plant objects with zero plant votes
        # (catches cases where even the background object is split across many non-plant classes)
        non_plant_count = 0
        for cls in top5_classes:
            cls_words = set(re.findall(r'\b\w+\b', cls))
            if any(kw in cls_words for kw in definitive_non_plant + definitive_insects):
                non_plant_count += 1
        
        if non_plant_count >= 4:
            # 4 or 5 of the top-5 predictions are non-plant → strongly reject
            print(f"DEBUG: REJECTED — {non_plant_count}/5 top predictions are non-plant objects")
            return False
        
        # In all other cases: PASS.
        # The leaf may be on a grey/dark/outdoor background and MobileNet might not
        # recognize it as a plant — but that's fine. The disease classifier handles this.
        print(f"DEBUG: Relevance Guard PASSED — image allowed through to disease classifier")
        return True
        
    except Exception as e:
        print(f"WARNING: Relevance Guard error: {e}. Allowing image through.")
        return True  # On any error, allow — don't block valid uploads



class InferenceEngine:
    def __init__(self):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model_dir = MODEL_DIR
        self.production_model_path = os.path.join(self.model_dir, "production_model.pth")
        self.transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
        ])
        self.classes = []
        self.model = None
        self.loaded_model_path = None
        
        # Attempt to load a default model at startup
        self.load_model()

    def analyze_leaf_health_hsv(self, image_path):
        try:
            img = cv2.imread(image_path)
            if img is None: return {"healthy": True, "infected_ratio": 0}
            hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
            
            lower_green = np.array([30, 20, 20])
            upper_green = np.array([90, 255, 255])
            
            lower_yellow_brown = np.array([10, 20, 20])
            upper_yellow_brown = np.array([30, 255, 255])
            
            mask_green = cv2.inRange(hsv, lower_green, upper_green)
            mask_yellow_brown = cv2.inRange(hsv, lower_yellow_brown, upper_yellow_brown)
            
            green_pixels = cv2.countNonZero(mask_green)
            yellow_brown_pixels = cv2.countNonZero(mask_yellow_brown)
            plant_pixels = green_pixels + yellow_brown_pixels
            
            if plant_pixels == 0:
                return {"healthy": True, "infected_ratio": 0}
                
            infected_ratio = yellow_brown_pixels / plant_pixels
            return {
                "healthy": infected_ratio < 0.08, # less than 8% yellow/brown is considered healthy
                "infected_ratio": infected_ratio
            }
        except Exception as e:
            print(f"HSV Health Analysis Error: {e}")
            return {"healthy": True, "infected_ratio": 0}

    def load_model(self, path=None):
        try:
            os.makedirs(self.model_dir, exist_ok=True)
            target_path = path or self.production_model_path
            
            # Check if this model is already loaded in memory to prevent slow re-reads
            if self.model is not None and self.loaded_model_path == target_path:
                return True
                
            # Smart Fallback if the requested target is missing: load latest trained job model
            if not os.path.exists(target_path):
                model_files = [f for f in os.listdir(self.model_dir) if f.startswith("job_") and f.endswith(".pth")]
                if model_files:
                    model_files.sort(key=lambda x: int(x.split("_")[1].split(".")[0]), reverse=True)
                    target_path = os.path.join(self.model_dir, model_files[0])
                
            if os.path.exists(target_path):
                print(f"Inference Engine: Loading model from {target_path}")
                checkpoint = torch.load(target_path, map_location=self.device)
                self.classes = checkpoint['classes']
                
                # Instantiate resnet architecture
                self.model = DiseaseClassifier(num_classes=len(self.classes))
                self.model.load_state_dict(checkpoint['model_state_dict'])
                self.model.to(self.device)
                self.model.eval()
                
                self.loaded_model_path = target_path
                print(f"Inference Engine: Model loaded successfully with classes: {self.classes}")
                return True
            else:
                print("Inference Engine: No model files found in storage/models.")
                return False
        except Exception as e:
            print(f"Inference Engine Load Error: {e}")
            return False

    def generate_gradcam_overlay(self, image_path, heatmap_tensor, output_path):
        """Smooth Grad-CAM: renders a jet-colormap attention heatmap blended over the original."""
        try:
            img = cv2.imread(image_path)
            if img is None: return False
            h, w = img.shape[:2]

            heatmap = heatmap_tensor.numpy()
            heatmap = cv2.resize(heatmap, (w, h))
            heatmap_uint8 = np.uint8(255 * heatmap)

            # Apply jet colormap for smooth heat gradient
            colormap = cv2.applyColorMap(heatmap_uint8, cv2.COLORMAP_JET)

            # Blend: colormap over original image
            blended = cv2.addWeighted(img, 0.55, colormap, 0.45, 0)
            cv2.imwrite(output_path, blended)
            return True
        except Exception as e:
            print(f"Grad-CAM Overlay Error: {e}")
            return False

    def generate_lesion_spotlight(self, image_path, heatmap_tensor, output_path):
        """Lesion Spotlight: draws precise CV2 contour circles on the most activated regions."""
        try:
            img = cv2.imread(image_path)
            if img is None: return False
            h, w = img.shape[:2]

            heatmap = heatmap_tensor.numpy()
            heatmap = cv2.resize(heatmap, (w, h))
            thresh = np.uint8(heatmap * 255)

            # Adaptive threshold to find hot regions
            _, binary = cv2.threshold(thresh, 130, 255, cv2.THRESH_BINARY)

            # Morphological clean-up to merge nearby blobs
            kernel = np.ones((7, 7), np.uint8)
            binary = cv2.morphologyEx(binary, cv2.MORPH_CLOSE, kernel)

            contours, _ = cv2.findContours(binary, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

            overlay = img.copy()
            for cnt in contours:
                area = cv2.contourArea(cnt)
                if area < 80: continue
                # Draw exact polygon contour boundary
                cv2.drawContours(overlay, [cnt], -1, (0, 255, 255), 3)
                # Add enclosing circle highlight
                (cx, cy), radius = cv2.minEnclosingCircle(cnt)
                cv2.circle(overlay, (int(cx), int(cy)), int(radius) + 6, (255, 80, 0), 2)

            # Dim the non-spot areas using semi-transparent dark mask
            mask = np.zeros((h, w), dtype=np.uint8)
            for cnt in contours:
                if cv2.contourArea(cnt) >= 80:
                    cv2.drawContours(mask, [cnt], -1, 255, -1)

            dim_layer = img.copy()
            dim_layer[mask == 0] = (dim_layer[mask == 0] * 0.45).astype(np.uint8)
            final = cv2.addWeighted(overlay, 0.6, dim_layer, 0.4, 0)

            cv2.imwrite(output_path, final)
            return True
        except Exception as e:
            print(f"Lesion Spotlight Error: {e}")
            return False

    def predict(self, image_path, target_crop=None, model_path=None):
        start_time = time.perf_counter()
        
        # 1. Relevance Guard — Reject clearly non-plant images (humans, objects, animals)
        if not is_plant_or_leaf(image_path):
            return {
                "success": False,
                "error_type": "RELEVANCE_ERROR",
                "message": "Please upload a valid leaf image. The uploaded photo does not appear to be a plant or leaf."
            }

        # Load correct specialized model for multi-model architecture
        if model_path:
            self.load_model(model_path)
        elif self.model is None:
            if not self.load_model():
                return {
                    "success": False,
                    "error_type": "MODEL_MISSING",
                    "message": "No machine learning model has been trained and deployed for this analysis yet."
                }

        try:
            image = Image.open(image_path).convert('RGB')
            # --- Test-Time Augmentation (TTA) for angle robustness ---
            # Run inference on original + horizontally flipped image,
            # then average the softmax outputs. This makes the model
            # robust to leaves photographed from different angles.
            import torchvision.transforms.functional as TF
            input_tensor = self.transform(image).unsqueeze(0).to(self.device)
            flipped_tensor = self.transform(TF.hflip(image)).unsqueeze(0).to(self.device)
            
            # Hooks for Grad-CAM activation heatmap
            features = []
            def hook_feature(module, input, output): features.append(output)
            gradients = []
            def hook_gradient(module, grad_input, grad_output): gradients.append(grad_output[0])

            target_layer = self.model.get_last_conv_layer()
            handle_f = target_layer.register_forward_hook(hook_feature)
            handle_g = target_layer.register_full_backward_hook(hook_gradient)
            
            # Average outputs from original and horizontally flipped image (TTA)
            outputs_orig = self.model(input_tensor)
            outputs_flip = self.model(flipped_tensor)
            # Average in probability space
            prob_orig = torch.nn.functional.softmax(outputs_orig, dim=1)[0]
            prob_flip = torch.nn.functional.softmax(outputs_flip, dim=1)[0]
            confidence_vals = (prob_orig + prob_flip) / 2.0
            
            class_idx = confidence_vals.argmax().item()
            class_name = self.classes[class_idx]
            # Use averaged outputs for backward pass
            outputs = (outputs_orig + outputs_flip) / 2.0
            _, predicted = torch.max(outputs, 1)
            top_confidence = confidence_vals[class_idx].item()
            confidence_pct = int(top_confidence * 100)

            # === OOD Detection: Entropy + Top-2 Gap Analysis ===
            # Genuine trained images have HIGH top-1 confidence AND a BIG gap vs top-2.
            # Untrained/ambiguous images scatter probability mass even if top-1 looks ok.
            import torch as _torch
            
            # 1) Shannon entropy of softmax distribution (higher = more confused = OOD)
            entropy = -(_torch.sum(confidence_vals * _torch.log(confidence_vals + 1e-10))).item()
            max_entropy = _torch.log(_torch.tensor(float(len(self.classes)))).item()
            normalized_entropy = entropy / max_entropy  # 0 = certain, 1 = totally uniform
            
            # 2) Top-2 gap: difference between top-1 and top-2 probabilities
            sorted_vals, _ = _torch.sort(confidence_vals, descending=True)
            top2_gap = (sorted_vals[0] - sorted_vals[1]).item()
            
            print(f"DEBUG OOD: class={class_name}, conf={confidence_pct}%, entropy={normalized_entropy:.3f}, top2_gap={top2_gap:.3f}")

            # Reject ONLY if the model is genuinely and extremely confused.
            # These thresholds are intentionally relaxed so that valid field photos
            # taken at angles, with backgrounds, or in imperfect lighting still pass.
            #   - entropy > 0.75: probability spread across nearly ALL classes (total confusion)
            #   - top2_gap < 0.06: top-2 choices are statistically identical (coin-flip)
            #   - confidence < 35%: absolute floor — model has no idea what it sees
            if confidence_pct < 35 or normalized_entropy > 0.75 or top2_gap < 0.06:
                print(f"DEBUG OOD: REJECTED (conf={confidence_pct}%, entropy={normalized_entropy:.3f}, gap={top2_gap:.3f})")
                return {
                    "success": False,
                    "error_type": "RELEVANCE_ERROR",
                    "message": "Could not confidently identify a supported crop leaf in this image. Please upload a clear photo of a supported crop leaf (Apple, Tomato, Potato, Grape, Corn, etc.)."
                }
                
            # === Smart Fallback: HSV Health Correction for Missing Dataset Classes ===
            hsv_health = self.analyze_leaf_health_hsv(image_path)
            predicted_crop = class_name.split("___")[0]
            is_predicted_healthy = "healthy" in class_name.lower()
            
            if is_predicted_healthy and not hsv_health["healthy"]:
                print(f"Smart Correction: Model predicted {class_name} but HSV found {hsv_health['infected_ratio']:.1%} infection.")
                class_name = f"{predicted_crop}___Unknown_Infection"
                
            elif not is_predicted_healthy and hsv_health["infected_ratio"] < 0.02:
                crop_classes = [c for c in self.classes if c.startswith(predicted_crop)]
                has_healthy_class = any("healthy" in c.lower() for c in crop_classes)
                if not has_healthy_class:
                    print(f"Smart Correction: Model predicted {class_name} but leaf is very green. Overriding to Healthy.")
                    class_name = f"{predicted_crop}___healthy"

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
            
            os.makedirs(HEATMAP_DIR, exist_ok=True)

            # Generate Grad-CAM smooth colormap overlay
            gradcam_filename = f"gradcam_{uuid.uuid4()}.png"
            gradcam_path = os.path.join(HEATMAP_DIR, gradcam_filename)
            self.generate_gradcam_overlay(image_path, heatmap_tensor, gradcam_path)

            # Generate CV2 Lesion Spotlight with contours
            spotlight_filename = f"spotlight_{uuid.uuid4()}.png"
            spotlight_path = os.path.join(HEATMAP_DIR, spotlight_filename)
            self.generate_lesion_spotlight(image_path, heatmap_tensor, spotlight_path)

            # Keep backward-compatible heatmap_filename pointing to gradcam
            heatmap_filename = gradcam_filename
            
            infected_pixels = (heatmap_tensor > 0.35).sum().item()
            infected_percentage = int((infected_pixels / heatmap_tensor.numel()) * 100)
            if infected_percentage == 0 and "healthy" not in class_name.lower():
                # Make sure there is always a visual area shown if it's infected
                infected_percentage = max(12, int(confidence_pct * 0.4))

            # Determine Severity
            severity = "Low"
            # Adjusted thresholds because Grad-CAM focal points might not cover the entire lesion area
            if infected_percentage >= 25: severity = "High"
            elif infected_percentage >= 8: severity = "Moderate"
            
            # Clean crop verification mapping
            predicted_crop = class_name.split("___")[0]
            if target_crop and clean_crop_name(predicted_crop) != clean_crop_name(target_crop):
                # Before saying "this looks like Peach/Apple", verify the confidence is
                # genuinely high enough to make that named claim. A spuriously-confident
                # prediction on an untrained leaf should just say it's unrecognized.
                if confidence_pct >= 90 and normalized_entropy < 0.25:
                    # Model is very sure — this IS a different crop
                    return {
                        "success": False,
                        "error_type": "CROP_MISMATCH",
                        "message": f"The uploaded leaf appears to belong to a {clean_crop_name(predicted_crop).title()} plant, not {target_crop.title()}. Please upload the correct crop leaf."
                    }
                else:
                    # Model is uncertain — give a helpful message without demanding plain background
                    return {
                        "success": False,
                        "error_type": "RELEVANCE_ERROR",
                        "message": f"The AI could not identify this as a {target_crop.title()} leaf. Please make sure the leaf is clearly visible and well-lit in the photo."
                    }

            # Retrieve details from knowledge base
            info = get_disease_info(class_name, severity)
            
            # Map symptoms image list
            symptoms_mapped = []
            for sym in info["symptoms"]:
                snake_title = sym["title"].lower().replace(" ", "_")
                symptoms_mapped.append({
                    "title": sym["title"],
                    "description": sym["description"],
                    "imageUrl": f"/storage/symptoms/{snake_title}.png"
                })

            # Setup severity messages matching sample
            severity_message = "Moderate infection detected. Immediate treatment recommended preventing spread."
            if severity == "High":
                severity_message = "Severe infection detected. Immediate aggressive treatment is required to prevent total crop loss."
            elif severity == "Low":
                severity_message = "Mild infection detected. Monitor the plant closely and remove any spotted leaves to prevent spread."

            # Construct the complete diagnostic details block matching the frontend requirements
            results = {
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
                    "symptoms": symptoms_mapped,
                    "causes": info["causes"],
                    "prevention": info["prevention"]
                },
                "treatment_plan": {
                    "organic": info["organic_treatment"],
                    "chemical": info["chemical_treatment"]
                },
                "visuals": {
                    "heatmap_url": f"/storage/heatmaps/{gradcam_filename}",
                    "gradcam_url": f"/storage/heatmaps/{gradcam_filename}",
                    "spotlight_url": f"/storage/heatmaps/{spotlight_filename}"
                },
                "ai_metadata": {
                    "model": "AgroSentry-V2-Production",
                    "latency": f"{int((time.perf_counter() - start_time) * 1000)}ms"
                }
            }

            # Build the exact JSON format requested by the user
            response_payload = {
                "success": True,
                "message": "Disease detected successfully" if "healthy" not in class_name.lower() else "Healthy leaf detected successfully",
                "data": {
                    "diagnosisId": f"DG{uuid.uuid4().hex[:5].upper()}",
                    "plant": {
                        "name": f"{info['crop_type']} Plant",
                        "captureDate": datetime.now().strftime("%Y-%m-%d")
                    },
                    "disease": {
                        "name": info["common_name"],
                        "scientificName": info["scientific_name"],
                        "description": info["overview"]
                    },
                    "analysis": {
                        "confidence": confidence_pct,
                        "infectionArea": infected_percentage,
                        "severity": "Medium" if severity == "Moderate" else severity,
                        "severityMessage": severity_message
                    },
                    "causes": info["causes"],
                    "symptoms": symptoms_mapped,
                    "highlight": {
                        "overlayImageUrl": f"/storage/heatmaps/{gradcam_filename}",
                        "gradcamUrl": f"/storage/heatmaps/{gradcam_filename}",
                        "spotlightUrl": f"/storage/heatmaps/{spotlight_filename}",
                        "opacity": 60
                    },
                    "treatment": {
                        "organic": info["organic_treatment"],
                        "chemical": info["chemical_treatment"],
                        "preventive": info["prevention"]
                    }
                },
                # Keep backward compatibility with frontend:
                "results": results
            }

            return response_payload

        except Exception as e:
            print(f"ERROR: Inference error: {e}")
            return {
                "success": False,
                "error_type": "INFERENCE_ERROR",
                "message": str(e)
            }

inference_engine = InferenceEngine()

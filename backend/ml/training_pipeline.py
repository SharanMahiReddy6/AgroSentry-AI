import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader
from torchvision import datasets, transforms
import os
from .models import DiseaseClassifier

def train_model(dataset_path, model_save_path, num_epochs=3, batch_size=64, lr=0.001):
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    
    # 1. Dynamic class detection and folder mapping
    train_dir = os.path.join(dataset_path, 'train')
    val_dir = os.path.join(dataset_path, 'valid')
    
    if not os.path.exists(train_dir):
        subdirs = [d for d in os.listdir(dataset_path) if os.path.isdir(os.path.join(dataset_path, d))]
        for sd in subdirs:
            potential_train = os.path.join(dataset_path, sd, 'train')
            if os.path.exists(potential_train):
                dataset_path = os.path.join(dataset_path, sd)
                train_dir = potential_train
                val_dir = os.path.join(dataset_path, 'valid')
                break
                
    if not os.path.exists(train_dir):
        raise Exception(f"Train directory not found in {dataset_path}. Ensure folder structure is train/ and valid/")
        
    classes = sorted([d for d in os.listdir(train_dir) if os.path.isdir(os.path.join(train_dir, d))])
    num_classes = len(classes)
    print(f"Detected {num_classes} classes: {classes}")

    # 2. Data transforms
    train_transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.RandomHorizontalFlip(),
        transforms.RandomRotation(10),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])
    
    val_transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])

    # 3. Load datasets
    train_dataset = datasets.ImageFolder(train_dir, transform=train_transform)
    train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
    
    val_loader = None
    if os.path.exists(val_dir):
        val_dataset = datasets.ImageFolder(val_dir, transform=val_transform)
        val_loader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False)
        print(f"Validation dataset loaded: {len(val_dataset)} images")

    # 4. Initialize model
    model = DiseaseClassifier(num_classes=num_classes)
    model.to(device)
    
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=lr)

    # 5. Training loop with Early Stopping
    best_val_acc = 0.0
    patience = 2
    no_improve_epochs = 0
    
    for epoch in range(num_epochs):
        # Training Phase
        model.train()
        train_correct = 0
        train_total = 0
        
        for inputs, labels in train_loader:
            inputs, labels = inputs.to(device), labels.to(device)
            optimizer.zero_grad()
            outputs = model(inputs)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            
            _, predicted = outputs.max(1)
            train_total += labels.size(0)
            train_correct += predicted.eq(labels).sum().item()
            
        train_acc = 100. * train_correct / train_total
        
        # Validation Phase
        val_acc = 0.0
        if val_loader:
            model.eval()
            val_correct = 0
            val_total = 0
            with torch.no_grad():
                for inputs, labels in val_loader:
                    inputs, labels = inputs.to(device), labels.to(device)
                    outputs = model(inputs)
                    _, predicted = outputs.max(1)
                    val_total += labels.size(0)
                    val_correct += predicted.eq(labels).sum().item()
            val_acc = 100. * val_correct / val_total
            
        print(f'Epoch {epoch+1}/{num_epochs} | Train Acc: {train_acc:.2f}% | Val Acc: {val_acc:.2f}%')
        
        # Early Stopping and Saving
        target_acc = val_acc if val_loader else train_acc
        
        # 1. Save if it's the best so far
        if target_acc > best_val_acc:
            best_val_acc = target_acc
            no_improve_epochs = 0
            os.makedirs(os.path.dirname(model_save_path), exist_ok=True)
            torch.save({
                'model_state_dict': model.state_dict(),
                'classes': classes,
                'accuracy': target_acc
            }, model_save_path)
        else:
            no_improve_epochs += 1
            
        # 2. Stop if we hit our 99% goal
        if target_acc >= 99.0:
            print(f"Goal accuracy (99%+) reached at epoch {epoch+1}. Stopping training early!")
            break
            
        # 3. Stop if it's not improving (Patience)
        if no_improve_epochs >= patience:
            print(f"Early stopping triggered. Model reached peak accuracy at epoch {epoch+1 - patience}.")
            break

    return classes, best_val_acc

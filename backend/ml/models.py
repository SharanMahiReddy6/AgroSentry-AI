import torch.nn as nn
from torchvision import models

class DiseaseClassifier(nn.Module):
    def __init__(self, num_classes=10):
        super(DiseaseClassifier, self).__init__()
        # Use newer weights parameter
        self.model = models.resnet18(weights=models.ResNet18_Weights.DEFAULT)
        num_ftrs = self.model.fc.in_features
        self.model.fc = nn.Linear(num_ftrs, num_classes)

    def forward(self, x):
        return self.model(x)

    def get_last_conv_layer(self):
        return self.model.layer4

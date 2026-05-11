FROM python:3.11

WORKDIR /app

# Install system dependencies for PostgreSQL and OpenCV
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and set a very high timeout for the large Torch download
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir --default-timeout=1000 torch==2.1.1 torchvision==0.16.1 --index-url https://download.pytorch.org/whl/cpu

# Install remaining requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Create storage directory for datasets and models
RUN mkdir -p /app/storage/datasets /app/storage/models /app/storage/uploads /app/storage/heatmaps

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

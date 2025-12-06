FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONPATH=/app/backend:$PYTHONPATH \
    TESSDATA_PREFIX=/usr/share/tesseract-ocr/4.00/tessdata

WORKDIR /app

# Copy only requirements to use Docker cache
COPY backend/requirements.txt ./requirements.txt

# Install system dependencies
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        build-essential \
        libpq-dev \
        poppler-utils \
        tesseract-ocr \
        ghostscript \
        ffmpeg \
        curl \
        ca-certificates && \
    mkdir -p /usr/share/tesseract-ocr/4.00/tessdata && \
    # Download Hindi, Gujarati, English traineddata
    curl -L https://raw.githubusercontent.com/tesseract-ocr/tessdata/main/eng.traineddata \
        -o /usr/share/tesseract-ocr/4.00/tessdata/eng.traineddata && \
    curl -L https://raw.githubusercontent.com/tesseract-ocr/tessdata/main/hin.traineddata \
        -o /usr/share/tesseract-ocr/4.00/tessdata/hin.traineddata && \
    curl -L https://raw.githubusercontent.com/tesseract-ocr/tessdata/main/guj.traineddata \
        -o /usr/share/tesseract-ocr/4.00/tessdata/guj.traineddata && \
    pip install --upgrade pip && \
    pip install -r requirements.txt && \
    # Extra packages to guarantee no missing modules
    pip install pydantic-settings pytesseract ocrmypdf pydub edge-tts --upgrade && \
    apt-get purge -y build-essential && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Copy backend code
COPY backend ./backend

EXPOSE 8000

CMD ["uvicorn", "app.main:create_app", "--factory", "--host", "0.0.0.0", "--port", "8000"]

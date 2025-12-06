FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONPATH=/app/backend:$PYTHONPATH \
    TESSDATA_PREFIX=/usr/share/tesseract-ocr/4.00/tessdata

WORKDIR /app

# Copy only requirements first to leverage Docker layer cache
COPY backend/requirements.txt ./requirements.txt

# Install system dependencies: Tesseract, Ghostscript, ffmpeg, etc.
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        build-essential \
        libpq-dev \
        poppler-utils \
        tesseract-ocr \
        tesseract-ocr-eng \
        tesseract-ocr-hin \
        ghostscript \
        ffmpeg \
        wget \
        ca-certificates \
    # Gujarati traineddata manually add karo
    && mkdir -p /usr/share/tesseract-ocr/4.00/tessdata && \
    wget -O /usr/share/tesseract-ocr/4.00/tessdata/guj.traineddata \
        https://github.com/tesseract-ocr/tessdata/raw/main/guj.traineddata \
    # Python deps
    && pip install --upgrade pip \
    && pip install -r requirements.txt \
    && pip install pytesseract ocrmypdf pydub edge-tts --upgrade \
    # Clean up to keep image small
    && apt-get purge -y build-essential wget \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Copy the backend code
COPY backend ./backend

EXPOSE 8000

CMD ["uvicorn", "app.main:create_app", "--factory", "--host", "0.0.0.0", "--port", "8000"]

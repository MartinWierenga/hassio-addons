FROM python:3.10-slim
RUN apt-get update && apt-get install -y git curl && \
    pip install --no-cache-dir huggingface_hub torch torchvision torchaudio aiohttp psutil gradio fastchat sentencepiece && \
    rm -rf /var/lib/apt/lists/*
COPY run.sh /run.sh
RUN chmod +x /run.sh
CMD ["/run.sh"]

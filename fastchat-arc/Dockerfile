FROM python:3.10-slim

RUN apt-get update && apt-get install -y --no-install-recommends git curl && \
    pip install --no-cache-dir huggingface_hub transformers sentencepiece fastchat uvicorn gradio && \
    rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]

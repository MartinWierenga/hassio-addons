FROM python:3.10-slim

# Install system and Python dependencies
RUN apt-get update && apt-get install -y git curl && \
    pip install --no-cache-dir huggingface_hub transformers sentencepiece fastchat uvicorn gradio && \
    rm -rf /var/lib/apt/lists/*

# Download the model at build time
RUN python3 -c "\
from huggingface_hub import snapshot_download;\
snapshot_download(repo_id='mistralai/Mistral-7B-Instruct-v0.2', local_dir='/models/mistral-7b-instruct', local_dir_use_symlinks=False)"

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]

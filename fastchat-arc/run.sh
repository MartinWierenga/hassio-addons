#!/usr/bin/env bash
set -e

MODEL_PATH=${MODEL_PATH:-/share/models/mistral-7b-instruct}
MAX_GPU_MEMORY=${MAX_GPU_MEMORY:-8Gib}
LOG_PATH=${LOG_PATH:-/share/fastchat/logs}
LOG_LEVEL=${LOG_LEVEL:-debug}

mkdir -p "$MODEL_PATH"
mkdir -p "$LOG_PATH"

# Download model at runtime if not already present
if [ ! -f "$MODEL_PATH/config.json" ]; then
    echo "[INFO] Model not found at $MODEL_PATH. Downloading..."
    pip install huggingface_hub
    python3 -c "
from huggingface_hub import snapshot_download
snapshot_download(
    repo_id='mistralai/Mistral-7B-Instruct-v0.2',
    local_dir='${MODEL_PATH}',
    local_dir_use_symlinks=False
)"
fi

echo "[INFO] FastChat booting..."
echo "[INFO] MODEL_PATH    = $MODEL_PATH"
echo "[INFO] MAX_GPU_MEMORY= $MAX_GPU_MEMORY"
echo "[INFO] LOG_PATH      = $LOG_PATH"
echo "[INFO] LOG_LEVEL     = $LOG_LEVEL"

exec python3 -m fastchat.serve.model_worker \
    --model-path "$MODEL_PATH" \
    --max-gpu-memory "$MAX_GPU_MEMORY" \
    --log-level "$LOG_LEVEL" >> "$LOG_PATH/model_worker.log" 2>&1

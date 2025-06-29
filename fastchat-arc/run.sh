#!/usr/bin/env bash
set -e

MODEL_PATH="${MODEL_PATH:-/share/models/mistral-7b-instruct}"
MAX_GPU_MEMORY="${MAX_GPU_MEMORY:-8Gib}"
LOG_PATH="${LOG_PATH:-/share/fastchat/logs}"
HF_USER_ACCESS_TOKEN="${HF_USER_ACCESS_TOKEN:-""}"

mkdir -p "$MODEL_PATH" "$LOG_PATH"

if [[ -n "$HF_USER_ACCESS_TOKEN" ]]; then
  echo "[INFO] Logging into Hugging Face CLI..."
  echo "$HF_USER_ACCESS_TOKEN" | huggingface-cli login --token
fi

echo "[INFO] FastChat booting..."
echo "[INFO] MODEL_PATH    = $MODEL_PATH"
echo "[INFO] MAX_GPU_MEMORY= $MAX_GPU_MEMORY"
echo "[INFO] LOG_PATH      = $LOG_PATH"

exec python3 -m fastchat.serve.model_worker     --model-path "$MODEL_PATH"     --max-gpu-memory "$MAX_GPU_MEMORY"

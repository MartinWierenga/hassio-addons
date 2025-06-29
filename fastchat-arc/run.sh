#!/usr/bin/env bash
set -e

MODEL_PATH="${MODEL_PATH:-/share/models/mistral-7b-instruct}"
MAX_GPU_MEMORY="${MAX_GPU_MEMORY:-8Gib}"
LOG_PATH="${LOG_PATH:-/share/fastchat/logs}"
HF_TOKEN="${HF_TOKEN:-}"
mkdir -p "$LOG_PATH"

echo "[INFO] FastChat booting..."
echo "[INFO] MODEL_PATH    = $MODEL_PATH"
echo "[INFO] MAX_GPU_MEMORY= $MAX_GPU_MEMORY"
echo "[INFO] LOG_PATH      = $LOG_PATH"
echo "[INFO] LOG_LEVEL     = ${LOG_LEVEL:-debug}"

# Authenticate and download model from Hugging Face
if [[ -n "$HF_TOKEN" && ! -d "$MODEL_PATH" ]]; then
  echo "[INFO] Hugging Face token provided. Downloading model to $MODEL_PATH..."
  python3 -c "
from huggingface_hub import snapshot_download
snapshot_download(
  repo_id='mistralai/Mistral-7B-Instruct-v0.2',
  local_dir='$MODEL_PATH',
  local_dir_use_symlinks=False,
  token='$HF_TOKEN'
)
" || echo '[ERROR] Model download failed!'
fi

# Start controller
python3 -m fastchat.serve.controller --host 0.0.0.0 --port 21001 --dispatch-method shortest_queue --log-level ${LOG_LEVEL:-debug} >> "$LOG_PATH/controller.log" 2>&1 &

# Start model worker
python3 -m fastchat.serve.model_worker --model-path "$MODEL_PATH" --max-gpu-memory "$MAX_GPU_MEMORY" >> "$LOG_PATH/model_worker.log" 2>&1 &

# Start OpenAI-compatible API server
python3 -m fastchat.serve.openai_api_server --host 0.0.0.0 --port 8000 --controller-address http://localhost:21001 >> "$LOG_PATH/openai_api.log" 2>&1 &

# Start Gradio Web UI
python3 -m fastchat.serve.gradio_web_server --controller-url http://localhost:21001 --port 7860 >> "$LOG_PATH/webui.log" 2>&1 &

# Tail logs
sleep 5
tail -F "$LOG_PATH"/*.log

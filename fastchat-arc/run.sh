#!/usr/bin/env bash
set -euo pipefail

MODEL_PATH=$(jq -r '.model_path // "/share/models/naturalfunctions"' /data/options.json)
MAX_GPU_MEMORY=$(jq -r '.max_gpu_memory // "8Gib"' /data/options.json)
LOG_PATH=$(jq -r '.log_path // "/share/fastchat/logs"' /data/options.json)
LOG_LEVEL=$(jq -r '.log_level // "info"' /data/options.json)

mkdir -p "$LOG_PATH"

echo "[INFO] FastChat booting..."
echo "[INFO] MODEL_PATH    = $MODEL_PATH"
echo "[INFO] MAX_GPU_MEMORY= $MAX_GPU_MEMORY"
echo "[INFO] LOG_PATH      = $LOG_PATH"
echo "[INFO] LOG_LEVEL     = $LOG_LEVEL"

# 1) Start model_worker
python3 -m fastchat.serve.model_worker \
  --model-path "$MODEL_PATH" \
  --max-gpu-memory "$MAX_GPU_MEMORY" \
  >> "$LOG_PATH/model_worker.log" 2>&1 &

# 2) Start controller
python3 -m fastchat.serve.controller \
  --host 0.0.0.0 --port 21001 \
  >> "$LOG_PATH/controller.log" 2>&1 &

# 3) Start OpenAI-compatible API
python3 -m fastchat.serve.openai_api_server \
  --host 0.0.0.0 --port 8000 \
  >> "$LOG_PATH/openai_api.log" 2>&1 &

# 4) Start Web UI
python3 -m fastchat.serve.gradio_web_server \
  --controller-url http://localhost:21001 \
  --port 7860 \
  >> "$LOG_PATH/webui.log" 2>&1 &

# 5) Keep container alive
exec tail -F "$LOG_PATH"/*.log

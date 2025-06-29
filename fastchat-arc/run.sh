#!/usr/bin/env bash
set -euo pipefail

# Load options
MODEL_PATH=$(jq -r '.model_path // "/models/vicuna-7b"' /data/options.json)
MAX_GPU_MEMORY=$(jq -r '.max_gpu_memory // "14Gib"' /data/options.json)
LOG_PATH=$(jq -r '.log_path // "/logs"' /data/options.json)
LOG_LEVEL=$(jq -r '.log_level // "info"' /data/options.json)

mkdir -p "$LOG_PATH"

echo "[INFO] FastChat starting with:"
echo "       MODEL_PATH    = $MODEL_PATH"
echo "       MAX_GPU_MEMORY= $MAX_GPU_MEMORY"
echo "       LOG_LEVEL     = $LOG_LEVEL"
echo "       LOG_PATH      = $LOG_PATH"

# 1) Controller
uvicorn fastchat.serve.controller:app \
    --host 0.0.0.0 --port 21001 \
    --log-level "$LOG_LEVEL" \
    --log-config none \
    > "$LOG_PATH/controller.log" 2>&1 &

# 2) Model worker
uvicorn fastchat.serve.model_worker:app \
    --host 0.0.0.0 --port 21002 \
    --log-level "$LOG_LEVEL" \
    --log-config none \
    --workers 1 \
    --lifespan off \
    --reload-dir "$MODEL_PATH" \
    --reload \
    --reload-delay 5 \
    --proxy-headers \
    --limit-max-requests 0 \
    > "$LOG_PATH/worker.log" 2>&1 &

# 3) OpenAI‑compatible API
uvicorn fastchat.serve.openai_api_server:app \
    --host 0.0.0.0 --port 8000 \
    --log-level "$LOG_LEVEL" \
    --log-config none \
    > "$LOG_PATH/openai_api.log" 2>&1 &

# 4) Web UI (Gradio)
uvicorn fastchat.serve.gradio_web_server:app \
    --host 0.0.0.0 --port 7860 \
    --log-level "$LOG_LEVEL" \
    --log-config none \
    > "$LOG_PATH/webui.log" 2>&1 &

# Keep the container running by tailing logs
exec tail -F "$LOG_PATH"/*.log

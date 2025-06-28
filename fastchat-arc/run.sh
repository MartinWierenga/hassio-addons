#!/usr/bin/env bash

# Load options from Home Assistant JSON config
MODEL_PATH=$(jq -r '.model_path // "/models/vicuna-7b"' /data/options.json)
MAX_GPU_MEMORY=$(jq -r '.max_gpu_memory // "14Gib"' /data/options.json)
LOG_PATH=$(jq -r '.log_path // "/logs"' /data/options.json)

mkdir -p "$LOG_PATH"

ARGS="--model-path $MODEL_PATH --max-gpu-memory $MAX_GPU_MEMORY"
echo "[INFO] Starting FastChat model_worker with args: $ARGS"

# Execute and log output
exec fastchat.serve.model_worker $ARGS >> "$LOG_PATH/model_worker.log" 2>&1

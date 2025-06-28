#!/usr/bin/env bash

LOG_PATH=${LOG_PATH:-/logs}
mkdir -p "$LOG_PATH"

ARGS="--model-path ${MODEL_PATH:-/models/naturalfunctions} --max-gpu-memory ${MAX_GPU_MEMORY:-8Gib}"
echo "[INFO] Starting FastChat model_worker with args: $ARGS"

exec python3 -m fastchat.serve.model_worker $ARGS >> "$LOG_PATH/model_worker.log" 2>&1

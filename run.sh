#!/usr/bin/env bash

LOG_PATH=${LOG_PATH:-/logs}
mkdir -p "$LOG_PATH"

ARGS="--model-path ${MODEL_PATH:-/models/vicuna-7b} --max-gpu-memory ${MAX_GPU_MEMORY:-14Gib}"
echo "[INFO] Starting FastChat model_worker with args: $ARGS"

exec fastchat.serve.model_worker $ARGS >> "$LOG_PATH/model_worker.log" 2>&1

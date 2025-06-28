#!/usr/bin/env bash

LOG_PATH=${LOG_PATH:-${OPTS_log_path:-/share/fastchat/logs}}
mkdir -p "$LOG_PATH"

ARGS="--model-path ${MODEL_PATH:-${OPTS_model_path}} --max-gpu-memory ${MAX_GPU_MEMORY:-${OPTS_max_gpu_memory}}"

echo "[INFO] Starting FastChat model_worker with logs in $LOG_PATH"

exec fastchat.serve.model_worker $ARGS >> "$LOG_PATH/model_worker.log" 2>&1

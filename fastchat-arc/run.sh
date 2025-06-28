#!/usr/bin/env bash
#
LOG_PATH=${LOG_PATH:-/share/fastchat/logs}
mkdir -p "$LOG_PATH"
#
ARGS="--model-path ${MODEL_PATH:-/share/models/naturalfunctions} --max-gpu-memory ${MAX_GPU_MEMORY:-8Gib}"
echo "[INFO] Starting FastChat model_worker with args: $ARGS"
#
python3 -m fastchat.serve.model_worker $ARGS >> "$LOG_PATH/model_worker.log" 2>&1
#
#!/usr/bin/env bash
#which python3
#python3 --version
#ls -al /

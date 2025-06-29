#!/usr/bin/env bash
set -e


MODEL_PATH="${MODEL_PATH:-/share/models/mistral-7b-instruct}"
MAX_GPU_MEMORY="${MAX_GPU_MEMORY:-8Gib}"
LOG_PATH="${LOG_PATH:-/share/fastchat/logs}"
HF_USER_ACCESS_TOKEN="${HF_USER_ACCESS_TOKEN:-""}"
<<<<<<< HEAD

mkdir -p "$MODEL_PATH" "$LOG_PATH"

if [[ -n "$HF_USER_ACCESS_TOKEN" ]]; then
  echo "[INFO] Logging into Hugging Face CLI..."
  echo "$HF_USER_ACCESS_TOKEN" | huggingface-cli login --token
fi
=======
mkdir -p "$LOG_PATH"
>>>>>>> a3817c7 (updated HF access)


echo "[INFO] FastChat booting..."
echo "[INFO] MODEL_PATH    = $MODEL_PATH"
echo "[INFO] MAX_GPU_MEMORY= $MAX_GPU_MEMORY"
echo "[INFO] LOG_PATH      = $LOG_PATH"

<<<<<<< HEAD
exec python3 -m fastchat.serve.model_worker $ARGS >> "$LOG_PATH/model_worker.log" 2>&1
=======
# Authenticate and download model from Hugging Face
if [[ -n "$HF_USER_ACCESS_TOKEN" ]]; then
  echo "[INFO] Hugging Face token provided, setting up authentication..."
  huggingface-cli login --token "$HF_USER_ACCESS_TOKEN"
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
>>>>>>> a3817c7 (updated HF access)
#!/usr/bin/env bash
set -e

# Read config yaml options passed by Supervisor as ENV
HF_TOKEN="${HF_USER_ACCESS_TOKEN:-""}"
# ... other envs

if [[ -n "$HF_TOKEN" ]] && [ ! -f "$MODEL_PATH/config.json" ]; then
  echo "Downloading model..."
  python3 - <<EOF
from huggingface_hub import snapshot_download
snapshot_download(repo_id="mistralai/Mistral-7B-Instruct-v0.2", local_dir="${MODEL_PATH}", token="${HF_TOKEN}")
EOF
fi

python3 -m fastchat.serve.model_worker --model-path "$MODEL_PATH" --max-gpu-memory "$MAX_GPU_MEMORY" &
python3 -m fastchat.serve.controller --host 0.0.0.0 --port 21001 &
python3 -m fastchat.serve.openai_api_server --host 0.0.0.0 --port 8000 &
python3 -m fastchat.serve.gradio_web_server --controller-url http://localhost:21001 --port 7860

wait

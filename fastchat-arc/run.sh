#!/usr/bin/env bash
set -e

# Read config yaml options passed by Supervisor as ENV
HF_TOKEN="${HF_USER_ACCESS_TOKEN:-""}"
# ... other envs

if [ ! -z "$HF_USER_ACCESS_TOKEN" ] && [ ! -d "$MODEL_PATH" ]; then
    echo "[INFO] Downloading model from Hugging Face..."
    python3 -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='mistralai/Mistral-7B-Instruct-v0.2', local_dir='$MODEL_PATH', local_dir_use_symlinks=False, token='$HF_USER_ACCESS_TOKEN')"
fi


python3 -m fastchat.serve.model_worker --model-path "$MODEL_PATH" --max-gpu-memory "$MAX_GPU_MEMORY" &
python3 -m fastchat.serve.controller --host 0.0.0.0 --port 21001 &
python3 -m fastchat.serve.openai_api_server --host 0.0.0.0 --port 8000 &
python3 -m fastchat.serve.gradio_web_server --controller-url http://localhost:21001 --port 7860

wait

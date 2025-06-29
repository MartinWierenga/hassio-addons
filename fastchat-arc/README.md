# FastChat ARC Add-on

This is a Home Assistant add-on for running FastChat with Intel Arc GPU acceleration and Hugging Face model support.

## Features

- Intel GPU support (i5/Arc)
- Hugging Face model download at runtime
- Web UI (Gradio)
- OpenAI-compatible API endpoint

## Usage

1. Add your Hugging Face token in the add-on configuration.
2. Specify a model path.
3. Start the add-on.

## Logs

Model, controller, API, and UI logs are stored in `/share/fastchat/logs/`.

## Example Configuration

```yaml
model_path: "/share/models/mistral-7b-instruct"
max_gpu_memory: "8Gib"
log_level: "debug"
log_path: "/share/fastchat/logs"
hf_token: "your-hf-token-here"
```

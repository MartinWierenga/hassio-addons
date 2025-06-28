# FastChat Intel GPU Home Assistant Add-on

This add-on runs FastChat `model_worker` using Intel Arc or iGPU, with OpenAI-compatible API support, inside Home Assistant OS.

## Configuration Options

- `model_path`: Path to your model directory (e.g., `/share/models/vicuna-7b`)
- `max_gpu_memory`: GPU memory allocation (e.g., `14Gib`)
- `log_level`: Log verbosity (`info`, `warning`, `debug`, etc.)
- `log_path`: Path to store logs (e.g., `/share/fastchat/logs`)

## Usage Notes

- Ensure your model files are placed under `/share/models/`
- Logs are written to the configured path
- Uses GHCR image: `ghcr.io/martinwierenga/fastchat-intel-gpu:1.0.0`

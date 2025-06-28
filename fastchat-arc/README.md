# FastChat Intel GPU Add-on for Home Assistant

Run OpenAI-compatible FastChat models on Intel Arc or iGPU hardware inside Home Assistant OS.

## 🔧 Configuration

| Option        | Description                            | Example                         |
|---------------|----------------------------------------|---------------------------------|
| `model_path`  | Model directory path                   | `/share/models/vicuna-7b`       |
| `max_gpu_memory` | Maximum GPU memory allowed          | `14Gib`                         |
| `log_level`   | Log verbosity                          | `info`, `debug`, `error`        |
| `log_path`    | Log file directory                     | `/share/fastchat/logs`          |

## 📡 Features

- Intel GPU support
- OpenAI-compatible API
- Managed sidebar UI
- Built for Home Assistant OS

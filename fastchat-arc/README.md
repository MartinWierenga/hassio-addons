# FastChat Intel GPU Home Assistant Add-on

Runs the FastChat API and Web UI optimized for Intel ARC/iGPU on Home Assistant OS.

## 🔧 Features
- ✅ FastChat model worker
- ✅ OpenAI-compatible API
- ✅ Intel Arc and iGPU support
- ✅ Mistral-7B-Instruct auto-download
- ✅ Persistent logs to `/share/fastchat/logs`

## ⚙️ Configuration

```yaml
model_path: "/share/models/mistral-7b-instruct"
max_gpu_memory: "8Gib"
log_level: "debug"
log_path: "/share/fastchat/logs"

# FastChat Home Assistant Add-on (Intel GPU Support)

This is a Home Assistant add-on for running FastChat with Intel Arc / iGPU support.

## Features
- OpenAI-compatible API on port `8000`
- Web UI on port `7860`
- Model config and logging path configurable from UI
- Supports Vicuna, NaturalFunctions, and other models

## Configuration

```yaml
model_path: "/share/models/naturalfunctions"
max_gpu_memory: "8Gib"
log_path: "/share/fastchat/logs"
log_level: "debug"
```

## Hardware
- Optimized for Intel iGPU / Arc (Level Zero + OpenCL)

#!/usr/bin/with-contenv bashio
# Launch the server with the specified model and options

# Note: adjust the executable name/path if needed. Often, the provided images entrypoint already
# points to the server binary so you may simply pass the additional parameters.
<<<<<<< HEAD
exec llama-server -m /models/7B/ggml-model-q4_0.gguf --port 8000 --host 0.0.0.0 -n 512
=======
docker run -v /media/models:/models -p 8000:8000 ghcr.io/ggml-org/llama.cpp:server -m /models/7B/ggml-model-q4_0.gguf --port 8000 --host 0.0.0.0 -n 512
>>>>>>> 9c5a217f5290998f45fe787817e7a858137f35c0

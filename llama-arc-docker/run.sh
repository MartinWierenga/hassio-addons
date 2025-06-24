#!/usr/bin/with-contenv bashio
# Launch the server with the specified model and options

# Note: adjust the executable name/path if needed. Often, the provided images entrypoint already
# points to the server binary so you may simply pass the additional parameters.
exec server -m /models/7B/ggml-model-q4_0.gguf --port 8000 --host 0.0.0.0 -n 512
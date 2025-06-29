# Use a Python base that includes pip
FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install git (for pip installs), jq, and build essentials
RUN apt-get update && \
    apt-get install -y --no-install-recommends git jq && \
    rm -rf /var/lib/apt/lists/*

# Install FastChat core, CLI wrapper, and Uvicorn
RUN pip install --no-cache-dir \
      git+https://github.com/lm-sys/FastChat.git \
      fschat[model_worker,webui] \
      uvicorn

# Copy your add‑on run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Default entrypoint
ENTRYPOINT ["/run.sh"]

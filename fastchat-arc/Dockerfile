FROM ghcr.io/martinwierenga/fastchat-intel-gpu:latest
#FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Python, pip, and basic tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python-is-python3 \
    git \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install FastChat directly from GitHub
RUN pip install --no-cache-dir git+https://github.com/lm-sys/FastChat.git

# Copy your run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Run it
ENTRYPOINT ["/run.sh"]

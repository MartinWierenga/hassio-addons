FROM alpine:edge

# Add edge community repo and install dependencies
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache \
    python3.10 \
    py3-pip \
    py3-setuptools \
    py3-virtualenv \
    build-base \
    cmake \
    curl \
    git \
    git-lfs \
    libffi-dev \
    jemalloc-dev \
    bash \
    wget \
    unzip \
    clinfo \
    numactl-dev \
    libstdc++ \
    libexecinfo-dev \
    libglvnd-dev \
    mesa-dev \
    mesa-gl \
    mesa-gbm \
    mesa-egl \
    mesa-glapi \
    egl-wayland \
    libx11 \
    libxext \
    libxrender \
    libxcomposite \
    libxrandr \
    libxcursor \
    libxdamage \
    libxfixes \
    libxi \
    libxinerama \
    libxxf86vm \
    libdrm \
    libjpeg-turbo \
    libpng \
    freetype

# Create virtualenv
RUN python3.10 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip
RUN pip install --upgrade pip setuptools wheel

# Set jemalloc preload path if it exists
ENV LD_PRELOAD=/usr/lib/libjemalloc.so

# Install Torch (pure CPU-only or compatible build; GPU/XPU not supported on Alpine directly)
RUN pip install torch==2.0.1 torchvision==0.15.2

# Install llama-cpp-python with clblast support
ENV CMAKE_ARGS="-DLLAMA_CLBLAST=on"
RUN pip install --no-cache-dir llama-cpp-python --force-reinstall --upgrade

# Install FastChat
RUN pip install "fschat[model_worker,webui]"

# Setup volumes and working dir
VOLUME [ "/deps", "/logs", "/root/.cache/huggingface" ]
RUN mkdir -p /logs
WORKDIR /logs

# Environment configuration
ENV FS_ENABLE_WEB=true
ENV FS_ENABLE_OPENAI_API=true
ENV LOGDIR=/logs

# Copy startup script
COPY startup.sh /bin/start_fastchat.sh
RUN chmod +x /bin/start_fastchat.sh

EXPOSE 7860
EXPOSE 8000

ENTRYPOINT [ "/bin/bash", "/bin/start_fastchat.sh" ]
CMD ["--model-path", "lmsys/vicuna-7b-v1.3", "--max-gpu-memory", "14Gib"]

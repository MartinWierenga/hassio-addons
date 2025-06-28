# ─────────────────────────────────────────────────────────────────────────────
# Stage: fastchat-xpu on Alpine 3.18
# ─────────────────────────────────────────────────────────────────────────────
FROM alpine:3.18 AS fastchat-xpu

# 1) Pin repos & enable community + edge for Intel packages
RUN printf '%s\n' \
    "https://dl-cdn.alpinelinux.org/alpine/v3.18/main" \
    "https://dl-cdn.alpinelinux.org/alpine/v3.18/community" \
    "https://dl-cdn.alpinelinux.org/alpine/edge/community" \
    "https://dl-cdn.alpinelinux.org/alpine/edge/testing" \
  > /etc/apk/repositories \
 && apk update

# 2) Install runtime & build deps
RUN apk add --no-cache \
      bash \
      ca-certificates \
      gnupg \
      unzip \
      wget \
      build-base \
      curl \
      git \
      git-lfs \
      opencl-headers \
      numactl \
      python3 \
      py3-pip \
      py3-virtualenv \
      libgomp \
      jemalloc \
      jemalloc-dev \
      glib \
      mesa-dri-gallium \
      mesa-va-gallium \
      mesa-vdpau \
      mesa-vulkan \
      libva-utils \
      clinfo \
      vainfo \
      hwinfo \
      intel-compute-runtime \
      intel-media-driver \
      libegl \
      libgbm \
      libglvnd-dev \
      mesa-dev

# 3) Force jemalloc as allocator (same as LD_PRELOAD on Ubuntu)
ENV LD_PRELOAD=/usr/lib/libjemalloc.so

# 4) Set up Python virtualenv
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --upgrade pip setuptools
ENV PATH="/opt/venv/bin:${PATH}"

# 5) Expose full VRAM to compute-runtime
ENV NEOReadDebugKeys=1 \
    ClDeviceGlobalMemSizeAvailablePercent=100

# 6) Install Intel oneAPI via official installer
#    Copy your .sh installer into the build context next to Dockerfile.
COPY l_BaseKit_p_2023.2.1.*.sh /tmp/
RUN chmod +x /tmp/l_BaseKit_*.sh \
 && /tmp/l_BaseKit_*.sh \
      --silent --eula accept \
      --install-dir /opt/intel/oneapi \
 && rm -f /tmp/l_BaseKit_*.sh

ENV PATH="/opt/intel/oneapi/compiler/latest/linux/bin:${PATH}" \
    LD_LIBRARY_PATH="/opt/intel/oneapi/compiler/latest/linux/lib:${LD_LIBRARY_PATH}"

# 7) Python-level installs: Torch, llama-cpp, fschat
RUN pip install \
      torch==2.0.1a0 \
      torchvision==0.15.2a0 \
      intel_extension_for_pytorch==2.0.110+xpu \
        --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us/ \
 && CMAKE_ARGS="-DLLAMA_CLBLAST=on" FORCE_CMAKE=1 \
    pip install llama-cpp-python --force-reinstall --upgrade --no-cache-dir \
 && pip install "fschat[model_worker,webui]"

# 8) Volumes, workdir, ports, entrypoint
VOLUME [ "/deps", "/logs", "/root/.cache/huggingface" ]
RUN mkdir /logs
WORKDIR /logs

EXPOSE 7860 8000

ENV FS_ENABLE_WEB=true \
    FS_ENABLE_OPENAI_API=true \
    LOGDIR=/logs

COPY startup.sh /bin/start_fastchat.sh
RUN chmod 755 /bin/start_fastchat.sh

ENTRYPOINT ["/bin/bash","/bin/start_fastchat.sh"]
CMD ["--model-path","lmsys/vicuna-7b-v1.3","--max-gpu-memory","14Gib"]

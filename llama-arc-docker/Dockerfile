# -----------------------------------------------------------------------------
# FastChat-XPU on Alpine Linux 3.18
# -----------------------------------------------------------------------------
FROM alpine:3.18 AS fastchat-xpu

# 1) Pin Alpine repos & enable edge/community for Intel packages
RUN printf '%s\n' \
     "https://dl-cdn.alpinelinux.org/alpine/v3.18/main" \
     "https://dl-cdn.alpinelinux.org/alpine/v3.18/community" \
     "https://dl-cdn.alpinelinux.org/alpine/edge/community" \
   > /etc/apk/repositories \
 && apk update

# 2) Install core tooling, Python, jemalloc & VAAPI/OpenCL utils
RUN apk add --no-cache \
      bash \
      ca-certificates \
      gnupg \
      unzip \
      wget \
      build-base        \
      curl \
      git \
      opencl-headers \
      numactl \
      python3 \
      py3-pip \
      libgomp \
      jemalloc \
      jemalloc-dev \
      libstdc++ \
      linux-headers \
      libva-utils \
      clinfo \
      vainfo \
      hwinfo \
# 3) Install git-lfs from edge/community
 && apk add --no-cache \
      --repository https://dl-cdn.alpinelinux.org/alpine/edge/community \
        git-lfs \
# 4) Smoke-test
 && vainfo \
 && clinfo

# 5) Force jemalloc as the allocator (mirrors LD_PRELOAD on Ubuntu)
ENV LD_PRELOAD=/usr/lib/libjemalloc.so

# 6) Expose full VRAM to compute-runtime
ENV NEOReadDebugKeys=1 \
    ClDeviceGlobalMemSizeAvailablePercent=100

# 7) Create & activate Python venv, upgrade pip/setuptools
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --upgrade pip setuptools
ENV PATH="/opt/venv/bin:${PATH}"

# 8) Install Intel oneAPI Base Toolkit (DPCPP, MKL, shared libs)
COPY l_BaseKit_p_2023.2.1.*.sh /tmp/
RUN chmod +x /tmp/l_BaseKit_*.sh \
 && /tmp/l_BaseKit_*.sh --silent --eula accept --install-dir /opt/intel/oneapi \
 && rm -f /tmp/l_BaseKit_*.sh

# 9) Add oneAPI compiler tools to PATH & LD_LIBRARY_PATH
ENV PATH="/opt/intel/oneapi/compiler/latest/linux/bin:${PATH}" \
    LD_LIBRARY_PATH="/opt/intel/oneapi/compiler/latest/linux/lib:${LD_LIBRARY_PATH}"

# 10) Python-level installs: Torch + Intel XPU ext, llama-cpp-python, fschat
RUN pip install \
      torch==2.0.1a0 \
      torchvision==0.15.2a0 \
      intel_extension_for_pytorch==2.0.110+xpu \
        --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us/ \
 && CMAKE_ARGS="-DLLAMA_CLBLAST=on" FORCE_CMAKE=1 \
    pip install llama-cpp-python --force-reinstall --upgrade --no-cache-dir \
 && pip install "fschat[model_worker,webui]"

# 11) Volumes, workdir, ports, envs
VOLUME [ "/deps", "/logs", "/root/.cache/huggingface" ]
RUN mkdir /logs
WORKDIR /logs

EXPOSE 7860 8000

ENV FS_ENABLE_WEB=true \
    FS_ENABLE_OPENAI_API=true \
    LOGDIR=/logs

# 12) Startup script & entrypoint
COPY startup.sh /bin/start_fastchat.sh
RUN chmod 755 /bin/start_fastchat.sh

ENTRYPOINT ["/bin/bash","/bin/start_fastchat.sh"]
CMD ["--model-path","lmsys/vicuna-7b-v1.3","--max-gpu-memory","14Gib"]

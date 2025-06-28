FROM alpine:3.18

# 1) Enable community & edge/community for Intel packages
RUN printf '%s\n' \
     "https://dl-cdn.alpinelinux.org/alpine/v3.18/main" \
     "https://dl-cdn.alpinelinux.org/alpine/v3.18/community" \
     "https://dl-cdn.alpinelinux.org/alpine/edge/community" \
   > /etc/apk/repositories \
 && apk update

# 2) Core tooling + Python + jemalloc + OpenCL/VA-API utilities
RUN apk add --no-cache \
      bash \
      ca-certificates \
      gnupg \
      unzip \
      wget \
      curl \
      build-base \
      git \
      git-lfs \
      linux-headers \
      libstdc++ \
      libgomp \
      jemalloc \
      jemalloc-dev \
      python3 \
      py3-pip \
      opencl-headers \
      numactl \
      libva-utils \
      clinfo \
      vainfo \
      hwinfo

# 3) Intel GPU / OpenCL + media driver from edge/community
RUN apk add --no-cache \
      --repository https://dl-cdn.alpinelinux.org/alpine/edge/community \
        intel-compute-runtime \
        intel-media-driver

# 4) Smoke-test OpenCL & VA API
RUN vainfo && clinfo

# 5) Force jemalloc and 100% VRAM envs
ENV LD_PRELOAD=/usr/lib/libjemalloc.so \
    NEOReadDebugKeys=1 \
    ClDeviceGlobalMemSizeAvailablePercent=100

# 6) Python venv
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --upgrade pip setuptools
ENV PATH="/opt/venv/bin:${PATH}"

# 7) Intel oneAPI Base Toolkit installer (copy .sh next to Dockerfile)
COPY l_BaseKit_p_2023.2.1.*.sh /tmp/
RUN chmod +x /tmp/l_BaseKit_*.sh \
 && /tmp/l_BaseKit_*.sh --silent --eula accept --install-dir /opt/intel/oneapi \
 && rm -f /tmp/l_BaseKit_*.sh

ENV PATH="/opt/intel/oneapi/compiler/latest/linux/bin:${PATH}" \
    LD_LIBRARY_PATH="/opt/intel/oneapi/compiler/latest/linux/lib:${LD_LIBRARY_PATH}"

# 8) pip install Torch + XPU ext, llama-cpp & fschat
RUN pip install \
      torch==2.0.1a0 \
      torchvision==0.15.2a0 \
      intel_extension_for_pytorch==2.0.110+xpu \
        --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us/ \
 && CMAKE_ARGS="-DLLAMA_CLBLAST=on" FORCE_CMAKE=1 \
    pip install llama-cpp-python --force-reinstall --upgrade --no-cache-dir \
 && pip install "fschat[model_worker,webui]"

# 9) Volumes & entrypoint
VOLUME ["/deps","/logs","/root/.cache/huggingface"]
RUN mkdir /logs
WORKDIR /logs

EXPOSE 7860 8000

ENV FS_ENABLE_WEB=true \
    FS_ENABLE_OPENAI_API=true \
    LOGDIR=/logs

COPY startup.sh /bin/start_fastchat.sh
RUN chmod +x /bin/start_fastchat.sh
ENTRYPOINT ["/bin/bash","/bin/start_fastchat.sh"]
CMD ["--model-path","lmsys/vicuna-7b-v1.3","--max-gpu-memory","14Gib"]

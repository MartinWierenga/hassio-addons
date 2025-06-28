###############################################################################
# FastChat-XPU on Alpine Linux 3.18 + Python 3.10
###############################################################################
FROM python:3.10-alpine3.18 AS fastchat-xpu

# 1) Enable edge/community for Intel packages
RUN printf '%s\n' \
     "https://dl-cdn.alpinelinux.org/alpine/v3.18/main" \
     "https://dl-cdn.alpinelinux.org/alpine/v3.18/community" \
     "https://dl-cdn.alpinelinux.org/alpine/edge/community" \
   > /etc/apk/repositories \
 && apk update

# 2) Install core tooling, jemalloc, OpenCL/VA-API utils
RUN apk add --no-cache \
      bash \
      ca-certificates \
      gnupg \
      unzip \
      wget \
      curl \
      build-base        \
      git               \
      linux-headers     \
      libstdc++         \
      libgomp           \
      jemalloc          \
      jemalloc-dev      \
      opencl-headers    \
      numactl           \
      libva-utils       \
      clinfo            \
      vainfo            \
      hwinfo

# 3) Install git-lfs and Intel GPU/OpenCL/Media-driver from edge/community
RUN apk add --no-cache \
      --repository https://dl-cdn.alpinelinux.org/alpine/edge/community \
        git-lfs \
        intel-compute-runtime \
        intel-media-driver

# 4) Quick smoke-test
RUN vainfo && clinfo

# 5) Force jemalloc & 100% VRAM
ENV LD_PRELOAD=/usr/lib/libjemalloc.so \
    NEOReadDebugKeys=1 \
    ClDeviceGlobalMemSizeAvailablePercent=100

# 6) Create & activate a venv, upgrade pip/setuptools
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --upgrade pip setuptools
ENV PATH="/opt/venv/bin:${PATH}"

# 7) Install Intel oneAPI Base Toolkit (DPCPP, MKL, shared libs)
#    Copy your BaseKit installer alongside this Dockerfile.
COPY l_BaseKit_p_2023.2.1.*.sh /tmp/
RUN chmod +x /tmp/l_BaseKit_*.sh \
 && /tmp/l_BaseKit_*.sh \
      --silent --eula accept \
      --install-dir /opt/intel/oneapi \
 && rm -f /tmp/l_BaseKit_*.sh

ENV PATH="/opt/intel/oneapi/compiler/latest/linux/bin:${PATH}" \
    LD_LIBRARY_PATH="/opt/intel/oneapi/compiler/latest/linux/lib:${LD_LIBRARY_PATH}"

# 8) Python-level installs: Torch+XPU, llama-cpp-python, fschat
RUN pip install \
      torch==2.0.1a0 \
      torchvision==0.15.2a0 \
      intel_extension_for_pytorch==2.0.110+xpu \
        --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us/ \
 && CMAKE_ARGS="-DLLAMA_CLBLAST=on" FORCE_CMAKE=1 \
    pip install llama-cpp-python --force-reinstall --upgrade --no-cache-dir \
 && pip install "fschat[model_worker,webui]"

# 9) Volumes, workdir, ports, entry
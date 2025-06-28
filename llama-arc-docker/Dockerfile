###############################################################################
# Add-on:  Llama Intel Arc Docker (FastChat-XPU)
# Supports: amd64
###############################################################################
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
ARG BUILD_VERSION
ARG BUILD_ARCH

FROM ${BUILD_FROM}

###############################################################################
# 1) ensure we’re root and install core tooling + Intel/OpenCL/VA-API
###############################################################################
USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      gnupg2 \
      gpg-agent \
      unzip \
      wget \
      build-essential \
      curl \
      libgl1 \
      libglib2.0-0 \
      libgomp1 \
      libjemalloc-dev \
      git \
      git-lfs \
      opencl-headers \
      clinfo \
      vainfo \
      hwinfo \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

###############################################################################
# 2) Add Intel oneAPI APT repos (GPG + list file)
###############################################################################
RUN curl -fsSL \
      https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
    | gpg --dearmor \
    | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null

RUN echo \
    "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] \
      https://apt.repos.intel.com/oneapi all main" \
     | tee /etc/apt/sources.list.d/oneAPI.list

###############################################################################
# 3) Add Intel GPU driver repo (for compute-runtime & media driver)
###############################################################################
RUN curl -fsSL \
      https://repositories.intel.com/gpu/intel-graphics.key \
    | gpg --dearmor \
    | tee /usr/share/keyrings/intel-graphics.gpg > /dev/null

RUN echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] \
      https://repositories.intel.com/gpu/ubuntu jammy client" \
    | tee /etc/apt/sources.list.d/intel-gpu-jammy.list

###############################################################################
# 4) Install Intel compute-runtime, media-driver, oneAPI runtimes
###############################################################################
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      intel-opencl-icd \
      intel-level-zero-gpu \
      level-zero \
      level-zero-dev \
      intel-oneapi-runtime-dpcpp-cpp \
      intel-oneapi-runtime-mkl \
      intel-oneapi-compiler-shared-common-2023.2.1 \
      intel-media-va-driver-non-free \
      libmfx1 \
      libmfxgen1 \
      libvpl2 \
      libegl-mesa0 \
      libgbm1 \
      libgl1-mesa-dri \
      mesa-va-drivers \
      mesa-vdpau-drivers \
      mesa-vulkan-drivers \
      va-driver-all \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

###############################################################################
# 5) jemalloc preload + full-VRAM flags
###############################################################################
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so \
    NEOReadDebugKeys=1 \
    ClDeviceGlobalMemSizeAvailablePercent=100

###############################################################################
# 6) Python venv + pip
###############################################################################
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --upgrade pip setuptools
ENV PATH="/opt/venv/bin:${PATH}"

###############################################################################
# 7) oneAPI BaseKit installer (copy your .sh next to this Dockerfile)
###############################################################################
COPY l_BaseKit_p_2023.2.1.*.sh /tmp/
RUN chmod +x /tmp/l_BaseKit_*.sh \
 && /tmp/l_BaseKit_*.sh --silent --eula accept --install-dir /opt/intel/oneapi \
 && rm -f /tmp/l_BaseKit_*.sh

ENV PATH="/opt/intel/oneapi/compiler/latest/linux/bin:${PATH}" \
    LD_LIBRARY_PATH="/opt/intel/oneapi/compiler/latest/linux/lib:${LD_LIBRARY_PATH}"

###############################################################################
# 8) Install Torch+XPU, llama-cpp, fschat
###############################################################################
RUN pip install \
      torch==2.0.1a0 \
      torchvision==0.15.2a0 \
      intel_extension_for_pytorch==2.0.110+xpu \
        --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us/ \
 && CMAKE_ARGS="-DLLAMA_CLBLAST=on" FORCE_CMAKE=1 \
    pip install llama-cpp-python --force-reinstall --upgrade --no-cache-dir \
 && pip install "fschat[model_worker,webui]"

###############################################################################
# 9) Volumes, workdir, ports, entrypoint
###############################################################################
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

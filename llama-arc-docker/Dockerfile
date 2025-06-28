# -----------------------------------------------------------------------------
# FastChat-XPU on Python 3.10 Alpine 3.18
# -----------------------------------------------------------------------------
FROM python:3.10-alpine3.18 AS fastchat-xpu

# 1) Enable Intel edge/community for compute-runtime & media-driver
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" \
     >> /etc/apk/repositories \
 && apk update

# 2) Core shell tooling + git
RUN apk add --no-cache \
     bash \
     ca-certificates \
     gnupg \
     unzip \
     wget \
     build-base \        # gcc, make, etc.
     curl \
     git \
 && apk add --no-cache \
     --repository https://dl-cdn.alpinelinux.org/alpine/edge/community \
     git-lfs

# 3) Python-adjacent libs for venv & compiler support
RUN apk add --no-cache \
     linux-headers \
     libstdc++ \
     libgomp

# 4) jemalloc (mirrors your LD_PRELOAD on Ubuntu)
RUN apk add --no-cache \
     jemalloc \
     jemalloc-dev

# 5) OpenCL headers & NUMA
RUN apk add --no-cache \
     opencl-headers \
     numactl

# 6) VA-API / OpenCL utilities
RUN apk add --no-cache \
     libva-utils \
     clinfo \
     vainfo \
     hwinfo

# 7) Intel GPU / OpenCL & media driver from edge/community
RUN apk add --no-cache \
     --repository https://dl-cdn.alpinelinux.org/alpine/edge/community \
     intel-compute-runtime \
     intel-media-driver

# 8) Smoke-test that VA-API and OpenCL are working
RUN vainfo && clinfo

# 9) Force jemalloc as allocator
ENV LD_PRELOAD=/usr/lib/libjemalloc.so

# 10) Expose 100% of VRAM to Intel compute-runtime
ENV NEOReadDebugKeys=1 \
    ClDeviceGlobalMemSizeAvailablePercent=100

# 11) Create & activate Python venv, upgrade pip/setuptools
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --upgrade pip setuptools
ENV PATH="/opt/venv/bin:${PATH}"

# 12) Install Intel oneAPI Base Toolkit (DPCPP, MKL, shared libs)
#     Copy your BaseKit installer next to this Dockerfile
COPY l_BaseKit_p_2023.2.1.*.sh /tmp/
RUN chmod +x /tmp/l_BaseKit_*.sh \
 && /tmp/l_BaseKit_*.sh --silent --eula accept --install-dir /opt/intel/oneapi \
 && rm -f /tmp/l_BaseKit_*.sh

# 13) Add oneAPI compiler tools to PATH & LD_LIBRARY_PATH
ENV PATH="/opt/intel/oneapi/compiler/latest/linux/bin:${PATH}" \
    LD_LIBRARY_PATH="/opt/intel/oneapi/compiler/latest/linux/lib:${LD_LIBRARY_PATH}"

# 14) Python-level installs: Torch + Intel XPU ext, llama-cpp-python, fschat
RUN pip install \
      torch==2.0.1a0 \
      torchvision==0.15.2a0 \
      intel_extension_for_pytorch==2.0.110+xpu \
        --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us/ \
 && CMAKE_ARGS="-DLLAMA_CLBLAST=on" FORCE_CMAKE=1 \
    pip install llama-cpp-python --force-reinstall --upgrade --no-cache-dir \
 && pip install "fschat[model_worker,webui]"

# 15) Volumes, workdir, ports, envs, entrypoint
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

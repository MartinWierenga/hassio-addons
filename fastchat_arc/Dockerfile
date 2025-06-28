FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates wget build-essential curl \
      libgl1 libgomp1 libjemalloc-dev python3-pip \
      intel-opencl-icd intel-level-zero-gpu level-zero \
    && rm -rf /var/lib/apt/lists/*

ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so

RUN pip3 install --upgrade pip setuptools && \
    pip3 install torch==2.0.1a0 torchvision==0.15.2a0 intel_extension_for_pytorch==2.0.110+xpu \
      --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us/ && \
    CMAKE_ARGS="-DLLAMA_CLBLAST=on" FORCE_CMAKE=1 pip3 install llama-cpp-python && \
    pip3 install "fschat[model_worker,webui]"

WORKDIR /data
COPY run.sh /usr/bin/run.sh
RUN chmod +x /usr/bin/run.sh

EXPOSE 7860 8000

ENTRYPOINT ["/usr/bin/run.sh"]

FROM ubuntu:22.04

# Add Intel GPU repositories
RUN apt-get update && apt-get install -y wget gnupg curl software-properties-common && \
    wget -qO - https://repositories.intel.com/graphics/intel-graphics.key | gpg --dearmor -o /usr/share/keyrings/intel-graphics.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/graphics/ubuntu jammy main" > /etc/apt/sources.list.d/intel.gpu.list && \
    apt-get update

# Install GPU runtime and Python dependencies
RUN apt-get install -y --no-install-recommends \
    intel-opencl-icd intel-level-zero-gpu level-zero libjemalloc-dev \
    python3 python3-pip python-is-python3 build-essential git cmake curl libgl1 libgomp1 && \
    rm -rf /var/lib/apt/lists/*

ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so

# Install Python AI stack
RUN pip install --upgrade pip setuptools && \
    pip install torch==2.0.1a0 torchvision==0.15.2a0 intel_extension_for_pytorch==2.0.110+xpu \
        --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us/ && \
    CMAKE_ARGS="-DLLAMA_CLBLAST=on" FORCE_CMAKE=1 pip install llama-cpp-python && \
    pip install "fschat[model_worker,webui]"

WORKDIR /app
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

EXPOSE 7860 8000

CMD ["/usr/local/bin/run.sh"]

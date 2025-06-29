FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends git jq && \
    rm -rf /var/lib/apt/lists/*

# Install FastChat and Uvicorn
RUN pip install --no-cache-dir \
      git+https://github.com/lm-sys/FastChat.git \
      fschat[model_worker,webui] \
      uvicorn

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]

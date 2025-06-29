FROM python:3.10-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends git jq && \
    rm -rf /var/lib/apt/lists/*

# Install FastChat + extras
RUN pip install --no-cache-dir \
      git+https://github.com/lm-sys/FastChat.git \
      fschat[model_worker,webui] \
      uvicorn

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]

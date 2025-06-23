ARG BUILD_FROM=ghcr.io/ggml-org/llama.cpp:server-intel
FROM ${BUILD_FROM}

# Copy the run script into the image and make it executable
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD [ "/run.sh" ]

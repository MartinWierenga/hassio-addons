FROM python:3.10-slim
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu && \
    pip install aiohttp psutil gradio
RUN apt-get update && apt-get install -y git && pip install huggingface_hub fastchat sentencepiece
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]

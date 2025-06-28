#FROM ghcr.io/martinwierenga/fastchat-intel-gpu:latest
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y jq && rm -rf /var/lib/apt/lists/*
RUN pip install fschat
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
ENTRYPOINT [ "/run.sh" ]
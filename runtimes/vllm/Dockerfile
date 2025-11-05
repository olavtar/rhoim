FROM nvidia/cuda:12.2.2-cudnn8-runtime-ubuntu22.04
ARG VLLM_VERSION=0.5.4
RUN apt-get update && apt-get install -y --no-install-recommends python3-pip git && \
    rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir vllm==${VLLM_VERSION} fastapi uvicorn prometheus-client
WORKDIR /srv
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
EXPOSE 8000
CMD ["/usr/local/bin/entrypoint.sh"]

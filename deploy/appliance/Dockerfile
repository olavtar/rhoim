FROM nvidia/cuda:12.2.2-cudnn8-runtime-ubuntu22.04
ARG VLLM_VERSION=0.5.4
WORKDIR /opt/rhoim
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip git curl ca-certificates rsync && rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir \
    vllm==${VLLM_VERSION} fastapi uvicorn[standard] prometheus-client \
    "huggingface_hub[cli]" awscli
COPY ../../gateway/requirements.txt /opt/rhoim/gateway/requirements.txt
RUN pip3 install --no-cache-dir -r /opt/rhoim/gateway/requirements.txt
COPY ../../gateway/app /opt/rhoim/gateway/app
COPY ../../scripts/model_pull.sh  /opt/rhoim/bin/model_pull.sh
COPY start.sh                     /opt/rhoim/bin/start.sh
RUN chmod +x /opt/rhoim/bin/*.sh
EXPOSE 8080 8000
ENV API_KEYS="devkey1,devkey2" ENABLE_RHOAI_ALIAS="true" BASE_PATH="/" \
    MODEL_URI="/models/llama3-8b" MODEL_SOURCE="" HF_TOKEN="" \
    VLLM_PORT="8000" GATEWAY_PORT="8080"
VOLUME ["/models"]
CMD ["/opt/rhoim/bin/start.sh"]

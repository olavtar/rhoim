FROM python:3.10-slim

ARG VLLM_VERSION=0.10.2
ARG PIP_INSTALL_OPTS="--prefer-binary --only-binary=:all:"

WORKDIR /opt/rhoim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates && rm -rf /var/lib/apt/lists/*

## Ensure vLLM build scripts detect a release environment without git metadata
ENV VLLM_VERSION=${VLLM_VERSION} \
    VLLM_RELEASE_BUILD=1 \
    VLLM_TARGET_DEVICE=cpu \
    VLLM_USE_CUDA=0 \
    VLLM_USE_FLASHINFER=0

RUN pip3 install --upgrade pip

# Ensure CPU-only torch is used (avoid CUDA libs)
RUN pip3 install --no-cache-dir --index-url https://download.pytorch.org/whl/cpu \
    torch==2.4.1 \
 && pip3 install --no-cache-dir $PIP_INSTALL_OPTS \
    vllm==${VLLM_VERSION} fastapi uvicorn[standard] prometheus-client \
    "huggingface_hub[cli]"

# Gateway bits
COPY gateway/requirements.txt /opt/rhoim/gateway/requirements.txt
RUN pip3 install --no-cache-dir -r /opt/rhoim/gateway/requirements.txt
COPY gateway/app /opt/rhoim/gateway/app

# Startup
COPY deploy/appliance-cpu/start.sh /opt/rhoim/bin/start.sh
RUN chmod +x /opt/rhoim/bin/start.sh

EXPOSE 8080 8000

ENV API_KEYS="devkey1,devkey2" ENABLE_RHOAI_ALIAS="true" BASE_PATH="/" \
    MODEL_URI="TinyLlama/TinyLlama-1.1B-Chat-v1.0" \
    VLLM_PORT="8000" GATEWAY_PORT="8080"

CMD ["/opt/rhoim/bin/start.sh"]




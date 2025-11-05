FROM python:3.10-slim

ARG VLLM_VERSION=0.10.2
ARG PIP_INSTALL_OPTS="--prefer-binary --only-binary=:all:"

RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

## Ensure vLLM build scripts detect a release environment without git metadata
ENV VLLM_VERSION=${VLLM_VERSION} \
    VLLM_RELEASE_BUILD=1 \
    VLLM_TARGET_DEVICE=cpu

# Newer pip helps resolve/platform-select wheels better
RUN pip3 install --upgrade pip

# vLLM CPU + minimal deps; include HF CLI for optional model pulls
RUN pip3 install --no-cache-dir $PIP_INSTALL_OPTS \
    vllm==${VLLM_VERSION} fastapi uvicorn prometheus-client \
    "huggingface_hub[cli]"

WORKDIR /srv

COPY runtimes/vllm-cpu/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8000

ENV PORT=8000 \
    MODEL_URI="TinyLlama/TinyLlama-1.1B-Chat-v1.0"

CMD ["/usr/local/bin/entrypoint.sh"]




#!/usr/bin/env bash
set -euo pipefail

# Start vLLM (CPU)
export VLLM_TARGET_DEVICE=cpu
export VLLM_DEVICE=cpu
export VLLM_USE_CUDA=0
export CUDA_VISIBLE_DEVICES=""
export VLLM_CPU_ONLY=1
export VLLM_PLATFORM=cpu
export VLLM_SKIP_PLATFORM_CHECK=1
export VLLM_USE_FLASHINFER=0
export VLLM_LOGGING_LEVEL=${VLLM_LOGGING_LEVEL:-DEBUG}
python3 -m vllm.entrypoints.openai.api_server \
  --model "${MODEL_URI:-TinyLlama/TinyLlama-1.1B-Chat-v1.0}" \
  --host 0.0.0.0 --port "${VLLM_PORT:-8000}" \
  --device cpu --dtype float32 --max-model-len 8192 \
  --attention-backend torch \
  --enforce-eager --disable-log-requests &

# Wait for vLLM to be ready
ready=0
for i in {1..60}; do
  if curl -sf "http://127.0.0.1:${VLLM_PORT:-8000}/v1/models" >/dev/null; then
    ready=1
    break
  fi
  sleep 1
done
if [ "$ready" -ne 1 ]; then
  echo "vLLM failed to start on CPU after 60s; exiting." >&2
  exit 1
fi

export VLLM_ENDPOINT="http://127.0.0.1:${VLLM_PORT:-8000}"
python3 -m uvicorn app.main:app \
  --host 0.0.0.0 --port "${GATEWAY_PORT:-8080}" --app-dir /opt/rhoim/gateway




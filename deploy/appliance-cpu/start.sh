#!/usr/bin/env bash
set -euo pipefail

# Start vLLM (CPU)
export VLLM_TARGET_DEVICE=${VLLM_TARGET_DEVICE:-cpu}
export VLLM_DEVICE=${VLLM_DEVICE:-cpu}
python3 -m vllm.entrypoints.openai.api_server \
  --model "${MODEL_URI:-TinyLlama/TinyLlama-1.1B-Chat-v1.0}" \
  --host 0.0.0.0 --port "${VLLM_PORT:-8000}" \
  --device cpu --dtype float32 --max-model-len 8192 &

# Wait for vLLM to be ready
for i in {1..60}; do
  curl -sf "http://127.0.0.1:${VLLM_PORT:-8000}/v1/models" >/dev/null && break || true
  sleep 1
done

export VLLM_ENDPOINT="http://127.0.0.1:${VLLM_PORT:-8000}"
python3 -m uvicorn app.main:app \
  --host 0.0.0.0 --port "${GATEWAY_PORT:-8080}" --app-dir /opt/rhoim/gateway




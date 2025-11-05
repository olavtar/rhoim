#!/usr/bin/env bash
set -euo pipefail
if [[ -n "${MODEL_SOURCE:-}" ]]; then
  echo "[appliance] Pulling model: ${MODEL_SOURCE} -> ${MODEL_URI:-/models/llama3-8b}"
  /opt/rhoim/bin/model_pull.sh
else
  echo "[appliance] MODEL_SOURCE not set; expecting model at ${MODEL_URI:-/models/llama3-8b}"
fi

/usr/bin/python3 -m vllm.entrypoints.openai.api_server \
  --model "${MODEL_URI:-/models/llama3-8b}" \
  --host 0.0.0.0 --port "${VLLM_PORT:-8000}" \
  --gpu-memory-utilization 0.9 --max-model-len 131072 &

for i in {1..60}; do
  curl -sf "http://127.0.0.1:${VLLM_PORT:-8000}/v1/models" >/dev/null && break || true
  sleep 1
done

export VLLM_ENDPOINT="http://127.0.0.1:${VLLM_PORT:-8000}"
/usr/bin/python3 -m uvicorn app.main:app \
  --host 0.0.0.0 --port "${GATEWAY_PORT:-8080}" --app-dir /opt/rhoim/gateway

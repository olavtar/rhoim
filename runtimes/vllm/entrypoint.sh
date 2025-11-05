#!/usr/bin/env bash
set -euo pipefail
MODEL_URI="${MODEL_URI:-/models/llama3-8b}"
PORT="${PORT:-8000}"
exec python3 -m vllm.entrypoints.openai.api_server \
  --model "${MODEL_URI}" \
  --host 0.0.0.0 --port "${PORT}" \
  --gpu-memory-utilization 0.9 \
  --max-model-len 131072

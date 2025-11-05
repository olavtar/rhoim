#!/usr/bin/env bash
set -euo pipefail

MODEL_URI="${MODEL_URI:-TinyLlama/TinyLlama-1.1B-Chat-v1.0}"
PORT="${PORT:-8000}"

exec python3 -m vllm.entrypoints.openai.api_server \
  --model "${MODEL_URI}" \
  --host 0.0.0.0 --port "${PORT}" \
  --device cpu --dtype float32 \
  --max-model-len 8192




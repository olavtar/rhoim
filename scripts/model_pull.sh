#!/usr/bin/env bash
set -euo pipefail
MODEL_SOURCE="${MODEL_SOURCE:-}"
MODEL_URI="${MODEL_URI:-/models/llama3-8b}"

if [[ -z "$MODEL_SOURCE" ]]; then
  echo "MODEL_SOURCE is empty; skipping pull. Expecting model at ${MODEL_URI}"
  exit 0
fi

mkdir -p "$MODEL_URI"

case "$MODEL_SOURCE" in
  hf://*)
    REPO="${MODEL_SOURCE#hf://}"
    command -v huggingface-cli >/dev/null || pip3 install --no-cache-dir "huggingface_hub[cli]" >/dev/null
    echo "Pulling HF repo $REPO -> $MODEL_URI"
    huggingface-cli download "$REPO" --local-dir "$MODEL_URI" --local-dir-use-symlinks False
    ;;
  s3://*)
    command -v aws >/dev/null || pip3 install --no-cache-dir awscli >/dev/null
    echo "Syncing S3 $MODEL_SOURCE -> $MODEL_URI"
    aws s3 sync "$MODEL_SOURCE" "$MODEL_URI" --no-progress
    ;;
  local:*)
    SRC="${MODEL_SOURCE#local:}"
    echo "Copying local $SRC -> $MODEL_URI"
    command -v rsync >/dev/null || (apt-get update && apt-get install -y --no-install-recommends rsync)
    rsync -a --delete "$SRC"/ "$MODEL_URI"/
    ;;
  *)
    echo "Unsupported MODEL_SOURCE: $MODEL_SOURCE"; exit 2;;
esac
echo "Model ready at $MODEL_URI"

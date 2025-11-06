# RHOIM Inference Platform – Repo Skeleton (OpenShift/K8s/off‑K8s)

A production‑ready skeleton to ship **images** using **bootc**, runnable on **OpenShift**, **vanilla Kubernetes**, and **off‑Kubernetes** (systemd), relying on **RHAIIS** for GPU enablement. Focus: help customers **transition to RHOAI**.

## Modes
- **Two‑container** (gateway + vLLM) for OCP/K8s
- **Single‑container Appliance** (gateway + vLLM in one image)
- **bootc VM image** (off‑K8s) with systemd: model‑pull → vLLM → gateway

## Quick Start (single‑container locally)
```bash
podman build -t rhoim:latest deploy/appliance-cpu
export HF_TOKEN=...   # if needed
podman run --rm -p 8080:8080 -v /srv/models:/models \\
  -e API_KEYS="devkey1,devkey2" \
  -e MODEL_SOURCE="hf://meta-llama/Meta-Llama-3-8B-Instruct" \
  -e MODEL_URI="/models/llama3-8b" \
  rhoim:latest

curl -H "Authorization: Bearer devkey1" -H 'Content-Type: application/json' \
  --data '{"model":"llama3-8b-instruct","messages":[{"role":"user","content":"hi"}]}' \
  http://localhost:8080/api/rhoai/v1/chat/completions
```

## CPU-only local quick start (no GPU, TinyLlama)
This uses a CPU-only image variant with `TinyLlama/TinyLlama-1.1B-Chat-v1.0` as default (a public model; no token required). Inspired by the vLLM CPU demo patterns in the bootc repo by Lokesh Rangineni.

```bash
# Build single appliance image locally
make build-appliance-cpu-local TAG=latest

# Run single-container (appliance) CPU image
podman run --rm -p 8080:8080 \
  -e API_KEYS="devkey1,devkey2" \
  -e MODEL_URI="TinyLlama/TinyLlama-1.1B-Chat-v1.0" \
  rhoim:latest

# Test health and chat
curl http://localhost:8080/healthz
curl -H "Authorization: Bearer devkey1" -H 'Content-Type: application/json' \
  --data '{"model":"TinyLlama/TinyLlama-1.1B-Chat-v1.0","messages":[{"role":"user","content":"hello"}]}' \
  http://localhost:8080/api/rhoai/v1/chat/completions

# Metrics
curl http://localhost:8080/metrics
```

### Build and store locally as tar (no registry)
```bash
# Build with local tag (no registry prefix)
make build-appliance-cpu-local TAG=latest

# Save tarball under ./image
make package-appliance-cpu TAG=latest

# Load on another machine (example)
podman load -i image/rhoim-latest.tar
podman run --rm -p 8080:8080 \
  -e API_KEYS="devkey1,devkey2" \
  -e MODEL_URI="TinyLlama/TinyLlama-1.1B-Chat-v1.0" \
  rhoim:latest
```

### Single-image workflow (only one image)
```bash
# Build only the single appliance image locally
make build-appliance-cpu-local TAG=latest

# Optionally package only that one image
make package-appliance-cpu TAG=latest

# Run it
podman run --rm -p 8080:8080 \
  -e API_KEYS="devkey1,devkey2" \
  -e MODEL_URI="TinyLlama/TinyLlama-1.1B-Chat-v1.0" \
  rhoim:latest
```

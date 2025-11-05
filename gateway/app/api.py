import time, httpx
from fastapi import APIRouter, Depends, Header, HTTPException, Request
from fastapi.responses import StreamingResponse, ORJSONResponse
from .openai_schemas import ChatRequest
from .settings import settings
from .metrics import REQUESTS, LATENCY, TOKENS

router = APIRouter()

def authenticate(authorization: str | None = Header(default=None)):
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="Missing bearer token")
    token = authorization.split(" ", 1)[1].strip()
    if token not in settings.api_keys:
        raise HTTPException(status_code=403, detail="Invalid API key")

@router.get("/healthz")
async def healthz():
    return {"status": "ok"}

async def _proxy_chat(req: ChatRequest, request: Request):
    start = time.time()
    url = f"{settings.vllm_endpoint}/v1/chat/completions"
    payload = req.model_dump(exclude_none=True)
    route_label = "/v1/chat/completions"
    k8s_ns = request.headers.get("X-Kubernetes-Namespace", "")
    rh_project = request.headers.get("X-RHOAI-Project", "")

    async with httpx.AsyncClient(timeout=120) as client:
        # vLLM supports SSE when stream=true
        r = await client.post(url, json=payload, headers={"Content-Type":"application/json"})
        REQUESTS.labels(route_label, r.status_code, req.model, k8s_ns, rh_project).inc()
        LATENCY.labels(route_label, req.model).observe(time.time()-start)
        if req.stream:
            async def _iter():
                async for chunk in r.aiter_raw():
                    yield chunk
            return StreamingResponse(_iter(), media_type="text/event-stream")
        data = r.json()
        usage = data.get("usage", {})
        total_tokens = usage.get("total_tokens")
        try:
            if isinstance(total_tokens, int):
                TOKENS.labels(req.model).observe(total_tokens)
        except Exception:
            pass
        return ORJSONResponse(data, status_code=r.status_code)

@router.post("/v1/chat/completions")
async def chat(req: ChatRequest, _=Depends(authenticate), request: Request = None):
    return await _proxy_chat(req, request)

@router.post("/api/rhoai/v1/chat/completions")
async def chat_rhoai(req: ChatRequest, _=Depends(authenticate), request: Request = None):
    return await _proxy_chat(req, request)

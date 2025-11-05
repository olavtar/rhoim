from prometheus_client import Counter, Histogram

REQUESTS = Counter(
    "rhoim_requests_total",
    "Total requests",
    ["route", "status_code", "model_name", "kubernetes_namespace", "rh_project"]
)
LATENCY = Histogram(
    "rhoim_latency_seconds",
    "Request latency seconds",
    ["route", "model_name"]
)
TOKENS = Histogram(
    "rhoim_tokens",
    "Generated tokens per request",
    ["model_name"]
)

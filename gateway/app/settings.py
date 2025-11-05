import os
from pydantic import BaseModel
from typing import List

class Settings(BaseModel):
    api_keys_csv: str = "devkey1,devkey2"
    vllm_endpoint: str = "http://rhoim-vllm:8000"
    base_path: str = "/"
    enable_rhoai_alias: bool = True

    @property
    def api_keys(self) -> List[str]:
        return [k.strip() for k in self.api_keys_csv.split(",") if k.strip()]

settings = Settings(
    api_keys_csv=os.getenv("API_KEYS", "devkey1,devkey2"),
    vllm_endpoint=os.getenv("VLLM_ENDPOINT", "http://rhoim-vllm:8000"),
    base_path=os.getenv("BASE_PATH", "/"),
    enable_rhoai_alias=os.getenv("ENABLE_RHOAI_ALIAS", "true").lower() in ("1","true","yes"),
)

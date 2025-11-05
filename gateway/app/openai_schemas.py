from pydantic import BaseModel, Field
from typing import List, Optional, Literal, Union, Any

Role = Literal["system", "user", "assistant", "tool"]

class Message(BaseModel):
    role: Role
    content: Union[str, List[dict]]

class ChatRequest(BaseModel):
    model: str
    messages: List[Message]
    stream: Optional[bool] = False
    temperature: Optional[float] = None
    max_tokens: Optional[int] = None
    top_p: Optional[float] = None
    stop: Optional[Union[str, List[str]]] = None

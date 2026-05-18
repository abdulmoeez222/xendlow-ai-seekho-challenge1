from pydantic import BaseModel
from typing import Optional, List, Any
import uuid


class NormalizedJson(BaseModel):
    entities: List[str] = []
    numbers: List[Any] = []
    dates: List[str] = []
    keywords: List[str] = []
    summary: str = ""


class Signal(BaseModel):
    id: Optional[str] = None
    source_type: str
    raw_content: Optional[str] = None
    normalized_json: Optional[NormalizedJson] = None

from pydantic import BaseModel
from typing import Optional, List
import uuid


class InsightReport(BaseModel):
    id: Optional[str] = None
    signal_ids: Optional[List[str]] = None
    primary_insight: str
    causal_chain: str
    severity_score: float
    affected_domains: List[str] = []

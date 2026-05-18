from pydantic import BaseModel
from typing import Optional, List, Any, Dict


class ActionTaken(BaseModel):
    type: str
    table: str
    row_id: str
    status: str


class StateSnapshot(BaseModel):
    campaigns_count: int
    last_pricing: float
    notifications_count: int


class ExecutionLog(BaseModel):
    id: Optional[str] = None
    plan_id: Optional[str] = None
    actions_taken: List[Any] = []
    before_snapshot: Optional[Dict] = None
    after_snapshot: Optional[Dict] = None
    status: str = "complete"

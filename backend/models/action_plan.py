from pydantic import BaseModel
from typing import Optional, List, Any, Dict


class FallbackAction(BaseModel):
    action: str
    trigger: str


class ActionPlan(BaseModel):
    id: Optional[str] = None
    insight_id: Optional[str] = None
    selected_action: str
    reasoning: str
    parameters: Dict[str, Any] = {}
    fallback_actions: List[Any] = []

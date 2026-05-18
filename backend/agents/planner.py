from routers.plan import plan_logic

class PlannerAgent:
    """Agent responsible for selecting the optimal execution strategy based on insights."""
    
    @staticmethod
    async def run(insight: dict, run_id: str = None) -> dict:
        plan = await plan_logic(insight_id=insight["id"], insight=insight, run_id=run_id)
        return plan

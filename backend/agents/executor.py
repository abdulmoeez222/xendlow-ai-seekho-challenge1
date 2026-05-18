from routers.execute import execute_logic

class ExecutorAgent:
    """Agent responsible for committing the plan to the real world (DB/Realtime)."""
    
    @staticmethod
    async def run(plan: dict) -> dict:
        execution_log = await execute_logic(plan_id=plan["id"], plan=plan)
        return execution_log

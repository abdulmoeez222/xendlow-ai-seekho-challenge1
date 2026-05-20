import time
from datetime import datetime, timezone
from services.supabase_client import get_supabase
from agents.ingestor import IngestorAgent
from agents.analyst import AnalystAgent
from agents.planner import PlannerAgent
from agents.executor import ExecutorAgent
from agents.reporter import ReporterAgent

class InsightEngine:
    """Master orchestrator for the Antigravity 5-Agent pipeline with HITL support."""
    
    def __init__(self, scenario: dict, run_id: str):
        self.scenario = scenario
        self.run_id = run_id
        self.db = get_supabase()
        
    async def run(self) -> dict:
        """Helper to run the full pipeline in one go (fallback or backwards compatibility)."""
        await self.run_phase1()
        return await self.run_phase2(self.run_id, approved=True)
        
    async def run_phase1(self) -> dict:
        """Executes Phase 1: Ingestor -> Analyst -> Planner agents.
        Hhalts the pipeline and sets status to pending_approval.
        """
        # 1. Ingestor Agent
        all_signals = await IngestorAgent.run(self.scenario["input_signals"])
        
        # 2. Analyst Agent
        insight = await AnalystAgent.run(all_signals)
        
        # 3. Planner Agent
        plan = await PlannerAgent.run(insight, self.run_id)
        
        # Update pipeline state for UI Stepper
        self.db.table("pipeline_runs").upsert({
            "plan_id": self.run_id,
            "status": "pending_approval",
            "signals_json": all_signals,
            "insight_json": insight,
            "action_plan_json": plan,
        }).execute()
        
        return plan

    @classmethod
    async def run_phase2(cls, plan_id: str, approved: bool = True) -> dict:
        """Executes Phase 2: Executor -> Reporter agents upon approval."""
        db = get_supabase()
        
        # Fetch the run state
        run_data = db.table("pipeline_runs").select("*").eq("plan_id", plan_id).maybe_single().execute().data
        if not run_data:
            raise ValueError(f"Pipeline run {plan_id} not found")
            
        if not approved:
            db.table("pipeline_runs").upsert({
                "plan_id": plan_id,
                "status": "rejected",
            }).execute()
            return {"status": "rejected"}
            
        # Set status to approved/executing
        db.table("pipeline_runs").upsert({
            "plan_id": plan_id,
            "status": "approved",
        }).execute()
        
        insight = run_data.get("insight_json")
        plan = run_data.get("action_plan_json")
        
        # 4. Executor Agent
        execution_log = await ExecutorAgent.run(plan)
        
        db.table("pipeline_runs").upsert({
            "plan_id": plan_id,
            "status": "reporting",
            "execution_log_json": execution_log,
        }).execute()
        
        # Calculate elapsed time from creation
        created_at_str = run_data.get("created_at")
        try:
            dt_str = created_at_str.replace('Z', '+00:00')
            created_at = datetime.fromisoformat(dt_str)
            elapsed_ms = int((datetime.now(timezone.utc) - created_at).total_seconds() * 1000)
        except Exception:
            elapsed_ms = 4200
            
        # 5. Reporter Agent
        report = ReporterAgent.run(insight, plan, execution_log, elapsed_ms)
        
        # Final pipeline state
        db.table("pipeline_runs").upsert({
            "plan_id": plan_id,
            "status": "complete",
            "report_json": report,
        }).execute()
        
        return report


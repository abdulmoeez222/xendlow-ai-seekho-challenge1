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
        Writes results to pipeline_runs incrementally after each agent so the
        mobile UI stepper advances in real-time. Sets status='failed' on any
        unhandled exception so the UI never hangs indefinitely.
        """
        try:
            # 1. Ingestor Agent — write signals immediately so UI can advance step 1
            all_signals = await IngestorAgent.run(self.scenario["input_signals"])
            self.db.table("pipeline_runs").update({
                "signals_json": all_signals,
            }).eq("plan_id", self.run_id).execute()
            print(f"[ORCHESTRATOR] Ingestor complete — {len(all_signals)} signal(s) stored.")

            # 2. Analyst Agent — write insight so UI can advance step 2
            insight = await AnalystAgent.run(all_signals)
            self.db.table("pipeline_runs").update({
                "insight_json": insight,
            }).eq("plan_id", self.run_id).execute()
            print(f"[ORCHESTRATOR] Analyst complete — insight id={insight.get('id')}")

            # 3. Planner Agent — write plan and flip to pending_approval so HITL gate opens
            plan = await PlannerAgent.run(insight, self.run_id)
            self.db.table("pipeline_runs").update({
                "status": "pending_approval",
                "action_plan_json": plan,
            }).eq("plan_id", self.run_id).execute()
            print(f"[ORCHESTRATOR] Planner complete — action={plan.get('selected_action')}. Awaiting operator approval.")

            return plan

        except Exception as e:
            import traceback
            print(f"[ORCHESTRATOR] *** Phase 1 FAILED *** {e}")
            traceback.print_exc()
            # Mark the run as failed so the UI can stop polling and display an error
            try:
                self.db.table("pipeline_runs").update({
                    "status": "failed",
                    "report_json": {
                        "error": str(e),
                        "message": "Phase 1 pipeline failed. Check server logs for details.",
                    },
                }).eq("plan_id", self.run_id).execute()
            except Exception as db_err:
                print(f"[ORCHESTRATOR] Could not write failure status to DB: {db_err}")
            raise

    @classmethod
    async def run_phase2(cls, plan_id: str, approved: bool = True) -> dict:
        """Executes Phase 2: Executor -> Reporter agents upon approval."""
        db = get_supabase()
        
        # Fetch the run state
        run_data = db.table("pipeline_runs").select("*").eq("plan_id", plan_id).maybe_single().execute().data
        if not run_data:
            raise ValueError(f"Pipeline run {plan_id} not found")
            
        if not approved:
            db.table("pipeline_runs").update({
                "status": "rejected",
            }).eq("plan_id", plan_id).execute()
            return {"status": "rejected"}
            
        # Set status to approved/executing
        db.table("pipeline_runs").update({
            "status": "approved",
        }).eq("plan_id", plan_id).execute()
        
        insight = run_data.get("insight_json")
        plan = run_data.get("action_plan_json")
        
        # 4. Executor Agent
        execution_log = await ExecutorAgent.run(plan)
        
        db.table("pipeline_runs").update({
            "status": "reporting",
            "execution_log_json": execution_log,
        }).eq("plan_id", plan_id).execute()
        
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
        db.table("pipeline_runs").update({
            "status": "complete",
            "report_json": report,
        }).eq("plan_id", plan_id).execute()
        
        return report


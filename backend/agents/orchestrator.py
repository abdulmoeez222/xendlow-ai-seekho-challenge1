import time
from services.supabase_client import get_supabase
from agents.ingestor import IngestorAgent
from agents.analyst import AnalystAgent
from agents.planner import PlannerAgent
from agents.executor import ExecutorAgent
from agents.reporter import ReporterAgent

class InsightEngine:
    """Master orchestrator for the Antigravity 5-Agent pipeline."""
    
    def __init__(self, scenario: dict, run_id: str):
        self.scenario = scenario
        self.run_id = run_id
        self.db = get_supabase()
        self.start_time = time.time()
        
    async def run(self) -> dict:
        """Executes the strict 5-agent pipeline."""
        
        # 1. Ingestor Agent
        all_signals = await IngestorAgent.run(self.scenario["input_signals"])
        
        # 2. Analyst Agent
        insight = await AnalystAgent.run(all_signals)
        
        # 3. Planner Agent
        plan = await PlannerAgent.run(insight, self.run_id)
        
        # Update pipeline state for UI Stepper
        self.db.table("pipeline_runs").upsert({
            "plan_id": self.run_id,
            "status": "running",
            "signals_json": all_signals,
            "insight_json": insight,
            "action_plan_json": plan,
        }).execute()
        
        # 4. Executor Agent
        execution_log = await ExecutorAgent.run(plan)
        
        self.db.table("pipeline_runs").upsert({
            "plan_id": self.run_id,
            "status": "reporting",
            "execution_log_json": execution_log,
        }).execute()
        
        # 5. Reporter Agent
        elapsed_ms = int((time.time() - self.start_time) * 1000)
        report = ReporterAgent.run(insight, plan, execution_log, elapsed_ms)
        
        # Final pipeline state
        self.db.table("pipeline_runs").upsert({
            "plan_id": self.run_id,
            "status": "complete",
            "report_json": report,
        }).execute()
        
        return report

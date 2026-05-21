import os
import sys
import asyncio
from dotenv import load_dotenv

# Add backend directory to sys.path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'backend'))

load_dotenv(os.path.join(os.path.dirname(__file__), '..', 'backend', '.env'))

from services.supabase_client import get_supabase
from agents.orchestrator import InsightEngine

async def run_test():
    db = get_supabase()
    # Fetch scenario 1
    scenario_resp = db.table("scenarios").select("*").eq("id", 1).maybe_single().execute()
    if not scenario_resp.data:
        print("Scenario 1 not found in database!")
        return
    
    scenario = scenario_resp.data
    run_id = "test-run-id-12345"
    print(f"Running Phase 1 for scenario: {scenario['name']}...")
    
    engine = InsightEngine(scenario, run_id)
    try:
        plan = await engine.run_phase1()
        print("SUCCESS! Phase 1 completed successfully.")
        print("Plan:", plan)
    except Exception as e:
        print("ERROR occurred during run_phase1:")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(run_test())

import uuid
from fastapi import APIRouter, HTTPException, BackgroundTasks
from services.supabase_client import get_supabase
from agents.orchestrator import InsightEngine

router = APIRouter()


@router.get("/scenarios")
def list_scenarios():
    rows = get_supabase().table("scenarios").select("*").order("id").execute()
    return rows.data


@router.post("/run-scenario/{scenario_id}")
async def run_scenario(scenario_id: int, background_tasks: BackgroundTasks):
    db = get_supabase()

    # 1. Fetch scenario
    scenario_resp = (
        db.table("scenarios")
        .select("*")
        .eq("id", scenario_id)
        .maybe_single()
        .execute()
    )
    if not scenario_resp.data:
        raise HTTPException(status_code=404, detail=f"Scenario {scenario_id} not found")
    scenario = scenario_resp.data

    # 2. Generate tracking ID for UI Stepper
    run_id = str(uuid.uuid4())

    # 3. Run the pipeline via the 5-Agent Orchestrator (Phase 1) in the background
    engine = InsightEngine(scenario, run_id)
    background_tasks.add_task(engine.run_phase1)

    return {"plan_id": run_id}


@router.post("/run-custom")
async def run_custom(body: dict, background_tasks: BackgroundTasks):
    run_id = str(uuid.uuid4())
    scenario = {
        "id": 999,
        "name": "Custom Live Scenario",
        "description": "User-provided custom signals.",
        "input_signals": body.get("signals", [])
    }
    
    engine = InsightEngine(scenario, run_id)
    background_tasks.add_task(engine.run_phase1)

    return {"plan_id": run_id}


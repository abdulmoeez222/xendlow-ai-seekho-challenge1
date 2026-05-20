from fastapi import APIRouter, HTTPException
from services.supabase_client import get_supabase
from routers.execute import _state_snapshot

router = APIRouter()


@router.get("/state/before")
def state_before():
    return _state_snapshot()


@router.get("/state/after/{plan_id}")
def state_after(plan_id: str):
    try:
        log = (
            get_supabase()
            .table("execution_logs")
            .select("after_snapshot")
            .eq("plan_id", plan_id)
            .maybe_single()
            .execute()
        )
        if log and log.data and log.data.get("after_snapshot"):
            return log.data["after_snapshot"]
    except Exception:
        pass
    # Fallback: return current live state
    return _state_snapshot()


@router.get("/logs/{plan_id}")
def get_logs(plan_id: str):
    run = (
        get_supabase()
        .table("pipeline_runs")
        .select("*")
        .eq("plan_id", plan_id)
        .maybe_single()
        .execute()
    )
    if run is None or not run.data:
        return {"plan_id": plan_id, "status": "not_found"}

    r = run.data
    resp = {"plan_id": plan_id, "status": r["status"]}
    if r.get("signals_json"):       resp["signals"]        = r["signals_json"]
    if r.get("insight_json"):       resp["insight_report"]  = r["insight_json"]
    if r.get("action_plan_json"):   resp["action_plan"]    = r["action_plan_json"]
    if r.get("execution_log_json"): resp["execution_log"]  = r["execution_log_json"]
    if r.get("report_json"):        resp["final_report"]   = r["report_json"]
    return resp

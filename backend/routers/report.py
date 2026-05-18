from fastapi import APIRouter
from services.supabase_client import get_supabase

router = APIRouter()


def build_report_object(insight: dict, plan: dict, execution_log: dict, elapsed_ms: int = 4200) -> dict:
    """Assemble a FinalReport from the pipeline artifacts.
    Shared by POST /report and POST /run-scenario.
    """
    reach = plan.get("parameters", {}).get("projected_reach", 50000)
    discount = plan.get("parameters", {}).get("discount_pct", 15)
    avg_order_pkr = 12000    # PKR, reasonable for electronics retail
    conversion_rate = 0.04   # 4% — conservative for discount campaign
    raw_recovery = reach * conversion_rate * avg_order_pkr
    recovery = int(min(raw_recovery, 50_000_000))  # Hard cap at PKR 50M
    return {
        "insight":                    insight.get("primary_insight", ""),
        "causal_chain":               insight.get("causal_chain", ""),
        "severity":                   insight.get("severity_score", 0),
        "selected_action":            plan.get("selected_action", ""),
        "reasoning":                  plan.get("reasoning", ""),
        "simulations_executed":       len(execution_log.get("actions_taken", [])),
        "projected_revenue_recovery": f"PKR {recovery:,}",
        "projected_reach":            reach,
        "execution_time_ms":          elapsed_ms,
        "before_state":               execution_log.get("before_snapshot", {}),
        "after_state":                execution_log.get("after_snapshot", {}),
        "actions_detail":             execution_log.get("actions_taken", []),
    }


@router.post("/report")
def generate_report(body: dict):
    execution_id = body["execution_id"]
    insight_id   = body["insight_id"]
    db = get_supabase()

    log     = db.table("execution_logs").select("*").eq("id", execution_id).single().execute().data
    insight = db.table("insight_reports").select("*").eq("id", insight_id).single().execute().data
    plan    = db.table("action_plans").select("*").eq("id", log["plan_id"]).single().execute().data

    report = build_report_object(insight, plan, log)

    # Mark pipeline_run complete with the report
    db.table("pipeline_runs").upsert({
        "plan_id": log["plan_id"],
        "status": "complete",
        "report_json": report,
    }).execute()

    return report

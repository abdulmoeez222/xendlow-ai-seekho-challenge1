from fastapi import APIRouter
from services.supabase_client import get_supabase

router = APIRouter()


def build_report_object(insight: dict, plan: dict, execution_log: dict, elapsed_ms: int = 4200) -> dict:
    """Assemble a FinalReport from the pipeline artifacts.
    Shared by POST /report and POST /run-scenario.
    """
    action_type = plan.get('action_type', 'campaign')
    params = plan.get('parameters', {})

    if action_type == 'notification':
        reach = params.get('recipient_count', 20)
        revenue_at_risk = params.get('revenue_at_risk', None)
        if revenue_at_risk:
            recovery_str = f"PKR {revenue_at_risk} protected"
        else:
            recovery_str = "Escalated to management"

    elif action_type == 'pricing':
        reach = params.get('projected_reach', 500)
        margin_recovery = params.get('margin_recovery', None)
        recovery_str = f"PKR {margin_recovery}" if margin_recovery else "Margin stabilized"

    else:  # campaign
        reach = params.get('projected_reach', 5000)
        recovery_str = f"PKR {reach * 240:,}"
    return {
        "insight":                    insight.get("primary_insight", ""),
        "causal_chain":               insight.get("causal_chain", ""),
        "severity":                   insight.get("severity_score", 0),
        "selected_action":            plan.get("selected_action", ""),
        "reasoning":                  plan.get("reasoning", ""),
        "simulations_executed":       len(execution_log.get("actions_taken", [])),
        "projected_revenue_recovery": recovery_str,
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

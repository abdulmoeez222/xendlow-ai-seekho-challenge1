import json
from fastapi import APIRouter
from services.supabase_client import get_supabase
from services.gemini_client import generate

router = APIRouter()


async def plan_logic(insight_id: str, insight: dict, run_id: str = None) -> dict:
    """Core plan logic — callable from /plan and /run-scenario."""

    prompt = f"""
You are an autonomous business decision agent.
You receive an InsightReport and COMMIT to one action. Not a list. Not options. One decision.

INSIGHT REPORT:
{json.dumps(insight, indent=2)}

Rules:
1. Generate 3 candidate actions internally
2. Score each: urgency x feasibility x impact (1-10 each)
3. Select the highest-scoring one — you commit to this
4. Write 2-3 sentences: why this action over the other two. Reference specific numbers (costs, percentages, capacity figures, fees like PKR 85,000 overage). Write your reasoning entirely in your own words. Never quote from the InsightReport using quotation marks. Explain the situation as if briefing a board member who has not read the report.
5. Define one fallback with a specific measurable trigger condition

CONSTRAINT CHECK (mandatory before selecting):
Before committing to an action, verify:
- If signals mention supplier delays or extended lead times → NEVER select reorder
- If signals mention inventory surplus or warehouse at >80% capacity → NEVER select reorder  
- If signals mention margin compression or currency devaluation → NEVER select campaign/discount
State which constraints you checked and why your action passes all of them.

Available action types:
  campaign:     regional discount (params: region, discount_pct, duration_days, projected_reach)
  pricing:      cost update (params: item_name, before_value, after_value)
  reorder:      supplier order (params: supplier, sku_count, urgency_days)
  notification: alert (params: channel, recipient_count, message_summary)

IMPORTANT RULES:
- For projected_reach, estimate a realistic number based on the region population and campaign scope. Do NOT default to 5000.
- Always include "region" in parameters, derived from the signals. If signals mention a specific city (Karachi, Lahore, etc.), that city is the region. If no city is mentioned, use "National".
- ALL action types must include a region parameter.

Return JSON only, no markdown fences:
{{
  "selected_action": "short action name",
  "action_type": "campaign|pricing|reorder|notification",
  "reasoning": "why this action beats the alternatives — cite specific numbers",
  "parameters": {{ "region": "Lahore", "discount_pct": 15, "duration_days": 14, "projected_reach": 50000 }},
  "fallback_actions": [{{"action": "...", "trigger": "specific measurable condition"}}]
}}
"""
    try:
        raw = generate(prompt, is_json=True, temperature=0.2)
        clean = raw.strip().replace("```json", "").replace("```", "").strip()
        result = json.loads(clean)
    except Exception as e:
        print(f"Gemini Plan Error: {e}")
        try:
            print(f"Raw output: {raw}")
        except:
            pass
        result = {
            "selected_action": "Launch regional discount campaign",
            "action_type": "campaign",
            "reasoning": "Default fallback — Gemini parse failed.",
            "parameters": {"region": "National", "discount_pct": 15, "duration_days": 14, "projected_reach": 50000},
            "fallback_actions": [{"action": "Update delivery pricing", "trigger": "if campaign ROI < 20% in 72h"}],
        }

    insert_data = {
        "insight_id": insight_id,
        "selected_action": result.get("selected_action", ""),
        "reasoning": result.get("reasoning", ""),
        "parameters": result.get("parameters", {}),
        "fallback_actions": result.get("fallback_actions", []),
    }
    
    if run_id:
        insert_data["id"] = run_id

    row = (
        get_supabase()
        .table("action_plans")
        .insert(insert_data)
        .execute()
        .data[0]
    )

    return row


@router.post("/plan")
async def plan(body: dict):
    insight_id = body.get("insight_id", "")
    insight = body.get("insight", {})
    return await plan_logic(insight_id=insight_id, insight=insight)

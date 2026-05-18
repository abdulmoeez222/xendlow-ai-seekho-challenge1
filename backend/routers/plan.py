import json
from fastapi import APIRouter
from services.supabase_client import get_supabase
from services.gemini_client import generate

router = APIRouter()


def extract_json_from_gemini(response_text: str) -> dict:
    """
    Gemini sometimes wraps JSON in markdown fences or adds preamble.
    This strips all of that and finds the raw JSON object.
    """
    import re, json

    text = response_text.strip()

    # Strip markdown code fences if present
    # Handles ```json ... ``` and ``` ... ```
    fenced = re.search(r'```(?:json)?\s*([\s\S]*?)```', text)
    if fenced:
        text = fenced.group(1).strip()

    # If still not starting with {, find the first { 
    if not text.startswith('{'):
        brace_start = text.find('{')
        if brace_start != -1:
            text = text[brace_start:]

    # Find matching closing brace (handles nested objects)
    depth = 0
    end_idx = -1
    for i, ch in enumerate(text):
        if ch == '{':
            depth += 1
        elif ch == '}':
            depth -= 1
            if depth == 0:
                end_idx = i + 1
                break

    if end_idx > 0:
        text = text[:end_idx]

    return json.loads(text)


async def plan_logic(insight_id: str, insight: dict, run_id: str = None) -> dict:
    """Core plan logic — callable from /plan and /run-scenario."""

    prompt = f"""
CRITICAL OUTPUT RULES:
- Respond with ONLY a raw JSON object.
- Do NOT wrap in markdown code fences.
- Do NOT add any text before or after the JSON.
- Do NOT add explanatory paragraphs.
- Your entire response must start with {{ and end with }}
- The JSON must include the field "action_type" set to one of:
  "campaign" | "pricing" | "notification" | "negotiation"

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
- If signals mention a client discount request with penalty clauses → PREFER negotiation
  over campaign. Accepting a discount request is not a campaign action.
State which constraints you checked and why your action passes all of them.

Available action types:
  campaign:     regional discount (params: region, discount_pct, duration_days, projected_reach)
  pricing:      cost update (params: item_name, before_value, after_value)
  reorder:      supplier order (params: supplier, sku_count, urgency_days)
  notification: alert (params: channel, recipient_count, message_summary)
  negotiation: Use when the optimal response involves direct client communication,
      counter-offers, contract renegotiation, or rejecting a client request while
      preserving the relationship. Parameters: client_name, current_offer, counter_offer,
      rationale, contact_channel, urgency_hours.
      Example: Ayesha Weddings requests 20% discount → counter with 10% + service upgrade
      instead of accepting full discount or risking cancellation.

IMPORTANT RULES:
- For projected_reach, estimate a realistic number based on the region population and campaign scope. Do NOT default to 5000.
- Always include "region" in parameters, derived from the signals. If signals mention a specific city (Karachi, Lahore, etc.), that city is the region. If no city is mentioned, use "National".
- ALL action types must include a region parameter.

Return JSON only, no markdown fences:
{{
  "selected_action": "short action name",
  "action_type": one of "campaign" | "pricing" | "notification" | "negotiation"
  
  Rules for selection:
  - campaign: when the action is a customer-facing discount or promotion
  - pricing: when the action is adjusting product/service prices
  - notification: when the action is an internal alert to staff
  - negotiation: when the action involves direct client/vendor communication,
                 counter-offers, or relationship management
                 
  "reasoning": "why this action beats the alternatives — cite specific numbers",
  "parameters": {{ "region": "Lahore", "discount_pct": 15, "duration_days": 14, "projected_reach": 50000 }},
  "fallback_actions": [{{"action": "...", "trigger": "specific measurable condition"}}]
}}
"""
    try:
        raw = generate(prompt, is_json=True, temperature=0.2)
        print(f"[PLANNER RAW] First 500 chars: {raw[:500]}")
        result = extract_json_from_gemini(raw)
    except Exception as e:
        print(f"[PLANNER PARSE ERROR] Raw response: {raw}")
        print(f"[PLANNER PARSE ERROR] Exception: {e}")
        raise  # Don't silently fall back — surface the error

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

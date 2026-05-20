import json
import re
from fastapi import APIRouter
from services.supabase_client import get_supabase
from services.gemini_client import generate

router = APIRouter()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# UTILITY — Robust JSON extraction from Gemini responses
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def extract_json_from_gemini(response_text: str) -> dict:
    """
    Gemini sometimes wraps JSON in markdown fences or adds preamble.
    This strips all of that and finds the raw JSON object.
    """
    text = response_text.strip()

    # Strip markdown code fences if present
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


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# IMPROVEMENT #1 — DATA GROUNDING
# Query real business tables so the Planner can calculate actual margins,
# stock impacts, and budget feasibility instead of guessing.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def fetch_planner_context() -> str:
    """Fetch compact business context for data-grounded planning."""
    db = get_supabase()
    sections = []

    # Products — prices, margins, stock
    try:
        rows = db.table("shopify_products") \
            .select("sku, name, current_price, cost_of_goods, profit_margin, stock_level, status") \
            .limit(10).execute()
        if rows.data:
            total_stock = sum(p["stock_level"] for p in rows.data)
            avg_margin = round(sum(p["profit_margin"] for p in rows.data) / len(rows.data), 1)
            at_risk = [p for p in rows.data if p["stock_level"] < 20 or p["profit_margin"] < 15]
            lines = [f"  {p['sku']}: {p['name']} | PKR {p['current_price']} | margin {p['profit_margin']}% | stock {p['stock_level']}"
                     for p in rows.data]
            sections.append(
                f"PRODUCT CATALOG ({len(rows.data)} items, total stock {total_stock}, avg margin {avg_margin}%):\n"
                + "\n".join(lines)
                + (f"\n  ⚠ AT-RISK ITEMS: {[p['sku'] for p in at_risk]}" if at_risk else "")
            )
    except Exception:
        pass

    # Competitor prices
    try:
        rows = db.table("competitor_prices") \
            .select("product_name, competitor_name, price") \
            .limit(10).execute()
        if rows.data:
            lines = [f"  {c['product_name']} — {c['competitor_name']}: PKR {c['price']}" for c in rows.data]
            sections.append("COMPETITOR PRICES:\n" + "\n".join(lines))
    except Exception:
        pass

    # Active campaigns — budget awareness
    try:
        rows = db.table("marketing_campaigns") \
            .select("campaign_name, network, spend, clicks, conversions, roas, active") \
            .limit(10).execute()
        if rows.data:
            total_spend = sum(c["spend"] for c in rows.data)
            avg_roas = round(sum(c["roas"] for c in rows.data) / len(rows.data), 2)
            lines = [f"  {c['campaign_name']} ({c['network']}): spend PKR {c['spend']}, ROAS {c['roas']}x, {'ACTIVE' if c['active'] else 'PAUSED'}"
                     for c in rows.data]
            sections.append(
                f"MARKETING CAMPAIGNS (total spend PKR {total_spend:,}, avg ROAS {avg_roas}x):\n"
                + "\n".join(lines)
            )
    except Exception:
        pass

    # Logistics
    try:
        rows = db.table("logistics_rates") \
            .select("city, carrier, base_shipping_fee") \
            .limit(10).execute()
        if rows.data:
            lines = [f"  {l['city']} via {l['carrier']}: PKR {l['base_shipping_fee']}" for l in rows.data]
            sections.append("LOGISTICS RATES:\n" + "\n".join(lines))
    except Exception:
        pass

    return "\n\n".join(sections) if sections else "No business context available."


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# IMPROVEMENT #2 — EPISODIC MEMORY (already existed, kept and cleaned up)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def fetch_episodic_memory() -> str:
    """Fetch last 5 completed pipeline runs as compressed one-liners."""
    try:
        db = get_supabase()
        runs = db.table("pipeline_runs") \
            .select("status, action_plan_json, report_json") \
            .eq("status", "complete") \
            .order("updated_at", desc=True) \
            .limit(5).execute()

        lines = []
        for i, r in enumerate(runs.data or []):
            p = r.get("action_plan_json") or {}
            rep = r.get("report_json") or {}
            action = p.get("selected_action", "Unknown")
            outcome = rep.get("projected_revenue_recovery", "Unknown")
            lines.append(f"[Run #{i+1}] Action: {action} | Status: COMPLETE | Recovery: {outcome}")

        return "\n".join(lines) if lines else "No past execution memory available."
    except Exception as e:
        print(f"[PLANNER] Memory fetch error: {e}")
        return "No past execution memory available."


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# IMPROVEMENT #3 — CODE-ENFORCED CONSTRAINTS
# After the LLM returns an action, Python validates it against the insight.
# If it violates a hard rule, we re-prompt with the violation flagged.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def check_constraints(result: dict, insight: dict) -> str | None:
    """
    Returns a violation message if the plan breaks a hard constraint.
    Returns None if all constraints pass.
    """
    action_type = result.get("action_type", "")
    insight_text = json.dumps(insight).lower()

    # RULE 1: Never reorder during supplier delays
    if action_type == "reorder":
        delay_keywords = ["supplier delay", "lead time", "shipping delay", "logistics disruption"]
        for kw in delay_keywords:
            if kw in insight_text:
                return f"VIOLATION: action_type='reorder' selected but insight mentions '{kw}'. Reordering during supply disruptions is forbidden."

    # RULE 2: Never reorder when inventory surplus / warehouse > 80%
    if action_type == "reorder":
        surplus_keywords = ["inventory surplus", "overstocked", "warehouse at", "excess stock"]
        for kw in surplus_keywords:
            if kw in insight_text:
                return f"VIOLATION: action_type='reorder' selected but insight mentions '{kw}'. Cannot reorder into an overstocked warehouse."

    # RULE 3: Never run discount campaign during margin compression
    if action_type == "campaign":
        margin_keywords = ["margin compression", "currency devaluation", "cost increase", "margin erosion"]
        for kw in margin_keywords:
            if kw in insight_text:
                return f"VIOLATION: action_type='campaign' (discount) selected but insight mentions '{kw}'. Discounting during margin pressure is forbidden."

    # RULE 4: Prefer negotiation over campaign for client discount requests
    if action_type == "campaign":
        negotiation_keywords = ["penalty clause", "cancellation fee", "client request", "discount request"]
        matches = [kw for kw in negotiation_keywords if kw in insight_text]
        if len(matches) >= 2:
            return f"VIOLATION: action_type='campaign' selected but insight contains {matches}. This situation calls for 'negotiation', not a blanket campaign."

    # RULE 5: Parameters must include region
    if "region" not in result.get("parameters", {}):
        return "VIOLATION: 'region' is missing from parameters. All action types must include a region."

    return None  # All constraints pass


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# IMPROVEMENT #4 — RISK ASSESSMENT
# Added to the output schema: risk_score, best_case, worst_case, reversibility
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# (Integrated directly into the prompt below)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CORE PLANNING LOGIC
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def check_resource_limits(candidate: dict) -> tuple[bool, str | None]:
    """
    Enforces budget and stock constraints programmatically in python.
    Returns (resource_fit: bool, rejection_reason: str | None).
    """
    db = get_supabase()
    action_type = candidate.get("action_type", "")
    params = candidate.get("parameters", {})

    if action_type == "campaign":
        # Check Total Marketing Budget Limit (PKR 150,000 limit)
        try:
            camp_rows = db.table("marketing_campaigns").select("spend").execute().data or []
            total_spend = sum(float(c["spend"]) for c in camp_rows)
            # Projected spend for the new campaign
            duration_days = float(params.get("duration_days", 14))
            projected_spend = duration_days * 1500.0
            if total_spend + projected_spend > 150000.0:
                return False, f"Total marketing budget exceeded (Current: PKR {total_spend:.2f}, limit: PKR 150,000)"
        except Exception as e:
            print(f"[RESOURCE CHECKER ERROR] {e}")

    if action_type in ("pricing", "campaign"):
        # Check product stock level
        item_name = params.get("item_name", "").lower()
        if item_name:
            try:
                prod_rows = db.table("shopify_products").select("name, stock_level").execute().data or []
                for p in prod_rows:
                    if p["name"].lower() in item_name or item_name in p["name"].lower():
                        if p["stock_level"] <= 0:
                            return False, f"Product '{p['name']}' is out of stock (Stock: 0). Cannot run pricing/discount actions on it."
            except Exception as e:
                print(f"[RESOURCE CHECKER ERROR] {e}")
                
    return True, None


def generate_candidates(insight: dict, business_context: str, memory_str: str) -> list:
    prompt = f"""
CRITICAL OUTPUT RULES:
- Respond with ONLY a raw JSON object matching the exact schema below.
- Do NOT wrap in markdown code fences.
- Your entire response must start with {{ and end with }}

You are an expert e-commerce business decision engine.
Analyze the following InsightReport, Episodic Memory, and Business Context, and generate exactly 3 distinct candidate action plans (Option 1, Option 2, and Option 3).
Each option should represent a different viable strategy to solve the issue (e.g. Campaign, Pricing update, Negotiation, Reorder, or Alert).

EPISODIC MEMORY:
{memory_str}

LIVE BUSINESS CONTEXT:
{business_context}

INSIGHT REPORT:
{json.dumps(insight, indent=2)}

Available action types and their parameters:
  campaign:     regional discount (params: region, discount_pct, duration_days, projected_reach)
  pricing:      cost update (params: item_name, before_value, after_value)
  reorder:      supplier order (params: supplier, sku_count, urgency_days)
  notification: alert (params: channel, recipient_count, message_summary)
  negotiation:  client/vendor communication (params: client_name, current_offer, counter_offer, contact_channel, urgency_hours)

IMPORTANT: All candidates must include a "region" parameter inside parameters.

Return JSON in this format:
{{
  "candidates": [
    {{
      "option_id": 1,
      "selected_action": "Short descriptive name of option 1",
      "action_type": "campaign | pricing | negotiation | reorder | notification",
      "parameters": {{ "region": "Lahore", ... }},
      "fallback_actions": [{{"action": "...", "trigger": "specific measurable condition"}}]
    }},
    {{
      "option_id": 2,
      "selected_action": "Short descriptive name of option 2",
      "action_type": "campaign | pricing | negotiation | reorder | notification",
      "parameters": {{ "region": "Lahore", ... }},
      "fallback_actions": [{{"action": "...", "trigger": "specific measurable condition"}}]
    }},
    {{
      "option_id": 3,
      "selected_action": "Short descriptive name of option 3",
      "action_type": "campaign | pricing | negotiation | reorder | notification",
      "parameters": {{ "region": "Lahore", ... }},
      "fallback_actions": [{{"action": "...", "trigger": "specific measurable condition"}}]
    }}
  ]
}}
"""
    raw = generate(prompt, is_json=True, temperature=0.3)
    parsed = extract_json_from_gemini(raw)
    return parsed.get("candidates") or []


def score_candidate(candidate: dict, insight: dict, business_context: str) -> dict:
    prompt = f"""
CRITICAL OUTPUT RULES:
- Respond with ONLY a raw JSON object matching the exact schema below.
- Do NOT wrap in markdown code fences.
- Your entire response must start with {{ and end with }}

You are a senior business evaluation agent.
Evaluate the viability of this proposed candidate action plan in response to the given InsightReport and Business Context.
You MUST calculate the precise financial cost/impact and profit margin changes using the numbers in the BUSINESS CONTEXT:
- If pricing or campaign: calculate unit discount amount, margin compression per unit, and total margin hit across stock levels.
- If reorder: calculate estimated supplier order cost and warehouse capacity impact.
- If negotiation: calculate cancellation penalties or penalty savings based on the insight's cancellation fees.

INSIGHT REPORT:
{json.dumps(insight, indent=2)}

BUSINESS CONTEXT:
{business_context}

PROPOSED CANDIDATE PLAN:
{json.dumps(candidate, indent=2)}

Evaluate and assign scores (1 to 10):
1. URGENCY: How critical is it to act on this option right now? (1 = low, 10 = immediate)
2. FEASIBILITY: How easy is it to execute this option without supply chain/logistical blocks? (1 = extremely difficult, 10 = instant/simple)
3. IMPACT: How effectively does this solve the problem and recover revenue/minimize loss? (1 = no impact, 10 = full resolution)

Return JSON in this format:
{{
  "urgency_score": 8,
  "feasibility_score": 9,
  "impact_score": 7,
  "reasoning": "Detailed 2-3 sentences explaining these scores. Write as if briefing a board member.",
  "cost_impact_calculation": "Explicit, step-by-step mathematical calculations showing margins, prices, or budget impacts based on real context numbers."
}}
"""
    raw = generate(prompt, is_json=True, temperature=0.2)
    return extract_json_from_gemini(raw)


async def plan_logic(insight_id: str, insight: dict, run_id: str = None) -> dict:
    """
    World-class Planner pipeline:
      1. Data Grounding             — fetch real business context from DB
      2. Episodic Memory            — last 5 completed runs
      3. Multi-path Candidates      — generate 3 separate viable strategies
      4. Programmatic Evaluation    — code-enforced resource checking (budget/stock)
      5. Independent LLM Scoring     — score candidates separately with cost/margin math
      6. Programmatic Selection     — pick winner by composite score
      7. Constraint Auto-Correction — check hard boundaries (re-prompt if needed)
      8. Critique & Self-Refinement — Senior Strategist pass with risk modeling
    """
    # ══════════════════════════════════════════════════════════════════════════
    # STEP 1 — DATA GROUNDING
    # ══════════════════════════════════════════════════════════════════════════
    business_context = fetch_planner_context()
    print(f"[PLANNER] Business context loaded ({len(business_context)} chars)")

    # ══════════════════════════════════════════════════════════════════════════
    # STEP 2 — EPISODIC MEMORY
    # ══════════════════════════════════════════════════════════════════════════
    memory_str = fetch_episodic_memory()

    # ══════════════════════════════════════════════════════════════════════════
    # STEP 3 & 4 & 5 & 6 — PROGRAMMATIC MULTI-PATH CANDIDATE ORCHESTRATION
    # ══════════════════════════════════════════════════════════════════════════
    print("[PLANNER] Generating 3 distinct candidate plans...")
    candidates = generate_candidates(insight, business_context, memory_str)
    
    if not candidates:
        print("[PLANNER] ⚠ Failed to generate candidates, falling back to static options.")
        candidates = [
            {
                "option_id": 1,
                "selected_action": "Pricing Adjustment",
                "action_type": "pricing",
                "parameters": {"region": "National", "item_name": insight.get("primary_insight", "")},
                "fallback_actions": [{"action": "Alert stakeholders", "trigger": "Immediate failure"}]
            }
        ]

    evaluated_candidates = []
    for cand in candidates:
        # Programmatic Resource Limits & Budget check
        resource_fit, rejection_reason = check_resource_limits(cand)
        
        # Independent candidate scoring LLM call
        try:
            scores = score_candidate(cand, insight, business_context)
        except Exception as scoring_err:
            print(f"[PLANNER] Scoring error for candidate {cand.get('option_id')}: {scoring_err}")
            scores = {
                "urgency_score": 5,
                "feasibility_score": 5,
                "impact_score": 5,
                "reasoning": "Fallback neutral scoring due to model exception.",
                "cost_impact_calculation": "N/A"
            }
            
        scores["resource_fit"] = resource_fit
        scores["rejection_reason"] = rejection_reason
        
        if not resource_fit:
            scores["composite_score"] = 0
        else:
            scores["composite_score"] = (
                int(scores.get("urgency_score", 5)) * 
                int(scores.get("feasibility_score", 5)) * 
                int(scores.get("impact_score", 5))
            )
            
        cand_eval = {**cand, **scores}
        evaluated_candidates.append(cand_eval)
        print(f"[PLANNER] Programmatic Eval Option #{cand['option_id']} ({cand['action_type']}): Urgency={scores['urgency_score']}, Feasibility={scores['feasibility_score']}, Impact={scores['impact_score']}, Fit={resource_fit}, Score={scores.get('composite_score')}")

    # Filter out resource check failures
    valid_candidates = [c for c in evaluated_candidates if c["resource_fit"]]
    if not valid_candidates:
        print("[PLANNER] ⚠ All candidates failed budget or stock limits! Selecting Option 1.")
        winner = evaluated_candidates[0]
    else:
        winner = max(valid_candidates, key=lambda c: c["composite_score"])
        
    print(f"[PLANNER] Winner Selected: Candidate #{winner['option_id']} ({winner['action_type']}) with composite score {winner.get('composite_score')}")

    # Prepare standard junior plan payload for backward compatibility
    result = {
        "selected_action": winner.get("selected_action", ""),
        "action_type": winner.get("action_type", ""),
        "reasoning": (
            f"{winner.get('reasoning', '')}\n\n"
            f"**Cost & Cost/Impact Calculations:**\n{winner.get('cost_impact_calculation', '')}"
        ),
        "parameters": winner.get("parameters", {}),
        "fallback_actions": winner.get("fallback_actions", []),
        "constraints_checked": "Programmatically evaluated budget limits and product stock constraints successfully."
    }

    # ══════════════════════════════════════════════════════════════════════════
    # STEP 7 — CODE-ENFORCED CONSTRAINT VALIDATION
    # ══════════════════════════════════════════════════════════════════════════
    violation = check_constraints(result, insight)
    if violation:
        print(f"[PLANNER] ⚠ Constraint violation detected: {violation}")
        retry_prompt = f"""
Your programmatically selected plan was REJECTED because of a constraint violation:
{violation}

You must select a DIFFERENT action_type that does not violate this constraint.

INSIGHT REPORT:
{json.dumps(insight, indent=2)}

BUSINESS CONTEXT:
{business_context}

Return the corrected JSON plan (same candidate schema). Do NOT select the same action_type.
"""
        try:
            raw2 = generate(retry_prompt, is_json=True, temperature=0.2)
            result = extract_json_from_gemini(raw2)
            print(f"[PLANNER] Re-planned after constraint violation → {result.get('action_type')}")
        except Exception as e:
            print(f"[PLANNER] Re-plan failed: {e}, keeping original despite violation")

    # ══════════════════════════════════════════════════════════════════════════
    # STEP 8 — SELF-REFLECTION (Senior Strategist Review)
    # ══════════════════════════════════════════════════════════════════════════
    reflection_prompt = f"""
You are a SENIOR business strategist reviewing a junior planner's action plan.
Your job is to catch strategic errors, refine metrics, and perform a rigorous risk assessment.

INSIGHT REPORT:
{json.dumps(insight, indent=2)}

BUSINESS CONTEXT:
{business_context}

CHOSEN PLAN:
{json.dumps(result, indent=2)}

Review critically:
1. Is the selected action the best response to this insight? Or is there a better action_type?
2. Are the parameters realistic given the business context? (Check actual margins, stock, prices)
3. Is the reasoning specific enough — does it cite real numbers from the business context?
4. Is the risk assessment honest? Perform a rigorous risk assessment:
   - Assign a risk_score (1.0 to 10.0)
   - Assign best_case (PKR impact)
   - Assign worst_case (PKR impact)
   - Assign expected_outcome (PKR impact)
   - Assign reversibility: fully_reversible | partially_reversible | irreversible
5. Is the fallback trigger measurable and actionable?
6. Are the constraint checks correct?

Return the IMPROVED plan as JSON only matching this schema exactly:
{{
  "selected_action": "short action name",
  "action_type": "campaign | pricing | notification | negotiation | reorder",
  "reasoning": "Citing real numbers from business context",
  "parameters": {{ "region": "...", ... }},
  "fallback_actions": [{{"action": "...", "trigger": "specific measurable condition"}}],
  "constraints_checked": "constraints verified",
  "risk_assessment": {{
    "risk_score": 0.0,
    "best_case": "description with PKR estimate",
    "worst_case": "description with PKR estimate",
    "expected_outcome": "description with PKR estimate",
    "reversibility": "fully_reversible | partially_reversible | irreversible"
  }},
  "reflection_notes": "1-2 sentences explaining your critique and adjustments"
}}
"""
    try:
        raw3 = generate(reflection_prompt, is_json=True, temperature=0.1)
        refined = extract_json_from_gemini(raw3)
        reflection_notes = refined.get("reflection_notes", "No changes")
        print(f"[PLANNER] Reflection complete: {reflection_notes[:100]}")
        result = refined
    except Exception as e:
        print(f"[PLANNER] Reflection error (keeping original): {e}")

    # ══════════════════════════════════════════════════════════════════════════
    # STORE THE FINAL PLAN
    # ══════════════════════════════════════════════════════════════════════════
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

    row["risk_assessment"] = result.get("risk_assessment", {})
    row["constraints_checked"] = result.get("constraints_checked", "")
    row["reflection_notes"] = result.get("reflection_notes", "")

    print(f"[PLANNER] [SUCCESS] Final plan stored - id={row['id']}, action={result.get('action_type')}, "
          f"risk={result.get('risk_assessment', {}).get('risk_score', 'N/A')}")
    return row


@router.post("/plan")
async def plan(body: dict):
    insight_id = body.get("insight_id", "")
    insight = body.get("insight", {})
    return await plan_logic(insight_id=insight_id, insight=insight)

import re
from fastapi import APIRouter
from services.supabase_client import get_supabase
from services.gemini_client import generate

router = APIRouter()


# ── BUG 1 FIX (prior session): Robust price parser ──

def parse_price(val, fallback: float) -> float:
    if isinstance(val, (int, float)):
        return float(val)
    if isinstance(val, str):
        digits = re.sub(r'[^\d.]', '', val.split('-')[0].strip())
        try:
            result = float(digits)
            # Reject if result looks like a percentage, not a price
            if result < 100 and fallback >= 100:
                return fallback
            return result
        except ValueError:
            return fallback
    return fallback


# ── Product base prices by category ──

PRODUCT_BASE_PRICES = {
    "wedding": 150000.0,
    "catering": 150000.0,
    "event": 120000.0,
    "booking": 150000.0,
    "ac": 85000.0,
    "air condition": 85000.0,
    "led": 45000.0,
    "tv": 45000.0,
    "washing": 32000.0,
    "appliance": 32000.0,
    "electronics": 40000.0,
    "default": 35000.0,
}


def get_product_base(plan: dict) -> float:
    sources = [
        str(plan.get('parameters', {}).get('item_name', '')),
        str(plan.get('selected_action', '')),
        str(plan.get('parameters', {}).get('rationale', ''))
    ]
    combined = ' '.join(sources).lower()
    for key, price in PRODUCT_BASE_PRICES.items():
        if key in combined:
            return price
    return PRODUCT_BASE_PRICES['default']


# ── State snapshot: reads pricing_log for THIS plan_id only ──

def _state_snapshot(plan_id: str = None) -> dict:
    try:
        db = get_supabase()
        camp_query = db.table("campaigns").select("*").order("created_at", desc=True)
        notif_query = db.table("notifications").select("*").order("created_at", desc=True)

        if plan_id:
            campaigns = camp_query.eq("plan_id", plan_id).execute().data
            notifs = notif_query.eq("plan_id", plan_id).execute().data
            
            pricing = db.table("pricing_log") \
                .select("before_value, after_value") \
                .eq("plan_id", plan_id) \
                .order("changed_at", desc=True) \
                .limit(1) \
                .execute()
                
            last_pricing = pricing.data[0]['after_value'] if pricing.data and len(pricing.data) > 0 else 295.0
        else:
            campaigns = []
            notifs = []
            last_pricing = 295.0

        return {
            "campaigns": campaigns,
            "last_pricing": last_pricing,
            "notifications": notifs,
        }
    except Exception as e:
        print(f"Error in _state_snapshot: {e}")
        return {
            "campaigns": [],
            "last_pricing": 295.0,
            "notifications": [],
        }


async def execute_logic(plan_id: str, plan: dict) -> dict:
    try:
        return await _execute_logic_inner(plan_id, plan)
    except Exception as e:
        import traceback
        with open("execute_error.txt", "w") as f:
            f.write(traceback.format_exc())
        raise

async def _execute_logic_inner(plan_id: str, plan: dict) -> dict:
    """Core execute logic — callable from /execute and /run-scenario.
    Branches campaign/pricing/notification simulations based on the Planner's action_type.
    """
    db = get_supabase()
    params = plan.get("parameters") or {}
    region = params.get("region", "National")

    action_type = plan.get('action_type', '').strip().lower()
    if not action_type:
        selected = plan.get('selected_action', '').lower()
        params = plan.get('parameters', {})
        if 'channel' in params or any(
            w in selected for w in [
                'notify', 'alert', 'expedite', 'stakeholder',
                'meeting', 'inform', 'negotiate', 'review',
                'escalate', 'hire', 'source', 'contact'
            ]
        ):
            action_type = 'notification'
        elif any(
            w in selected for w in [
                'price', 'pricing', 'adjust', 'increase',
                'decrease', 'margin'
            ]
        ):
            action_type = 'pricing'
        else:
            action_type = 'campaign'

    KNOWN_TYPES = {'campaign', 'pricing', 'notification'}
    if action_type not in KNOWN_TYPES:
        action_type = 'notification'

    # 1. Before snapshot (no plan_id — anchor baseline)
    before = _state_snapshot()

    # ══════════════════════════════════════════════════════
    # 2. CAMPAIGN simulation — branches by action_type
    # ══════════════════════════════════════════════════════
    if action_type == 'campaign':
        is_recovery = any(w in plan.get('selected_action', '').lower()
                          for w in ['recover', 'crisis', 'alert', 'negotiate'])
        campaign_prefix = "Recovery Campaign" if is_recovery else "Growth Campaign"
        campaign_name = f"{campaign_prefix} — {params.get('region', 'National')}"
        
        campaign_insert = {
            "plan_id": plan_id,
            "name": campaign_name,
            "region": params.get('region', 'National'),
            "discount_pct": params.get('discount_pct', 15),
            "status": "active",
            "projected_reach": params.get('projected_reach', 5000)
        }

    elif action_type == 'pricing':
        # Client-specific pricing adjustment — not a public campaign
        item = params.get('item_name', 'Client Account')
        campaign_insert = {
            "plan_id": plan_id,
            "name": f"Pricing Adjustment — {item}",
            "region": params.get('region', 'National'),
            "discount_pct": 0,
            "status": "internal",
            "projected_reach": 1   # client-specific, not mass
        }

    elif action_type == 'negotiation':
        campaign_insert = {
            "plan_id": plan_id,
            "name": f"Client Negotiation — {params.get('client_name', 'Key Account')}",
            "region": params.get('region', 'National'),
            "discount_pct": 0,
            "status": "internal",
            "projected_reach": 1
        }

    else:  # notification
        campaign_insert = {
            "plan_id": plan_id,
            "name": f"Internal Alert — {params.get('channel', 'Management')}",
            "region": params.get('region', 'National'),
            "discount_pct": 0,
            "status": "internal",
            "projected_reach": params.get('recipient_count', 10)
        }
        
    campaign_row = db.table("campaigns").insert(campaign_insert).execute().data[0]

    # ══════════════════════════════════════════════════════
    # 3. PRICING simulation — direction depends on action_type
    # ══════════════════════════════════════════════════════
    base = get_product_base(plan)
    before_val = parse_price(params.get('before_value'), base)

    if action_type == 'campaign':
        pct = float(params.get('discount_pct', 15))
        after_val = parse_price(
            params.get('after_value'),
            round(before_val * (1 - pct / 100), 2)
        )
    elif action_type == 'pricing':
        after_val = parse_price(
            params.get('after_value'),
            round(before_val * 1.09, 2)   # default 9% pass-through
        )
    elif action_type == 'negotiation':
        after_val = before_val
    else:  # notification — no price change
        after_val = before_val

    before['last_pricing'] = before_val

    item_name = params.get(
        'item_name',
        f"product_price_{params.get('region', 'national').lower()}"
    )

    pricing_row = db.table("pricing_log").insert({
        "plan_id": plan_id,
        "item_name": item_name,
        "before_value": before_val,
        "after_value": after_val
    }).execute().data[0]

    # ══════════════════════════════════════════════════════
    # 4. NOTIFICATION simulation — prompt branches by action_type
    # ══════════════════════════════════════════════════════
    # action_type already resolved at top of execute_logic

    if action_type == 'notification':
        situation_text = (
            params.get('message_summary')
            or params.get('rationale')
            or params.get('counter_offer')
            or plan.get('selected_action', 'Action required')
        )
        
        notify_prompt = f"""
Write a 2-sentence internal WhatsApp alert.
Recipient team: {params.get('channel', 'Management')}
Situation: {situation_text}

Rules:
- Professional and urgent tone
- Internal staff only — do NOT mention customer discounts
- Do NOT use the word "discount"
Return only the message text.
"""

    elif action_type == 'pricing':
        notify_prompt = f"""
Write a 2-sentence internal pricing team notification.
Action: {plan.get('selected_action', '')}
Products affected: {params.get('item_name', 'key import product lines')}
Reason: margin compression due to currency depreciation requires immediate price adjustment

Rules:
- Addressed to internal pricing and sales team
- Factual and professional
- Do NOT mention customer discounts or promotional offers
- Mention that prices are being increased to protect margins
Return only the message text.
"""

    elif action_type == 'negotiation':
        notify_prompt = f"""
Write a 2-sentence internal WhatsApp alert to the sales/account team.
Action: Client negotiation initiated
Client: {params.get('client_name', 'Key Account')}
Situation: {params.get('rationale', plan.get('selected_action', ''))}
Counter-offer prepared: {params.get('counter_offer', 'See action plan')}
Urgency: Respond within {params.get('urgency_hours', 48)} hours

Rules:
- Professional and urgent tone
- Internal use only — do NOT mention discounts to customers
- Do NOT use the word "discount"
- This is an account management escalation
Return only the message text. No labels. No quotes.
"""

    else:  # campaign
        region = params.get('region', 'National')
        # Ensure region is a real string, not a template placeholder
        if not region or region == 'National':
            region_greeting = 'Nationwide'
        else:
            region_greeting = region
            
        notify_prompt = f"""
Write a customer-facing WhatsApp promotion message.
Region: {region}
Discount: {params.get('discount_pct', 15)}%
Duration: {params.get('duration_days', 14)} days
Campaign: {plan.get('selected_action', '')}

Rules:
- Open by addressing the audience as '{region_greeting}'
- State the discount % and duration explicitly
- End with a single call to action
- Maximum 3 sentences
Return only the message text.
"""

    try:
        message = generate(notify_prompt).strip()
    except Exception:
        if action_type == "notification":
            message = f"Urgent: {plan.get('selected_action', 'Action required')} — all {region} stakeholders please respond immediately."
        elif action_type == "pricing":
            message = f"Notice: Pricing update in effect for {item_name}. Please update your systems accordingly."
        else:
            message = f"Special offer: {params.get('discount_pct', 15)}% discount in {region} for {params.get('duration_days', 14)} days."

    notif_row = db.table("notifications").insert({
        "plan_id": plan_id,
        "channel": "whatsapp",
        "recipient_count": params.get("projected_reach", params.get("recipient_count", 50000)),
        "message_body": message,
        "status": "internal" if action_type in ("notification", "pricing") else "drafted",
    }).execute().data[0]

    # 5. After snapshot (with plan_id — reads the pricing_log row we just wrote)
    after = _state_snapshot(plan_id)

    # 6. Write execution_log
    log = (
        db.table("execution_logs")
        .insert({
            "plan_id": plan_id,
            "actions_taken": [
                {"type": "campaign",     "table": "campaigns",     "row_id": campaign_row["id"], "status": "success"},
                {"type": "pricing",      "table": "pricing_log",   "row_id": pricing_row["id"],  "status": "success"},
                {"type": "notification", "table": "notifications", "row_id": notif_row["id"],    "status": "success"},
            ],
            "before_snapshot": before,
            "after_snapshot": after,
            "agent_trace": {"note": "Antigravity trace will be attached in M8"},
            "status": "complete",
        })
        .execute()
        .data[0]
    )

    # 7. Update pipeline_runs
    db.table("pipeline_runs").upsert({
        "plan_id": plan_id,
        "status": "executing",
        "execution_log_json": log,
    }).execute()

    return log


@router.post("/execute")
async def execute(body: dict):
    plan_id = body.get("plan_id", "")
    plan = body.get("plan", {})
    return await execute_logic(plan_id=plan_id, plan=plan)

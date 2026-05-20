import re
from fastapi import APIRouter, BackgroundTasks, HTTPException
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


# ── Product base prices by category (Fallback only) ──

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


# ── Database Helpers for Dynamic Resolution ──

def find_matching_product(item_name: str) -> dict:
    if not item_name:
        return None
    try:
        db = get_supabase()
        # Try SKU match first
        res = db.table("shopify_products").select("*").eq("sku", item_name).execute()
        if res.data:
            return res.data[0]
            
        # Try name ilike match
        res = db.table("shopify_products").select("*").ilike("name", f"%{item_name}%").execute()
        if res.data:
            return res.data[0]

        # Token-based match
        tokens = [t.strip() for t in item_name.split() if len(t.strip()) > 2]
        for token in tokens:
            res = db.table("shopify_products").select("*").ilike("name", f"%{token}%").execute()
            if res.data:
                return res.data[0]
    except Exception as e:
        print(f"[EXECUTOR] Error matching product: {e}")
    return None


def find_matching_campaign(name_query: str) -> dict:
    if not name_query:
        return None
    try:
        db = get_supabase()
        res = db.table("marketing_campaigns").select("*").ilike("campaign_name", f"%{name_query}%").execute()
        if res.data:
            return res.data[0]
            
        res = db.table("marketing_campaigns").select("*").ilike("network", f"%{name_query}%").execute()
        if res.data:
            return res.data[0]
    except Exception as e:
        print(f"[EXECUTOR] Error matching campaign: {e}")
    return None


def fetch_full_store_snapshot() -> dict:
    """Fetch complete state of shopify products and marketing campaigns for comparison."""
    try:
        db = get_supabase()
        products = db.table("shopify_products").select("*").execute().data or []
        campaigns = db.table("marketing_campaigns").select("*").execute().data or []
        return {
            "products": products,
            "campaigns": campaigns
        }
    except Exception as e:
        print(f"[EXECUTOR] Error capturing store snapshot: {e}")
        return {
            "products": [],
            "campaigns": []
        }


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
    """Core execute logic.
    Branches campaign/pricing/notification simulations based on the Planner's action_type.
    """
    db = get_supabase()
    params = plan.get("parameters") or {}
    region = params.get("region", "National")

    # 1. Resolve action type
    action_type = plan.get('action_type', '').strip().lower()
    if not action_type:
        selected = plan.get('selected_action', '').lower()
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

    KNOWN_TYPES = {'campaign', 'pricing', 'notification', 'negotiation'}
    if action_type not in KNOWN_TYPES:
        action_type = 'notification'

    # 2. Pre-execution validations & Grounding
    validation_warnings = []
    validation_errors = []
    
    item_name = params.get('item_name') or plan.get('selected_action') or ''
    matching_product = find_matching_product(item_name)
    
    # Resolve product base price dynamically or fallback
    if matching_product:
        base_val = float(matching_product["current_price"])
    else:
        base_val = get_product_base(plan)
        if action_type in ('pricing', 'campaign') and item_name:
            validation_warnings.append(f"Product '{item_name}' not found in shopify_products. Using fallback base price {base_val}")

    # Capture BEFORE snapshot of live products and campaigns
    before_store_state = fetch_full_store_snapshot()
    before_legacy = _state_snapshot()

    # Calculate pricing values
    before_val = parse_price(params.get('before_value'), base_val)
    clamped = False

    if action_type == 'campaign':
        pct = float(params.get('discount_pct', 15))
        after_val = parse_price(
            params.get('after_value'),
            round(before_val * (1 - pct / 100), 2)
        )
    elif action_type == 'pricing':
        # Default price adjustment
        after_val = parse_price(
            params.get('after_value'),
            round(before_val * 1.09, 2)   # default 9% pass-through
        )
    else:
        after_val = before_val

    # Safety margin check: prevent price from falling below COGS unless explicitly permitted
    if matching_product and after_val < matching_product["cost_of_goods"]:
        rationale_text = str(plan.get("reasoning", "")).lower() + " " + str(plan.get("selected_action", "")).lower()
        is_clearance = any(w in rationale_text for w in ["clearance", "fire-sale", "liquidation", "markdown", "dump"])
        if not is_clearance:
            safe_price = round(matching_product["cost_of_goods"] * 1.10, 2)
            validation_warnings.append(
                f"Safety Guardrail: Proposed price PKR {after_val} is below Cost of Goods (PKR {matching_product['cost_of_goods']}). "
                f"Clamped to safety price (COGS + 10% = PKR {safe_price}) to protect profit margins."
            )
            after_val = safe_price
            clamped = True

    # ══════════════════════════════════════════════════════
    # 3. CAMPAIGN simulation — branches by action_type
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
        item = params.get('item_name', 'Client Account')
        campaign_insert = {
            "plan_id": plan_id,
            "name": f"Pricing Adjustment — {item}",
            "region": params.get('region', 'National'),
            "discount_pct": 0,
            "status": "internal",
            "projected_reach": 1
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
    # 4. PRICING simulation
    # ══════════════════════════════════════════════════════
    before_legacy['last_pricing'] = before_val

    pricing_item_name = params.get(
        'item_name',
        f"product_price_{params.get('region', 'national').lower()}"
    )

    pricing_row = db.table("pricing_log").insert({
        "plan_id": plan_id,
        "item_name": pricing_item_name,
        "before_value": before_val,
        "after_value": after_val
    }).execute().data[0]

    # ══════════════════════════════════════════════════════
    # 5. NOTIFICATION generation
    # ══════════════════════════════════════════════════════
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
        reg = params.get('region', 'National')
        region_greeting = 'Nationwide' if not reg or reg == 'National' else reg
            
        notify_prompt = f"""
Write a customer-facing WhatsApp promotion message.
Region: {reg}
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
            message = f"Notice: Pricing update in effect for {pricing_item_name}. Please update your systems accordingly."
        else:
            message = f"Special offer: {params.get('discount_pct', 15)}% discount in {region} for {params.get('duration_days', 14)} days."

    notif_row = db.table("notifications").insert({
        "plan_id": plan_id,
        "channel": "whatsapp",
        "recipient_count": params.get("projected_reach", params.get("recipient_count", 50000)),
        "message_body": message,
        "status": "internal" if action_type in ("notification", "pricing") else "drafted",
    }).execute().data[0]

    # ══════════════════════════════════════════════════════
    # 6. E-Commerce Mutations (Safeguarded with Rollback)
    # ══════════════════════════════════════════════════════
    modified_products = []
    modified_campaigns = []
    
    try:
        if action_type == 'pricing' or (action_type == 'campaign' and matching_product):
            if matching_product:
                p_id = matching_product["id"]
                cogs = matching_product["cost_of_goods"]
                new_margin = round((after_val - cogs) / after_val, 2) if after_val > 0 else 0.0
                
                db.table("shopify_products").update({
                    "current_price": after_val,
                    "profit_margin": new_margin,
                    "status": "Active" if new_margin >= 0.2 else "At Risk"
                }).eq("id", p_id).execute()
                modified_products.append(matching_product["sku"])

        elif action_type == 'campaign':
            sel_act = plan.get('selected_action', '').lower()
            if any(w in sel_act for w in ['pause', 'stop', 'halt', 'disable']):
                # Pause a campaign by matching name or network
                camp_name = params.get('campaign_name') or params.get('network') or ''
                target_camp = find_matching_campaign(camp_name)
                if target_camp:
                    db.table("marketing_campaigns").update({"active": False}).eq("id", target_camp["id"]).execute()
                    modified_campaigns.append(target_camp["campaign_name"])
                else:
                    # Fallback to pausing all matching network campaigns
                    all_camps = db.table("marketing_campaigns").select("*").execute().data or []
                    for c in all_camps:
                        if c["network"].lower() in sel_act:
                            db.table("marketing_campaigns").update({"active": False}).eq("id", c["id"]).execute()
                            modified_campaigns.append(c["campaign_name"])
                            
            if any(w in sel_act for w in ['activate', 'start', 'shift', 'increase', 'summer']):
                # Activate or update spend
                target_camp = find_matching_campaign(params.get('campaign_name') or 'summer')
                if target_camp:
                    new_spend = target_camp["spend"] + 22000.0 if 'increase' in sel_act or 'summer' in sel_act else target_camp["spend"]
                    db.table("marketing_campaigns").update({"active": True, "spend": new_spend}).eq("id", target_camp["id"]).execute()
                    modified_campaigns.append(target_camp["campaign_name"])
                    
    except Exception as mutation_error:
        print(f"[EXECUTOR] Mutation failed. Initiating automatic rollback...")
        # Restore shopify products
        for prod in before_store_state.get("products") or []:
            db.table("shopify_products").update({
                "current_price": prod["current_price"],
                "profit_margin": prod["profit_margin"],
                "status": prod["status"],
                "stock_level": prod["stock_level"]
            }).eq("sku", prod["sku"]).execute()
        # Restore marketing campaigns
        for camp in before_store_state.get("campaigns") or []:
            db.table("marketing_campaigns").update({
                "active": camp["active"],
                "spend": camp["spend"],
                "clicks": camp["clicks"],
                "conversions": camp["conversions"],
                "roas": camp["roas"]
            }).eq("campaign_name", camp["campaign_name"]).execute()
            
        raise HTTPException(status_code=500, detail=f"Database update failed. Transaction was rolled back: {mutation_error}")

    # Capture AFTER snapshot of live products and campaigns
    after_store_state = fetch_full_store_snapshot()
    after_legacy = _state_snapshot(plan_id)

    # ══════════════════════════════════════════════════════
    # 7. Post-Execution Verification
    # ══════════════════════════════════════════════════════
    verification_successful = True
    verification_errors = []

    if matching_product and matching_product["sku"] in modified_products:
        updated = db.table("shopify_products").select("current_price").eq("sku", matching_product["sku"]).maybe_single().execute().data
        if updated:
            actual = float(updated["current_price"])
            if abs(actual - after_val) > 0.01:
                verification_successful = False
                verification_errors.append(f"DB pricing mismatch for {matching_product['sku']}: found {actual}, expected {after_val}")
        else:
            verification_successful = False
            verification_errors.append(f"Failed to fetch updated product {matching_product['sku']}")

    if modified_campaigns:
        for cname in modified_campaigns:
            updated = db.table("marketing_campaigns").select("active").eq("campaign_name", cname).maybe_single().execute().data
            if updated:
                sel_act = plan.get('selected_action', '').lower()
                is_active = updated["active"]
                if any(w in sel_act for w in ['pause', 'stop', 'halt', 'disable']) and is_active:
                    verification_successful = False
                    verification_errors.append(f"Campaign {cname} failed to pause.")
                elif any(w in sel_act for w in ['activate', 'start', 'shift', 'increase', 'summer']) and not is_active:
                    verification_successful = False
                    verification_errors.append(f"Campaign {cname} failed to activate.")
            else:
                verification_successful = False
                verification_errors.append(f"Failed to fetch updated campaign {cname}")

    # ══════════════════════════════════════════════════════
    # 8. Write Execution Logs
    # ══════════════════════════════════════════════════════
    log = (
        db.table("execution_logs")
        .insert({
            "plan_id": plan_id,
            "actions_taken": [
                {"type": "campaign",     "table": "campaigns",     "row_id": campaign_row["id"], "status": "success"},
                {"type": "pricing",      "table": "pricing_log",   "row_id": pricing_row["id"],  "status": "success"},
                {"type": "notification", "table": "notifications", "row_id": notif_row["id"],    "status": "success"},
            ],
            "before_snapshot": before_store_state,
            "after_snapshot": after_store_state,
            "agent_trace": {
                "validation_warnings": validation_warnings,
                "validation_errors": validation_errors,
                "verification_successful": verification_successful,
                "verification_errors": verification_errors,
                "clamped": clamped,
                "modified_products": modified_products,
                "modified_campaigns": modified_campaigns,
                "note": "Antigravity production executor execution trace"
            },
            "status": "complete" if verification_successful else "verification_failed",
        })
        .execute()
        .data[0]
    )

    # 9. Update pipeline_runs
    db.table("pipeline_runs").upsert({
        "plan_id": plan_id,
        "status": "executing",
        "execution_log_json": log,
    }).execute()

    return log


# ── Rollback Execution Logic ──

async def rollback_execution_logic(plan_id: str) -> dict:
    try:
        db = get_supabase()
        log_res = db.table("execution_logs").select("*").eq("plan_id", plan_id).order("created_at", desc=True).limit(1).execute()
        if not log_res.data:
            return {"status": "error", "message": f"No execution log found for plan {plan_id}"}
        log_data = log_res.data[0]
        
        before_snap = log_data.get("before_snapshot") or {}
        
        restored_products = []
        restored_campaigns = []
        
        # 1. Restore products
        products_to_restore = before_snap.get("products") or []
        for prod in products_to_restore:
            sku = prod.get("sku")
            if sku:
                db.table("shopify_products").update({
                    "current_price": prod.get("current_price"),
                    "profit_margin": prod.get("profit_margin"),
                    "status": prod.get("status"),
                    "stock_level": prod.get("stock_level")
                }).eq("sku", sku).execute()
                restored_products.append(sku)
                
        # 2. Restore campaigns
        campaigns_to_restore = before_snap.get("campaigns") or []
        for camp in campaigns_to_restore:
            name = camp.get("campaign_name")
            if name:
                db.table("marketing_campaigns").update({
                    "active": camp.get("active"),
                    "spend": camp.get("spend"),
                    "clicks": camp.get("clicks"),
                    "conversions": camp.get("conversions"),
                    "roas": camp.get("roas")
                }).eq("campaign_name", name).execute()
                restored_campaigns.append(name)
                
        # 3. Update pipeline status
        db.table("pipeline_runs").update({
            "status": "rolled_back"
        }).eq("plan_id", plan_id).execute()
        
        # 4. Update execution log status
        db.table("execution_logs").update({
            "status": "rolled_back"
        }).eq("plan_id", plan_id).execute()
        
        return {
            "status": "success",
            "message": "Rollback completed successfully",
            "restored_products": restored_products,
            "restored_campaigns": restored_campaigns
        }
    except Exception as e:
        print(f"[EXECUTOR] Error in rollback execution logic: {e}")
        return {"status": "error", "message": str(e)}


# ── Route Definitions ──

@router.post("/execute")
async def execute(body: dict):
    plan_id = body.get("plan_id", "")
    plan = body.get("plan", {})
    return await execute_logic(plan_id=plan_id, plan=plan)


@router.post("/approve-plan")
async def approve_plan(body: dict, background_tasks: BackgroundTasks):
    from agents.orchestrator import InsightEngine
    plan_id = body.get("plan_id")
    if not plan_id:
        plan_id = body.get("plan", {}).get("id")
    background_tasks.add_task(InsightEngine.run_phase2, plan_id, True)
    return {"status": "approved", "message": "Phase 2 execution started"}


@router.post("/reject-plan")
async def reject_plan(body: dict, background_tasks: BackgroundTasks):
    from agents.orchestrator import InsightEngine
    plan_id = body.get("plan_id")
    if not plan_id:
        plan_id = body.get("plan", {}).get("id")
    background_tasks.add_task(InsightEngine.run_phase2, plan_id, False)
    return {"status": "rejected", "message": "Plan rejected"}


@router.post("/rollback-execution")
async def rollback_execution(body: dict):
    plan_id = body.get("plan_id")
    if not plan_id:
        plan_id = body.get("plan", {}).get("id")
    if not plan_id:
        raise HTTPException(status_code=400, detail="Missing plan_id")
    
    result = await rollback_execution_logic(plan_id)
    if result.get("status") == "error":
        raise HTTPException(status_code=500, detail=result.get("message"))
    return result

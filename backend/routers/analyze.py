import json
import re
from fastapi import APIRouter
from services.supabase_client import get_supabase
from services.gemini_client import generate

router = APIRouter()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# IMPROVEMENT #3 — ReAct-style Tool Use / Data Grounding
# Instead of reasoning in a vacuum, the Analyst queries real business tables
# BEFORE calling the LLM so the analysis is grounded in actual data.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def fetch_business_context() -> str:
    """
    ReAct Tool Use: Query shopify_products, competitor_prices,
    marketing_campaigns, and logistics_rates to build a compact
    business-context string (< 200 tokens) for prompt injection.
    """
    db = get_supabase()
    sections = []

    # ── Products snapshot ──
    try:
        rows = db.table("shopify_products") \
            .select("sku, name, current_price, profit_margin, stock_level, status") \
            .limit(10).execute()
        if rows.data:
            compact = [
                f"{p['sku']}: {p['name']} @ PKR {p['current_price']} "
                f"(margin {p['profit_margin']}%, stock {p['stock_level']}, {p['status']})"
                for p in rows.data
            ]
            sections.append("PRODUCTS:\n" + "\n".join(compact))
    except Exception:
        pass

    # ── Competitor prices ──
    try:
        rows = db.table("competitor_prices") \
            .select("product_name, competitor_name, price") \
            .limit(10).execute()
        if rows.data:
            compact = [
                f"{c['product_name']} — {c['competitor_name']}: PKR {c['price']}"
                for c in rows.data
            ]
            sections.append("COMPETITOR PRICES:\n" + "\n".join(compact))
    except Exception:
        pass

    # ── Active marketing campaigns ──
    try:
        rows = db.table("marketing_campaigns") \
            .select("campaign_name, network, spend, roas, active") \
            .limit(10).execute()
        if rows.data:
            compact = [
                f"{c['campaign_name']} ({c['network']}): spend PKR {c['spend']}, ROAS {c['roas']}x"
                for c in rows.data
            ]
            sections.append("CAMPAIGNS:\n" + "\n".join(compact))
    except Exception:
        pass

    # ── Logistics rates ──
    try:
        rows = db.table("logistics_rates") \
            .select("city, carrier, base_shipping_fee") \
            .limit(10).execute()
        if rows.data:
            compact = [
                f"{l['city']} via {l['carrier']}: PKR {l['base_shipping_fee']}"
                for l in rows.data
            ]
            sections.append("LOGISTICS:\n" + "\n".join(compact))
    except Exception:
        pass

    return "\n\n".join(sections) if sections else "No business context available."


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# IMPROVEMENT #4 — Output Validation
# Clamp severity to [0,10], confidence to [0,1], ensure required fields exist.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def validate_insight(result: dict) -> dict:
    """Guardrail: ensure output values are within legal ranges."""
    # Severity must be 0–10
    sev = result.get("severity_score", 5.0)
    try:
        sev = float(sev)
    except (TypeError, ValueError):
        sev = 5.0
    result["severity_score"] = max(0.0, min(10.0, sev))

    # Confidence must be 0–1
    conf = result.get("confidence", 0.5)
    try:
        conf = float(conf)
    except (TypeError, ValueError):
        conf = 0.5
    result["confidence"] = max(0.0, min(1.0, conf))

    # Required string fields
    for field in ("primary_insight", "causal_chain"):
        if not result.get(field) or not isinstance(result[field], str):
            result[field] = "Analysis incomplete."

    # Required list fields
    for field in ("affected_domains", "key_figures"):
        if not isinstance(result.get(field), list):
            result[field] = []

    return result


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CORE ANALYSIS LOGIC
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

async def analyze_logic(signal_ids: list, signals: list) -> dict:
    """
    World-class Analyst pipeline:
      1. Data Grounding  — fetch real business context from DB
      2. Initial Analysis — temperature 0.2 for determinism
      3. Self-Reflection  — critique + refine (Reflexion pattern)
      4. Validation       — clamp outputs, enforce schema
    """

    signals_json = json.dumps(
        [s.get("normalized_json", s) for s in signals], indent=2
    )

    # ══════════════════════════════════════════════════════════════════════════
    # STEP 1 — DATA GROUNDING (ReAct Tool Use)
    # ══════════════════════════════════════════════════════════════════════════
    business_context = fetch_business_context()
    print(f"[ANALYST] Business context loaded ({len(business_context)} chars)")

    # ══════════════════════════════════════════════════════════════════════════
    # STEP 2 — INITIAL ANALYSIS  (temperature 0.2 — deterministic)
    # ══════════════════════════════════════════════════════════════════════════
    initial_prompt = f"""
You are a business intelligence analyst receiving multiple business signals.
Your job is NOT to summarize each signal separately.

Your job:
1. Find causal relationships BETWEEN the signals
2. Identify compounding effects (signals that make each other worse)
3. Output ONE insight capturing the cross-signal situation
4. Rate severity 0-10 (10 = act immediately)
5. List affected business domains
6. Rate your own confidence 0.0-1.0

LIVE BUSINESS CONTEXT (queried from database):
{business_context}

SIGNALS:
{signals_json}

Return JSON only, no markdown fences:
{{
  "primary_insight": "One sentence — how the signals relate, not what they say",
  "causal_chain": "Your chain MUST include any specific financial consequences mentioned in the signals — penalty clauses, cancellation fees, or contractual obligations. If a PKR amount appears in the signals as a consequence of inaction, include it explicitly in the chain using the exact figure.",
  "severity_score": 0.0,
  "affected_domains": ["domain1", "domain2"],
  "key_figures": ["list of critical PKR amounts, percentages, or timeframes"],
  "confidence": 0.0
}}

CRITICAL CONSTRAINTS:
1. Never list signals as separate points. Find the relationship between them.
2. Your causal_chain MUST reference at least N-1 signals where N is the number of signals provided.
3. Do NOT reference signals by number (e.g. "Signal 1"). Use actual business context.
4. GROUND your analysis in the BUSINESS CONTEXT above. Reference actual product prices, margins, stock levels, competitor data, or campaign ROAS when they are relevant to the signals.
5. confidence = how certain you are about the causal relationships you identified.
"""

    try:
        raw = generate(initial_prompt, is_json=True, temperature=0.2)
        match = re.search(r'\{[\s\S]*\}', raw)
        initial_result = json.loads(match.group(0) if match else "{}")
        print(f"[ANALYST] Initial analysis complete — severity={initial_result.get('severity_score')}")
    except Exception as e:
        print(f"[ANALYST] Initial analysis error: {e}")
        initial_result = {
            "primary_insight": "Unable to analyze signals.",
            "causal_chain": "Analysis failed.",
            "severity_score": 5.0,
            "affected_domains": [],
            "key_figures": [],
            "confidence": 0.0,
        }

    # ══════════════════════════════════════════════════════════════════════════
    # STEP 3 — SELF-REFLECTION (Reflexion / LATS pattern)
    # A "senior analyst" reviews and refines the initial output.
    # ══════════════════════════════════════════════════════════════════════════
    reflection_prompt = f"""
You are a SENIOR business analyst reviewing a junior analyst's work.
Your job is to catch errors, fill gaps, and sharpen the analysis.

ORIGINAL SIGNALS:
{signals_json}

BUSINESS CONTEXT:
{business_context}

JUNIOR ANALYST OUTPUT:
{json.dumps(initial_result, indent=2)}

Perform this review:
1. Did the junior analyst miss any causal link between signals?
2. Is the severity score justified by the evidence? Should it be higher or lower?
3. Are the key_figures accurate — do they match the numbers in the signals and business context?
4. Is the causal_chain logically sound or does it contain unsupported leaps?
5. Does the confidence score match the strength of evidence?
6. Did the analyst reference actual business data (prices, margins, stock) or reason in a vacuum?

Return the IMPROVED analysis as JSON only, no markdown fences:
{{
  "primary_insight": "refined insight — keep original if it was correct",
  "causal_chain": "refined chain — keep original if it was correct",
  "severity_score": 0.0,
  "affected_domains": ["domain1", "domain2"],
  "key_figures": ["refined figures"],
  "confidence": 0.0,
  "reflection_notes": "1-2 sentences: what you changed and why"
}}
"""

    try:
        raw2 = generate(reflection_prompt, is_json=True, temperature=0.1)
        match2 = re.search(r'\{[\s\S]*\}', raw2)
        refined_result = json.loads(match2.group(0) if match2 else "{}")
        print(f"[ANALYST] Reflection complete — "
              f"severity {initial_result.get('severity_score')} → {refined_result.get('severity_score')} | "
              f"reflection: {refined_result.get('reflection_notes', 'none')[:80]}")
    except Exception as e:
        print(f"[ANALYST] Reflection error (keeping initial): {e}")
        refined_result = initial_result

    # ══════════════════════════════════════════════════════════════════════════
    # STEP 4 — OUTPUT VALIDATION (Guardrails)
    # ══════════════════════════════════════════════════════════════════════════
    final = validate_insight(refined_result)

    # ── Write to Supabase ─────────────────────────────────────────────────────
    row = (
        get_supabase()
        .table("insight_reports")
        .insert({
            "signal_ids": signal_ids,
            "primary_insight": final["primary_insight"],
            "causal_chain": final["causal_chain"],
            "severity_score": final["severity_score"],
            "affected_domains": final["affected_domains"],
            "key_figures": final["key_figures"],
        })
        .execute()
        .data[0]
    )

    print(f"[ANALYST] ✅ Final insight stored — id={row['id']}, severity={final['severity_score']}, confidence={final['confidence']}")
    return row


@router.post("/analyze")
async def analyze(body: dict):
    signal_ids = body.get("signal_ids", [])
    signals = body.get("signals", [])
    return await analyze_logic(signal_ids=signal_ids, signals=signals)

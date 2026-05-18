import json
from fastapi import APIRouter
from services.supabase_client import get_supabase
from services.gemini_client import generate

router = APIRouter()


async def analyze_logic(signal_ids: list, signals: list) -> dict:
    """Core analyze logic — callable from /analyze and /run-scenario."""

    prompt = f"""
You are a business intelligence analyst receiving multiple business signals.
Your job is NOT to summarize each signal separately.

Your job:
1. Find causal relationships BETWEEN the signals
2. Identify compounding effects (signals that make each other worse)
3. Output ONE insight capturing the cross-signal situation
4. Rate severity 0-10 (10 = act immediately)
5. List affected business domains

SIGNALS:
{json.dumps([s.get('normalized_json', s) for s in signals], indent=2)}

Return JSON only, no markdown fences:
{{
  "primary_insight": "One sentence — how the signals relate, not what they say",
  "causal_chain": "[Signal A effect] → [causes X] → [which combines with Signal B effect] → [resulting in Y]",
  "severity_score": 0.0,
  "affected_domains": ["domain1", "domain2"]
}}

CRITICAL CONSTRAINTS:
1. Never list signals as separate points. Find the relationship between them.
2. Your causal_chain MUST reference at least N-1 signals where N is the number of signals provided. If given 3 signals, the chain must connect at least 2 of them explicitly.
3. Do NOT reference signals by number (e.g. "Signal 1", "Signal 2"). Describe each effect directly using the actual business context.
"""
    try:
        import re
        raw = generate(prompt, is_json=True, temperature=0.5)
        match = re.search(r'\{[\s\S]*\}', raw)
        clean = match.group(0) if match else "{}"
        result = json.loads(clean)
    except Exception as e:
        print(f"Gemini Analyze Error: {e}")
        result = {
            "primary_insight": "Unable to analyze signals.",
            "causal_chain": "Analysis failed.",
            "severity_score": 5.0,
            "affected_domains": [],
        }

    # Write to Supabase
    row = (
        get_supabase()
        .table("insight_reports")
        .insert({
            "signal_ids": signal_ids,
            "primary_insight": result.get("primary_insight", ""),
            "causal_chain": result.get("causal_chain", ""),
            "severity_score": result.get("severity_score", 5.0),
            "affected_domains": result.get("affected_domains", []),
        })
        .execute()
        .data[0]
    )

    return row


@router.post("/analyze")
async def analyze(body: dict):
    signal_ids = body.get("signal_ids", [])
    signals = body.get("signals", [])
    return await analyze_logic(signal_ids=signal_ids, signals=signals)

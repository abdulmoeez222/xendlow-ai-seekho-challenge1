import asyncio
import sys
import os
from dotenv import load_dotenv
load_dotenv()

sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'backend'))

from routers.plan import plan_logic

insight = {
  "primary_insight": "The competitor's aggressive electronics price cut directly exacerbates our severe electronics overstock and warehouse capacity issues, demanding immediate pricing action to prevent significant losses.",
  "causal_chain": "[Signal A effect] → [causes X] → [which combines with Signal B effect] → [resulting in Y]",
  "severity_score": 9.0,
  "affected_domains": [
    "Sales",
    "Supply Chain",
    "Finance",
    "Pricing Strategy",
    "Inventory Management"
  ]
}

async def run():
    print("Testing planner logic...")
    from services.supabase_client import get_supabase
    db = get_supabase()
    insight_id = "550e8400-e29b-41d4-a716-446655440000"
    db.table("insight_reports").upsert({
        "id": insight_id,
        "primary_insight": insight["primary_insight"],
        "causal_chain": insight["causal_chain"],
        "severity_score": insight["severity_score"],
        "affected_domains": insight["affected_domains"]
    }).execute()
    result = await plan_logic(insight_id, insight)
    print("Result:", result)

if __name__ == "__main__":
    asyncio.run(run())

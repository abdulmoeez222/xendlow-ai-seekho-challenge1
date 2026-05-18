import asyncio
import sys
import os

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
    result = await plan_logic("test-insight-123", insight)
    print("Result:", result)

if __name__ == "__main__":
    asyncio.run(run())

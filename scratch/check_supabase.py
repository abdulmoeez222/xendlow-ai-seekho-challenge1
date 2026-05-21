import os
import sys
from dotenv import load_dotenv

# Add backend directory to sys.path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'backend'))

load_dotenv(os.path.join(os.path.dirname(__file__), '..', 'backend', '.env'))

from services.supabase_client import get_supabase

def check_runs():
    db = get_supabase()
    # Get latest 5 pipeline runs
    print("--- LATEST PIPELINE RUNS ---")
    try:
        res = db.table("pipeline_runs").select("*").order("created_at", desc=True).limit(5).execute()
        for idx, row in enumerate(res.data):
            print(f"\n[{idx+1}] Plan ID: {row['plan_id']}")
            print(f"Status: {row['status']}")
            print(f"Created At: {row['created_at']}")
            print(f"Signals keys: {list(row['signals_json'].keys()) if row.get('signals_json') and isinstance(row['signals_json'], dict) else type(row.get('signals_json'))}")
            print(f"Insight JSON keys: {list(row['insight_json'].keys()) if row.get('insight_json') and isinstance(row['insight_json'], dict) else type(row.get('insight_json'))}")
            print(f"Action Plan JSON keys: {list(row['action_plan_json'].keys()) if row.get('action_plan_json') and isinstance(row['action_plan_json'], dict) else type(row.get('action_plan_json'))}")
            if row.get('error'):
                print(f"Error: {row['error']}")
    except Exception as e:
        print("Error fetching pipeline_runs:", e)

    # Let's check signals table too
    print("\n--- LATEST SIGNALS ---")
    try:
        res_sig = db.table("signals").select("*").order("id", desc=True).limit(5).execute()
        for idx, row in enumerate(res_sig.data):
            print(f"\n[{idx+1}] ID: {row['id']}")
            print(f"Source Type: {row['source_type']}")
            print(f"Created At: {row.get('created_at')}")
            print(f"Raw Content Excerpt: {str(row['raw_content'])[:100]}")
    except Exception as e:
        print("Error fetching signals:", e)

if __name__ == "__main__":
    check_runs()

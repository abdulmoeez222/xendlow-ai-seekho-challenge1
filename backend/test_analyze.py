import asyncio
import json
from dotenv import load_dotenv
load_dotenv()
from services.gemini_client import generate
from services.supabase_client import get_supabase

async def test_analyze():
    db = get_supabase()
    signals = db.table("signals").select("*").limit(2).execute().data
    
    prompt = f"""
    Analyze these signals: {json.dumps(signals)}
    Find causal relationships.
    Return JSON ONLY:
    {{
      "primary_insight": "string",
      "causal_chain": "string",
      "severity": 1-10
    }}
    """
    
    raw = generate(prompt)
    print("--- RAW OUTPUT FROM GEMINI ---")
    print(raw)
    print("------------------------------")
    
    try:
        clean = raw.strip().replace("```json", "").replace("```", "").strip()
        result = json.loads(clean)
        print("Successfully parsed JSON!")
    except Exception as e:
        print("Failed to parse JSON:", e)

if __name__ == "__main__":
    asyncio.run(test_analyze())

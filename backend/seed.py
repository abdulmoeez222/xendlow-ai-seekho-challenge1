import json
import glob
from dotenv import load_dotenv
from services.supabase_client import get_supabase

load_dotenv()


def seed():
    db = get_supabase()
    for path in sorted(glob.glob("scenarios/*.json")):
        with open(path) as f:
            s = json.load(f)
        db.table("scenarios").upsert(s).execute()
        print(f"Seeded: {s['name']} (id={s['id']})")


if __name__ == "__main__":
    seed()
    print("All scenarios seeded.")

"""
apply_schema.py
---------------
Applies missing database tables to the live Supabase instance.

OPTION A (Automatic — Supabase Management API):
  1. Get your personal access token from: https://supabase.com/dashboard/account/tokens
  2. Set it in .env as: SUPABASE_ACCESS_TOKEN=sbp_xxxx
  3. Run: python apply_schema.py

OPTION B (Manual):
  1. Open: https://supabase.com/dashboard/project/lasvykpqbxntybfjnydu/sql/new
  2. Paste the contents of apply_tables.sql and click Run
"""
import os
import sys
import requests
from dotenv import load_dotenv

load_dotenv()

PROJECT_REF = "lasvykpqbxntybfjnydu"

NEW_TABLES_SQL = """
-- =====================================================================
-- Insight Engine: New E-Commerce Tables
-- =====================================================================

CREATE TABLE IF NOT EXISTS shopify_products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sku text UNIQUE NOT NULL,
  name text NOT NULL,
  current_price float4 NOT NULL,
  cost_of_goods float4 NOT NULL,
  profit_margin float4 NOT NULL,
  stock_level int4 NOT NULL,
  status text NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS marketing_campaigns (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  network text NOT NULL,
  campaign_name text UNIQUE NOT NULL,
  spend float4 NOT NULL,
  clicks int4 NOT NULL,
  conversions int4 NOT NULL,
  roas float4 NOT NULL,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS competitor_prices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_name text NOT NULL,
  competitor_name text NOT NULL,
  price float4 NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS logistics_rates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  city text NOT NULL,
  carrier text NOT NULL,
  base_shipping_fee float4 NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS raw_signals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  run_id uuid,
  raw_content text,
  created_at timestamptz DEFAULT now()
);

-- Disable Row Level Security for backend access via anon key
ALTER TABLE shopify_products      DISABLE ROW LEVEL SECURITY;
ALTER TABLE marketing_campaigns   DISABLE ROW LEVEL SECURITY;
ALTER TABLE competitor_prices     DISABLE ROW LEVEL SECURITY;
ALTER TABLE logistics_rates       DISABLE ROW LEVEL SECURITY;
ALTER TABLE raw_signals           DISABLE ROW LEVEL SECURITY;

-- Reload PostgREST schema cache so tables are immediately accessible
NOTIFY pgrst, 'reload schema';
"""


def apply_via_management_api(token: str):
    """Apply SQL using the Supabase Management API."""
    url = f"https://api.supabase.com/v1/projects/{PROJECT_REF}/database/query"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }
    resp = requests.post(url, json={"query": NEW_TABLES_SQL}, headers=headers, timeout=30)

    if resp.status_code in (200, 201):
        print("[OK] Schema applied successfully via Management API!")
        print("[OK] Tables created: shopify_products, marketing_campaigns, competitor_prices, logistics_rates, raw_signals")
        print("[OK] RLS disabled on all new tables")
        print("[OK] PostgREST schema cache reloaded")
        return True
    else:
        print(f"[ERROR] Management API returned {resp.status_code}: {resp.text}")
        return False


def print_manual_instructions():
    """Print fallback instructions for manual SQL Editor."""
    print()
    print("=" * 70)
    print("MANUAL FALLBACK: Paste the following in the Supabase SQL Editor")
    print(f"URL: https://supabase.com/dashboard/project/{PROJECT_REF}/sql/new")
    print("=" * 70)
    print(NEW_TABLES_SQL)
    print("=" * 70)


def main():
    token = os.getenv("SUPABASE_ACCESS_TOKEN", "").strip()

    if token:
        print(f"[INFO] Found SUPABASE_ACCESS_TOKEN. Applying schema via Management API...")
        success = apply_via_management_api(token)
        if not success:
            print("[WARN] Management API failed. Showing manual instructions instead.")
            print_manual_instructions()
    else:
        print("[WARN] SUPABASE_ACCESS_TOKEN not set in .env")
        print("[INFO] To set it:")
        print("  1. Go to: https://supabase.com/dashboard/account/tokens")
        print("  2. Create a new Personal Access Token")
        print("  3. Add to backend/.env: SUPABASE_ACCESS_TOKEN=sbp_xxxx")
        print("  4. Re-run: python apply_schema.py")
        print()
        print("[INFO] Alternatively, apply the schema MANUALLY using the SQL below:")
        print_manual_instructions()


if __name__ == "__main__":
    main()

-- =====================================================================
-- Insight Engine: New E-Commerce Tables (apply in Supabase SQL Editor)
-- URL: https://supabase.com/dashboard/project/lasvykpqbxntybfjnydu/sql/new
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

-- Disable Row Level Security so backend anon key can read/write
ALTER TABLE shopify_products      DISABLE ROW LEVEL SECURITY;
ALTER TABLE marketing_campaigns   DISABLE ROW LEVEL SECURITY;
ALTER TABLE competitor_prices     DISABLE ROW LEVEL SECURITY;
ALTER TABLE logistics_rates       DISABLE ROW LEVEL SECURITY;
ALTER TABLE raw_signals           DISABLE ROW LEVEL SECURITY;

-- Reload PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- Insight Engine — Supabase Schema
-- Run this entire file in the Supabase SQL Editor.
-- After running, enable Realtime on: campaigns, pricing_log, notifications

create table if not exists signals (
  id uuid primary key default gen_random_uuid(),
  source_type text not null,
  raw_content text,
  normalized_json jsonb,
  created_at timestamptz default now()
);

create table if not exists insight_reports (
  id uuid primary key default gen_random_uuid(),
  signal_ids uuid[],
  primary_insight text,
  causal_chain text,
  severity_score float4,
  affected_domains text[],
  key_figures jsonb default '[]',
  created_at timestamptz default now()
);

create table if not exists action_plans (
  id uuid primary key default gen_random_uuid(),
  insight_id uuid references insight_reports(id),
  selected_action text,
  reasoning text,
  parameters jsonb,
  fallback_actions jsonb,
  created_at timestamptz default now()
);

create table if not exists campaigns (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid references action_plans(id),
  name text,
  region text,
  discount_pct float4,
  status text default 'active',
  projected_reach int4,
  created_at timestamptz default now()
);

create table if not exists pricing_log (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid references action_plans(id),
  item_name text,
  before_value float4,
  after_value float4,
  changed_at timestamptz default now()
);

create table if not exists notifications (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid references action_plans(id),
  channel text default 'whatsapp',
  recipient_count int4,
  message_body text,
  status text default 'drafted',
  created_at timestamptz default now()
);

create table if not exists execution_logs (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid references action_plans(id),
  actions_taken jsonb,
  before_snapshot jsonb,
  after_snapshot jsonb,
  agent_trace jsonb,
  status text default 'complete',
  created_at timestamptz default now()
);

create table if not exists scenarios (
  id int primary key,
  name text,
  description text,
  input_signals jsonb
);

create table if not exists pipeline_runs (
  plan_id uuid primary key,
  status text default 'running',
  signals_json jsonb,
  insight_json jsonb,
  action_plan_json jsonb,
  execution_log_json jsonb,
  report_json jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists shopify_products (
  id uuid primary key default gen_random_uuid(),
  sku text unique not null,
  name text not null,
  current_price float4 not null,
  cost_of_goods float4 not null,
  profit_margin float4 not null,
  stock_level int4 not null,
  status text not null,
  created_at timestamptz default now()
);

create table if not exists marketing_campaigns (
  id uuid primary key default gen_random_uuid(),
  network text not null, -- 'meta' or 'google'
  campaign_name text not null,
  spend float4 not null,
  clicks int4 not null,
  conversions int4 not null,
  roas float4 not null,
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists competitor_prices (
  id uuid primary key default gen_random_uuid(),
  product_name text not null,
  competitor_name text not null,
  price float4 not null,
  created_at timestamptz default now()
);

create table if not exists logistics_rates (
  id uuid primary key default gen_random_uuid(),
  city text not null,
  carrier text not null,
  base_shipping_fee float4 not null,
  created_at timestamptz default now()
);
CREATE TABLE IF NOT EXISTS raw_signals (
  id uuid primary key default gen_random_uuid(),
  run_id uuid,
  raw_content text,
  created_at timestamptz default now()
);


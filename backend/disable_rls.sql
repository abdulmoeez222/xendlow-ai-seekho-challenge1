-- Run this in Supabase SQL Editor if using the anon key in your backend.
-- For a server-side backend, using the service_role key is preferred instead.

alter table signals          disable row level security;
alter table insight_reports  disable row level security;
alter table action_plans     disable row level security;
alter table campaigns        disable row level security;
alter table pricing_log      disable row level security;
alter table notifications    disable row level security;
alter table execution_logs   disable row level security;
alter table scenarios        disable row level security;
alter table pipeline_runs    disable row level security;

# SAAD — Insight Engine Backend + Antigravity Orchestration
## Root file: `/SAAD_Antigravity_Prompt.md`

---

## FIRST ACTION — UPDATE AGENT_RULES.md

Before writing a single line of code, open `AGENT_RULES.md` in the root
directory and **replace its contents entirely** with the following:

```markdown
# AGENT_RULES.md — Insight Engine

## PRIME DIRECTIVE
You build the backend and Antigravity pipeline for Insight Engine.
You work module by module. You do NOT move to the next module until
Saad explicitly says: "Module X complete — next"

## RULES (NON-NEGOTIABLE)

1. ONE MODULE AT A TIME
   Build only the current module. Do not scaffold future modules speculatively.

2. STOP AND TEST
   At the end of every module, output the exact manual test steps for that module.
   Wait for green signal before continuing.

3. MARK COMPLETION
   When Saad gives green signal, mark the module [x] DONE in
   SAAD_Antigravity_Prompt.md. Confirm the update before moving on.

4. WIRE TO EXISTING FRONTENDS — DO NOT CHANGE THEM
   Omer's web app:    /web/src/
   Moeez's mobile:    /mobile/lib/
   Every endpoint must match what those files already expect.
   The frontend contracts are locked. You adapt to them, not the other way around.

5. NO GUESSING ON CONTRACTS
   If a response shape is ambiguous, state what you are about to build
   and wait for confirmation before implementing.

6. BACKEND FOLDER ONLY
   All files go inside /backend/
   Never touch /web/, /mobile/, /docs/, or any root-level file
   except SAAD_Antigravity_Prompt.md (module tracking only).

7. ENV VARS — NEVER HARDCODE SECRETS
   Always use os.getenv(). Keep .env.example updated after every module.

8. RAILWAY LAST
   Do not attempt Railway deployment until Module 9.
```

---

## REPO CONTEXT

```
insight-engine/                      ← monorepo root
├── AGENT_RULES.md                   ← you manage this
├── SAAD_Antigravity_Prompt.md       ← this file (mark modules done here)
├── README.md
├── docs/
│   └── InsightEngine_SRS.pdf
│
├── web/                             ← OMER'S CODE — DO NOT TOUCH
│   └── src/
│       ├── lib/api.js               ← calls your endpoints
│       ├── lib/supabase.js          ← uses your Supabase creds
│       ├── hooks/useRealtime.js     ← subscribes to your Realtime tables
│       └── store/pipelineStore.js   ← expects your exact JSON shapes
│
└── mobile/                          ← MOEEZ'S CODE — DO NOT TOUCH
    └── lib/
        ├── config.dart              ← needs RAILWAY_URL + Supabase creds
        ├── services/api_service.dart       ← calls your endpoints
        └── services/realtime_service.dart  ← subscribes to your Realtime tables
```

Your output: everything inside `/backend/`.

---

## MODULE TRACKER
### Mark [x] DONE only when Saad gives explicit green signal per module.

- [ ] **M1**  — Backend scaffold + Supabase schema
- [ ] **M2**  — POST /ingest
- [ ] **M3**  — POST /analyze
- [ ] **M4**  — POST /plan
- [ ] **M5**  — POST /execute
- [ ] **M6**  — GET /state/before · /state/after/{plan_id} · /logs/{plan_id} · POST /report
- [ ] **M7**  — GET /scenarios · POST /run-scenario/{id} · seed.py · 3 JSON files
- [ ] **M8**  — Antigravity: 5 agents + orchestration workflow
- [ ] **M9**  — Railway deployment + credential handoff to Omer and Moeez
- [ ] **M10** — Full end-to-end test, all 3 scenarios, both frontends

---

## FRONTEND CONTRACT REFERENCE
### These shapes are locked. Build exactly to these — never deviate.

### Endpoints Omer's api.js calls
```
POST  /ingest                 → { signals: [...SignalObject] }
POST  /analyze                → InsightReport
POST  /plan                   → ActionPlan
POST  /execute                → ExecutionLog
POST  /report                 → FinalReport
GET   /state/before           → StateSnapshot
GET   /state/after/{plan_id}  → StateSnapshot
GET   /logs/{plan_id}         → PipelineRunLog
GET   /scenarios              → Scenario[]
POST  /run-scenario/{id}      → FinalReport
```

### Endpoints Moeez's api_service.dart calls
```
POST  /run-scenario/{id}      → FinalReport
GET   /logs/{plan_id}         → PipelineRunLog
GET   /state/before           → StateSnapshot
GET   /state/after/{plan_id}  → StateSnapshot
```

### StateSnapshot shape
```json
{ "campaigns_count": 0, "last_pricing": 250.0, "notifications_count": 0 }
```

### FinalReport shape (both frontends consume this)
```json
{
  "insight": "string",
  "causal_chain": "string",
  "severity": 8.7,
  "selected_action": "string",
  "reasoning": "string",
  "simulations_executed": 3,
  "projected_revenue_recovery": "PKR 1.2M",
  "projected_reach": 5000,
  "execution_time_ms": 4200,
  "before_state": { "campaigns_count": 0, "last_pricing": 250.0, "notifications_count": 0 },
  "after_state":  { "campaigns_count": 1, "last_pricing": 295.0, "notifications_count": 1 },
  "actions_detail": [
    { "type": "campaign",     "table": "campaigns",     "row_id": "uuid", "status": "success" },
    { "type": "pricing",      "table": "pricing_log",   "row_id": "uuid", "status": "success" },
    { "type": "notification", "table": "notifications", "row_id": "uuid", "status": "success" }
  ]
}
```

### PipelineRunLog shape (mobile polls this every 2s to advance its stepper)
```json
{
  "plan_id": "uuid",
  "status": "running | complete",
  "signals": [...],         ← presence = Ingestor step done
  "insight": {...},         ← presence = Analyst step done
  "action_plan": {...},     ← presence = Planner step done
  "execution_log": {...},   ← presence = Executor step done
  "report": {...}           ← presence = Reporter step done
}
```
Keys are added progressively as the pipeline runs. Mobile checks for each key
on every 2-second poll to decide which stepper step to mark done.

### Supabase Realtime (both frontends subscribe to INSERT events)
```
Table: campaigns      filter: plan_id = {current_plan_id}
Table: pricing_log    filter: plan_id = {current_plan_id}
Table: notifications  filter: plan_id = {current_plan_id}
```
Realtime MUST be enabled on these 3 tables in Supabase dashboard.

---

## MODULE 1 — Backend Scaffold + Supabase Schema

### Folder structure to create

```
backend/
├── agents/
│   ├── __init__.py
│   ├── ingestor.py       ← empty stub
│   ├── analyst.py        ← empty stub
│   ├── planner.py        ← empty stub
│   ├── executor.py       ← empty stub
│   └── reporter.py       ← empty stub
├── routers/
│   ├── __init__.py
│   ├── ingest.py         ← empty stub
│   ├── analyze.py        ← empty stub
│   ├── plan.py           ← empty stub
│   ├── execute.py        ← empty stub
│   ├── report.py         ← empty stub
│   └── state.py          ← empty stub
├── services/
│   ├── __init__.py
│   ├── supabase_client.py
│   ├── gemini_client.py
│   └── file_parser.py    ← empty stub
├── models/
│   ├── __init__.py
│   ├── signal.py
│   ├── insight.py
│   ├── action_plan.py
│   └── execution_log.py
├── scenarios/
│   ├── scenario_1.json
│   ├── scenario_2.json
│   └── scenario_3.json
├── schema.sql
├── seed.py               ← empty stub
├── main.py
├── requirements.txt
├── Procfile
├── .env.example
└── .env                  ← gitignored
```

### schema.sql — run this in Supabase SQL Editor

```sql
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
```

After running, enable Realtime in Supabase → Database → Replication for:
`campaigns`, `pricing_log`, `notifications`

### main.py (starter — health check only for now)

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="Insight Engine API", version="1.0.0")
app.add_middleware(CORSMiddleware, allow_origins=["*"],
    allow_methods=["*"], allow_headers=["*"])

@app.get("/health")
def health():
    return { "status": "ok", "service": "insight-engine-api" }
```

### services/supabase_client.py

```python
import os
from supabase import create_client, Client

_client: Client = None

def get_supabase() -> Client:
    global _client
    if _client is None:
        url = os.getenv("SUPABASE_URL")
        key = os.getenv("SUPABASE_KEY")
        if not url or not key:
            raise RuntimeError("SUPABASE_URL and SUPABASE_KEY must be set in .env")
        _client = create_client(url, key)
    return _client
```

### services/gemini_client.py

```python
import os
import google.generativeai as genai

_model = None

def get_gemini():
    global _model
    if _model is None:
        genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
        _model = genai.GenerativeModel("gemini-1.5-flash")
    return _model

def generate(prompt: str) -> str:
    model = get_gemini()
    response = model.generate_content(prompt)
    return response.text
```

### requirements.txt

```
fastapi
uvicorn
supabase
httpx
pdfplumber
python-multipart
python-dotenv
google-generativeai
beautifulsoup4
```

### .env.example

```
SUPABASE_URL=
SUPABASE_KEY=
GEMINI_API_KEY=
```

### Procfile

```
web: uvicorn main:app --host 0.0.0.0 --port $PORT
```

---

### ✋ M1 STOP — MANUAL TESTS

Run these tests and report results. Do not start M2 until green signal.

```
TEST 1 — Folder exists
  Confirm /backend/ folder is created with all files from the structure above.
  Stubs can be empty — they just need to exist.

TEST 2 — Supabase tables
  Open Supabase → Table Editor.
  Confirm all 9 tables visible:
  signals, insight_reports, action_plans, campaigns,
  pricing_log, notifications, execution_logs, scenarios, pipeline_runs

TEST 3 — Realtime enabled
  Supabase → Database → Replication.
  Confirm: campaigns, pricing_log, notifications show Realtime ON.

TEST 4 — Server starts
  cd backend
  pip install -r requirements.txt
  uvicorn main:app --reload
  Open: http://localhost:8000/health
  Expected: { "status": "ok", "service": "insight-engine-api" }

TEST 5 — Swagger loads
  Open: http://localhost:8000/docs
  Expected: FastAPI Swagger UI with no errors.
```

---

## MODULE 2 — POST /ingest

Build `backend/routers/ingest.py` fully. Register in `main.py`.

### Endpoint

```
POST /ingest
Content-Type: multipart/form-data

Fields:
  input_type: str   → "text" | "pdf" | "url" | "csv"
  content:    str   → raw text or URL string
  file:       UploadFile (optional) → for pdf/csv uploads

Response 200:
{
  "signals": [{
    "id": "uuid",
    "source_type": "text",
    "raw_content": "...",
    "normalized_json": {
      "entities": ["Lahore", "Ali Traders"],
      "numbers": [{ "value": 25, "unit": "%", "context": "order decline" }],
      "dates": ["Q2"],
      "keywords": ["orders", "decline", "fuel"],
      "summary": "One sentence summary"
    }
  }]
}
```

### Logic

```python
# Step 1 — Extract raw text per input_type
if input_type == "text":
    raw_text = content

elif input_type == "url":
    async with httpx.AsyncClient() as client:
        r = await client.get(content, timeout=10)
    from bs4 import BeautifulSoup
    raw_text = BeautifulSoup(r.text, "html.parser").get_text()[:5000]

elif input_type == "pdf":
    import pdfplumber, io
    data = await file.read()
    with pdfplumber.open(io.BytesIO(data)) as pdf:
        raw_text = "\n".join(p.extract_text() or "" for p in pdf.pages)

elif input_type == "csv":
    import csv, io
    data = await file.read()
    rows = list(csv.DictReader(io.StringIO(data.decode())))
    raw_text = f"CSV with {len(rows)} rows. Columns: {list(rows[0].keys())}. Sample: {rows[:3]}"

# Step 2 — Gemini extraction
prompt = f"""
Extract structured information from this business text.
Return JSON only — no explanation, no markdown fences.

Text: {raw_text[:3000]}

Return exactly:
{{
  "entities": ["organizations, people, locations"],
  "numbers": [{{"value": number, "unit": "unit or %", "context": "what this refers to"}}],
  "dates": ["dates or time periods"],
  "keywords": ["important business keywords"],
  "summary": "One sentence capturing the core business fact"
}}
"""
raw = generate(prompt)
clean = raw.strip().replace("```json","").replace("```","").strip()
normalized = json.loads(clean)

# Step 3 — Write to Supabase
row = get_supabase().table("signals").insert({
    "source_type": input_type,
    "raw_content": raw_text[:10000],
    "normalized_json": normalized
}).execute().data[0]

return { "signals": [row] }
```

---

### ✋ M2 STOP — MANUAL TESTS

```
TEST 1 — Text input
  Swagger → POST /ingest
  input_type: text
  content: "Lahore region orders declined 25% vs Q1. Fuel prices up 18%."
  Expected:
    signals[0].normalized_json.numbers contains values 25 and 18
    signals[0].normalized_json.summary is one sentence
    signals[0].id is a UUID

TEST 2 — URL input
  input_type: url
  content: https://www.dawn.com
  Expected: signals[0].raw_content is non-empty, normalized_json has keywords

TEST 3 — Supabase row
  Supabase → signals table → 2 new rows from above tests.

TEST 4 — Empty input (edge case)
  input_type: text, content: (empty)
  Expected: does NOT crash, returns signal with summary "No content provided" or similar.
```

---

## MODULE 3 — POST /analyze

Build `backend/routers/analyze.py` fully. Register in `main.py`.

### Endpoint

```
POST /analyze
Content-Type: application/json

Body: { "signal_ids": ["uuid1","uuid2"], "signals": [...SignalObjects] }

Response 200:
{
  "id": "uuid",
  "primary_insight": "cross-signal causal finding",
  "causal_chain": "Fuel ↑ → delivery cost ↑ → margin ↓ → revenue gap widens",
  "severity_score": 8.7,
  "affected_domains": ["pricing", "logistics", "revenue"]
}
```

### Gemini prompt (use verbatim)

```python
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
{json.dumps([s['normalized_json'] for s in signals], indent=2)}

Return JSON only, no markdown fences:
{{
  "primary_insight": "One sentence — how the signals relate, not what they say",
  "causal_chain": "Effect of A → causes X → which compounds with Effect of B → resulting in Y",
  "severity_score": float 0-10,
  "affected_domains": ["domain1", "domain2"]
}}

CRITICAL: Never list signals as separate points. Find the relationship between them.
"""
```

Write to `insight_reports` table. Return InsightReport with ID.

---

### ✋ M3 STOP — MANUAL TESTS

```
TEST 1 — Two-signal causal analysis
  First: POST /ingest twice to get 2 signals:
    "Lahore orders down 25% vs Q1"
    "Fuel prices increased 18% this week"
  Then: POST /analyze with both signal objects and IDs.
  Expected:
    primary_insight mentions BOTH signals together (not a summary of each)
    causal_chain has → arrows
    severity_score is 0-10
    affected_domains is a non-empty array

TEST 2 — Supabase row
  Supabase → insight_reports → 1 new row with all fields.

TEST 3 — Single signal (edge case)
  POST /analyze with only 1 signal. Does NOT crash.
```

---

## MODULE 4 — POST /plan

Build `backend/routers/plan.py` fully. Register in `main.py`.

### Endpoint

```
POST /plan
Content-Type: application/json

Body: { "insight_id": "uuid", "insight": { InsightReport } }

Response 200:
{
  "id": "uuid",
  "selected_action": "Launch regional discount campaign",
  "reasoning": "2-3 sentences — why this over alternatives",
  "parameters": {
    "type": "campaign",
    "region": "Lahore",
    "discount_pct": 15,
    "duration_days": 14,
    "projected_reach": 5000
  },
  "fallback_actions": [
    { "action": "Update delivery pricing", "trigger": "if campaign ROI < 20% in 72h" }
  ]
}
```

### Gemini prompt (use verbatim)

```python
prompt = f"""
You are an autonomous business decision agent.
You receive an InsightReport and COMMIT to one action. Not a list. Not options. One decision.

INSIGHT REPORT:
{json.dumps(insight, indent=2)}

Rules:
1. Generate 3 candidate actions internally
2. Score each: urgency x feasibility x impact (1-10 each)
3. Select the highest-scoring one — you commit to this
4. Write 2-3 sentences: why this action over the other two
5. Define one fallback with a specific measurable trigger condition

Available action types:
  campaign:     regional discount (params: region, discount_pct, duration_days, projected_reach)
  pricing:      cost update (params: item_name, before_value, after_value)
  reorder:      supplier order (params: supplier, sku_count, urgency_days)
  notification: alert (params: channel, recipient_count, message_summary)

Return JSON only, no markdown fences:
{{
  "selected_action": "short action name",
  "action_type": "campaign|pricing|reorder|notification",
  "reasoning": "why this action beats the alternatives",
  "parameters": {{ action-specific params }},
  "fallback_actions": [{{ "action": "...", "trigger": "specific measurable condition" }}]
}}
"""
```

Write to `action_plans`. Return ActionPlan with ID.

---

### ✋ M4 STOP — MANUAL TESTS

```
TEST 1 — Plan from real insight
  Use the insight_id from M3.
  POST /plan with that insight_id and InsightReport.
  Expected:
    selected_action is a single string (not a list)
    reasoning is 2-3 sentences mentioning why over alternatives
    parameters has at least: type + one other param
    fallback_actions has at least 1 item with a trigger

TEST 2 — Supabase row
  Supabase → action_plans → new row with insight_id matching insight_reports.

TEST 3 — Variety check
  Run POST /plan two more times with different insights.
  Verify not every run selects "campaign" — different signals should yield different actions.
```

---

## MODULE 5 — POST /execute

Build `backend/routers/execute.py` fully. Register in `main.py`.
This is the most critical endpoint — it fires the Realtime events both frontends listen for.

### Endpoint

```
POST /execute
Content-Type: application/json

Body: { "plan_id": "uuid", "plan": { ActionPlan } }

Response 200:
{
  "id": "uuid",
  "plan_id": "uuid",
  "actions_taken": [
    { "type": "campaign",     "table": "campaigns",     "row_id": "uuid", "status": "success" },
    { "type": "pricing",      "table": "pricing_log",   "row_id": "uuid", "status": "success" },
    { "type": "notification", "table": "notifications", "row_id": "uuid", "status": "success" }
  ],
  "before_snapshot": { "campaigns_count": 0, "last_pricing": 250.0, "notifications_count": 0 },
  "after_snapshot":  { "campaigns_count": 1, "last_pricing": 295.0, "notifications_count": 1 },
  "status": "complete"
}
```

### Logic — always run all 3 simulations regardless of action_type

```python
db = get_supabase()

# 1. Before snapshot
before = _state_snapshot()

# 2. Campaign simulation (always runs)
campaign = db.table("campaigns").insert({
    "plan_id": plan_id,
    "name": f"Recovery Campaign — {plan['parameters'].get('region', 'National')}",
    "region": plan['parameters'].get('region', 'Lahore'),
    "discount_pct": plan['parameters'].get('discount_pct', 15),
    "status": "active",
    "projected_reach": plan['parameters'].get('projected_reach', 5000)
}).execute().data[0]

# 3. Pricing simulation (always runs)
before_val = float(plan['parameters'].get('before_value', 250.0))
after_val  = float(plan['parameters'].get('after_value', round(before_val * 1.18, 2)))
pricing = db.table("pricing_log").insert({
    "plan_id": plan_id,
    "item_name": plan['parameters'].get('item_name', 'delivery_cost_lahore'),
    "before_value": before_val,
    "after_value": after_val
}).execute().data[0]

# 4. Notification simulation — Gemini drafts the message
msg_prompt = f"""
Write a short WhatsApp business notification (max 3 sentences) for:
  Action: {plan['selected_action']}
  Region: {plan['parameters'].get('region','Lahore')}
  Discount: {plan['parameters'].get('discount_pct',15)}%
  Duration: {plan['parameters'].get('duration_days',14)} days

Return only the message text. No labels. No quotes.
"""
message = generate(msg_prompt).strip()
notif = db.table("notifications").insert({
    "plan_id": plan_id,
    "channel": "whatsapp",
    "recipient_count": plan['parameters'].get('projected_reach', 5000),
    "message_body": message,
    "status": "drafted"
}).execute().data[0]

# 5. After snapshot
after = _state_snapshot()

# 6. Write execution_log
log = db.table("execution_logs").insert({
    "plan_id": plan_id,
    "actions_taken": [
        { "type": "campaign",     "table": "campaigns",     "row_id": campaign['id'], "status": "success" },
        { "type": "pricing",      "table": "pricing_log",   "row_id": pricing['id'],  "status": "success" },
        { "type": "notification", "table": "notifications", "row_id": notif['id'],    "status": "success" }
    ],
    "before_snapshot": before,
    "after_snapshot":  after,
    "agent_trace": { "note": "Antigravity trace will be attached in M8" },
    "status": "complete"
}).execute().data[0]

# 7. Update pipeline_runs
db.table("pipeline_runs").upsert({
    "plan_id": plan_id,
    "status": "executing",
    "execution_log_json": log
}).execute()


# Helper
def _state_snapshot() -> dict:
    db = get_supabase()
    campaigns = db.table("campaigns").select("id").execute().data
    pricing   = db.table("pricing_log").select("after_value").order("changed_at", desc=True).limit(1).execute().data
    notifs    = db.table("notifications").select("id").execute().data
    return {
        "campaigns_count":    len(campaigns),
        "last_pricing":       pricing[0]['after_value'] if pricing else 250.0,
        "notifications_count": len(notifs)
    }
```

---

### ✋ M5 STOP — MANUAL TESTS

```
TEST 1 — Execute with real plan_id
  Use plan_id from M4.
  POST /execute with that plan_id and full ActionPlan.
  Expected:
    actions_taken has exactly 3 items (campaign, pricing, notification)
    all 3 status = "success"
    after_snapshot.campaigns_count = before_snapshot.campaigns_count + 1
    after_snapshot.last_pricing > before_snapshot.last_pricing

TEST 2 — Supabase writes (THE CRITICAL CHECK)
  campaigns:    new row — region, discount_pct, status "active"
  pricing_log:  new row — before_value and after_value (after > before)
  notifications: new row — message_body is a real sentence (not empty, not placeholder)

TEST 3 — Realtime fires
  Open Supabase → Realtime Inspector (or listen via JS in browser console).
  Call POST /execute again.
  Expected: INSERT events appear on campaigns, pricing_log, notifications within 2s.
  This confirms Omer's BeforeAfter panel and Moeez's SimulationScreen will update live.

TEST 4 — execution_logs row
  Supabase → execution_logs → 1 new row, status "complete", actions_taken is array of 3.
```

---

## MODULE 6 — State + Logs + Report Endpoints

Add to `backend/routers/state.py` and `backend/routers/report.py`. Register both in `main.py`.

### GET /state/before

```python
@router.get("/state/before")
def state_before():
    return _state_snapshot()   # reuse helper from M5
```

### GET /state/after/{plan_id}

```python
@router.get("/state/after/{plan_id}")
def state_after(plan_id: str):
    log = get_supabase().table("execution_logs") \
        .select("after_snapshot").eq("plan_id", plan_id) \
        .maybe_single().execute()
    if not log.data:
        raise HTTPException(404, "No execution log found for this plan_id")
    return log.data['after_snapshot']
```

### GET /logs/{plan_id}

This is what Moeez's app polls every 2 seconds.
Only include keys that have data — mobile advances stepper based on key presence.

```python
@router.get("/logs/{plan_id}")
def get_logs(plan_id: str):
    run = get_supabase().table("pipeline_runs") \
        .select("*").eq("plan_id", plan_id) \
        .maybe_single().execute()
    if not run.data:
        return { "plan_id": plan_id, "status": "not_found" }
    r = run.data
    resp = { "plan_id": plan_id, "status": r['status'] }
    if r.get('signals_json'):      resp['signals']       = r['signals_json']
    if r.get('insight_json'):      resp['insight']       = r['insight_json']
    if r.get('action_plan_json'):  resp['action_plan']   = r['action_plan_json']
    if r.get('execution_log_json'):resp['execution_log'] = r['execution_log_json']
    if r.get('report_json'):       resp['report']        = r['report_json']
    return resp
```

### POST /report

```python
@router.post("/report")
def generate_report(body: dict):
    execution_id = body['execution_id']
    insight_id   = body['insight_id']
    db = get_supabase()
    log     = db.table("execution_logs").select("*").eq("id", execution_id).single().execute().data
    insight = db.table("insight_reports").select("*").eq("id", insight_id).single().execute().data
    plan    = db.table("action_plans").select("*").eq("id", log['plan_id']).single().execute().data

    reach = plan['parameters'].get('projected_reach', 5000)
    report = {
        "insight":                    insight['primary_insight'],
        "causal_chain":               insight['causal_chain'],
        "severity":                   insight['severity_score'],
        "selected_action":            plan['selected_action'],
        "reasoning":                  plan['reasoning'],
        "simulations_executed":       len(log['actions_taken']),
        "projected_revenue_recovery": f"PKR {reach * 240:,}",
        "projected_reach":            reach,
        "execution_time_ms":          4200,
        "before_state":               log['before_snapshot'],
        "after_state":                log['after_snapshot'],
        "actions_detail":             log['actions_taken']
    }
    # Update pipeline_runs with report and mark complete
    db.table("pipeline_runs").upsert({
        "plan_id": log['plan_id'],
        "status": "complete",
        "report_json": report
    }).execute()
    return report
```

---

### ✋ M6 STOP — MANUAL TESTS

```
TEST 1 — GET /state/before
  Expected: { campaigns_count: N, last_pricing: N.N, notifications_count: N }
  All 3 keys present. All values are numbers.

TEST 2 — GET /state/after/{plan_id}
  Use plan_id from M5. campaigns_count should be higher than before.

TEST 3 — GET /logs/{plan_id}
  Expected keys: plan_id, status, signals, insight, action_plan, execution_log
  (report key absent — will appear after POST /report is called)

TEST 4 — POST /report
  Body: { "execution_id": "M5 execution_logs id", "insight_id": "M3 insight_reports id" }
  Expected: full FinalReport matching the contract shape exactly.
  Check every key: insight, causal_chain, severity, selected_action, reasoning,
  simulations_executed (must be 3), projected_revenue_recovery, projected_reach,
  execution_time_ms, before_state, after_state, actions_detail.

TEST 5 — GET /logs/{plan_id} again
  After calling POST /report, poll /logs again.
  Expected: "report" key now present and status is "complete".
```

---

## MODULE 7 — Scenarios + /run-scenario + seed.py

### scenario JSON files (save to backend/scenarios/)

**scenario_1.json**
```json
{
  "id": 1,
  "name": "Regional Sales Drop + Fuel Shock",
  "description": "Three compounding signals hit Lahore distribution simultaneously",
  "input_signals": [
    { "type": "text", "content": "Q2 sales report: Lahore region orders declined 25% vs Q1. Electronics down 30%, Appliances down 22%. Revenue gap: PKR 3.2M." },
    { "type": "text", "content": "Breaking: Pakistan fuel prices up 18% immediately. Petrol now PKR 295/litre. Logistics cost impact expected same day." },
    { "type": "text", "content": "Vendor alert from Ali Traders: Lead times extended from 2 to 5 weeks — port congestion Karachi. Affects 40% of our SKU catalog." }
  ]
}
```

**scenario_2.json**
```json
{
  "id": 2,
  "name": "Competitor Price Drop + Inventory Surplus",
  "description": "Market pressure meets overstock — margin and capacity crisis",
  "input_signals": [
    { "type": "text", "content": "Intelligence: Competitor TechMart cut electronics prices 20% this week. Three of our core SKUs now priced 25% higher than theirs." },
    { "type": "text", "content": "Warehouse: Karachi facility at 94% capacity. Electronics at 60 days stock vs 30-day target. Accessories risk expiry in 45 days." }
  ]
}
```

**scenario_3.json**
```json
{
  "id": 3,
  "name": "Rupee Devaluation + Import Pipeline",
  "description": "Currency shock hits dollar-denominated inventory in transit",
  "input_signals": [
    { "type": "text", "content": "SBP: PKR depreciated 8.3% vs USD this month. Rate now PKR 285/USD — 18-month high. Further depreciation consensus among analysts." },
    { "type": "text", "content": "Finance: 70% of inventory is dollar-denominated imports. USD 2.3M in transit. Landed cost increase: estimated PKR 52M." },
    { "type": "text", "content": "Margin analysis: Import gross margins currently 18%. Post-devaluation: 9.2%. Break-even risk on ACs, LED TVs, Washing Machines." }
  ]
}
```

### seed.py

```python
import json, glob, os
from services.supabase_client import get_supabase
from dotenv import load_dotenv

load_dotenv()

def seed():
    db = get_supabase()
    for path in glob.glob("scenarios/*.json"):
        with open(path) as f:
            s = json.load(f)
        db.table("scenarios").upsert(s).execute()
        print(f"Seeded: {s['name']}")

if __name__ == "__main__":
    seed()
    print("All scenarios seeded.")
```

### GET /scenarios

```python
@router.get("/scenarios")
def list_scenarios():
    rows = get_supabase().table("scenarios").select("*").order("id").execute()
    return rows.data
```

### POST /run-scenario/{id}

Refactor each endpoint's logic into standalone async functions first
(`ingest_logic`, `analyze_logic`, `plan_logic`, `execute_logic`, `report_logic`),
then chain them here:

```python
@router.post("/run-scenario/{scenario_id}")
async def run_scenario(scenario_id: int):
    import time
    start = time.time()
    db = get_supabase()

    # 1. Fetch scenario
    scenario = db.table("scenarios").select("*").eq("id", scenario_id).single().execute().data

    # 2. Ingest all signals
    all_signals = []
    for sig in scenario['input_signals']:
        result = await ingest_logic(input_type=sig['type'], content=sig['content'])
        all_signals.extend(result['signals'])

    signal_ids = [s['id'] for s in all_signals]

    # 3. Analyze
    insight = await analyze_logic(signal_ids=signal_ids, signals=all_signals)

    # 4. Plan
    plan = await plan_logic(insight_id=insight['id'], insight=insight)
    plan_id = plan['id']

    # 5. Create pipeline_run (now we have plan_id)
    db.table("pipeline_runs").upsert({
        "plan_id": plan_id,
        "status": "running",
        "signals_json": all_signals,
        "insight_json": insight,
        "action_plan_json": plan
    }).execute()

    # 6. Execute
    execution_log = await execute_logic(plan_id=plan_id, plan=plan)
    db.table("pipeline_runs").upsert({
        "plan_id": plan_id,
        "status": "reporting",
        "execution_log_json": execution_log
    }).execute()

    # 7. Build report
    elapsed_ms = int((time.time() - start) * 1000)
    report = build_report_object(insight, plan, execution_log, elapsed_ms)
    db.table("pipeline_runs").upsert({
        "plan_id": plan_id,
        "status": "complete",
        "report_json": report
    }).execute()

    return report
```

---

### ✋ M7 STOP — MANUAL TESTS

```
TEST 1 — seed.py
  cd backend && python seed.py
  Supabase → scenarios table → 3 rows with ids 1, 2, 3.

TEST 2 — GET /scenarios
  Expected: array of 3 objects, each with id, name, description, input_signals.

TEST 3 — POST /run-scenario/1 (THE BIG ONE — expect 20-45 seconds)
  Call POST /run-scenario/1.
  Expected FinalReport:
    insight mentions fuel AND orders together (not one signal)
    causal_chain has → arrows
    selected_action is one committed action
    simulations_executed = 3
    all 8 Supabase tables have new rows from this run

TEST 4 — GET /logs/{plan_id} after scenario run
  Use plan_id from the run (it's the action_plans id).
  Expected: all 5 keys present — signals, insight, action_plan, execution_log, report.
  status = "complete"

TEST 5 — Scenarios 2 and 3
  POST /run-scenario/2 and /run-scenario/3.
  Both return valid FinalReport. Different scenarios → different selected_actions.
```

---

## MODULE 8 — Antigravity: 5 Agents + Orchestration

Create all 5 agents in Antigravity dashboard using your live Railway URL.

### Agent 1: insight-ingestor

**System Prompt:**
```
You are the Ingestor Agent for Insight Engine.
Accept unstructured input. Normalize it into signal objects.

Steps:
1. Identify input type: text, pdf, url, or csv
2. Call ingest_content for each input
3. Return normalized signals array to orchestrator

You do not analyze. You do not decide. You only ingest.
```
**Tool ingest_content:** POST {RAILWAY_URL}/ingest

### Agent 2: insight-analyst

**System Prompt:**
```
You are the Analyst Agent for Insight Engine.
Find CAUSAL RELATIONSHIPS across signals. Never summarize individually.

Steps:
1. Call analyze_signals with all signal IDs and content
2. The insight must explain HOW signals relate — not WHAT they say separately
3. Severity above 7 = act now

FORBIDDEN: Do not list signals as separate bullet points.
```
**Tool analyze_signals:** POST {RAILWAY_URL}/analyze

### Agent 3: insight-planner

**System Prompt:**
```
You are the Planner Agent for Insight Engine.
You COMMIT to one action. No options list. No suggestions. One decision.

Steps:
1. Call create_action_plan with the InsightReport
2. Review the committed action
3. Return the ActionPlan

CRITICAL: One action. Clearly reasoned. Committed.
```
**Tool create_action_plan:** POST {RAILWAY_URL}/plan

### Agent 4: insight-executor

**System Prompt:**
```
You are the Executor Agent for Insight Engine.
Execute the ActionPlan — write real state to the database.

Steps:
1. Call execute_actions with plan_id and plan
2. Verify 3 simulations completed: campaign, pricing, notification
3. Return ExecutionLog with before and after state

You execute. The Planner already decided.
```
**Tool execute_actions:** POST {RAILWAY_URL}/execute

### Agent 5: insight-reporter

**System Prompt:**
```
You are the Reporter Agent for Insight Engine.
Generate the final output card that judges will see.

Steps:
1. Call generate_report with execution_id and insight_id
2. Output is structured: insight → causal chain → action → outcome
3. Return FinalReport

No vague language. Be specific. Be impactful.
```
**Tool generate_report:** POST {RAILWAY_URL}/report

### Orchestration Workflow

```
Name: insight-engine-pipeline
Input: { raw_inputs: ["string1", "string2", ...] }

Step 1: insight-ingestor   → signals[]
Step 2: insight-analyst    → InsightReport
Step 3: insight-planner    → ActionPlan
Step 4: insight-executor   → ExecutionLog
Step 5: insight-reporter   → FinalReport

Output: { report: FinalReport }
```

---

### ✋ M8 STOP — MANUAL TESTS

```
TEST 1 — Each agent individually in Antigravity
  Trigger each agent with a test input.
  Expected: each calls its tool endpoint and returns valid data.

TEST 2 — Full pipeline via Antigravity
  Trigger insight-engine-pipeline with:
  { "raw_inputs": ["Lahore orders down 25%. Fuel prices up 18%."] }
  Expected: all 5 agents activate in sequence. Full FinalReport returned.

TEST 3 — Workplan trace
  Antigravity → Workplan view.
  Expected:
    All 5 agent steps marked complete.
    Tool calls visible with inputs and outputs logged.
    Decision reasoning at each step traceable.
  Screenshot this — it is the Agent Trace deliverable for judges.

TEST 4 — Supabase populated
  After Antigravity run: all tables have new rows.
  Realtime events fired on campaigns, pricing_log, notifications.
```

---

## MODULE 9 — Railway Deployment + Credential Handoff

### Deploy

```bash
# Ensure /backend/.env is in .gitignore ← confirm this before pushing
# Push monorepo to GitHub

# Railway:
# 1. Create new project → Deploy from GitHub repo
# 2. Set root directory: backend
# 3. Add env vars in Railway dashboard:
#    SUPABASE_URL, SUPABASE_KEY, GEMINI_API_KEY
# Railway auto-detects Procfile → runs uvicorn
```

### After deployment — update team files

Tell Moeez to update `mobile/lib/config.dart`:
```dart
static const String apiBase = 'https://YOUR_RAILWAY_URL.railway.app';
static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

Tell Omer to update `web/.env`:
```
VITE_API_URL=https://YOUR_RAILWAY_URL.railway.app
VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
VITE_SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

---

### ✋ M9 STOP — MANUAL TESTS

```
TEST 1 — Railway health
  GET https://YOUR_RAILWAY_URL.railway.app/health
  Expected: { "status": "ok" }

TEST 2 — Remote run
  POST https://YOUR_RAILWAY_URL.railway.app/run-scenario/1
  Expected: full FinalReport within 45 seconds.

TEST 3 — Web app connected (Omer)
  Vercel URL → click "Regional Sales Drop + Fuel Shock"
  Expected: pipeline animates, BeforeAfter panel updates with real data.

TEST 4 — Mobile app connected (Moeez)
  Device → tap Scenario 1
  Expected: stepper activates step by step, SimulationScreen shows 3 tiles live.

TEST 5 — Realtime over Railway
  Watch Moeez's SimulationScreen. Trigger POST /run-scenario/1 from curl.
  Expected: tiles appear within 2 seconds of DB writes.
```

---

## MODULE 10 — Full End-to-End Test (All 3 Scenarios)

No code. Pure testing with both frontends open.

```
Run all 3 scenarios back-to-back with web + mobile open simultaneously:

SCENARIO 1 → verify causal chain mentions fuel AND orders
SCENARIO 2 → verify different selected_action vs Scenario 1
SCENARIO 3 → verify Rupee devaluation appears in insight

ANTIGRAVITY CHECK
  3 full pipeline traces visible in Workplan.
  Each trace shows 5 steps + tool call logs.
  Screenshot all 3 — this is the judges' deliverable.

DEMO READINESS
  Can you press Scenario 1 button on web and have it run
  to full FinalReport without any error? → Ready to record.
```

---

## FINAL DEFINITION OF DONE

- [ ] M1  — Scaffold + 9 Supabase tables + Realtime on 3
- [ ] M2  — POST /ingest (text, pdf, url, csv + Gemini extraction)
- [ ] M3  — POST /analyze (causal chain, not summaries)
- [ ] M4  — POST /plan (one committed decision)
- [ ] M5  — POST /execute (3 Supabase writes + Realtime fires)
- [ ] M6  — /state/before · /state/after · /logs · /report
- [ ] M7  — /scenarios · /run-scenario · seed.py · 3 JSON files
- [ ] M8  — 5 Antigravity agents + pipeline workflow + traces visible
- [ ] M9  — Railway live · Omer and Moeez configs updated · both frontends connected
- [ ] M10 — All 3 scenarios pass end-to-end on web + mobile · demo ready

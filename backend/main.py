from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

load_dotenv()

# ── Routers ───────────────────────────────────────────────────────────────────
from routers.ingest    import router as ingest_router
from routers.analyze   import router as analyze_router
from routers.plan      import router as plan_router
from routers.execute   import router as execute_router
from routers.report    import router as report_router
from routers.state     import router as state_router
from routers.scenarios import router as scenarios_router

app = FastAPI(title="Insight Engine API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Route registration ────────────────────────────────────────────────────────
app.include_router(ingest_router)      # POST  /ingest
app.include_router(analyze_router)     # POST  /analyze
app.include_router(plan_router)        # POST  /plan
app.include_router(execute_router)     # POST  /execute
app.include_router(report_router)      # POST  /report
app.include_router(state_router)       # GET   /state/before  /state/after/{plan_id}  /logs/{plan_id}
app.include_router(scenarios_router)   # GET   /scenarios  POST /run-scenario/{id}


@app.get("/health")
def health():
    return {"status": "ok", "service": "insight-engine-api"}

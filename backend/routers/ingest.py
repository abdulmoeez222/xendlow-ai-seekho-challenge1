import json
import io
import csv
import httpx
import pdfplumber
from fastapi import APIRouter, Form, UploadFile, File
from typing import Optional
from bs4 import BeautifulSoup
from services.supabase_client import get_supabase
from services.gemini_client import generate

router = APIRouter()


async def ingest_logic(input_type: str, content: str = "", file: UploadFile = None) -> dict:
    """Core ingest logic — callable from /ingest endpoint and /run-scenario."""

    # ── Step 1: Extract raw text ──────────────────────────────────────────────
    if input_type == "text":
        raw_text = content if content.strip() else "No content provided."

    elif input_type == "url":
        try:
            async with httpx.AsyncClient() as client:
                r = await client.get(content, timeout=10)
            raw_text = BeautifulSoup(r.text, "html.parser").get_text()[:5000]
        except Exception as e:
            raw_text = f"URL fetch failed: {str(e)}"

    elif input_type == "pdf":
        data = await file.read()
        with pdfplumber.open(io.BytesIO(data)) as pdf:
            raw_text = "\n".join(p.extract_text() or "" for p in pdf.pages)
        raw_text = raw_text.strip() or "No text extracted from PDF."

    elif input_type == "csv":
        data = await file.read()
        rows = list(csv.DictReader(io.StringIO(data.decode())))
        if rows:
            raw_text = f"CSV with {len(rows)} rows. Columns: {list(rows[0].keys())}. Sample: {rows[:3]}"
        else:
            raw_text = "CSV file was empty."

    else:
        raw_text = content or "No content provided."

    # ── Step 2: Gemini extraction ─────────────────────────────────────────────
    prompt = f"""
Extract structured information from this business text.
Return JSON only — no explanation, no markdown fences.

Text: {raw_text[:3000]}

Return exactly:
{{
  "entities": ["organizations, people, locations"],
  "numbers": [{{"value": 0, "unit": "unit or %", "context": "what this refers to"}}],
  "dates": ["dates or time periods"],
  "keywords": ["important business keywords"],
  "summary": "One sentence capturing the core business fact"
}}
"""
    try:
        raw = generate(prompt, is_json=True)
        clean = raw.strip().replace("```json", "").replace("```", "").strip()
        normalized = json.loads(clean)
    except Exception:
        normalized = {
            "entities": [],
            "numbers": [],
            "dates": [],
            "keywords": [],
            "summary": "No content provided" if not raw_text.strip() else raw_text[:100],
        }

    # ── Step 3: Write to Supabase ─────────────────────────────────────────────
    row = (
        get_supabase()
        .table("signals")
        .insert({
            "source_type": input_type,
            "raw_content": raw_text[:10000],
            "normalized_json": normalized,
        })
        .execute()
        .data[0]
    )

    return {"signals": [row]}


@router.post("/ingest")
async def ingest(
    input_type: str = Form(...),
    content: str = Form(""),
    file: Optional[UploadFile] = File(None),
):
    return await ingest_logic(input_type=input_type, content=content, file=file)

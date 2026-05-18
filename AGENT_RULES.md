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

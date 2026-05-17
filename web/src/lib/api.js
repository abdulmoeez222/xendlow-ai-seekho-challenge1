const BASE = import.meta.env.VITE_API_URL

export const api = {
  runScenario: (id) => fetch(`${BASE}/run-scenario/${id}`, { method: 'POST' }).then(r => r.json()),
  runCustom: (signals) => fetch(`${BASE}/ingest`, { 
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(signals)
  }).then(r => r.json()),
  getStateBefore: () => fetch(`${BASE}/state/before`).then(r => r.json()),
  getStateAfter: (planId) => fetch(`${BASE}/state/after/${planId}`).then(r => r.json()),
  getLogs: (planId) => fetch(`${BASE}/logs/${planId}`).then(r => r.json()),
  getScenarios: () => fetch(`${BASE}/scenarios`).then(r => r.json()),
}

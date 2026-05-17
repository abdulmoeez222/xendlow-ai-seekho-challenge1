# Insight Engine 🚀

An autonomous Agentic AI system that transforms unstructured business signals into executed real-time actions. Built for the Google Antigravity Hackathon (Challenge 1).

---

## 📂 Unified Monorepo Structure

This repository is structured as a clean, unified monorepo to house the entire architecture of the Insight Engine:

```
insight-engine/
│
├── backend/                       # FastAPI Server (Autonomous Agentic Pipeline)
│
├── web/                           # React + Vite Web Dashboard
│
├── mobile/                        # Flutter Mobile Application (Our Module!)
│   ├── lib/                       # Screen implementations, state management, models
│   ├── assets/scenarios/          # Local demo scenario files
│   └── test/                      # Comprehensive unit and widget tests
│
└── docs/                          # Architecture Diagrams & Documentation
    └── InsightEngine_SRS.pdf      # Software Requirements Specification (SRS)
```

---

## 📱 Mobile App Module

The `/mobile` directory contains the cross-platform **Flutter** application, serving as the primary control center and live visualizer for the Insight Engine.

### Core Features
- **Demo Scenarios:** One-click execution of 3 predefined compounding business volatility scenarios.
- **5-Step Autonomous Tracker:** A sequence dashboard mapping Ingestor, Analyst, Planner, Executor, and Reporter agent states with live status updates.
- **Root Cause & Decision:** Beautiful visualizations for causal chains and committed mitigation actions.
- **Real-time Live Simulation:** Coordinated streams of marketing campaign cards, automated pricing adjustments, and WhatsApp notifications powered by Supabase Realtime.
- **Animated Metrics:** Responsive grid cards showcasing exact projected recovery value and customer reach.

---

## 🛠️ Getting Started (Mobile)

To run the mobile application locally:

1. Navigate to the mobile directory:
   ```bash
   cd mobile
   ```
2. Fetch Dart dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application on your physical device or emulator:
   ```bash
   flutter run
   ```

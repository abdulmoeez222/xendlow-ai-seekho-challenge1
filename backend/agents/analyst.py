from routers.analyze import analyze_logic

class AnalystAgent:
    """Agent responsible for causal analysis across ingested signals."""
    
    @staticmethod
    async def run(signals: list) -> dict:
        signal_ids = [s["id"] for s in signals]
        insight = await analyze_logic(signal_ids=signal_ids, signals=signals)
        return insight

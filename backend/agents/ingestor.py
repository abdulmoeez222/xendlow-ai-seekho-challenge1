from routers.ingest import ingest_logic

class IngestorAgent:
    """Agent responsible for ingesting signals from multiple sources."""
    
    @staticmethod
    async def run(input_signals: list) -> list:
        all_signals = []
        for sig in input_signals:
            result = await ingest_logic(input_type=sig["type"], content=sig["content"])
            all_signals.extend(result["signals"])
        return all_signals

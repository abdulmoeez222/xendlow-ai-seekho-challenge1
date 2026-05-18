from routers.report import build_report_object

class ReporterAgent:
    """Agent responsible for compiling the final execution state into a comprehensive report."""
    
    @staticmethod
    def run(insight: dict, plan: dict, execution_log: dict, elapsed_ms: int) -> dict:
        report = build_report_object(insight, plan, execution_log, elapsed_ms)
        return report

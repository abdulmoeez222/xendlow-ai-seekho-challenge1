class FinalReport {
  final String insight;
  final String causalChain;
  final double severity;
  final String selectedAction;
  final String reasoning;
  final int simulationsExecuted;
  final String projectedRevenueRecovery;
  final int projectedReach;
  final int executionTimeMs;
  final Map<String, dynamic> beforeState;
  final Map<String, dynamic> afterState;

  FinalReport({
    required this.insight,
    required this.causalChain,
    required this.severity,
    required this.selectedAction,
    required this.reasoning,
    required this.simulationsExecuted,
    required this.projectedRevenueRecovery,
    required this.projectedReach,
    required this.executionTimeMs,
    required this.beforeState,
    required this.afterState,
  });

  FinalReport.fromJson(Map<String, dynamic> j)
      : insight = j['insight'],
        causalChain = j['causal_chain'],
        severity = j['severity'].toDouble(),
        selectedAction = j['selected_action'],
        reasoning = j['reasoning'],
        simulationsExecuted = j['simulations_executed'],
        projectedRevenueRecovery = j['projected_revenue_recovery'],
        projectedReach = j['projected_reach'],
        executionTimeMs = j['execution_time_ms'],
        beforeState = j['before_state'],
        afterState = j['after_state'];
}

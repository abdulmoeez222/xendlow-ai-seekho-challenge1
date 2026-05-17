class ActionPlan {
  final String id;
  final String selectedAction;
  final String reasoning;
  final Map<String, dynamic> parameters;
  final List<Map<String, dynamic>> fallbackActions;

  ActionPlan({
    required this.id,
    required this.selectedAction,
    required this.reasoning,
    required this.parameters,
    required this.fallbackActions,
  });

  ActionPlan.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        selectedAction = j['selected_action'],
        reasoning = j['reasoning'],
        parameters = j['parameters'],
        fallbackActions = List<Map<String, dynamic>>.from(j['fallback_actions']);
}

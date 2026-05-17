class ExecutionLog {
  final String planId;
  final List<Map<String, dynamic>> steps;

  ExecutionLog({required this.planId, required this.steps});

  ExecutionLog.fromJson(Map<String, dynamic> json)
      : planId = json['plan_id'] ?? '',
        steps = List<Map<String, dynamic>>.from(json['steps'] ?? []);
}

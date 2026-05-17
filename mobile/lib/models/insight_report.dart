class InsightReport {
  final String id;
  final String primaryInsight;
  final String causalChain;
  final double severityScore;
  final List<String> affectedDomains;

  InsightReport({
    required this.id,
    required this.primaryInsight,
    required this.causalChain,
    required this.severityScore,
    required this.affectedDomains,
  });

  InsightReport.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        primaryInsight = j['primary_insight'],
        causalChain = j['causal_chain'],
        severityScore = j['severity_score'].toDouble(),
        affectedDomains = List<String>.from(j['affected_domains']);
}

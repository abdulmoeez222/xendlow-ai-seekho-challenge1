import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../models/insight_report.dart';
import '../models/action_plan.dart';
import '../providers/pipeline_provider.dart';
import '../widgets/severity_badge.dart';
import '../widgets/causal_chain.dart';
import 'action_screen.dart';

class InsightScreen extends StatelessWidget {
  final InsightReport report;
  final ActionPlan? plan;

  const InsightScreen({super.key, required this.report, this.plan});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Analysis', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'INSIGHT DETECTED',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.grey,
                  ),
                ),
                SeverityBadge(score: report.severityScore),
              ],
            ),
            const Gap(16),
            Text(
              report.primaryInsight,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const Gap(32),
            const Text(
              'CAUSAL CHAIN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.grey,
              ),
            ),
            const Gap(16),
            CausalChainWidget(causalChain: report.causalChain),
            const Gap(40),
            const Text(
              'AFFECTED DOMAINS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.grey,
              ),
            ),
            const Gap(16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: report.affectedDomains.map((domain) {
                return Chip(
                  label: Text(domain),
                  backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                  labelStyle: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                );
              }).toList(),
            ),
            const Gap(48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ActionPlan? targetPlan = plan;
                  if (targetPlan == null) {
                    try {
                      final provider = Provider.of<PipelineProvider>(context, listen: false);
                      if (provider.actionData != null) {
                        targetPlan = ActionPlan.fromJson(provider.actionData);
                      }
                    } catch (_) {}
                  }

                  // Fallback if no plan is available (e.g. mock test context)
                  targetPlan ??= ActionPlan(
                    id: 'fallback_id',
                    selectedAction: 'Strategic Price Adjustment',
                    reasoning: 'Compounding margin recovery action planning.',
                    parameters: {},
                    fallbackActions: [],
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActionScreen(plan: targetPlan!),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Review Action Strategy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

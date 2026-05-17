import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/pipeline_provider.dart';
import '../widgets/metric_card.dart';

class ImpactScreen extends StatelessWidget {
  const ImpactScreen({super.key});

  void _showSummary(BuildContext context, PipelineProvider provider) {
    final report = provider.finalReport;
    if (report == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MISSION SUMMARY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Gap(16),
            Text(
              'Insight: ${report.insight}\n\n'
              'Action Taken: ${report.selectedAction}\n\n'
              'Impact: ${report.projectedRevenueRecovery} recovery across ${report.projectedReach} users.',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const Gap(24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PipelineProvider>();
    final report = provider.finalReport;

    if (report == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Gap(40),
              // Header with animated check
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              ),
              const Gap(24),
              const Text(
                'MISSION COMPLETE',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
              ).animate().fadeIn(delay: 200.ms),
              const Gap(40),
              
              // 2x2 Grid of metrics
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  MetricCard(
                    label: 'Revenue Recovery',
                    value: report.projectedRevenueRecovery,
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                  MetricCard(
                    label: 'Customer Reach',
                    value: '${report.projectedReach} users',
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  MetricCard(
                    label: 'Actions Executed',
                    value: '${report.simulationsExecuted} sims',
                    icon: Icons.flash_on,
                    color: Colors.purple,
                  ),
                  MetricCard(
                    label: 'Pipeline Time',
                    value: '${report.executionTimeMs}ms',
                    icon: Icons.timer,
                    color: Colors.orange,
                  ),
                ],
              ),
              
              const Gap(48),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => _showSummary(context, provider),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const Gap(16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    provider.reset();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Run Again', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

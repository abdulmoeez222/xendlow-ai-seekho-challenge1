import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../models/insight_report.dart';
import '../widgets/severity_badge.dart';
import '../widgets/causal_chain.dart';
import 'action_screen.dart';

class InsightScreen extends StatelessWidget {
  final InsightReport report;

  const InsightScreen({super.key, required this.report});

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ActionScreen()),
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

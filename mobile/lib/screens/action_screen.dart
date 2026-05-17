import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../models/action_plan.dart';
import 'simulation_screen.dart';

class ActionScreen extends StatelessWidget {
  final ActionPlan plan;

  const ActionScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planner Strategy', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'COMMITTED DECISION',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const Gap(16),
            Text(
              plan.selectedAction,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const Gap(32),
            const Text(
              'REASONING',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.grey,
              ),
            ),
            const Gap(16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: const Border(
                  left: BorderSide(color: Color(0xFF2563EB), width: 4),
                ),
              ),
              child: Text(
                plan.reasoning,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const Gap(40),
            ExpansionTile(
              title: const Text(
                'Fallback Conditions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${plan.fallbackActions.length} automatic mitigations available',
                style: const TextStyle(fontSize: 12),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: plan.fallbackActions.map((fallback) {
                      final name = fallback['action'] ?? 'Unknown Action';
                      return Chip(
                        label: Text(name),
                        backgroundColor: Colors.grey[200],
                        labelStyle: const TextStyle(fontSize: 12),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const Gap(48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SimulationScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('View Execution Output', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

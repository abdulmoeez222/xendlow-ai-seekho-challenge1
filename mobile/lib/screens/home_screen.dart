import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import '../widgets/scenario_card.dart';
import '../providers/pipeline_provider.dart';
import '../services/api_service.dart';
import 'pipeline_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _inputController = TextEditingController();

  Future<void> _runScenario(int id) async {
    final provider = Provider.of<PipelineProvider>(context, listen: false);
    provider.reset();
    provider.isRunning = true;

    try {
      // 1. Get stateBefore
      final stateBefore = await ApiService.getStateBefore();
      provider.stateBefore = stateBefore;

      // 2. Call ApiService.runScenario(id) → get plan_id
      final result = await ApiService.runScenario(id);
      final planId = result['plan_id']?.toString();

      // 3. Store plan_id in provider
      provider.planId = planId;

      // 4. Navigate to PipelineScreen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PipelineScreen()),
        );
      }
    } catch (e) {
      provider.isRunning = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insight Engine',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    Gap(4),
                    Text(
                      'Autonomous Content-to-Action Agent',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(40),
              const Text(
                'DEMO SCENARIOS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
              const Gap(16),
              ScenarioCard(
                name: 'Regional Sales Drop + Fuel Shock',
                description: 'Three compounding signals hit Lahore distribution simultaneously',
                accentColor: Colors.blue,
                onTap: () => _runScenario(1),
              ),
              ScenarioCard(
                name: 'Competitor Price Drop + Inventory Surplus',
                description: 'Market pressure plus overstock creates margin and capacity crisis',
                accentColor: Colors.purple,
                onTap: () => _runScenario(2),
              ),
              ScenarioCard(
                name: 'Rupee Devaluation + Import Pipeline Exposure',
                description: 'Currency shock hits dollar-denominated inventory pipeline',
                accentColor: Colors.red,
                onTap: () => _runScenario(3),
              ),
              const Gap(32),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or enter custom input', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const Gap(32),
              TextField(
                controller: _inputController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe a business signal (e.g., "Competitor dropped prices by 10% in Karachi...")',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Logic for custom input could go here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Analyze & Act', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

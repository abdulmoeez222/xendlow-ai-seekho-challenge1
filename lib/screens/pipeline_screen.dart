import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import '../providers/pipeline_provider.dart';
import '../services/api_service.dart';
import '../widgets/step_tile.dart';

class PipelineScreen extends StatefulWidget {
  const PipelineScreen({super.key});

  @override
  State<PipelineScreen> createState() => _PipelineScreenState();
}

class _PipelineScreenState extends State<PipelineScreen> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    final provider = Provider.of<PipelineProvider>(context, listen: false);
    final planId = provider.planId;

    if (planId == null) return;

    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final logs = await ApiService.getLogs(planId);

        // Map logs to provider steps
        if (logs['signals'] != null && provider.stepStatuses[PipelineStep.ingestor] != StepStatus.done) {
          provider.setStepDone(PipelineStep.ingestor, logs['signals']);
          provider.setStepRunning(PipelineStep.analyst);
        }
        if (logs['insight'] != null && provider.stepStatuses[PipelineStep.analyst] != StepStatus.done) {
          provider.setStepDone(PipelineStep.analyst, logs['insight']);
          provider.setStepRunning(PipelineStep.planner);
        }
        if (logs['action_plan'] != null && provider.stepStatuses[PipelineStep.planner] != StepStatus.done) {
          provider.setStepDone(PipelineStep.planner, logs['action_plan']);
          provider.setStepRunning(PipelineStep.executor);
        }
        if (logs['execution_log'] != null && provider.stepStatuses[PipelineStep.executor] != StepStatus.done) {
          provider.setStepDone(PipelineStep.executor, logs['execution_log']);
          provider.setStepRunning(PipelineStep.reporter);
        }
        if (logs['final_report'] != null && provider.stepStatuses[PipelineStep.reporter] != StepStatus.done) {
          provider.setStepDone(PipelineStep.reporter, logs['final_report']);
          _pollingTimer?.cancel();
        }
      } catch (e) {
        debugPrint('Polling error: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PipelineProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Autonomous Pipeline', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            StepTile(
              title: 'Business Signal Ingestion',
              agentName: 'Ingestor Agent',
              icon: Icons.input,
              status: provider.stepStatuses[PipelineStep.ingestor]!,
              previewText: 'Scanning unstructured sources for critical volatility...',
            ),
            StepTile(
              title: 'Deep Volatility Analysis',
              agentName: 'Analyst Agent',
              icon: Icons.bar_chart,
              status: provider.stepStatuses[PipelineStep.analyst]!,
              previewText: provider.insightData?['primary_insight'],
            ),
            StepTile(
              title: 'Action Strategy Planning',
              agentName: 'Planner Agent',
              icon: Icons.track_changes,
              status: provider.stepStatuses[PipelineStep.planner]!,
              previewText: provider.actionData?['selected_action'],
            ),
            StepTile(
              title: 'Real-time Execution',
              agentName: 'Executor Agent',
              icon: Icons.bolt,
              status: provider.stepStatuses[PipelineStep.executor]!,
              previewText: 'Simulating 3 production environments...',
            ),
            StepTile(
              title: 'Business Impact Reporting',
              agentName: 'Reporter Agent',
              icon: Icons.trending_up,
              status: provider.stepStatuses[PipelineStep.reporter]!,
              previewText: provider.finalReport != null 
                ? 'Mission Complete: ${provider.finalReport!.projectedRevenueRecovery} recovery projected'
                : null,
            ),
            
            const Gap(32),
            
            if (provider.stepStatuses[PipelineStep.reporter] == StepStatus.done)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Will navigate to ImpactScreen in later module
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View Full Report', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import '../widgets/app_drawer.dart';
import '../widgets/scenario_card.dart';
import '../providers/pipeline_provider.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isPipelineActive = false;
  String? _activePlanId;
  String _pipelineStatus = 'pending'; // 'pending', 'running', 'pending_approval', 'executing', 'complete', 'rejected'
  Timer? _pollingTimer;

  // Custom step statuses tracked locally for premium control
  String _ingestorText = 'Waiting...';
  String _analystText = 'Waiting...';
  String _plannerText = 'Waiting...';
  String _executorText = 'Waiting...';
  String _reporterText = 'Waiting...';

  // State data
  Map<String, dynamic>? _insightData;
  Map<String, dynamic>? _planData;
  Map<String, dynamic>? _finalReportData;

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _runScenario(int id, String scenarioName) async {
    setState(() {
      _isPipelineActive = true;
      _pipelineStatus = 'running';
      _ingestorText = 'Normalizing CSV Order Logs... Running';
      _analystText = 'Waiting...';
      _plannerText = 'Waiting...';
      _executorText = 'Waiting...';
      _reporterText = 'Waiting...';
      _insightData = null;
      _planData = null;
      _finalReportData = null;
    });
    _scrollToBottom();

    try {
      final result = await ApiService.runScenario(id);
      final planId = result['plan_id']?.toString();
      
      setState(() {
        _activePlanId = planId;
      });

      if (planId != null) {
        _startPolling(planId);
      }
    } catch (e) {
      setState(() {
        _isPipelineActive = false;
        _pipelineStatus = 'error';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting scenario: $e')),
        );
      }
    }
  }

  void _startPolling(String planId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) async {
      try {
        final logs = await ApiService.getLogs(planId);
        
        if (logs['signals'] != null && _ingestorText.contains('Running')) {
          setState(() {
            _ingestorText = 'Normalizing CSV Order Logs... Completed';
            _analystText = 'Compounding Causal Chain... Running';
          });
          _scrollToBottom();
        }

        if (logs['insight'] != null && _analystText.contains('Running')) {
          setState(() {
            _analystText = 'Compounding Causal Chain... Completed';
            _plannerText = 'Calculating Optimal Price Strategy... Running';
            _insightData = logs['insight'];
          });
          _scrollToBottom();
        }

        if (logs['action_plan'] != null && _plannerText.contains('Running')) {
          setState(() {
            _plannerText = 'Calculating Optimal Price Strategy... Completed';
            _pipelineStatus = 'pending_approval';
            _planData = logs['action_plan'];
          });
          _pollingTimer?.cancel(); // Stop polling Phase 1
          _scrollToBottom();
        }
      } catch (e) {
        debugPrint('Polling error: $e');
      }
    });
  }

  Future<void> _approvePlan() async {
    if (_activePlanId == null) return;
    setState(() {
      _pipelineStatus = 'executing';
      _executorText = 'Applying database mutations... Running';
    });
    _scrollToBottom();

    try {
      await ApiService.approvePlan(_activePlanId!);
      
      // Start polling Phase 2 execution
      _pollingTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) async {
        try {
          final logs = await ApiService.getLogs(_activePlanId!);
          
          if (logs['execution_log'] != null && _executorText.contains('Running')) {
            setState(() {
              _executorText = 'Applying database mutations... Completed';
              _reporterText = 'Generating impact report... Running';
            });
            _scrollToBottom();
          }

          if (logs['final_report'] != null && _reporterText.contains('Running')) {
            setState(() {
              _reporterText = 'Generating impact report... Completed';
              _pipelineStatus = 'complete';
              _finalReportData = logs['final_report'];
            });
            _pollingTimer?.cancel();
            _scrollToBottom();
          }
        } catch (e) {
          debugPrint('Phase 2 polling error: $e');
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving plan: $e')),
        );
      }
    }
  }

  Future<void> _rejectPlan() async {
    if (_activePlanId == null) return;
    setState(() {
      _pipelineStatus = 'rejecting';
    });

    try {
      await ApiService.rejectPlan(_activePlanId!);
      setState(() {
        _pipelineStatus = 'rejected';
        _ingestorText = 'Aborted';
        _analystText = 'Aborted';
        _plannerText = 'Aborted';
        _executorText = 'Aborted';
        _reporterText = 'Aborted';
      });
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting plan: $e')),
        );
      }
    }
  }

  void _resetConsole() {
    setState(() {
      _isPipelineActive = false;
      _activePlanId = null;
      _pipelineStatus = 'pending';
      _ingestorText = 'Waiting...';
      _analystText = 'Waiting...';
      _plannerText = 'Waiting...';
      _executorText = 'Waiting...';
      _reporterText = 'Waiting...';
      _insightData = null;
      _planData = null;
      _finalReportData = null;
    });
  }

  Widget _buildStepItem(String stepName, String details, String status) {
    Color iconColor = Colors.grey;
    IconData icon = Icons.circle_outlined;

    if (details.contains('Completed') || details.contains('Done')) {
      iconColor = Colors.greenAccent;
      icon = Icons.check_circle_rounded;
    } else if (details.contains('Running')) {
      iconColor = const Color(0xFF3B82F6);
      icon = Icons.sync_rounded;
    } else if (details.contains('Aborted')) {
      iconColor = Colors.redAccent;
      icon = Icons.cancel_outlined;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 8),
          Text(
            '[$stepName] ',
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Expanded(
            child: Text(
              details,
              style: TextStyle(
                color: iconColor == Colors.greenAccent ? Colors.greenAccent : Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      drawer: const AppDrawer(currentRoute: 'chat'),
      appBar: AppBar(
        title: const Text(
          'Chat Console',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Token balance moon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: const Row(
              children: [
                Icon(Icons.dark_mode_rounded, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(
                  '15',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _resetConsole,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isPipelineActive) ...[
                      // Welcome & Info
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Insight AI Agent',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Select a market shock scenario to execute the autonomous operations engine.',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Scenario selectors
                      ScenarioCard(
                        name: 'Regional Sales Drop + Fuel Shock',
                        description: 'Three compounding signals hit Lahore distribution simultaneously',
                        accentColor: const Color(0xFF3B82F6),
                        onTap: () => _runScenario(1, 'Scenario 1: Regional Sales Drop + Fuel Shock'),
                      ),
                      ScenarioCard(
                        name: 'Competitor Price Drop + Inventory Surplus',
                        description: 'Market pressure plus overstock creates margin and capacity crisis',
                        accentColor: const Color(0xFF8B5CF6),
                        onTap: () => _runScenario(2, 'Scenario 2: Competitor Price Drop + Inventory Surplus'),
                      ),
                      ScenarioCard(
                        name: 'Rupee Devaluation + Import Pipeline Exposure',
                        description: 'Currency shock hits dollar-denominated inventory pipeline',
                        accentColor: const Color(0xFFEF4444),
                        onTap: () => _runScenario(3, 'Scenario 3: Rupee Devaluation + Import Pipeline Exposure'),
                      ),
                    ] else ...[
                      // Chat log view representing the agent pipeline
                      
                      // Message 1: User selection
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(left: 48, bottom: 16),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Analyze and formulate action for: ${_activePlanId != null ? "Active Run" : "Scenario"}',
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),

                      // Stepper Frame Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(right: 32, bottom: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.tune_rounded, color: Color(0xFF3B82F6), size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  _pipelineStatus == 'complete' ? 'Pipeline complete' : 'Agent Pipeline Status',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                            const Divider(color: Color(0xFF334155), height: 20),
                            _buildStepItem('Ingestor', _ingestorText, _pipelineStatus),
                            _buildStepItem('Analyst', _analystText, _pipelineStatus),
                            _buildStepItem('Planner', _plannerText, _pipelineStatus),
                            _buildStepItem('Executor', _executorText, _pipelineStatus),
                            _buildStepItem('Reporter', _reporterText, _pipelineStatus),
                          ],
                        ),
                      ),

                      // Phase 1 Completion and HITL Proposal
                      if (_planData != null) ...[
                        // Proposal Bubble
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(right: 32, bottom: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PROPOSED STRATEGY',
                                style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _planData!['selected_action'] ?? '',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              
                              // Before/After comparison box
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Text('Before:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _planData!['action_type'] == 'campaign' 
                                            ? 'Active - PKR 22K/day spend, ROAS 1.8x' 
                                            : 'Product Price: PKR 2,000',
                                        style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 14),
                                    const SizedBox(width: 8),
                                    const Text('After:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _planData!['action_type'] == 'campaign' 
                                            ? 'Paused - Shift to Meta Summer Sale' 
                                            : 'Product Price: PKR 1,800',
                                        style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              const Text(
                                'Agent Reasoning Citation:',
                                style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _planData!['reasoning'] ?? '',
                                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                              ),
                              
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF065F46).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF047857).withOpacity(0.3)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent, size: 14),
                                    SizedBox(width: 6),
                                    Text(
                                      'Save PKR 154K/wk, redirect to high-performing channel',
                                      style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action Buttons if awaiting approval
                        if (_pipelineStatus == 'pending_approval') ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: OutlinedButton(
                                      onPressed: _rejectPlan,
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.redAccent),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text('Reject (Abandon)', style: TextStyle(color: Colors.redAccent)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _approvePlan,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text('Accept (Execute)', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],

                      // Reject/Cancel View
                      if (_pipelineStatus == 'rejected') ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7F1D1D).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFB91C1C).withOpacity(0.3)),
                          ),
                          child: const Text(
                            'Plan rejected. Autonomous execution aborted.',
                            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],

                      // Phase 2 Final Report Card
                      if (_pipelineStatus == 'complete' && _finalReportData != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(right: 32, bottom: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 18),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Plan accepted and executed',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                              const Divider(color: Color(0xFF334155), height: 20),
                              Text(
                                _finalReportData!['projected_revenue_recovery'] ?? 'Execution and mutations complete.',
                                style: const TextStyle(color: Colors.greenAccent, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _finalReportData!['summary_report'] ?? '',
                                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            
            // Bottom Chat Input Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF0B0F19),
                border: Border(top: BorderSide(color: Color(0xFF1E293B))),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file_rounded, color: Colors.grey),
                    onPressed: () {
                      // Attach file mockup toast
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('File attachment catalog opened.')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic_none_rounded, color: Colors.grey),
                    onPressed: () {
                      // Mic voice-input mockup
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Listening for voice instruction...')),
                      );
                    },
                  ),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _inputController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: _isPipelineActive 
                              ? 'Type an instruction...' 
                              : 'Type a signal or instruction...',
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (val) {
                          if (val.trim().isEmpty) return;
                          _inputController.clear();
                          _runScenario(2, val); // Defaults to scenario 2 mock for custom triggers
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: Color(0xFF2563EB)),
                    onPressed: () {
                      final val = _inputController.text.trim();
                      if (val.isEmpty) return;
                      _inputController.clear();
                      _runScenario(2, val);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

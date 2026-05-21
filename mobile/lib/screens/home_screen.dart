import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../services/api_service.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _bg           = Color(0xFF0A0A0A);
const _surface      = Color(0xFF111111);
const _surfaceHover = Color(0xFF181818);
const _border       = Color(0xFF222222);
const _borderSubtle = Color(0xFF1A1A1A);
const _textPrimary  = Color(0xFFFFFFFF);
const _textSecondary= Color(0xFF8C8C8C);
const _textTertiary = Color(0xFF555555);
// ──────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isPipelineActive = false;
  String? _activePlanId;
  String _pipelineStatus = 'pending';
  Timer? _pollingTimer;
  late AnimationController _dotAnimController;

  String _ingestorText = 'Waiting';
  String _analystText  = 'Waiting';
  String _plannerText  = 'Waiting';
  String _executorText = 'Waiting';
  String _reporterText = 'Waiting';

  Map<String, dynamic>? _insightData;
  Map<String, dynamic>? _planData;
  Map<String, dynamic>? _finalReportData;

  @override
  void initState() {
    super.initState();
    _dotAnimController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    _dotAnimController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _runScenario(int id, String scenarioName) async {
    setState(() {
      _isPipelineActive = true;
      _pipelineStatus = 'running';
      _ingestorText = 'Running';
      _analystText  = 'Waiting';
      _plannerText  = 'Waiting';
      _executorText = 'Waiting';
      _reporterText = 'Waiting';
      _insightData  = null;
      _planData     = null;
      _finalReportData = null;
    });
    _scrollToBottom();

    try {
      final result = await ApiService.runScenario(id);
      final planId = result['plan_id']?.toString();
      setState(() => _activePlanId = planId);
      if (planId != null) _startPolling(planId);
    } catch (e) {
      setState(() { _isPipelineActive = false; _pipelineStatus = 'error'; });
    }
  }

  void _startPolling(String planId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) async {
      try {
        final logs = await ApiService.getLogs(planId);

        if (logs['signals'] != null && _ingestorText == 'Running') {
          setState(() { _ingestorText = 'Done'; _analystText = 'Running'; });
          _scrollToBottom();
        }
        if (logs['insight'] != null && _analystText == 'Running') {
          setState(() {
            _analystText = 'Done';
            _plannerText = 'Running';
            _insightData = logs['insight'];
          });
          _scrollToBottom();
        }
        if (logs['action_plan'] != null && _plannerText == 'Running') {
          setState(() {
            _plannerText = 'Done';
            _pipelineStatus = 'pending_approval';
            _planData = logs['action_plan'];
          });
          _pollingTimer?.cancel();
          _scrollToBottom();
        }
        if (logs['status'] == 'failed') {
          setState(() { _pipelineStatus = 'error'; });
          _pollingTimer?.cancel();
        }
      } catch (_) {}
    });
  }

  Future<void> _approvePlan() async {
    if (_activePlanId == null) return;
    setState(() { _pipelineStatus = 'executing'; _executorText = 'Running'; });
    _scrollToBottom();

    try {
      await ApiService.approvePlan(_activePlanId!);
      _pollingTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) async {
        try {
          final logs = await ApiService.getLogs(_activePlanId!);
          if (logs['execution_log'] != null && _executorText == 'Running') {
            setState(() { _executorText = 'Done'; _reporterText = 'Running'; });
            _scrollToBottom();
          }
          if (logs['final_report'] != null && _reporterText == 'Running') {
            setState(() {
              _reporterText = 'Done';
              _pipelineStatus = 'complete';
              _finalReportData = logs['final_report'];
            });
            _pollingTimer?.cancel();
            _scrollToBottom();
          }
        } catch (_) {}
      });
    } catch (_) {}
  }

  Future<void> _rejectPlan() async {
    if (_activePlanId == null) return;
    try {
      await ApiService.rejectPlan(_activePlanId!);
      setState(() {
        _pipelineStatus = 'rejected';
        _ingestorText = _analystText = _plannerText = _executorText = _reporterText = 'Aborted';
      });
    } catch (_) {}
  }

  void _resetConsole() {
    _pollingTimer?.cancel();
    setState(() {
      _isPipelineActive = false;
      _activePlanId = null;
      _pipelineStatus = 'pending';
      _ingestorText = _analystText = _plannerText = _executorText = _reporterText = 'Waiting';
      _insightData = _planData = _finalReportData = null;
    });
  }

  // ── Widgets ─────────────────────────────────────────────────────────────────

  Widget _stepRow(String label, String status) {
    final bool isDone    = status == 'Done';
    final bool isRunning = status == 'Running';
    final bool isAborted = status == 'Aborted';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: isDone
                ? const Icon(Icons.check, size: 14, color: _textPrimary)
                : isAborted
                    ? const Icon(Icons.remove, size: 14, color: _textTertiary)
                    : isRunning
                        ? FadeTransition(
                            opacity: _dotAnimController,
                            child: Container(
                              width: 6, height: 6,
                              margin: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: _textPrimary,
                              ),
                            ),
                          )
                        : Container(
                            width: 6, height: 6,
                            margin: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: _textTertiary,
                            ),
                          ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: isDone ? _textPrimary : isRunning ? _textPrimary : _textTertiary,
              fontSize: 13,
              fontWeight: isRunning ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            isDone ? 'Complete' : isRunning ? 'Processing...' : isAborted ? 'Aborted' : '',
            style: TextStyle(
              color: isDone ? _textSecondary : isRunning ? _textSecondary : _textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiMessage(Widget child) => Padding(
    padding: const EdgeInsets.only(bottom: 20, right: 48),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28, height: 28,
          decoration: const BoxDecoration(
            color: _textPrimary, shape: BoxShape.circle,
          ),
          child: const Icon(Icons.bolt, color: _bg, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    ),
  );

  Widget _userMessage(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 20, left: 48),
    child: Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
        ),
        child: Text(text, style: const TextStyle(color: _textPrimary, fontSize: 14, height: 1.4)),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      drawer: const AppDrawer(currentRoute: 'chat'),
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: _textPrimary),
        title: const Text(
          'Insight AI',
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _borderSubtle),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _textSecondary, size: 20),
            onPressed: _resetConsole,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_isPipelineActive) ...[
                    // ── Welcome state ──────────────────────────────────────
                    const Padding(
                      padding: EdgeInsets.only(bottom: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Autonomous Operations Engine',
                            style: TextStyle(
                              color: _textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Select a scenario or type a signal to activate the 5-agent pipeline.',
                            style: TextStyle(color: _textSecondary, fontSize: 14, height: 1.5),
                          ),
                        ],
                      ),
                    ),

                    // Scenario tiles
                    _ScenarioTile(
                      index: '01',
                      title: 'Regional Sales Drop + Fuel Shock',
                      subtitle: 'Three compounding signals hit Lahore distribution simultaneously',
                      onTap: () => _runScenario(1, 'Scenario 1'),
                    ),
                    const SizedBox(height: 8),
                    _ScenarioTile(
                      index: '02',
                      title: 'Competitor Price Drop + Inventory Surplus',
                      subtitle: 'Market pressure plus overstock creates margin and capacity crisis',
                      onTap: () => _runScenario(2, 'Scenario 2'),
                    ),
                    const SizedBox(height: 8),
                    _ScenarioTile(
                      index: '03',
                      title: 'Rupee Devaluation + Import Pipeline Exposure',
                      subtitle: 'Currency shock hits dollar-denominated inventory pipeline',
                      onTap: () => _runScenario(3, 'Scenario 3'),
                    ),
                  ] else ...[
                    // ── Active pipeline view ───────────────────────────────

                    // User message
                    _userMessage('Analyze and formulate action plan for the selected scenario.'),

                    // Agent pipeline status card
                    _aiMessage(
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Running pipeline',
                              style: TextStyle(
                                color: _textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _stepRow('Ingestor — Normalizing signal data', _ingestorText),
                            _divider(),
                            _stepRow('Analyst — Compounding causal chain', _analystText),
                            _divider(),
                            _stepRow('Planner — Generating action candidates', _plannerText),
                            _divider(),
                            _stepRow('Executor — Applying store mutations', _executorText),
                            _divider(),
                            _stepRow('Reporter — Compiling impact report', _reporterText),
                          ],
                        ),
                      ),
                    ),

                    // Planner output — approval gate
                    if (_planData != null) ...[
                      _aiMessage(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Recommended Action',
                                    style: TextStyle(
                                      color: _textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _planData!['selected_action'] ?? '',
                                    style: const TextStyle(
                                      color: _textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Before → After row
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _bg,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: _borderSubtle),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _planData!['action_type'] == 'campaign'
                                                ? 'Active · PKR 22K/day · ROAS 1.8x'
                                                : 'Price: PKR ${_planData!['parameters']?['before_value'] ?? '—'}',
                                            style: const TextStyle(color: _textTertiary, fontSize: 12),
                                          ),
                                        ),
                                        const Icon(Icons.arrow_forward, color: _textTertiary, size: 14),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 8),
                                            child: Text(
                                              _planData!['action_type'] == 'campaign'
                                                  ? 'Paused · Redirect to seasonal'
                                                  : 'Price: PKR ${_planData!['parameters']?['after_value'] ?? '—'}',
                                              style: const TextStyle(color: _textPrimary, fontSize: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  if ((_planData!['reasoning'] ?? '').toString().isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      (_planData!['reasoning'] ?? '').toString().length > 180
                                          ? '${(_planData!['reasoning'] ?? '').toString().substring(0, 180)}…'
                                          : (_planData!['reasoning'] ?? '').toString(),
                                      style: const TextStyle(color: _textSecondary, fontSize: 13, height: 1.5),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // HITL buttons
                            if (_pipelineStatus == 'pending_approval') ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _ActionButton(
                                      label: 'Reject',
                                      isPrimary: false,
                                      onTap: _rejectPlan,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _ActionButton(
                                      label: 'Accept & Execute',
                                      isPrimary: true,
                                      onTap: _approvePlan,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    // Rejected state
                    if (_pipelineStatus == 'rejected')
                      _aiMessage(
                        const Text(
                          'Plan rejected. Autonomous execution aborted. The pipeline has been halted.',
                          style: TextStyle(color: _textSecondary, fontSize: 14, height: 1.5),
                        ),
                      ),

                    // Final report
                    if (_pipelineStatus == 'complete' && _finalReportData != null)
                      _aiMessage(
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, color: _textPrimary, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    _finalReportData!['projected_revenue_recovery'] ?? 'Execution complete',
                                    style: const TextStyle(
                                      color: _textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _finalReportData!['summary_report'] ?? 
                                _finalReportData!['executive_summary_markdown'] ?? '',
                                style: const TextStyle(color: _textSecondary, fontSize: 13, height: 1.6),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Error state
                    if (_pipelineStatus == 'error')
                      _aiMessage(
                        const Text(
                          'The pipeline encountered an error. Please reset and try again.',
                          style: TextStyle(color: _textSecondary, fontSize: 14),
                        ),
                      ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Bottom input bar ───────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: _bg,
              border: Border(top: BorderSide(color: _borderSubtle)),
            ),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
            child: Container(
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      style: const TextStyle(color: _textPrimary, fontSize: 14, height: 1.4),
                      maxLines: 4,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: _isPipelineActive
                            ? 'Type an instruction…'
                            : 'Describe a market signal or instruction…',
                        hintStyle: const TextStyle(color: _textTertiary, fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isEmpty) return;
                        _inputController.clear();
                        _runScenario(2, val);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        final val = _inputController.text.trim();
                        if (val.isEmpty) return;
                        _inputController.clear();
                        _runScenario(2, val);
                      },
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: _inputController.text.trim().isEmpty ? _surface : _textPrimary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _border),
                        ),
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          color: _inputController.text.trim().isEmpty ? _textTertiary : _bg,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(color: _borderSubtle, height: 14);
}

// ── Scenario Tile ─────────────────────────────────────────────────────────────
class _ScenarioTile extends StatefulWidget {
  final String index;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ScenarioTile({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_ScenarioTile> createState() => _ScenarioTileState();
}

class _ScenarioTileState extends State<_ScenarioTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _hovered ? _surfaceHover : _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _hovered ? const Color(0xFF333333) : _border),
        ),
        child: Row(
          children: [
            Text(
              widget.index,
              style: const TextStyle(color: _textTertiary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(color: _textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: _textTertiary, size: 12),
          ],
        ),
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary ? _textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isPrimary ? _textPrimary : _border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isPrimary ? _bg : _textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

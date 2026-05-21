import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart';

const _bg            = Color(0xFF0A0A0A);
const _surface       = Color(0xFF111111);
const _border        = Color(0xFF1F1F1F);
const _borderSubtle  = Color(0xFF161616);
const _textPrimary   = Color(0xFFFFFFFF);
const _textSecondary = Color(0xFF8C8C8C);
const _textTertiary  = Color(0xFF444444);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  double _totalSpend = 850000.0;
  int _campaignsBelowThreshold = 1;
  int _activeCampaignsCount = 3;

  @override
  void initState() {
    super.initState();
    _fetchDbMetrics();
  }

  Future<void> _fetchDbMetrics() async {
    try {
      final list = (await _supabase.from('marketing_campaigns').select()) as List<dynamic>? ?? [];
      double spendSum = 0; int below = 0; int active = 0;
      for (var c in list) {
        if (c['active'] == true) {
          spendSum += (c['spend'] ?? 0).toDouble(); active++;
          if ((c['roas'] ?? 0).toDouble() < 2.0) below++;
        }
      }
      if (mounted) {
        setState(() {
          _totalSpend = spendSum > 0 ? spendSum : 850000.0;
          _campaignsBelowThreshold = below;
          _activeCampaignsCount = active;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spendStr = _totalSpend >= 1000
        ? 'PKR ${(_totalSpend / 1000).toStringAsFixed(0)}K'
        : 'PKR ${_totalSpend.toStringAsFixed(0)}';

    return Scaffold(
      backgroundColor: _bg,
      drawer: const AppDrawer(currentRoute: 'dashboard'),
      appBar: _appBar('Dashboard'),
      body: RefreshIndicator(
        color: _textPrimary,
        backgroundColor: _surface,
        onRefresh: _fetchDbMetrics,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                const LinearProgressIndicator(
                  color: _textPrimary,
                  backgroundColor: _borderSubtle,
                  minHeight: 1,
                ),
              const SizedBox(height: 8),

              // ── KPI grid ──────────────────────────────────────────────────
              const _SectionLabel('KEY METRICS'),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.45,
                children: [
                  _MetricCard(label: 'Revenue', value: 'PKR 2.4M',  delta: '+12.4%', positive: true),
                  _MetricCard(label: 'Ad Spend', value: spendStr,   delta: '+8.2%',  positive: false),
                  _MetricCard(label: 'Net Profit', value: 'PKR 1.2M', delta: '+15.1%', positive: true),
                  _MetricCard(label: 'Conversion', value: '3.2%',   delta: '-0.4pp', positive: false),
                ],
              ),
              const SizedBox(height: 24),

              // ── Revenue bar chart ──────────────────────────────────────────
              const _SectionLabel('REVENUE — THIS WEEK'),
              const SizedBox(height: 10),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('May 2026', style: TextStyle(color: _textSecondary, fontSize: 13)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _borderSubtle,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('7d', style: TextStyle(color: _textSecondary, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _Bar('M', 0.35, false),
                          _Bar('T', 0.48, false),
                          _Bar('W', 0.62, false),
                          _Bar('T', 0.55, false),
                          _Bar('F', 0.95, true),
                          _Bar('S', 0.75, false),
                          _Bar('S', 0.40, false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Alert ──────────────────────────────────────────────────────
              if (_campaignsBelowThreshold > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Color(0xFFFF4D4D),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$_campaignsBelowThreshold campaign below 2.0x ROAS — budget at risk',
                          style: const TextStyle(color: _textSecondary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String delta;
  final bool positive;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.delta,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: _textSecondary, fontSize: 12)),
          Text(
            value,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            delta,
            style: TextStyle(
              color: positive ? const Color(0xFF6EE7B7) : const Color(0xFFFF9999),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String day;
  final double pct;
  final bool highlight;
  const _Bar(this.day, this.pct, this.highlight);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 100 * pct,
          decoration: BoxDecoration(
            color: highlight ? _textPrimary : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: TextStyle(
            color: highlight ? _textPrimary : _textTertiary,
            fontSize: 11,
            fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _textTertiary,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

AppBar _appBar(String title) => AppBar(
  backgroundColor: _bg,
  elevation: 0,
  scrolledUnderElevation: 0,
  iconTheme: const IconThemeData(color: _textPrimary),
  centerTitle: false,
  title: Text(
    title,
    style: const TextStyle(
      color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w600,
    ),
  ),
  bottom: const PreferredSize(
    preferredSize: Size.fromHeight(1),
    child: Divider(height: 1, color: Color(0xFF1A1A1A)),
  ),
);

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  double _totalSpend = 850000.0; // Default mockup baseline
  int _campaignsBelowThreshold = 1;
  int _activeCampaignsCount = 3;

  @override
  void initState() {
    super.initState();
    _fetchDbMetrics();
  }

  Future<void> _fetchDbMetrics() async {
    try {
      final campaignsData = await _supabase.from('marketing_campaigns').select();
      final list = campaignsData as List<dynamic>? ?? [];
      double spendSum = 0;
      int belowThreshold = 0;
      int activeCount = 0;
      for (var c in list) {
        if (c['active'] == true) {
          spendSum += (c['spend'] ?? 0).toDouble();
          activeCount++;
          if ((c['roas'] ?? 0).toDouble() < 2.0) {
            belowThreshold++;
          }
        }
      }
      if (mounted) {
        setState(() {
          // Add to baseline to keep realistic scale if needed, or use exact db values
          // If we want exact screenshot scale:
          _totalSpend = spendSum > 0 ? spendSum : 850000.0;
          _campaignsBelowThreshold = belowThreshold;
          _activeCampaignsCount = activeCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                color: isPositive ? Colors.greenAccent : Colors.redAccent,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  color: isPositive ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double heightPct, bool isHighlighted) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 120 * heightPct,
          width: 18,
          decoration: BoxDecoration(
            color: isHighlighted ? const Color(0xFF3B82F6) : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(4),
            border: isHighlighted ? null : Border.all(color: const Color(0xFF334155)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            color: isHighlighted ? Colors.white : Colors.grey,
            fontSize: 11,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatSpend = _totalSpend >= 1000 ? '${(_totalSpend / 1000).toStringAsFixed(0)}K' : _totalSpend.toString();
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      drawer: const AppDrawer(currentRoute: 'dashboard'),
      appBar: AppBar(
        title: const Text(
          'Store Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
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
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDbMetrics,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                const LinearProgressIndicator(color: Color(0xFF2563EB), backgroundColor: Color(0xFF1E293B)),
              
              const Text(
                'Overview metrics',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              // Grid of metrics
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildMetricCard(
                    title: 'Revenue',
                    value: 'PKR 2.4M',
                    change: '+12.4%',
                    isPositive: true,
                    color: Colors.blue,
                  ),
                  _buildMetricCard(
                    title: 'Ad Costs',
                    value: 'PKR $formatSpend',
                    change: '+8.2%',
                    isPositive: true,
                    color: Colors.purple,
                  ),
                  _buildMetricCard(
                    title: 'Net Profit',
                    value: 'PKR 1.2M',
                    change: '+15.1%',
                    isPositive: true,
                    color: Colors.green,
                  ),
                  _buildMetricCard(
                    title: 'Conversion Rate',
                    value: '3.2%',
                    change: '-0.4pp',
                    isPositive: false,
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Revenue chart card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Revenue this week',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Last 30 days · May 2026',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBar('M', 0.35, false),
                        _buildBar('T', 0.48, false),
                        _buildBar('W', 0.62, false),
                        _buildBar('T', 0.55, false),
                        _buildBar('F', 0.95, true), // Highlighted Friday
                        _buildBar('S', 0.75, false),
                        _buildBar('S', 0.40, false),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Alerts panel
              if (_campaignsBelowThreshold > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F1D1D).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFB91C1C).withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ROAS Alert Warning',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$_campaignsBelowThreshold campaign below 2.0x ROAS threshold. Retargeting campaign is burning budget.',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
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

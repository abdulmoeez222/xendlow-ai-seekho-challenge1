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

AppBar _appBar(String title) => AppBar(
  backgroundColor: _bg, elevation: 0, scrolledUnderElevation: 0,
  iconTheme: const IconThemeData(color: _textPrimary),
  title: Text(title, style: const TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
  bottom: const PreferredSize(
    preferredSize: Size.fromHeight(1),
    child: Divider(height: 1, color: Color(0xFF1A1A1A)),
  ),
);

class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _campaigns = [];
  int _underperforming = 0;

  @override
  void initState() { super.initState(); _fetchCampaigns(); }

  Future<void> _fetchCampaigns() async {
    try {
      final list = (await _supabase.from('marketing_campaigns').select().order('campaign_name')) as List<dynamic>? ?? [];
      int u = 0;
      for (var c in list) {
        if ((c['active'] ?? false) && (c['roas'] ?? 0).toDouble() < 2.0) u++;
      }
      if (mounted) setState(() { _campaigns = list; _underperforming = u; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      drawer: const AppDrawer(currentRoute: 'ads'),
      appBar: _appBar('Ad Campaigns'),
      body: RefreshIndicator(
        color: _textPrimary,
        backgroundColor: _surface,
        onRefresh: _fetchCampaigns,
        child: Column(
          children: [
            if (_isLoading)
              const LinearProgressIndicator(color: _textPrimary, backgroundColor: _borderSubtle, minHeight: 1),

            if (_underperforming > 0)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFF9999)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$_underperforming campaign below 2.0x ROAS threshold',
                      style: const TextStyle(color: _textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: _campaigns.isEmpty && !_isLoading
                  ? const Center(child: Text('No campaigns found.', style: TextStyle(color: _textTertiary, fontSize: 14)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: _campaigns.length,
                      itemBuilder: (ctx, i) {
                        final c = _campaigns[i];
                        final String  network     = (c['network'] ?? 'meta').toUpperCase();
                        final String  name        = c['campaign_name'] ?? '';
                        final double  spend       = (c['spend'] ?? 0).toDouble();
                        final int     clicks      = c['clicks'] ?? 0;
                        final int     conversions = c['conversions'] ?? 0;
                        final double  roas        = (c['roas'] ?? 0).toDouble();
                        final bool    active      = c['active'] ?? false;
                        final bool    underp      = active && roas < 2.0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: active ? _surface : _borderSubtle,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '$network · $name',
                                      style: TextStyle(
                                        color: active ? _textPrimary : _textTertiary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _bg,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: _border),
                                    ),
                                    child: Text(
                                      active ? 'Active' : 'Paused',
                                      style: TextStyle(
                                        color: active ? _textSecondary : _textTertiary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _CampStat(label: 'Spend/day', value: 'PKR ${spend.toStringAsFixed(0)}'),
                                  _CampStat(label: 'Clicks',    value: clicks.toString()),
                                  _CampStat(label: 'Convs',     value: conversions.toString()),
                                  _CampStat(
                                    label: 'ROAS',
                                    value: '${roas.toStringAsFixed(1)}x',
                                    warn: underp,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampStat extends StatelessWidget {
  final String label;
  final String value;
  final bool warn;
  const _CampStat({required this.label, required this.value, this.warn = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _textTertiary, fontSize: 10)),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: warn ? const Color(0xFFFF9999) : _textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

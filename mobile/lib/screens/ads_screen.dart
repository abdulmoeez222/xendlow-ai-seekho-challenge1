import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart';

class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _campaigns = [];
  int _underperformingCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCampaigns();
  }

  Future<void> _fetchCampaigns() async {
    try {
      final res = await _supabase
          .from('marketing_campaigns')
          .select()
          .order('campaign_name', ascending: true);
      
      final list = res as List<dynamic>? ?? [];
      int underperforming = 0;
      for (var c in list) {
        final roas = (c['roas'] ?? 0).toDouble();
        final active = c['active'] ?? false;
        if (active && roas < 2.0) {
          underperforming++;
        }
      }

      if (mounted) {
        setState(() {
          _campaigns = list;
          _underperformingCount = underperforming;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      drawer: const AppDrawer(currentRoute: 'ads'),
      appBar: AppBar(
        title: const Text(
          'Ad Campaigns',
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
        onRefresh: _fetchCampaigns,
        child: Column(
          children: [
            if (_isLoading)
              const LinearProgressIndicator(color: Color(0xFF2563EB), backgroundColor: Color(0xFF1E293B)),
            
            // Warnings Banner
            if (_underperformingCount > 0)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF7F1D1D).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB91C1C).withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$_underperformingCount campaign below 2.0x ROAS threshold',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            
            Expanded(
              child: _campaigns.isEmpty && !_isLoading
                  ? const Center(
                      child: Text(
                        'No marketing campaigns found.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _campaigns.length,
                      itemBuilder: (context, index) {
                        final c = _campaigns[index];
                        final String network = c['network'] ?? 'meta';
                        final String name = c['campaign_name'] ?? '';
                        final double spend = (c['spend'] ?? 0).toDouble();
                        final int clicks = c['clicks'] ?? 0;
                        final int conversions = c['conversions'] ?? 0;
                        final double roas = (c['roas'] ?? 0).toDouble();
                        final bool active = c['active'] ?? false;

                        // Network Icon
                        IconData networkIcon = Icons.facebook_rounded;
                        Color networkColor = const Color(0xFF1877F2); // Facebook blue
                        if (network.toLowerCase() == 'google') {
                          networkIcon = Icons.g_mobiledata_rounded;
                          networkColor = const Color(0xFFEA4335); // Google red
                        }

                        Color roasColor = roas < 2.0 ? Colors.redAccent : Colors.greenAccent;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: active ? const Color(0xFF1E293B) : const Color(0xFF1E293B).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: active ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.01),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: networkColor.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          networkIcon,
                                          color: networkColor,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${network.toUpperCase()} $name',
                                        style: TextStyle(
                                          color: active ? Colors.white : Colors.grey,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: active ? Colors.greenAccent.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: active ? Colors.greenAccent.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      active ? 'Active' : 'Paused',
                                      style: TextStyle(
                                        color: active ? Colors.greenAccent : Colors.grey,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Spend/day', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                      const SizedBox(height: 2),
                                      Text(
                                        'PKR ${spend.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color: active ? Colors.white : Colors.grey,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Clicks', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                      const SizedBox(height: 2),
                                      Text(
                                        clicks.toString(),
                                        style: TextStyle(
                                          color: active ? Colors.white : Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Convs', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                      const SizedBox(height: 2),
                                      Text(
                                        conversions.toString(),
                                        style: TextStyle(
                                          color: active ? Colors.white : Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('ROAS', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${roas.toStringAsFixed(1)}x',
                                        style: TextStyle(
                                          color: active ? roasColor : Colors.grey,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
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

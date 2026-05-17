import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/pipeline_provider.dart';
import '../widgets/campaign_card.dart';
import '../widgets/pricing_diff.dart';
import '../widgets/whatsapp_bubble.dart';
import 'impact_screen.dart';

class SimulationScreen extends StatelessWidget {
  const SimulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PipelineProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Live Execution', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'REAL-TIME SIMULATION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.grey,
              ),
            ),
            const Gap(24),
            
            // Tile 1: Campaign
            if (provider.liveCampaigns.isNotEmpty)
              CampaignCard(
                region: provider.liveCampaigns.first['region'] ?? 'Unknown',
                discountPct: provider.liveCampaigns.first['discount_pct'] ?? 0,
              )
            else
              _buildShimmerPlaceholder(),
              
            const Gap(24),
            
            // Tile 2: Pricing
            if (provider.livePricing.isNotEmpty)
              PricingDiff(
                itemName: provider.livePricing.first['item_name'] ?? 'Item',
                oldValue: provider.livePricing.first['old_price']?.toString() ?? '0',
                newValue: provider.livePricing.first['new_price']?.toString() ?? '0',
              )
            else
              _buildShimmerPlaceholder(),
              
            const Gap(24),
            
            // Tile 3: Notification
            if (provider.liveNotifications.isNotEmpty)
              WhatsAppBubble(
                message: provider.liveNotifications.first['message_body'] ?? '',
                recipientCount: provider.liveNotifications.first['recipient_count'] ?? 0,
              )
            else
              _buildShimmerPlaceholder(),
              
            const Gap(48),
            
            if (provider.stepStatuses[PipelineStep.reporter] == StepStatus.done)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ImpactScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View Impact Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

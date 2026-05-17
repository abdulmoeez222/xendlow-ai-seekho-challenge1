import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

class CampaignCard extends StatelessWidget {
  final String region;
  final int discountPct;

  const CampaignCard({
    super.key,
    required this.region,
    required this.discountPct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Campaign Created',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const Gap(12),
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF2563EB), size: 16),
              const Gap(8),
              Text(region, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const Gap(8),
          Text(
            '$discountPct% discount applied to all affected SKUs',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOut).fadeIn();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

class PricingDiff extends StatelessWidget {
  final String itemName;
  final String oldValue;
  final String newValue;

  const PricingDiff({
    super.key,
    required this.itemName,
    required this.oldValue,
    required this.newValue,
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
          Text(
            itemName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const Gap(12),
          Row(
            children: [
              Text(
                oldValue,
                style: const TextStyle(
                  color: Colors.red,
                  decoration: TextDecoration.lineThrough,
                  fontSize: 18,
                ),
              ).animate().fadeOut(duration: 600.ms, delay: 200.ms),
              const Gap(12),
              const Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 16),
              const Gap(12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  newValue,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ).animate().slideX(begin: 0.5, duration: 400.ms, curve: Curves.easeOutQuad).fadeIn(),
            ],
          ),
        ],
      ),
    );
  }
}

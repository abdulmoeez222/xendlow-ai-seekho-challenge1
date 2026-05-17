import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CausalChainWidget extends StatelessWidget {
  final String causalChain;

  const CausalChainWidget({super.key, required this.causalChain});

  @override
  Widget build(BuildContext context) {
    final segments = causalChain.split(' → ');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: segments.asMap().entries.map((entry) {
          final idx = entry.key;
          final segment = entry.value;

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  segment,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              if (idx < segments.length - 1) ...[
                const Gap(8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF2563EB),
                  size: 18,
                ),
                const Gap(8),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }
}

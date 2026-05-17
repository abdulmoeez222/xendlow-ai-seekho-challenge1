import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class BeforeAfterTile extends StatelessWidget {
  final String label;
  final String before;
  final String after;

  const BeforeAfterTile({
    super.key,
    required this.label,
    required this.before,
    required this.after,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const Gap(8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('BEFORE', style: TextStyle(fontSize: 10, color: Colors.red)),
                    Text(before, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('AFTER', style: TextStyle(fontSize: 10, color: Colors.green)),
                    Text(after, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SeverityBadge extends StatelessWidget {
  final double score;

  const SeverityBadge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    if (score >= 7.0) {
      color = Colors.red;
      label = 'CRITICAL';
    } else if (score >= 4.0) {
      color = Colors.amber[800]!;
      label = 'ELEVATED';
    } else {
      color = Colors.green;
      label = 'LOW';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            '$label (${score.toStringAsFixed(1)})',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

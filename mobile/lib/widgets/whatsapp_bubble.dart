import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WhatsAppBubble extends StatelessWidget {
  final String message;
  final int recipientCount;

  const WhatsAppBubble({
    super.key,
    required this.message,
    required this.recipientCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF25D366), // WhatsApp green
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.circular(4), // chat bubble tail effect
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📢  Campaign Alert",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.people_outline, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(
                "$recipientCount recipients",
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
              const Spacer(),
              const Icon(Icons.done_all, color: Colors.white70, size: 14),
            ],
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut);
  }
}

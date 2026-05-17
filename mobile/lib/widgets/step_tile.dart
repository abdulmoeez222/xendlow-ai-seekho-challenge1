import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../providers/pipeline_provider.dart';

class StepTile extends StatelessWidget {
  final String title;
  final String agentName;
  final IconData icon;
  final StepStatus status;
  final String? previewText;

  const StepTile({
    super.key,
    required this.title,
    required this.agentName,
    required this.icon,
    required this.status,
    this.previewText,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Widget trailing;

    switch (status) {
      case StepStatus.pending:
        statusColor = Colors.grey;
        trailing = const Icon(Icons.circle_outlined, color: Colors.grey);
        break;
      case StepStatus.running:
        statusColor = const Color(0xFF2563EB);
        trailing = const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ).animate(onPlay: (controller) => controller.repeat()).fadeIn();
        break;
      case StepStatus.done:
        statusColor = Colors.green;
        trailing = const Icon(Icons.check_circle, color: Colors.green);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: status == StepStatus.running ? statusColor.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status == StepStatus.running ? statusColor : Colors.grey[200]!,
          width: status == StepStatus.running ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: statusColor, size: 20),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agentName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
          if (status == StepStatus.done && previewText != null) ...[
            const Gap(12),
            const Divider(),
            const Gap(8),
            Text(
              previewText!,
              style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

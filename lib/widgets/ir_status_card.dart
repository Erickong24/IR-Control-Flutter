import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class IrStatusCard extends StatelessWidget {
  const IrStatusCard({
    super.key,
    required this.checking,
    required this.hasEmitter,
    required this.activity,
    required this.ranges,
  });

  final bool checking;
  final bool hasEmitter;
  final String activity;
  final List<List<int>> ranges;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.panel,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: .06)),
    ),
    child: Row(
      children: [
        if (checking)
          const SizedBox(
            width: 17,
            height: 17,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.mint),
          )
        else
          Icon(
            hasEmitter ? Icons.circle : Icons.error_outline_rounded,
            color: hasEmitter ? AppColors.mint : Colors.redAccent,
            size: 12,
          ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                checking
                    ? 'Buscando emisor IR'
                    : hasEmitter
                    ? 'Emisor IR disponible'
                    : 'Emisor IR no detectado',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                activity,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  height: 1.3,
                ),
              ),
              if (ranges.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'Frecuencia compatible: ${ranges.map((r) => '${r[0]}–${r[1]} Hz').join(', ')}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 9),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

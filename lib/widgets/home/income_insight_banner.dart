// lib/widgets/home/income_insight_banner.dart
import 'package:flutter/material.dart';
import '../../provider/user_profile_provider.dart';

class IncomeInsightBanner extends StatelessWidget {
  final String message;
  final IncomeHealthStatus status;

  const IncomeInsightBanner({
    super.key,
    required this.message,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final config = _getStatusConfig(status, colorScheme);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
            config.color.withOpacity(0.2),
            config.color.withOpacity(0.1),
          ]
              : [
            config.color.withOpacity(0.1),
            config.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: config.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: config.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              config.icon,
              color: config.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(IncomeHealthStatus status, ColorScheme colorScheme) {
    switch (status) {
      case IncomeHealthStatus.healthy:
        return _StatusConfig(
          color: const Color(0xFF10B981),
          icon: Icons.check_circle_rounded,
        );
      case IncomeHealthStatus.warning:
        return _StatusConfig(
          color: const Color(0xFFF59E0B),
          icon: Icons.info_rounded,
        );
      case IncomeHealthStatus.danger:
        return _StatusConfig(
          color: const Color(0xFFEF4444),
          icon: Icons.warning_rounded,
        );
      case IncomeHealthStatus.unknown:
        return _StatusConfig(
          color: colorScheme.primary,
          icon: Icons.lightbulb_rounded,
        );
    }
  }
}

class _StatusConfig {
  final Color color;
  final IconData icon;

  _StatusConfig({required this.color, required this.icon});
}
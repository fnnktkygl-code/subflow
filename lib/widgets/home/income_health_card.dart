import 'package:flutter/material.dart';
import '../../theme/design_system.dart';
import '../../provider/user_profile_provider.dart';

class IncomeHealthCard extends StatefulWidget {
  final String title;
  final String message;
  final IncomeHealthStatus status;

  const IncomeHealthCard({
    super.key,
    required this.title,
    required this.message,
    required this.status,
  });

  @override
  State<IncomeHealthCard> createState() => _IncomeHealthCardState();
}

class _IncomeHealthCardState extends State<IncomeHealthCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(context);
    final statusIcon = _getStatusIcon();

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: statusColor.withOpacity(isDark ? 0.12 : 0.06),
            border: Border.all(
              color: statusColor.withOpacity(0.25),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.08 * _pulseController.value),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(DesignSystem.spacing12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and title
              Row(
                children: [
                  AnimatedScale(
                    scale: 1.0 + (0.08 * _pulseController.value),
                    duration: Duration.zero,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(
                                0.15 * _pulseController.value),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        statusIcon,
                        color: statusColor,
                        size: 26,
                      ),
                    ),
                  ),
                  SizedBox(width: DesignSystem.spacing12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: DesignSystem.spacing12),
              // Message with improved spacing
              Text(
                widget.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(BuildContext context) {
    if (widget.status == IncomeHealthStatus.healthy) {
      return const Color(0xFF10B981); // Emerald
    } else if (widget.status == IncomeHealthStatus.warning) {
      return const Color(0xFFF59E0B); // Amber
    }
    return Theme.of(context).colorScheme.outline;
  }

  IconData _getStatusIcon() {
    if (widget.status == IncomeHealthStatus.healthy) {
      return Icons.check_circle_rounded;
    } else if (widget.status == IncomeHealthStatus.warning) {
      return Icons.warning_rounded;
    }
    return Icons.help_outline_rounded;
  }
}
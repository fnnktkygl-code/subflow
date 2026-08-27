// lib/widgets/home/spending_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../provider/user_profile_provider.dart';
import '../../theme/design_system.dart';

class SpendingCard extends StatelessWidget {
  final double monthlyCost;
  final double? goal;
  final double? monthlyIncome;
  final VoidCallback onEditGoal;
  final VoidCallback onEditIncome;
  final UserProfileProvider profileProvider;

  const SpendingCard({
    super.key,
    required this.monthlyCost,
    required this.goal,
    this.monthlyIncome,
    required this.onEditGoal,
    required this.onEditIncome,
    required this.profileProvider,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final yearly = monthlyCost * 12;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.7),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : const Color(0xFF20201E).withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacing10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Title & Yearly Projection + Action Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Spending',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '≈ €${yearly.toStringAsFixed(0)} / year',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onEditGoal();
                  },
                  icon: Icon(
                    Icons.tune_rounded,
                    size: DesignSystem.iconMedium,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  tooltip: 'Adjust Spend Target',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                    ),
                    padding: const EdgeInsets.all(DesignSystem.spacing4),
                    minimumSize: const Size(DesignSystem.minTouchTarget, DesignSystem.minTouchTarget),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignSystem.spacing8),

            // Large Japandi Spend Display
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '€${monthlyCost.toStringAsFixed(0)}',
                  style: textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -1.0,
                    height: 1.0,
                  ),
                ),
                Text(
                  '.${(monthlyCost % 1 * 100).toStringAsFixed(0).padLeft(2, '0')}',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: DesignSystem.spacing4),
                Text(
                  '/ month',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignSystem.spacing10),

            // Target Buffer Gauge or Prompt
            if (goal != null && goal! > 0)
              _buildTargetGauge(context, monthlyCost, goal!)
            else
              _buildSetTargetPrompt(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetGauge(BuildContext context, double cost, double target) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isUnderTarget = cost <= target;
    final progress = (cost / target).clamp(0.0, 1.0);
    final diff = (target - cost).abs();

    final Color statusColor = isUnderTarget
        ? colorScheme.primary
        : colorScheme.error;
    final Color statusBg = isUnderTarget
        ? colorScheme.primaryContainer.withValues(alpha: 0.4)
        : colorScheme.errorContainer.withValues(alpha: 0.4);

    final String statusText = isUnderTarget
        ? '€${diff.toStringAsFixed(0)} buffer remaining'
        : '€${diff.toStringAsFixed(0)} over target';

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onEditGoal();
      },
      borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Minimalist Progress Track
          ClipRRect(
            borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        width: constraints.maxWidth * progress,
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spacing6),

          // Status & Target Metadata
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSystem.spacing6,
                  vertical: DesignSystem.spacing2,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUnderTarget ? Icons.check_rounded : Icons.info_outline_rounded,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Target: €${target.toStringAsFixed(0)}/mo',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetTargetPrompt(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onEditGoal();
      },
      borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSystem.spacing8,
          vertical: DesignSystem.spacing6,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.track_changes_rounded,
              size: DesignSystem.iconSmall,
              color: colorScheme.primary,
            ),
            const SizedBox(width: DesignSystem.spacing6),
            Expanded(
              child: Text(
                'Set a monthly spend target',
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.add_rounded,
              size: DesignSystem.iconSmall,
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

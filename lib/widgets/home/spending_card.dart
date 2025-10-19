// lib/widgets/home/spending_card.dart
import 'package:aada_app/provider/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/custom_colors.dart';
import '../../theme/design_system.dart';

class SpendingCard extends StatelessWidget {
  final double monthlyCost;
  // ✅ FIX: The goal is now nullable.
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

    final incomePercentage = monthlyIncome != null && monthlyIncome! > 0
        ? (monthlyCost / monthlyIncome!) * 100
        : null;
    final yearly = monthlyCost * 12;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [colorScheme.surface, colorScheme.surface.withOpacity(0.8)]
              : [colorScheme.surface, colorScheme.surfaceContainerLow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(DesignSystem.spacing10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '💰',
                            style: TextStyle(fontSize: DesignSystem.iconLarge),
                          ),
                          const SizedBox(width: DesignSystem.spacing4),
                          Text(
                            'Monthly Spending',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignSystem.spacing2),
                      if (incomePercentage != null)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DesignSystem.spacing4,
                                vertical: DesignSystem.spacing2,
                              ),
                              decoration: BoxDecoration(
                                color: _getIncomeColor(incomePercentage).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                              ),
                              child: Text(
                                '${incomePercentage.toStringAsFixed(1)}% of income',
                                style: textTheme.labelMedium?.copyWith(
                                  color: _getIncomeColor(incomePercentage),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: DesignSystem.spacing4),
                            Text(
                              '• €${yearly.toStringAsFixed(0)}/year',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      else
                        InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onEditIncome();
                          },
                          borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DesignSystem.spacing4,
                              vertical: DesignSystem.spacing2,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Add income for insights',
                                  style: textTheme.labelMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: DesignSystem.spacing2),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: DesignSystem.iconXSmall,
                                  color: colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _showSettingsMenu(context);
                  },
                  icon: Icon(
                    Icons.tune_rounded,
                    size: DesignSystem.iconMedium,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                    ),
                    padding: const EdgeInsets.all(DesignSystem.spacing4),
                    minimumSize: const Size(DesignSystem.minTouchTarget, DesignSystem.minTouchTarget),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant,
          ),
          // ✅ FIX: Conditionally show the correct widget.
          Padding(
            padding: const EdgeInsets.all(DesignSystem.spacing10),
            child: goal != null
                ? _GoalProgress(
              monthlyCost: monthlyCost,
              goal: goal!, // We know it's not null here.
            )
                : _PromptToSetGoal(
              onTap: onEditGoal,
            ),
          ),
        ],
      ),
    );
  }

  Color _getIncomeColor(double percentage) {
    if (percentage < 10) return HealthColors.healthy;
    if (percentage < 15) return HealthColors.warning;
    return HealthColors.danger;
  }

  void _showSettingsMenu(BuildContext context) {
    // ... (Implementation remains the same)
  }

  void _showResetConfirmationDialog(BuildContext context) async {
    // ... (Implementation remains the same)
  }
}

// ✅ NEW/UPDATED WIDGETS

/// Displays the progress towards a spending goal.
class _GoalProgress extends StatelessWidget {
  final double monthlyCost;
  final double goal;

  const _GoalProgress({required this.monthlyCost, required this.goal});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final customColors = Theme.of(context).extension<CustomColors>();
    final isUnderLimit = monthlyCost <= goal;

    final double progressBarValue = goal > 0 ? (monthlyCost / goal).clamp(0.0, 1.0) : 0.0;
    final String statusText;
    final IconData statusIcon;
    final List<Color> progressGradient;

    if (isUnderLimit) {
      final amountLeft = goal - monthlyCost;
      statusIcon = Icons.check_circle_rounded;
      statusText = '€${amountLeft.toStringAsFixed(0)} under limit';
      progressGradient = customColors?.successGradient ?? [colorScheme.primary, colorScheme.secondary];
    } else {
      final amountOver = monthlyCost - goal;
      final percentOver = goal > 0 ? (amountOver / goal * 100) : 100;
      statusIcon = Icons.warning_rounded;
      statusText = '€${amountOver.toStringAsFixed(0)} over (+${percentOver.toStringAsFixed(0)}%)';
      progressGradient = customColors?.errorGradient ?? [colorScheme.error, HealthColors.warning];
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '€${monthlyCost.toStringAsFixed(0)}',
              style: textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: isUnderLimit ? colorScheme.primary : colorScheme.error,
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: DesignSystem.spacing4),
              child: Text(
                '.${(monthlyCost % 1 * 100).toStringAsFixed(0).padLeft(2, '0')}',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: (isUnderLimit ? colorScheme.primary : colorScheme.error).withOpacity(0.6),
                  height: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignSystem.spacing4),
        Text(
          'of €${goal.toStringAsFixed(0)} limit',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing12),
        ClipRRect(
          borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
          child: SizedBox(
            height: 12,
            child: Stack(
              children: [
                Container(color: colorScheme.surfaceContainerHighest),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      width: constraints.maxWidth * progressBarValue,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: progressGradient),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: DesignSystem.spacing6),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.spacing6,
            vertical: DesignSystem.spacing4,
          ),
          decoration: BoxDecoration(
            color: (isUnderLimit ? colorScheme.primaryContainer : colorScheme.errorContainer).withOpacity(0.5),
            borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, size: DesignSystem.iconXSmall, color: isUnderLimit ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer),
              const SizedBox(width: DesignSystem.spacing2),
              Text(
                statusText,
                style: textTheme.labelMedium?.copyWith(
                  color: isUnderLimit ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Displays an invitation to set a spending goal.
class _PromptToSetGoal extends StatelessWidget {
  final VoidCallback onTap;

  const _PromptToSetGoal({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(DesignSystem.spacing10),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
          border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.track_changes_rounded,
              size: DesignSystem.iconXLarge,
              color: colorScheme.primary,
            ),
            const SizedBox(height: DesignSystem.spacing6),
            Text(
              'Set a Spend Limit',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: DesignSystem.spacing2),
            Text(
              'Track your spending against a monthly goal to stay on budget.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// lib/widgets/home/spending_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/custom_colors.dart';
import '../../theme/design_system.dart';

class SpendingCard extends StatelessWidget {
  final double monthlyCost;
  final double goal;
  final double? monthlyIncome;
  final VoidCallback onEditGoal;
  final VoidCallback onEditIncome;

  const SpendingCard({
    super.key,
    required this.monthlyCost,
    required this.goal,
    this.monthlyIncome,
    required this.onEditGoal,
    required this.onEditIncome,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final customColors = Theme.of(context).extension<CustomColors>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final yearly = monthlyCost * 12;
    final isUnderLimit = monthlyCost <= goal;

    // Calculate income percentage
    final incomePercentage = monthlyIncome != null && monthlyIncome! > 0
        ? (monthlyCost / monthlyIncome!) * 100
        : null;

    final double progressBarValue;
    final String statusText;
    final IconData statusIcon;
    final List<Color> progressGradient;

    if (isUnderLimit) {
      progressBarValue = goal > 0 ? (monthlyCost / goal).clamp(0.0, 1.0) : 0.0;
      final amountLeft = goal - monthlyCost;
      statusIcon = Icons.check_circle_rounded;
      statusText = '€${amountLeft.toStringAsFixed(0)} under limit';
      progressGradient = customColors?.successGradient ?? [colorScheme.primary, colorScheme.secondary];
    } else {
      progressBarValue = 1.0;
      final amountOver = monthlyCost - goal;
      final percentOver = goal > 0 ? (amountOver / goal * 100) : 100;
      statusIcon = Icons.warning_rounded;
      statusText = '€${amountOver.toStringAsFixed(0)} over (+${percentOver.toStringAsFixed(0)}%)';
      progressGradient = customColors?.errorGradient ?? [colorScheme.error, HealthColors.warning];
    }

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
          // Header section
          Padding(
            padding: EdgeInsets.all(DesignSystem.spacing10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '💰',
                            style: TextStyle(fontSize: DesignSystem.iconLarge),
                          ),
                          SizedBox(width: DesignSystem.spacing4),
                          Text(
                            'Monthly Spending',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: DesignSystem.spacing2),
                      if (incomePercentage != null)
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
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
                            SizedBox(width: DesignSystem.spacing4),
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
                            padding: EdgeInsets.symmetric(
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
                                SizedBox(width: DesignSystem.spacing2),
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
                // Settings button
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
                    padding: EdgeInsets.all(DesignSystem.spacing4),
                    minimumSize: Size(DesignSystem.minTouchTarget, DesignSystem.minTouchTarget),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withOpacity(0.2),
          ),

          // Amount display
          Padding(
            padding: EdgeInsets.all(DesignSystem.spacing10),
            child: Column(
              children: [
                // Main amount
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
                      padding: EdgeInsets.only(top: DesignSystem.spacing4),
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
                SizedBox(height: DesignSystem.spacing4),
                Text(
                  'of €${goal.toStringAsFixed(0)} limit',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: DesignSystem.spacing12),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                  child: SizedBox(
                    height: 12,
                    child: Stack(
                      children: [
                        Container(
                          color: colorScheme.surfaceContainerHighest,
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              width: constraints.maxWidth * progressBarValue,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: progressGradient,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: DesignSystem.spacing6),

                // Status text
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignSystem.spacing6,
                    vertical: DesignSystem.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: (isUnderLimit
                        ? colorScheme.primaryContainer
                        : colorScheme.errorContainer)
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: DesignSystem.iconXSmall,
                        color: isUnderLimit
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onErrorContainer,
                      ),
                      SizedBox(width: DesignSystem.spacing2),
                      Text(
                        statusText,
                        style: textTheme.labelMedium?.copyWith(
                          color: isUnderLimit
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(DesignSystem.spacing10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignSystem.radiusXXL),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: DesignSystem.spacing10),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Set Limit option
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                  ),
                  child: Icon(
                    Icons.track_changes_rounded,
                    color: colorScheme.onPrimaryContainer,
                    size: DesignSystem.iconMedium,
                  ),
                ),
                title: Text(
                  'Set Spend Limit',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Currently €${goal.toStringAsFixed(0)}/month',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onEditGoal();
                },
              ),

              SizedBox(height: DesignSystem.spacing4),

              // Income option
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: colorScheme.onSecondaryContainer,
                    size: DesignSystem.iconMedium,
                  ),
                ),
                title: Text(
                  monthlyIncome != null ? 'Update Income' : 'Add Income',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  monthlyIncome != null
                      ? '€${monthlyIncome!.toStringAsFixed(0)}/month'
                      : 'Get personalized insights',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onEditIncome();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
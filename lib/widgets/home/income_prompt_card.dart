// lib/widgets/home/income_prompt_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/design_system.dart';

class IncomePromptCard extends StatelessWidget {
  final VoidCallback onAddIncome;
  final VoidCallback onDismiss;

  const IncomePromptCard({
    super.key,
    required this.onAddIncome,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(DesignSystem.spacing10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
            const Color(0xFF6366F1).withValues(alpha: 0.2),
            const Color(0xFF8B5CF6).withValues(alpha: 0.15),
          ]
              : [
            const Color(0xFF6366F1).withValues(alpha: 0.1),
            const Color(0xFF8B5CF6).withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: DesignSystem.iconCard,
                height: DesignSystem.iconCard,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_graph_rounded,
                  color: Colors.white,
                  size: DesignSystem.iconLarge,
                ),
              ),
              SizedBox(width: DesignSystem.spacing6),
              Expanded(
                child: Text(
                  'Unlock Insights',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: DesignSystem.iconMedium,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onDismiss();
                },
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                  ),
                  padding: EdgeInsets.all(DesignSystem.spacing4),
                  minimumSize: Size(32, 32),
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSystem.spacing6),
          Text(
            'Add your monthly income to see what % of your money goes to subscriptions. Make smarter decisions with context.',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: DesignSystem.spacing8),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: DesignSystem.spacing8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onAddIncome();
                  },
                  icon: Icon(Icons.account_balance_wallet_rounded, size: DesignSystem.iconSmall),
                  label: Text(
                    'Add Income',
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
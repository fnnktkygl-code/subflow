import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpendingCard extends StatelessWidget {
  final double monthlyCost;
  final double goal;
  final VoidCallback onEditGoal;

  const SpendingCard({
    super.key,
    required this.monthlyCost,
    required this.goal,
    required this.onEditGoal,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final yearly = monthlyCost * 12;
    final progress = goal > 0 ? (monthlyCost / goal).clamp(0.0, 1.0) : 0.0;
    final isGoalMet = monthlyCost <= goal;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
            colorScheme.primaryContainer.withOpacity(0.3),
            colorScheme.secondaryContainer.withOpacity(0.2),
          ]
              : [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    isGoalMet ? '🏆' : '💰',
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGoalMet ? 'crushing it!' : 'monthly spend',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        '€${yearly.toStringAsFixed(0)}/year',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onEditGoal();
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '€${monthlyCost.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                        letterSpacing: -2.5,
                        height: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        '.${(monthlyCost % 1 * 100).toStringAsFixed(0).padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'of €${goal.toStringAsFixed(0)} goal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 16,
              child: Stack(
                children: [
                  Container(color: colorScheme.surfaceContainerHighest),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        width: constraints.maxWidth * progress,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isGoalMet
                                ? [const Color(0xFF43E97B), const Color(0xFF38F9D7)]
                                : [colorScheme.primary, colorScheme.secondary],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              isGoalMet ? 'goal achieved! 🎉' : '${(progress * 100).toStringAsFixed(0)}% of goal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
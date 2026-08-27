// lib/pages/onboarding_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../provider/user_profile_provider.dart';
import '../theme/design_system.dart';
import '../widgets/shared/japandi_svg_icons.dart';

/// Serene 1-Screen Japandi Onboarding
/// Replaces slow marketing carousels with instant, high-trust onboarding.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  void _completeOnboarding(BuildContext context) {
    HapticFeedback.heavyImpact();
    context.read<UserProfileProvider>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : const Color(0xFFFAF8F5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSystem.spacing12,
                vertical: DesignSystem.spacing10,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (DesignSystem.spacing10 * 2),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Brand Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(DesignSystem.spacing4),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                                ),
                                child: const JapandiSvgIcon(
                                  type: JapandiSvgType.leaf,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: DesignSystem.spacing4),
                              Text(
                                'SUBFLOW',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.0,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => _completeOnboarding(context),
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: DesignSystem.spacing12),

                      // Hero Illustration & Headline
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isDark
                                ? colorScheme.surfaceContainerHigh
                                : colorScheme.surfaceContainerLowest,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.6),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.25)
                                    : const Color(0xFF20201E).withValues(alpha: 0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: JapandiSvgIcon(
                              type: JapandiSvgType.sparkles,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: DesignSystem.spacing8),

                      Text(
                        'Mindful Spending,\nTotal Clarity.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.2,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: DesignSystem.spacing4),
                      Text(
                        'Your calm sanctuary to track recurring commitments, simulate savings, and regain control.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: DesignSystem.spacing12),

                      // 3 Value Pillars
                      _buildPillar(
                        context,
                        icon: JapandiSvgType.subscriptions,
                        title: 'Frictionless Entry',
                        subtitle: 'Single-view input with smart predictions and zero clutter.',
                      ),
                      const SizedBox(height: DesignSystem.spacing6),
                      _buildPillar(
                        context,
                        icon: JapandiSvgType.chart,
                        title: 'What-If Simulation',
                        subtitle: 'Snooze subscriptions on the fly to see instant monthly savings.',
                      ),
                      const SizedBox(height: DesignSystem.spacing6),
                      _buildPillar(
                        context,
                        icon: JapandiSvgType.leaf,
                        title: '100% Private & Local',
                        subtitle: 'No accounts required. Your financial data never leaves your device.',
                      ),

                      const Spacer(),
                      const SizedBox(height: DesignSystem.spacing10),

                      // Bottom CTA
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => _completeOnboarding(context),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: DesignSystem.spacing4),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPillar(
    BuildContext context, {
    required JapandiSvgType icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacing8),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.5)
            : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
            ),
            child: Center(
              child: JapandiSvgIcon(
                type: icon,
                size: 18,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: DesignSystem.spacing8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

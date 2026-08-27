// lib/widgets/shared/goal_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../provider/user_profile_provider.dart';
import '../../theme/design_system.dart';
import '../../utils/security_sanitizer.dart';

/// Pure Japandi Monthly Spend Target Dialog
/// Streamlined, frictionless, zero-lock-in budget planning.
class GoalDialog {
  static void show(
    BuildContext context, {
    required double? currentGoal,
    required double currentCost,
    required double? monthlyIncome,
    required UserProfileProvider profileProvider,
    required Function(double?) onGoalSet,
    VoidCallback? onAddIncome,
  }) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GoalDialogContent(
        initialGoal: currentGoal,
        currentCost: currentCost,
        onGoalSet: onGoalSet,
      ),
    );
  }
}

class _GoalDialogContent extends StatefulWidget {
  final double? initialGoal;
  final double currentCost;
  final Function(double?) onGoalSet;

  const _GoalDialogContent({
    required this.initialGoal,
    required this.currentCost,
    required this.onGoalSet,
  });

  @override
  State<_GoalDialogContent> createState() => _GoalDialogContentState();
}

class _GoalDialogContentState extends State<_GoalDialogContent> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialGoal ?? (widget.currentCost > 0 ? widget.currentCost : 50.0);
    _controller = TextEditingController(
      text: initial.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyQuickPreset(double amount) {
    HapticFeedback.selectionClick();
    setState(() {
      _controller.text = amount.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cost = widget.currentCost;
    final presets = <double>[];
    if (cost > 0) {
      presets.add((cost * 0.8).roundToDouble()); // -20% budget
      presets.add(cost.roundToDouble());        // Match current
      presets.add((cost * 1.2).roundToDouble()); // +20% buffer
    } else {
      presets.addAll([30.0, 50.0, 100.0]);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          DesignSystem.spacing10,
          DesignSystem.spacing6,
          DesignSystem.spacing10,
          DesignSystem.spacing12,
        ),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : const Color(0xFFFAF8F5),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DesignSystem.radiusXXL),
          ),
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.6),
              width: 1.0,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Japandi Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: DesignSystem.spacing6),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monthly Spend Target',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: DesignSystem.spacing2),
              Text(
                "Set a calm monthly ceiling for your recurring commitments.",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: DesignSystem.spacing8),

              // Main Numeric Target Input
              TextField(
                controller: _controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                  letterSpacing: -0.5,
                ),
                decoration: InputDecoration(
                  prefixText: '€ ',
                  prefixStyle: theme.textTheme.headlineLarge?.copyWith(
                    color: colorScheme.primary.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w700,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? colorScheme.surfaceContainerHigh
                      : colorScheme.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: DesignSystem.spacing6),

              // Quick Preset Chips
              Wrap(
                spacing: DesignSystem.spacing4,
                alignment: WrapAlignment.center,
                children: presets.map((preset) {
                  return ActionChip(
                    backgroundColor: isDark
                        ? colorScheme.surfaceContainer
                        : colorScheme.surface,
                    side: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                    ),
                    label: Text(
                      '€${preset.toStringAsFixed(0)}/mo',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onPressed: () => _applyQuickPreset(preset),
                  );
                }).toList(),
              ),
              const SizedBox(height: DesignSystem.spacing10),

              // Action Buttons: Save Target & Remove Target
              Row(
                children: [
                  if (widget.initialGoal != null) ...[
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(color: colorScheme.error.withValues(alpha: 0.4)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          widget.onGoalSet(null);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: DesignSystem.spacing4),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        final raw = _controller.text.replaceAll(',', '.').trim();
                        final val = double.tryParse(raw);
                        if (val != null && val >= 0) {
                          final sanitized = SecuritySanitizer.sanitizeAmount(val);
                          widget.onGoalSet(sanitized);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Set Target',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

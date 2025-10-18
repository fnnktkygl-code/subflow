// lib/widgets/shared/goal_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'income_setup_dialog.dart'; // Ensure this is imported

class GoalDialog {
  // Static show method remains the entry point
  static void show(
      BuildContext context, {
        required double currentGoal,
        required double currentCost,
        required double? monthlyIncome,
        required Function(double) onGoalSet,
        required VoidCallback onAddIncome, // The callback to trigger opening IncomeSetupDialog
      }) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GoalDialogContent(
        // Pass initial values and callbacks to the StatefulWidget
        initialGoal: currentGoal,
        initialIncome: monthlyIncome,
        onGoalSet: onGoalSet,
        onAddIncome: onAddIncome,
      ),
    );
  }

// --- Helper methods remain static ---

  // Widget for the interactive slider when income is set
  static Widget _buildEnabledSlider({
    required BuildContext context,
    required double percentage,
    required double monthlyIncome,
    required ValueChanged<double> onChanged,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Slider(
          value: percentage,
          min: 0,
          max: 100,
          divisions: 100,
          label: '${percentage.toStringAsFixed(0)}%',
          onChanged: onChanged,
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            children: [
              const TextSpan(text: 'This is '),
              TextSpan(
                text: '${percentage.toStringAsFixed(0)}% of your ',
                style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
              TextSpan(
                text: '€${monthlyIncome.toStringAsFixed(0)} income',
                style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget to display when income is NOT set
  static Widget _buildDisabledSlider({
    required BuildContext context,
    required VoidCallback onUnlock,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onUnlock,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.lock, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set limit by percentage',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add your income to unlock this feature.',
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

// --- Internal StatefulWidget to manage state and controller ---
class _GoalDialogContent extends StatefulWidget {
  final double initialGoal;
  final double? initialIncome;
  final Function(double) onGoalSet;
  final VoidCallback onAddIncome;

  const _GoalDialogContent({
    required this.initialGoal,
    this.initialIncome,
    required this.onGoalSet,
    required this.onAddIncome,
  });

  @override
  State<_GoalDialogContent> createState() => _GoalDialogContentState();
}

class _GoalDialogContentState extends State<_GoalDialogContent> {
  late TextEditingController _controller;
  late ValueNotifier<double?> _currentIncomeNotifier;
  double _percentage = 15.0; // Default

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialGoal.toStringAsFixed(0));
    _currentIncomeNotifier = ValueNotifier(widget.initialIncome);
    _recalculatePercentage(); // Initial calculation
    _controller.addListener(_updatePercentageFromAmount); // Add listener
  }

  @override
  void dispose() {
    _controller.removeListener(_updatePercentageFromAmount); // Remove listener
    _controller.dispose();
    _currentIncomeNotifier.dispose();
    super.dispose();
  }

  void _recalculatePercentage() {
    final income = _currentIncomeNotifier.value;
    final goalAmount = double.tryParse(_controller.text) ?? widget.initialGoal;
    if (income != null && income > 0) {
      // ✅ Explicitly ensure result is double and clamp with doubles
      _percentage = (goalAmount / income * 100.0).clamp(0.0, 100.0);
    } else {
      _percentage = 15.0; // Reset to default if no income
    }
  }

  void _updatePercentageFromAmount() {
    final income = _currentIncomeNotifier.value;
    if (income != null && income > 0) {
      final amount = double.tryParse(_controller.text) ?? 0.0;
      // ✅ Explicitly ensure result is double and clamp with doubles
      final newPercentage = (amount / income * 100.0).clamp(0.0, 100.0);
      // Only update state if percentage actually changed to avoid excessive rebuilds
      if ((newPercentage - _percentage).abs() > 0.01) { // Use a small epsilon
        setState(() {
          _percentage = newPercentage;
        });
      }
    }
  }


  void _handleIncomeUpdate(double? newIncome) {
    _currentIncomeNotifier.value = newIncome; // Update notifier
    // No need for setState here, ValueListenableBuilder handles it
    _recalculatePercentage(); // Recalculate based on new income
    // Force a rebuild if needed, though ValueListenableBuilder should handle it
    if(mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<double?>(
        valueListenable: _currentIncomeNotifier,
        builder: (context, currentIncome, child) {
          bool hasIncome = currentIncome != null && currentIncome > 0;

          // Recalculate percentage inside the builder to ensure it's up-to-date
          double currentPercentage = 15.0; // Default
          if(hasIncome) {
            double goalValue = double.tryParse(_controller.text) ?? widget.initialGoal;
            if (currentIncome > 0) {
              // ✅ Explicitly ensure result is double and clamp with doubles
              currentPercentage = (goalValue / currentIncome * 100.0).clamp(0.0, 100.0);
            }
          } else {
            currentPercentage = 15.0; // Reset if income removed
          }


          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Set your spend limit 🎯',
                    style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "What's the max you want to spend on subscriptions each month?",
                    style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),

                  // --- Amount Input ---
                  TextField(
                    controller: _controller, // Use the state's controller
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                    decoration: InputDecoration(
                      prefixText: '€ ',
                      prefixStyle: textTheme.displayMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                    // Listener handles updates
                  ),

                  // --- Conditional Percentage UI ---
                  const SizedBox(height: 24),
                  hasIncome
                      ? GoalDialog._buildEnabledSlider(
                    context: context,
                    percentage: currentPercentage, // Use calculated percentage
                    monthlyIncome: currentIncome, // Use current income
                    onChanged: (newPercentage) {
                      // Update text field when slider changes
                      final newGoal = currentIncome * (newPercentage / 100.0); // Ensure double division
                      setState(() {
                        _percentage = newPercentage; // Update internal state for immediate slider feedback
                        _controller.text = newGoal.toStringAsFixed(0);
                      });
                    },
                  )
                      : GoalDialog._buildDisabledSlider(
                    context: context,
                    onUnlock: () {
                      // Show the IncomeSetupDialog, passing our internal update function.
                      IncomeSetupDialog.show(
                        context,
                        currentIncome: currentIncome, // Pass current session income
                        onIncomeSaved: _handleIncomeUpdate, // Link update function
                        allowSkip: true,
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // --- Set Limit Button ---
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {
                        final newGoal = double.tryParse(_controller.text);
                        if (newGoal != null && newGoal >= 0) {
                          widget.onGoalSet(newGoal); // Call original callback
                          HapticFeedback.lightImpact();
                        }
                        Navigator.pop(context); // Close GoalDialog
                      },
                      child: Text(
                        'Set Limit',
                        style: textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}
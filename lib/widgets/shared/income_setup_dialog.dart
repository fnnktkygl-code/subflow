// lib/widgets/shared/income_setup_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IncomeSetupDialog {
  static void show(
      BuildContext context, {
        required Function(double?) onIncomeSaved,
        double? currentIncome,
        bool allowSkip = true,
      }) {
    final controller = TextEditingController(
      text: currentIncome != null ? currentIncome.toStringAsFixed(0) : '',
    );


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: allowSkip,
      enableDrag: allowSkip,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surface : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.4 : 0.8),
                  width: 1.0,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentIncome != null ? 'Update Monthly Income' : 'Monthly Income',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (allowSkip)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: () => Navigator.pop(context),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Track what % of your income goes to subscriptions.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),

                // Input field
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    prefixText: '€ ',
                    prefixStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    hintText: '2,500',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    if (allowSkip)
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (currentIncome != null) {
                              _showRemoveConfirmation(context, onIncomeSaved);
                            } else {
                              onIncomeSaved(null);
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            currentIncome != null ? 'Remove' : 'Skip',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    if (allowSkip) const SizedBox(width: 8),
                    Expanded(
                      flex: allowSkip ? 2 : 1,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          final income = double.tryParse(controller.text.replaceAll(',', '.'));
                          if (income != null && income > 0) {
                            HapticFeedback.lightImpact();
                            onIncomeSaved(income);
                            Navigator.pop(context);
                          } else {
                            HapticFeedback.mediumImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a valid amount'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Text(
                          currentIncome != null ? 'Update Income' : 'Save Income',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _showRemoveConfirmation(
      BuildContext context,
      Function(double?) onIncomeSaved,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove income data?'),
        content: const Text(
          'This will remove your income information and related insights. You can add it back anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onIncomeSaved(null);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
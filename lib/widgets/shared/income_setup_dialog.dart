// lib/widgets/shared/income_setup_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/design_system.dart';

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
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(DesignSystem.spacing12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(DesignSystem.radiusXXL),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              if (allowSkip)
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: DesignSystem.spacing12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

              // Icon Container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: DesignSystem.iconLarge,
                ),
              ),
              SizedBox(height: DesignSystem.spacing12),

              // Title
              Text(
                currentIncome != null ? 'Update your income' : 'Add your monthly income',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: DesignSystem.spacing8),

              // Explanation
              Text(
                "We'll show you what % of your income goes to subscriptions. This helps you make smarter decisions.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              SizedBox(height: DesignSystem.spacing10),

              // Privacy assurance
              Container(
                padding: EdgeInsets.all(DesignSystem.spacing10),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: DesignSystem.spacing8),
                    Expanded(
                      child: Text(
                        'Private & secure. Only stored on your device.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: DesignSystem.spacing12),

              // Input field
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: '€ ',
                  prefixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  hintText: '2,500',
                  helperText: 'Your monthly take-home pay (after taxes)',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(DesignSystem.radiusXL),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: DesignSystem.spacing12,
                    vertical: DesignSystem.spacing10,
                  ),
                ),
              ),
              SizedBox(height: DesignSystem.spacing12),

              // Buttons
              Row(
                children: [
                  if (allowSkip)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: DesignSystem.spacing10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(DesignSystem.radiusMedium),
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
                          currentIncome != null ? 'Remove' : 'Skip for now',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (allowSkip) SizedBox(width: DesignSystem.spacing8),
                  Expanded(
                    flex: allowSkip ? 2 : 1,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: DesignSystem.spacing10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(DesignSystem.radiusMedium),
                        ),
                      ),
                      onPressed: () {
                        final income = double.tryParse(controller.text);
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
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: DesignSystem.spacing8),
            ],
          ),
        ),
      ),
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
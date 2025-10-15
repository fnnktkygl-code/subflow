import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/subscription_model.dart';
import '../provider/simplified_subscription_provider.dart';

/// Mixin to add what-if mode (selection mode) functionality
/// to any widget that displays subscription cards
mixin SelectionModeMixin<T extends StatefulWidget> on State<T> {
  bool _isSelectionMode = false;
  final Set<String> _snoozedIds = {};

  bool get isSelectionMode => _isSelectionMode;
  Set<String> get snoozedIds => _snoozedIds;

  /// Check if a subscription is snoozed
  bool isSubscriptionSnoozed(String subscriptionId) {
    return _snoozedIds.contains(subscriptionId);
  }

  /// Toggle snooze for a subscription
  void toggleSnooze(String subscriptionId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_snoozedIds.contains(subscriptionId)) {
        _snoozedIds.remove(subscriptionId);
      } else {
        _snoozedIds.add(subscriptionId);
      }
    });
  }

  /// Enter selection mode and select a subscription
  void enterSelectionMode(String subscriptionId) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSelectionMode = true;
      _snoozedIds.add(subscriptionId);
    });
  }

  /// Exit selection mode and clear selections
  void exitSelectionMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _isSelectionMode = false;
      _snoozedIds.clear();
    });
  }

  /// Clear all selections without exiting selection mode
  void clearAllSelections() {
    HapticFeedback.lightImpact();
    setState(() {
      _snoozedIds.clear();
    });
  }

  /// Calculate potential savings based on selected subscriptions
  double calculatePotentialSavings(SimplifiedSubscriptionProvider provider) {
    double savings = 0.0;
    for (final id in _snoozedIds) {
      final sub = provider.subscriptions.firstWhere(
            (s) => s.id == id,
        orElse: () => Subscription(
          id: '',
          name: '',
          logoUrl: '',
          amount: 0,
          cycle: 'Monthly',
          startDate: DateTime.now(),
          category: '',
        ),
      );
      if (sub.id.isEmpty) continue;

      switch (sub.cycle) {
        case 'Yearly':
          savings += sub.amount.abs();
          break;
        case 'Monthly':
          savings += sub.amount.abs() * 12;
          break;
        case 'Weekly':
          savings += sub.amount.abs() * 52; // ✅ FIX: Standardized calculation
          break;
      }
    }
    return savings;
  }

  /// Build the what-if action bar (bottom bar with savings)
  Widget buildWhatIfActionBar({
    required SimplifiedSubscriptionProvider provider,
    required ColorScheme colorScheme,
  }) {
    final savings = calculatePotentialSavings(provider);

    // ✅ FIX: Replaced AnimatedPositioned with AnimatedContainer to work inside a Column.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      height: _isSelectionMode ? 92.0 : 0.0, // Animate height for show/hide
      child: ClipRect( // Prevents overflow when the container is animating
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surfaceContainerHighest,
                  colorScheme.surfaceContainer,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.2),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: clearAllSelections,
                  child: const Text('Clear All'),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Potential Savings',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        '€${savings.toStringAsFixed(2)}/year',
                        key: ValueKey(savings),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.green,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: exitSelectionMode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
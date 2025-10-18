// lib/mixins/selection_mode_mixin.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/subscription_model.dart';
import '../provider/simplified_subscription_provider.dart';

/// Mixin to add what-if mode (selection mode) functionality
/// to any widget that displays subscription cards.
///
/// This mixin provides a modern UX approach where:
/// - Cards stay visible but dim when excluded
/// - Live savings preview updates in real-time
/// - Clear visual feedback with checkboxes and badges
/// - Easy "Select All" / "Clear All" actions
/// - What-If bar is pinned at the bottom (handled by parent widget)
mixin SelectionModeMixin<T extends StatefulWidget> on State<T> {
  bool _isSelectionMode = false;
  final Set<String> _snoozedIds = {};
  bool _hasShownTutorial = false;

  bool get isSelectionMode => _isSelectionMode;
  Set<String> get snoozedIds => _snoozedIds;

  /// Check if a subscription is snoozed (excluded)
  bool isSubscriptionSnoozed(String subscriptionId) {
    return _snoozedIds.contains(subscriptionId);
  }

  /// Toggle snooze for a subscription
  void toggleSnooze(String subscriptionId) {
    // ✅ MODIFIED: Removed HapticFeedback
    setState(() {
      if (_snoozedIds.contains(subscriptionId)) {
        _snoozedIds.remove(subscriptionId);
      } else {
        _snoozedIds.add(subscriptionId);
      }
    });
  }

  /// Select all subscriptions
  void selectAllSubscriptions(SimplifiedSubscriptionProvider provider) {
    // ✅ MODIFIED: Removed HapticFeedback
    setState(() {
      _snoozedIds.clear();
      _snoozedIds.addAll(provider.subscriptions.map((s) => s.id));
    });
  }

  /// Enter selection mode and optionally select a subscription
  void enterSelectionMode(String subscriptionId) {
    // ✅ MODIFIED: Removed HapticFeedback
    setState(() {
      _isSelectionMode = true;
      _snoozedIds.add(subscriptionId);
    });

    // Show tutorial on first use
    _showTutorialIfNeeded();
  }

  /// Exit selection mode and clear selections
  void exitSelectionMode() {
    // ✅ MODIFIED: Removed HapticFeedback
    setState(() {
      _isSelectionMode = false;
      _snoozedIds.clear();
    });
  }

  /// Clear all selections without exiting selection mode
  void clearAllSelections() {
    // ✅ MODIFIED: Removed HapticFeedback
    setState(() {
      _snoozedIds.clear();
    });
  }

  /// Show tutorial overlay on first use
  void _showTutorialIfNeeded() {
    if (_hasShownTutorial) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _WhatIfTutorialOverlay(
          onDismiss: () {
            _hasShownTutorial = true;
            Navigator.of(context).pop();
          },
        ),
      );
    });
  }

  // ... (rest of mixin is unchanged) ...

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
          savings += sub.amount.abs() * 52;
          break;
      }
    }
    return savings;
  }

  /// Build the pinned what-if action bar with live savings preview
  ///
  /// This widget is designed to be used in a Positioned widget at the bottom
  /// of the screen, acting like a persistent bottom sheet. It does NOT handle
  /// its own positioning - that should be done by the parent widget.
  Widget buildWhatIfActionBar({
    required SimplifiedSubscriptionProvider provider,
    required ColorScheme colorScheme,
  }) {
    if (!_isSelectionMode) return const SizedBox.shrink();

    final totalSubs = provider.subscriptions.length;
    final selectedCount = _snoozedIds.length;

    // Calculate savings
    final totalMonthlyCost = provider.totalMonthlyCost;
    final filteredCost = provider.getFilteredTotalMonthlyCost(_snoozedIds);
    final monthlySavings = totalMonthlyCost - filteredCost;
    final yearlySavings = monthlySavings * 12;

    // ✅ Simple Container - positioning handled by parent (bottom_nav_bar)
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, -4), // Shadow goes upward
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with title and exit button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                Icon(
                  Icons.science_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "What If Mode",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        "Tap cards to exclude",
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: exitSelectionMode,
                  icon: Icon(
                    Icons.close_rounded,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          // Live savings preview
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSavingsMetric(
                      context: context,
                      label: "EXCLUDED",
                      value: "$selectedCount / $totalSubs",
                      icon: Icons.remove_circle_outline,
                      color: colorScheme.error,
                    ),
                    _buildSavingsMetric(
                      context: context,
                      label: "MONTHLY SAVINGS",
                      value: "€${monthlySavings.toStringAsFixed(0)}",
                      icon: Icons.trending_down_rounded,
                      color: colorScheme.tertiary,
                    ),
                    _buildSavingsMetric(
                      context: context,
                      label: "YEARLY SAVINGS",
                      value: "€${yearlySavings.toStringAsFixed(0)}",
                      icon: Icons.savings_outlined,
                      color: colorScheme.secondary,
                    ),
                  ],
                ),

                // Progress bar showing selection percentage
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: totalSubs > 0 ? selectedCount / totalSubs : 0,
                    minHeight: 6,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    label: "Select All",
                    icon: Icons.check_circle_outline,
                    onPressed: () => selectAllSubscriptions(provider),
                    isPrimary: false,
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    label: "Clear All",
                    icon: Icons.clear_all_rounded,
                    onPressed: clearAllSelections,
                    isPrimary: false,
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsMetric({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: AnimatedSwitcher(
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
                value,
                key: ValueKey<String>(value),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isPrimary,
    required ColorScheme colorScheme,
  }) {
    return Material(
      color: isPrimary
          ? colorScheme.primary
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isPrimary
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TUTORIAL OVERLAY - Shows on first use
// ============================================================================

class _WhatIfTutorialOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const _WhatIfTutorialOverlay({
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: Colors.black.withOpacity(0.8),
      child: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.science_outlined,
                  size: 64,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  "What If Mode",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTutorialStep(
                  context: context,
                  icon: Icons.touch_app_rounded,
                  text: "Tap any subscription to exclude it",
                ),
                const SizedBox(height: 12),
                _buildTutorialStep(
                  context: context,
                  icon: Icons.visibility_off_rounded,
                  text: "Excluded items stay visible but dimmed",
                ),
                const SizedBox(height: 12),
                _buildTutorialStep(
                  context: context,
                  icon: Icons.savings_outlined,
                  text: "See your potential savings in real-time",
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Got it!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialStep({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 24,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// CARD OVERLAY WIDGET - Add this to your subscription cards
// ============================================================================
// Usage: Wrap your SubscriptionCard with Stack and add this as a child:
//
// Stack(
//   children: [
//     YourSubscriptionCard(...),
//     WhatIfCardOverlay(
//       isSelectionMode: isSelectionMode,
//       isSnoozed: isSnoozed,
//       onToggle: onSnoozeChanged,
//     ),
//   ],
// )

class WhatIfCardOverlay extends StatelessWidget {
  final bool isSelectionMode;
  final bool isSnoozed;
  final VoidCallback onToggle;

  const WhatIfCardOverlay({
    super.key,
    required this.isSelectionMode,
    required this.isSnoozed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSelectionMode) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onToggle();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isSnoozed
                ? colorScheme.error.withOpacity(0.15)
                : Colors.transparent,
            border: Border.all(
              color: isSnoozed
                  ? colorScheme.error.withOpacity(0.5)
                  : colorScheme.outline.withOpacity(0.3),
              width: isSnoozed ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              // Dimming overlay when excluded
              if (isSnoozed)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: colorScheme.surface.withOpacity(0.7),
                    ),
                  ),
                ),

              // Checkbox indicator
              Positioned(
                top: 12,
                right: 12,
                child: AnimatedScale(
                  scale: isSelectionMode ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSnoozed
                          ? colorScheme.error
                          : colorScheme.surface,
                      border: Border.all(
                        color: isSnoozed
                            ? colorScheme.error
                            : colorScheme.outline,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSnoozed
                        ? Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: colorScheme.onError,
                    )
                        : null,
                  ),
                ),
              ),

              // "Excluded" badge
              if (isSnoozed)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.error.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.visibility_off_rounded,
                          size: 14,
                          color: colorScheme.onError,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "EXCLUDED",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onError,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
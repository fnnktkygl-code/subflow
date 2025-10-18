// lib/widgets/shared/subscription_card_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/subscription_model.dart';
import '../subscription_card.dart';
import '../subscription_popup.dart';

/// A wrapper that adds swipe-to-edit/delete and long-press what-if
/// functionality to any SubscriptionCard, making it reusable across the app.
class SubscriptionCardWrapper extends StatelessWidget {
  final Subscription subscription;
  final DateTime displayDate;
  final bool isAmountBlurred;

  // Callbacks
  final void Function(Subscription) onEdit;
  final Future<bool> Function(Subscription) onDelete;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap; // Standard tap action (outside selection mode)

  // Selection mode (what-if feature)
  final bool isSelectionMode;
  final bool isSnoozed;
  final void Function(bool?)? onSnoozeChanged;

  // ✅ Flag to control swipe/long-press
  final bool interactionsEnabled;

  const SubscriptionCardWrapper({
    super.key,
    required this.subscription,
    required this.displayDate,
    required this.onEdit,
    required this.onDelete,
    this.isAmountBlurred = false,
    this.onLongPress,
    this.onTap,
    this.isSelectionMode = false,
    this.isSnoozed = false,
    this.onSnoozeChanged,
    this.interactionsEnabled = true, required void Function(dynamic _) onSnoozChanged, // ✅ Default to true
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 1. Create the core InkWell widget first
    final cardInkWell = InkWell(
      onTap: () {
        // ✅ CORRECTION DÉFINITIVE :
        // Si on est en mode "what-if", l'action prioritaire est de basculer l'état.
        if (isSelectionMode && onSnoozeChanged != null) {
          if (onSnoozeChanged != null) {
            HapticFeedback.lightImpact();
            // On appelle la même fonction que la checkbox pour une cohérence parfaite.
            onSnoozeChanged!(!isSnoozed);
          }
          // On s'arrête ici, on ne veut pas d'autre action en mode sélection.
          return;
        }

        // Si on n'est PAS en mode "what-if", on exécute l'action de clic normale, si elle existe.
        if (onTap != null) {
          onTap!();
        }
      },
      // ✅ MODIFIED: Disable long press if interactions are not enabled
      onLongPress: !interactionsEnabled
          ? null
          : () {
        if (onLongPress != null) {
          HapticFeedback.heavyImpact();
          onLongPress!();
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: SubscriptionCard(
        subscription: subscription,
        displayDate: displayDate,
        isAmountBlurred: isAmountBlurred,
        isSnoozed: isSnoozed,
        isSelectionMode: isSelectionMode,
        onSnoozeChanged: onSnoozeChanged,
      ),
    );

    // ✅ 2. Conditionally wrap in Dismissible
    if (!interactionsEnabled) {
      // If interactions are disabled, just return the InkWell
      return cardInkWell;
    }

    // If interactions are enabled, return the Dismissible
    return Dismissible(
      key: ValueKey('${subscription.id}_$displayDate'),
      background: _buildDismissBackground(colorScheme, isLeft: true),
      secondaryBackground: _buildDismissBackground(colorScheme, isLeft: false),
      confirmDismiss: (direction) async {
        // This check is still good as a fallback
        if (isSelectionMode) return false;

        if (direction == DismissDirection.startToEnd) {
          _handleEdit(context);
          return false;
        } else {
          return await onDelete(subscription);
        }
      },
      child: cardInkWell, // Pass the InkWell as the child
    );
  }

  void _handleEdit(BuildContext context) {
    showAddSubscriptionPopup(
      context,
          (updatedSub) => onEdit(updatedSub),
      subscriptionToEdit: subscription,
    );
  }

  Widget _buildDismissBackground(ColorScheme colorScheme, {required bool isLeft}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isLeft ? colorScheme.secondaryContainer : colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLeft) ...[
            Icon(
              Icons.edit_outlined,
              color: colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 8),
            Text(
              'Edit',
              style: TextStyle(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else ...[
            Text(
              'Delete',
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.delete_outline,
              color: colorScheme.onErrorContainer,
            ),
          ],
        ],
      ),
    );
  }
}
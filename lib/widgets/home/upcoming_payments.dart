// lib/widgets/shared/category_bottom_sheet.dart
import 'package:flutter/material.dart';
// ✅ Import provider
import '../../models/subscription_model.dart';
import '../../utils/home_helpers.dart';
import '../shared/subscription_card_wrapper.dart';

class CategoryBottomSheet {
  static void show(
      BuildContext context, {
        required String category,
        required List<Subscription> subscriptions,
        String? categoryInsight,
        VoidCallback? onFindAlternatives,
        // ✅ Add callbacks for edit/delete
        required Function(Subscription) onEdit,
        required Future<bool> Function(Subscription) onDelete,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    HomeHelpers.getCategoryColor(category);
    HomeHelpers.getCategoryIcon(category);
    subscriptions.fold(0.0, (sum, sub) => sum + sub.monthlyCost);
    // ✅ Get provider instance for callbacks if needed inside the sheet (though passing them is cleaner)
    // final provider = Provider.of<SimplifiedSubscriptionProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container( /* ... (no changes) ... */ ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row( /* ... (no changes) ... */ ),
                  const SizedBox(height: 16),
                  Container( /* ... Total amount card (no changes) ... */ ),
                  if (categoryInsight != null) ...[ /* ... Category insight (no changes) ... */ ],
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Subscriptions list - ✅ Use SubscriptionCardWrapper
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: subscriptions.length,
                itemBuilder: (context, index) {
                  final sub = subscriptions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    // ✅ Use the Wrapper here
                    child: SubscriptionCardWrapper(
                      subscription: sub,
                      // displayDate is less relevant here, use start date or a fixed date?
                      // Using start date for consistency, though it won't show the date badge logic
                      displayDate: sub.startDate,
                      onEdit: onEdit,   // Pass the provided callback
                      onDelete: onDelete, // Pass the provided callback
                      isSelectionMode: false,
                      isSnoozed: false, onSnoozChanged: (_) {  },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

// _getBillingText is no longer needed as the card handles formatting
// static String _getBillingText(Subscription sub) { ... }
}
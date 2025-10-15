import 'package:aada_app/extensions/subscription_extensions.dart';
import 'package:flutter/material.dart';
import '../../models/subscription_model.dart';
import 'subscription_card_wrapper.dart';

class CategoryBottomSheet {
  static void show(
      BuildContext context, {
        required String category,
        required List<Subscription> subscriptions,
        required VoidCallback onFindAlternatives,
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.toUpperCase(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: subscriptions.length,
                      itemBuilder: (context, index) {
                        final sub = subscriptions[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: SubscriptionCardWrapper(
                            subscription: sub,
                            displayDate: sub.nextBillingDate,
                            onEdit: (_) {},
                            onDelete: (_) async => true,
                            isSelectionMode: false,
                            isSnoozed: false,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onFindAlternatives,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Find Alternatives'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/subscription_model.dart';
import '../../provider/simplified_subscription_provider.dart';
import '../shared/subscription_card_wrapper.dart';
import '../../views/calendar_helpers.dart';

class UpcomingPayments extends StatelessWidget {
  final VoidCallback? onViewAll;

  const UpcomingPayments({super.key, this.onViewAll, required List<Subscription> subscriptions});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SimplifiedSubscriptionProvider>();

    if (provider.subscriptions.isEmpty) return const SizedBox.shrink();

    // Get next 3 upcoming occurrences
    final upcoming = CalendarHelpers.getUpcomingOccurrences(provider.subscriptions)
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.calendar_month_rounded, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Upcoming Payments",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              if (onViewAll != null)
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onViewAll,
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      "View All",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...upcoming.map(
              (occurrence) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SubscriptionCardWrapper(
              subscription: occurrence.subscription,
              displayDate: occurrence.date,
              onEdit: (sub) => provider.updateSubscription(sub),
              onDelete: (sub) async {
                provider.deleteSubscription(sub.id);
                return true;
              },
              isSelectionMode: false,
              isSnoozed: false,
            ),
          ),
        ),
      ],
    );
  }
}

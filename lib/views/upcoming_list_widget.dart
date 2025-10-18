// FILE 1: lib/views/upcoming_list_widget.dart
// Add staggered animations and improved styling

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/subscription_model.dart';
import '../../provider/simplified_subscription_provider.dart';
import '../widgets/shared/subscription_card_wrapper.dart';
import '../../views/calendar_helpers.dart';
import '../../theme/design_system.dart';

class UpcomingPayments extends StatefulWidget {
  final List<Subscription> subscriptions;
  final VoidCallback? onViewAll;

  const UpcomingPayments({
    super.key,
    required this.subscriptions,
    this.onViewAll,
  });

  @override
  State<UpcomingPayments> createState() => _UpcomingPaymentsState();
}

class _UpcomingPaymentsState extends State<UpcomingPayments>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SimplifiedSubscriptionProvider>();

    if (provider.subscriptions.isEmpty) return const SizedBox.shrink();

    final upcoming = CalendarHelpers.getUpcomingOccurrences(provider.subscriptions)
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(upcoming.length, (index) {
        final occurrence = upcoming[index];
        final begin = Offset(0.2, 0);
        final end = Offset.zero;
        final curve = Curves.easeOut;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        final delay = index * 0.1;

        return FutureBuilder(
          future: Future.delayed(Duration(milliseconds: (delay * 1000).toInt())),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SlideTransition(
                  position: _staggerController.drive(tween),
                  child: FadeTransition(
                    opacity: _staggerController.drive(
                      Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: DesignSystem.spacing6),
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
                        interactionsEnabled: false,
                        onSnoozChanged: (_) {},
                      ),
                    ),
                  )
              );
            }
            return const SizedBox.shrink();
          },
        );
      }),
    );
  }
}

// ---===---===---===---===---===---===---===---===---===---===---===---

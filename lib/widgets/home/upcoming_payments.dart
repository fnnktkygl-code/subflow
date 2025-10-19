// lib/widgets/home/upcoming_payments.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../provider/simplified_subscription_provider.dart';
import '../shared/subscription_card_wrapper.dart';
import '../../views/calendar_helpers.dart';
import '../../theme/design_system.dart';

class UpcomingPayments extends StatefulWidget {
  // ✅ REMOVED: The 'subscriptions' parameter is no longer needed.
  final VoidCallback? onViewAll;

  const UpcomingPayments({
    super.key,
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
    // ✅ GET PROVIDER: Fetch data directly from the provider.
    final provider = context.watch<SimplifiedSubscriptionProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    if (provider.subscriptions.isEmpty) return const SizedBox.shrink();

    // ✅ LOGIC MOVED INSIDE: The widget is now self-sufficient.
    final allUpcoming =
    CalendarHelpers.getUpcomingOccurrences(provider.subscriptions);
    final upcomingToShow = allUpcoming.take(3).toList();
    final bool hasMoreToShow = allUpcoming.length > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (upcomingToShow.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  Icons.celebration_rounded,
                  size: 40,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No upcoming payments!',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ...List.generate(upcomingToShow.length, (index) {
          final occurrence = upcomingToShow[index];
          final begin = const Offset(0.2, 0);
          final end = Offset.zero;
          final curve = Curves.easeOut;
          final tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final delay = index * 0.1;

          return FutureBuilder(
            future:
            Future.delayed(Duration(milliseconds: (delay * 1000).toInt())),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SlideTransition(
                  position: _staggerController.drive(tween),
                  child: FadeTransition(
                    opacity: _staggerController.drive(
                      Tween(begin: 0.0, end: 1.0)
                          .chain(CurveTween(curve: curve)),
                    ),
                    child: Padding(
                      padding:
                      const EdgeInsets.only(bottom: DesignSystem.spacing6),
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
                        onSnoozeChanged: (_) {},
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          );
        }),
        // ✅ CTA BUTTON: This logic now works correctly.
        if (widget.onViewAll != null && hasMoreToShow) ...[
          const SizedBox(height: DesignSystem.spacing4),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: DesignSystem.spacing4),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onViewAll!();
                },
                icon: const Icon(Icons.read_more_rounded,
                    size: DesignSystem.iconMedium),
                label: const Text('View All Subscriptions'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: DesignSystem.spacing8),
                  foregroundColor: colorScheme.primary,
                  side:
                  BorderSide(color: colorScheme.primary.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(DesignSystem.radiusMedium),
                  ),
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }
}
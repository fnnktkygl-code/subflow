
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../models/subscription_model.dart';
import '../provider/simplified_subscription_provider.dart';
import '../widgets/subscription_card.dart';
import '../theme/design_system.dart';

class SubscriptionListView extends StatefulWidget {
  const SubscriptionListView({super.key});

  @override
  State<SubscriptionListView> createState() => _SubscriptionListViewState();
}

class _SubscriptionListViewState extends State<SubscriptionListView>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

    final occurrences = _getUpcomingOccurrences(provider.subscriptions);
    final grouped = _groupOccurrences(occurrences);

    if (occurrences.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(DesignSystem.spacing16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(DesignSystem.spacing16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
                ),
                child: Icon(
                  Icons.list_alt_rounded,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
              ),
              SizedBox(height: DesignSystem.spacing12),
              Text(
                "No upcoming subscriptions!",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final sectionList = grouped.entries.toList();

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSystem.spacing8,
        vertical: DesignSystem.spacing6,
      ),
      itemCount: sectionList.length,
      itemBuilder: (context, sectionIndex) {
        final entry = sectionList[sectionIndex];
        final groupTitle = entry.key;
        final groupItems = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header with Icon
            Padding(
              padding: EdgeInsets.fromLTRB(
                DesignSystem.spacing8,
                DesignSystem.spacing12,
                DesignSystem.spacing8,
                DesignSystem.spacing6,
              ),
              child: _buildSectionHeader(context, groupTitle),
            ),
            // Section Items
            ...List.generate(groupItems.length, (itemIndex) {
              final occ = groupItems[itemIndex];
              final globalIndex = sectionIndex * 10 + itemIndex;
              final delay = (globalIndex * 0.05).clamp(0.0, 0.5);

              return FutureBuilder(
                future:
                Future.delayed(Duration(milliseconds: (delay * 1000).toInt())),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return SlideTransition(
                      position: _staggerController.drive(
                        Tween(begin: const Offset(0.2, 0), end: Offset.zero)
                            .chain(CurveTween(curve: Curves.easeOut)),
                      ),
                      child: FadeTransition(
                        opacity: _staggerController.drive(
                          Tween(begin: 0.0, end: 1.0)
                              .chain(CurveTween(curve: Curves.easeOut)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: DesignSystem.spacing4,
                          ),
                          child: SubscriptionCard(
                            subscription: occ.subscription,
                            displayDate: occ.date,
                            isAmountBlurred: false,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    IconData iconData;
    Color headerColor = colorScheme.primary;

    switch (title) {
      case 'Due Today':
        iconData = Icons.notification_important_rounded;
        headerColor = colorScheme.error;
        break;
      case 'Due this Week':
        iconData = Icons.calendar_view_week_rounded;
        headerColor = colorScheme.secondary;
        break;
      case 'Later this Month':
        iconData = Icons.calendar_month_rounded;
        headerColor = colorScheme.primary;
        break;
      default:
        iconData = Icons.schedule_rounded;
        headerColor = colorScheme.primary;
    }

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(DesignSystem.spacing6),
          decoration: BoxDecoration(
            color: headerColor.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.1,
            ),
            borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
          ),
          child: Icon(
            iconData,
            size: DesignSystem.iconLarge,
            color: headerColor,
          ),
        ),
        SizedBox(width: DesignSystem.spacing8),
        Text(
          title.toUpperCase(),
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  List<SubscriptionOccurrence> _getUpcomingOccurrences(
      List<Subscription> subs) {
    final now = DateTime.now();
    final limit = DateTime(now.year, now.month + 2, 0);
    final occurrences = <SubscriptionOccurrence>[];

    for (final sub in subs) {
      DateTime current = sub.startDate;
      while (current.isBefore(limit)) {
        if (!current.isBefore(now) || DateUtils.isSameDay(current, now)) {
          occurrences.add(SubscriptionOccurrence(sub, current));
        }
        if (sub.endDate != null && current.isAfter(sub.endDate!)) break;

        DateTime next = _nextDate(current, sub.cycle);
        if (next.isBefore(current) || next == current) break;
        current = next;
      }
    }
    occurrences.sort((a, b) => a.date.compareTo(b.date));
    return occurrences;
  }

  Map<String, List<SubscriptionOccurrence>> _groupOccurrences(
      List<SubscriptionOccurrence> occurrences) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfWeek = today.add(Duration(days: 7 - today.weekday));
    final map = <String, List<SubscriptionOccurrence>>{};

    for (var occ in occurrences) {
      String key;
      if (DateUtils.isSameDay(occ.date, today)) {
        key = 'Due Today';
      } else if (!occ.date.isAfter(endOfWeek)) {
        key = 'Due this Week';
      } else if (occ.date.month == today.month) {
        key = 'Later this Month';
      } else {
        key = DateFormat('MMMM yyyy').format(occ.date);
      }
      map.putIfAbsent(key, () => []).add(occ);
    }
    return map;
  }

  DateTime _nextDate(DateTime current, String cycle) {
    switch (cycle) {
      case 'Weekly':
        return current.add(const Duration(days: 7));
      case 'Monthly':
        var newMonth = current.month + 1;
        var newYear = current.year;
        if (newMonth > 12) {
          newMonth = 1;
          newYear++;
        }
        final daysInNextMonth = DateUtils.getDaysInMonth(newYear, newMonth);
        final day = min(current.day, daysInNextMonth);
        return DateTime(newYear, newMonth, day);
      case 'Yearly':
        final isLeapDay = current.month == 2 && current.day == 29;
        return DateTime(current.year + 1, current.month,
            isLeapDay ? 28 : current.day);
      default:
        return DateTime.now().add(const Duration(days: 365 * 10));
    }
  }
}

class SubscriptionOccurrence {
  final Subscription subscription;
  final DateTime date;
  SubscriptionOccurrence(this.subscription, this.date);
}
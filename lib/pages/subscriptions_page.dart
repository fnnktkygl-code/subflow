// lib/pages/subscriptions_page.dart

import 'package:aada_app/widgets/shared/page_layout.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/subscription_model.dart';
import '../provider/simplified_subscription_provider.dart';
import '../widgets/shared/subscription_card_wrapper.dart';
import '../utils/subscription_utils.dart';
import '../widgets/home/empty_state.dart';
import '../theme/design_system.dart';
import 'dart:math';

class Subscriptions extends StatefulWidget {
  const Subscriptions({
    super.key,
    required this.onEdit,
    required this.isSubscriptionSnoozed,
    required this.onDelete,
    required this.isSelectionMode,
    required this.enterSelectionMode,
    required this.toggleSnooze,
    required this.snoozedIds,
  });

  final Future<void> Function(dynamic sub) onEdit;
  final bool Function(String subscriptionId) isSubscriptionSnoozed;
  final Future<bool> Function(dynamic sub) onDelete;
  final bool isSelectionMode;
  final void Function(String subscriptionId) enterSelectionMode;
  final void Function(String subscriptionId) toggleSnooze;
  final Set<String> snoozedIds;

  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}

class _SubscriptionsState extends State<Subscriptions> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SimplifiedSubscriptionProvider>();

    if (provider.subscriptions.isEmpty) {
      return const Scaffold(body: EmptyState());
    }

    final occurrences =
    SubscriptionUtils.getRelevantOccurrences(provider.subscriptions);
    final grouped = SubscriptionUtils.groupOccurrences(occurrences);

    final sectionOrder = [
      'Paid Earlier This Month',
      'Due Today',
      'Due this Week',
      'Later this Month',
    ];

    final orderedKeys = sectionOrder.where((key) => grouped.containsKey(key)).toList();

    final remainingKeys = grouped.keys
        .where((key) => !sectionOrder.contains(key))
        .toList()
      ..sort((a, b) {
        try {
          final dateA = DateFormat('MMMM yyyy').parse(a);
          final dateB = DateFormat('MMMM yyyy').parse(b);
          return dateA.compareTo(dateB);
        } catch (_) {
          return a.compareTo(b);
        }
      });

    final finalSectionKeys = orderedKeys + remainingKeys;

    // ✅ DEFINITIVE FIX: Define heights for both states.
    const double whatIfBarAreaHeight = 260.0; // For "What If" mode bar
    const double navBarAreaHeight = 120.0;   // For the standard bottom nav bar

    return PageLayout(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyHeaderDelegate(
            minHeight: 115.0,
            maxHeight: 115.0,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: _EnhancedStatsHeader(
                isSelectionMode: widget.isSelectionMode,
                snoozedIds: widget.snoozedIds,
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final sectionKey = finalSectionKeys[index];
              final sectionOccurrences = grouped[sectionKey]!;
              return _SubscriptionSection(
                title: sectionKey,
                occurrences: sectionOccurrences,
                widget: widget,
                provider: provider,
                showDeleteConfirmation: _showDeleteConfirmation,
              );
            },
            childCount: finalSectionKeys.length,
          ),
        ),

        // ✅ DEFINITIVE FIX: Add a single, adaptive spacer at the end.
        // This sliver's height changes depending on the mode. It adds
        // just enough scrollable space to see the last item above EITHER
        // the "What If" bar OR the regular bottom navigation bar.
        SliverToBoxAdapter(
          child: SizedBox(
            height: widget.isSelectionMode ? whatIfBarAreaHeight : navBarAreaHeight,
          ),
        ),
      ],
    );
  }

  Future<bool> _showDeleteConfirmation({
    required BuildContext context,
    required Subscription subscription,
    required SimplifiedSubscriptionProvider provider,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Confirm Deletion',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Delete "${subscription.name}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              provider.deleteSubscription(subscription.id);
              Navigator.pop(context, true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

// --- WIDGETS ---

class _EnhancedStatsHeader extends StatelessWidget {
  final bool isSelectionMode;
  final Set<String> snoozedIds;

  const _EnhancedStatsHeader({
    required this.isSelectionMode,
    required this.snoozedIds,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<SimplifiedSubscriptionProvider>(
      builder: (context, provider, _) {
        int displaySubsCount;
        double displayMonthly;

        if (isSelectionMode) {
          displaySubsCount = provider.subscriptions.length - snoozedIds.length;
          displayMonthly = provider.getFilteredTotalMonthlyCost(snoozedIds);
        } else {
          displaySubsCount = provider.subscriptions.length;
          displayMonthly = provider.totalMonthlyCost;
        }

        final displayYearly = displayMonthly * 12;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
              DesignSystem.spacing8,
              DesignSystem.spacing4,
              DesignSystem.spacing8,
              DesignSystem.spacing8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: DesignSystem.spacing6,
                    horizontal: DesignSystem.spacing8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: isSelectionMode ? 'Remaining' : 'Total Subs',
                        value: displaySubsCount.toString(),
                        icon: Icons.list_alt_rounded,
                        color: colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: DesignSystem.spacing4),
                    Expanded(
                      child: _StatCard(
                        label: 'Monthly Cost',
                        value: '€${displayMonthly.toStringAsFixed(0)}',
                        icon: Icons.calendar_today_rounded,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: DesignSystem.spacing4),
                    Expanded(
                      child: _StatCard(
                        label: 'Yearly Cost',
                        value: '€${displayYearly.toStringAsFixed(0)}',
                        icon: Icons.trending_up_rounded,
                        color: colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: DesignSystem.iconMedium),
        const SizedBox(height: DesignSystem.spacing2),
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
            height: 1.0,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant.withOpacity(0.8),
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SubscriptionSection extends StatelessWidget {
  final String title;
  final List<SubscriptionOccurrence> occurrences;
  final Subscriptions widget;
  final SimplifiedSubscriptionProvider provider;
  final Function({
  required BuildContext context,
  required Subscription subscription,
  required SimplifiedSubscriptionProvider provider,
  }) showDeleteConfirmation;

  const _SubscriptionSection({
    required this.title,
    required this.occurrences,
    required this.widget,
    required this.provider,
    required this.showDeleteConfirmation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignSystem.spacing8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacing8),
            child: _buildSectionHeader(context, title),
          ),
          SizedBox(height: DesignSystem.spacing6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacing8),
            child: Column(
              children: occurrences.map((occ) {
                return SubscriptionCardWrapper(
                  subscription: occ.subscription,
                  displayDate: occ.date,
                  isAmountBlurred: false,
                  isSelectionMode: widget.isSelectionMode,
                  isSnoozed: widget.isSubscriptionSnoozed(occ.subscription.id),
                  onEdit: (sub) => widget.onEdit(sub),
                  onDelete: (sub) => showDeleteConfirmation(
                    context: context,
                    subscription: sub,
                    provider: provider,
                  ),
                  onLongPress: () =>
                      widget.enterSelectionMode(occ.subscription.id),
                  onTap: widget.isSelectionMode
                      ? () => widget.toggleSnooze(occ.subscription.id)
                      : null,
                  onSnoozeChanged: (_) {
                    if (widget.isSelectionMode) {
                      widget.toggleSnooze(occ.subscription.id);
                    }
                  },
                  interactionsEnabled: true, onSnoozChanged: (_) {  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    IconData iconData;
    Color headerColor = colorScheme.primary;

    switch (title) {
      case 'Paid Earlier This Month':
        iconData = Icons.history_rounded;
        break;
      case 'Due Today':
        iconData = Icons.notification_important_rounded;
        headerColor = colorScheme.error;
        break;
      case 'Due this Week':
        iconData = Icons.calendar_view_week_rounded;
        headerColor = colorScheme.secondary;
        break;
      default:
        iconData = Icons.calendar_month_rounded;
        headerColor = colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: DesignSystem.spacing12,
        bottom: DesignSystem.spacing6,
      ),
      child: Row(
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
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}


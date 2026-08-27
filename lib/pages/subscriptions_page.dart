// lib/pages/subscriptions_page.dart

import 'package:subflow_app/widgets/shared/page_layout.dart';
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

    // --- Data processing ---
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

    // --- Define bottom area heights ---
    const double whatIfBarAreaHeight = 260.0;
    const double navBarAreaHeight = 120.0;

    // --- Build the Page Layout ---
    return PageLayout(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      slivers: [
        // --- Sticky Header ---
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyHeaderDelegate(
            // Use original heights (no manual padding needed here)
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

        // --- Subscription List ---
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

        // --- Bottom Spacer ---
        SliverToBoxAdapter(
          child: SizedBox(
            height: widget.isSelectionMode ? whatIfBarAreaHeight : navBarAreaHeight,
          ),
        ),
      ],
    );
  }

  // --- Delete Confirmation Dialog ---
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

// --- Enhanced Stats Header ---
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<SimplifiedSubscriptionProvider>(
      builder: (context, provider, _) {
        // ... (data calculation logic remains the same)
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
                // ✅ REDUCE VERTICAL PADDING HERE slightly
                padding: const EdgeInsets.symmetric(
                    vertical: DesignSystem.spacing6, // Was spacing8
                    horizontal: DesignSystem.spacing8),
                decoration: BoxDecoration(
                    color: isDark ? colorScheme.surface : Colors.white,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.4 : 0.8),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.25)
                            : const Color(0xFF20201E).withValues(alpha: 0.035),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      )
                    ]
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
                    Container(
                      height: 50,
                      width: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      margin: const EdgeInsets.symmetric(horizontal: DesignSystem.spacing2),
                    ),
                    Expanded(
                      child: _StatCard(
                        label: 'Monthly Cost',
                        value: '€${displayMonthly.toStringAsFixed(0)}',
                        icon: Icons.calendar_today_rounded,
                        color: colorScheme.primary,
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      margin: const EdgeInsets.symmetric(horizontal: DesignSystem.spacing2),
                    ),
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

// --- Stat Card (Keep previous changes - titleMedium, labelSmall) ---
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
        Icon(icon, color: color, size: DesignSystem.iconLarge),
        const SizedBox(height: DesignSystem.spacing2),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith( // Keep as titleMedium
            fontWeight: FontWeight.w700,
            color: color,
            height: 1.0,
            letterSpacing: -0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: DesignSystem.spacing2),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith( // Keep as labelSmall
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// --- Subscription Section (Unchanged) ---
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
                  interactionsEnabled: true,
                );
              }).toList(),
            ),
          ),        ],
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
              color: headerColor.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.1,
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

// --- Sticky Header Delegate (Unchanged) ---
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
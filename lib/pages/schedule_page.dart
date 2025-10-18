// lib/pages/schedule_page.dart

import 'package:aada_app/widgets/shared/page_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/simplified_subscription_provider.dart';
import '../views/modern_calendar_view.dart';
import '../models/subscription_model.dart';
import '../theme/design_system.dart'; // Import Design System

class Schedule extends StatefulWidget {
  final void Function(Subscription) onEdit;
  final Future<bool> Function(Subscription) onDelete;
  final bool isSelectionMode;
  final bool Function(String) isSubscriptionSnoozed;
  final void Function(String) onLongPress;
  final void Function(String) onTap;
  final void Function(String) onSnoozeChanged; // Check type
  final Set<String> snoozedIds;

  const Schedule({
    super.key,
    required this.onEdit,
    required this.onDelete,
    required this.isSelectionMode,
    required this.isSubscriptionSnoozed,
    required this.onLongPress,
    required this.onTap,
    required this.onSnoozeChanged, // Check type
    required this.snoozedIds,
  });

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<SimplifiedSubscriptionProvider>();

    if (provider.subscriptions.isEmpty) {
      return _buildEmptyState(theme.colorScheme);
    }

    // ✅ RECO: Define the height of the "What If" bar plus some extra padding
    // This value is used to extend the scrollable area.
    const double whatIfBarAreaHeight = 220.0 + 40.0; // 220 for the bar, 40 for comfort

    return PageLayout(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      slivers: [
        // ✅ RECO: It's crucial that the main content is in a SliverToBoxAdapter,
        // NOT a SliverFillRemaining. This allows the content to scroll freely.
        SliverToBoxAdapter(
          child: RefreshIndicator(
            color: colorScheme.primary,
            backgroundColor: colorScheme.surface,
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ModernCalendarView(
              onEdit: widget.onEdit,
              onDelete: widget.onDelete,
              isSelectionMode: widget.isSelectionMode,
              isSubscriptionSnoozed: widget.isSubscriptionSnoozed,
              onLongPress: widget.onLongPress,
              onTap: widget.onTap,
              onSnoozChanged: (subId) => widget.onSnoozeChanged(subId),
              snoozedIds: widget.snoozedIds,
              onSnoozeChanged: (_) {},
            ),
          ),
        ),

        // ✅ RECO: This is the core of the solution.
        // We add a conditional spacer INSIDE the CustomScrollView. This sliver
        // only exists when in selection mode, adding extra scrollable space
        // at the bottom to push the content above the "What If" bar.
        if (widget.isSelectionMode)
          const SliverToBoxAdapter(
            child: SizedBox(height: whatIfBarAreaHeight),
          ),

        // This is the normal padding for when the nav bar is visible.
        SliverToBoxAdapter(
          child: SizedBox(height: _getBottomPadding(context)),
        ),
      ],
    );
  }

  double _getBottomPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomViewInset = mediaQuery.viewInsets.bottom;
    // This padding ensures content is not hidden behind the regular nav bar.
    return 120.0 + (bottomViewInset > 0 ? 0 : DesignSystem.spacing12);
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    // Empty state remains the same
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer.withOpacity(0.5),
                      colorScheme.secondaryContainer.withOpacity(0.3),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: 72,
                  color: colorScheme.primary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "No Schedule Yet",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Add subscriptions to see them\norganized in your calendar view",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


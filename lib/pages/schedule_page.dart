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
  final void Function(String) onSnoozeChanged;
  final Set<String> snoozedIds;

  const Schedule({
    super.key,
    required this.onEdit,
    required this.onDelete,
    required this.isSelectionMode,
    required this.isSubscriptionSnoozed,
    required this.onLongPress,
    required this.onTap,
    required this.onSnoozeChanged,
    required this.snoozedIds,
  });

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SimplifiedSubscriptionProvider>();

    if (provider.subscriptions.isEmpty) {
      return _buildEmptyState(theme.colorScheme);
    }

    // Define bottom area heights
    const double whatIfBarAreaHeight = 220.0 + 40.0;

    // Use PageLayout which now handles RefreshIndicator displacement
    return PageLayout(
      onRefresh: () async {
        // You might want provider-specific refresh logic here
        await Future.delayed(const Duration(milliseconds: 500));
      },
      slivers: [
        // ✅ Main content in SliverToBoxAdapter
        // ❌ REMOVE the inner RefreshIndicator, PageLayout handles it now
        SliverToBoxAdapter(
          child: ModernCalendarView(
            onEdit: widget.onEdit,
            onDelete: widget.onDelete,
            isSelectionMode: widget.isSelectionMode,
            isSubscriptionSnoozed: widget.isSubscriptionSnoozed,
            onLongPress: widget.onLongPress,
            onTap: widget.onTap,
            onSnoozeChanged: widget.onSnoozeChanged, // Pass the correct callback
            snoozedIds: widget.snoozedIds,
            // REMOVE duplicate onSnoozeChanged: (_) {}, if it existed
          ),
        ),

        // --- Conditional Bottom Spacer for "What If" mode ---
        if (widget.isSelectionMode)
          const SliverToBoxAdapter(
            child: SizedBox(height: whatIfBarAreaHeight),
          ),

        // --- Standard Bottom Spacer for Nav Bar ---
        SliverToBoxAdapter(
          child: SizedBox(height: _getBottomPadding(context)),
        ),
      ],
    );
  }

  // Helper to calculate bottom padding needed above the nav bar
  double _getBottomPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomViewInset = mediaQuery.viewInsets.bottom; // Padding for keyboard etc.
    // Base padding (nav bar height) + extra space + keyboard inset adjustment
    return 120.0 + (bottomViewInset > 0 ? 0 : DesignSystem.spacing12);
  }

  // --- Empty State Widget (Unchanged) ---
  Widget _buildEmptyState(ColorScheme colorScheme) {
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
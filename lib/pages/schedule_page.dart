// lib/pages/schedule_page.dart

import 'package:subflow_app/widgets/shared/page_layout.dart';
import 'package:flutter/material.dart';
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
}
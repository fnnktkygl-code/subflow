import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/simplified_subscription_provider.dart';
import '../views/modern_calendar_view.dart';
import '../models/subscription_model.dart';

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
  State<Schedule> createState() =>
      _ScheduleState();
}

class _ScheduleState extends State<Schedule>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOutCubicEmphasized,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    // Start animation
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SimplifiedSubscriptionProvider>();

    return Container(
      color: theme.colorScheme.surface,
      child: provider.subscriptions.isEmpty
          ? _buildEmptyState(theme.colorScheme)
          : SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ModernCalendarView(
            onEdit: widget.onEdit,
            onDelete: widget.onDelete,
            isSelectionMode: widget.isSelectionMode,
            isSubscriptionSnoozed: widget.isSubscriptionSnoozed,
            onLongPress: widget.onLongPress,
            onTap: widget.onTap,
            onSnoozeChanged: widget.onSnoozeChanged,
            snoozedIds: widget.snoozedIds,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container with gradient
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
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: 72,
                  color: colorScheme.primary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                "No Schedule Yet",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                "Add subscriptions to see them\norganized in your calendar view",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),

              // Hint with icon
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_circle_outline_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Tap the + button to start",
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
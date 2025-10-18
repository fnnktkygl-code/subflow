// lib/views/modern_calendar_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import '../widgets/shared/subscription_card_wrapper.dart';
import '../models/subscription_model.dart';
import '../provider/simplified_subscription_provider.dart';
import '../widgets/subscription_popup.dart';
import 'calendar_helpers.dart';
import '../theme/design_system.dart';

// ==================================
// Main Calendar View Widget
// ==================================
class ModernCalendarView extends StatefulWidget {
  final void Function(Subscription) onEdit;
  final Future<bool> Function(Subscription) onDelete;
  final bool isSelectionMode;
  final bool Function(String) isSubscriptionSnoozed;
  final void Function(String) onLongPress;
  final void Function(String) onTap;
  final void Function(String) onSnoozChanged;
  final Set<String> snoozedIds;

  const ModernCalendarView({
    super.key,
    required this.onEdit,
    required this.onDelete,
    required this.isSelectionMode,
    required this.isSubscriptionSnoozed,
    required this.onLongPress,
    required this.onTap,
    required this.onSnoozChanged,
    required this.snoozedIds,
    required void Function(dynamic subId) onSnoozeChanged,
  });

  @override
  State<ModernCalendarView> createState() => _ModernCalendarViewState();
}

class _ModernCalendarViewState extends State<ModernCalendarView>
    with TickerProviderStateMixin {
  late DateTime _currentMonth;
  DateTime? _selectedDay;
  final DateTime _today = DateTime.now();
  bool _isAmountBlurred = false;
  int _swipeDirection = 0;

  late ScrollController _monthScrollController;

  static const double _itemWidth = 80.0;
  static const double _itemMargin = 4.0;
  double get _itemSlotWidth => _itemWidth + (_itemMargin * 2);
  final int _centerIndex = 12;
  List<DateTime> _months = [];

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(_today.year, _today.month, 1);
    _selectedDay = _today;
    _initializeMonths(_currentMonth);
    _monthScrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedMonth(_centerIndex);
    });
  }

  @override
  void dispose() {
    _monthScrollController.dispose();
    super.dispose();
  }

  void _initializeMonths(DateTime centerMonth) {
    _months = List.generate(25, (index) {
      return DateTime(centerMonth.year, centerMonth.month - 12 + index, 1);
    });
  }

  void _scrollToSelectedMonth(int index) {
    if (!mounted || !_monthScrollController.hasClients) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final targetOffset =
        (index * _itemSlotWidth) - (screenWidth / 2) + (_itemSlotWidth / 2);

    _monthScrollController.animateTo(
      targetOffset.clamp(0.0, _monthScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _changeMonth(int index) {
    HapticFeedback.lightImpact();
    final newSelectedMonth = _months[index];
    setState(() {
      _swipeDirection = index > _centerIndex ? 1 : (index < _centerIndex ? -1 : 0);
      _currentMonth = newSelectedMonth;
      _selectedDay = null;
      _initializeMonths(_currentMonth);
    });
    _scrollToSelectedMonth(_centerIndex);
  }

  void _selectDay(DateTime date) {
    HapticFeedback.lightImpact();
    setState(() => _selectedDay = (_selectedDay != null && DateUtils.isSameDay(_selectedDay!, date)) ? null : date);
  }

  void _toggleBlur() {
    setState(() => _isAmountBlurred = !_isAmountBlurred);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SimplifiedSubscriptionProvider>();
    final groupedSubs = provider.groupByDate();

    // ✅ FIXED: Replaced the nested SingleChildScrollView with a Column.
    //
    // PREVIOUS ISSUE:
    // This widget had its own scroll view, which conflicted with the main
    // page's scroll view (`CustomScrollView` in PageLayout). The inner scroll
    // view would "trap" the scroll gestures, preventing the main page from
    // scrolling far enough to see content hidden by the "What If" bar.
    //
    // THE SOLUTION:
    // By using a simple Column, this widget no longer scrolls independently.
    // It becomes part of the main page's content, and the PageLayout's
    // CustomScrollView becomes the one and only scroll controller. This allows
    // the conditional padding in `schedule_page.dart` to work correctly.
    return Column(
      children: [
        _buildModernMonthSelector(),
        const _WeekdayHeaderWidget(),
        _buildMonthPages(groupedSubs),
        _buildMonthlyTotal(provider),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _selectedDay != null
              ? _buildSelectedDayDetails(groupedSubs[_selectedDay!] ?? [])
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildModernMonthSelector() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        controller: _monthScrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: DesignSystem.spacing8),
        itemCount: _months.length,
        itemBuilder: (context, index) {
          final monthDate = _months[index];
          return _MonthSelectorItemWidget(
            monthDate: monthDate,
            isSelected: DateUtils.isSameMonth(monthDate, _currentMonth),
            isTodayMonth: DateUtils.isSameMonth(monthDate, _today),
            itemWidth: _itemWidth,
            itemMargin: _itemMargin,
            onTap: () => _changeMonth(index),
          );
        },
      ),
    );
  }

  Widget _buildMonthPages(Map<DateTime, List<Subscription>> groupedSubs) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        HorizontalDragGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
              () => HorizontalDragGestureRecognizer(),
              (HorizontalDragGestureRecognizer instance) {
            instance.onEnd = (details) {
              if (details.primaryVelocity == null) return;
              if (details.primaryVelocity! < -200) {
                _changeMonth(_centerIndex + 1);
              } else if (details.primaryVelocity! > 200) {
                _changeMonth(_centerIndex - 1);
              }
            };
          },
        ),
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          final slideAnimation = Tween<Offset>(
            begin: Offset(_swipeDirection.toDouble() * 0.3, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slideAnimation, child: child),
          );
        },
        child: Container(
          key: ValueKey<DateTime>(_currentMonth),
          height: 330,
          margin: EdgeInsets.symmetric(horizontal: DesignSystem.spacing8),
          child: _buildCalendarGrid(groupedSubs),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(Map<DateTime, List<Subscription>> groupedSubs) {
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstDayOffset = (DateTime(_currentMonth.year, _currentMonth.month, 1).weekday + 6) % 7;

    return GridView.builder(
      padding: EdgeInsets.all(DesignSystem.spacing8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: daysInMonth + firstDayOffset,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < firstDayOffset) return const SizedBox.shrink();

        final day = index - firstDayOffset + 1;
        final date = DateTime(_currentMonth.year, _currentMonth.month, day);
        final subsOnDay = groupedSubs[date] ?? [];

        return _CalendarDayWidget(
          date: date,
          isToday: DateUtils.isSameDay(date, _today),
          isSelected: _selectedDay != null && DateUtils.isSameDay(_selectedDay!, date),
          subscriptions: subsOnDay,
          onTap: () => _selectDay(date),
          onLongPress: () => _showActionsBottomSheet(date, subsOnDay),
        );
      },
    );
  }

  Widget _buildMonthlyTotal(SimplifiedSubscriptionProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final monthlyTotal = provider.calculateCashFlowForMonth(widget.snoozedIds, _currentMonth);
    final amountColor = CalendarHelpers.getAmountColor(monthlyTotal, colorScheme);

    return Container(
      margin: EdgeInsets.fromLTRB(
        DesignSystem.spacing12,
        DesignSystem.spacing12,
        DesignSystem.spacing12,
        DesignSystem.spacing12,
      ),
      padding: EdgeInsets.all(DesignSystem.spacing12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withOpacity(0.8),
        borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "CASH FLOW THIS MONTH",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: DesignSystem.spacing6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _toggleBlur,
                child: Container(
                  padding: EdgeInsets.all(DesignSystem.spacing6),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isAmountBlurred
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: DesignSystem.iconSmall,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(width: DesignSystem.spacing10),
              GestureDetector(
                onTap: _toggleBlur,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (Widget child, Animation<double> animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Text(
                    CalendarHelpers.formatAmount(monthlyTotal, _isAmountBlurred, context),
                    key: ValueKey<String>(
                        '$_currentMonth-$_isAmountBlurred-${widget.snoozedIds.length}'),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: amountColor,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayDetails(List<Subscription> subs) {
    final colorScheme = Theme.of(context).colorScheme;

    if (subs.isEmpty) {
      return Container(
        margin: EdgeInsets.fromLTRB(
          DesignSystem.spacing12,
          0,
          DesignSystem.spacing12,
          DesignSystem.spacing12,
        ),
        padding: EdgeInsets.all(DesignSystem.spacing20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy_rounded,
                size: 40,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              SizedBox(height: DesignSystem.spacing12),
              Text(
                'No subscriptions today',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            DesignSystem.spacing16,
            DesignSystem.spacing8,
            DesignSystem.spacing16,
            DesignSystem.spacing10,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(DesignSystem.spacing6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: DesignSystem.iconMedium,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(width: DesignSystem.spacing8),
              Text(
                '${subs.length} ${subs.length == 1 ? 'subscription' : 'subscriptions'}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            DesignSystem.spacing12,
            0,
            DesignSystem.spacing12,
            DesignSystem.spacing12,
          ),
          itemCount: subs.length,
          itemBuilder: (context, index) {
            final sub = subs[index];
            return SubscriptionCardWrapper(
              subscription: sub,
              displayDate: _selectedDay!,
              isAmountBlurred: _isAmountBlurred,
              onEdit: widget.onEdit,
              onDelete: widget.onDelete,
              isSelectionMode: widget.isSelectionMode,
              isSnoozed: widget.isSubscriptionSnoozed(sub.id),
              onLongPress: () => widget.onLongPress(sub.id),
              onTap: () => widget.onTap(sub.id),
              onSnoozeChanged: (_) => widget.onSnoozChanged(sub.id),
              interactionsEnabled: true, onSnoozChanged: (_) {  },
            );
          },
        ),
      ],
    );
  }

  void _showActionsBottomSheet(DateTime date, List<Subscription> subscriptionsForDay) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => _CalendarActionsBottomSheet(
          date: date,
          subscriptionsForDay: subscriptionsForDay,
          scrollController: scrollController,
          onAdd: (startDate) {
            showAddSubscriptionPopup(
              context,
                  (newSub) =>
                  context.read<SimplifiedSubscriptionProvider>().addSubscription(newSub),
              defaultStartDate: startDate,
            );
          },
          onEdit: (subToEdit) {
            showAddSubscriptionPopup(
              context,
                  (updatedSub) => context
                  .read<SimplifiedSubscriptionProvider>()
                  .updateSubscription(updatedSub),
              subscriptionToEdit: subToEdit,
            );
          },
          onDelete: (subToDelete) {
            _showDeleteConfirmation(context: context, subscription: subToDelete);
          },
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation({
    required BuildContext context,
    required Subscription subscription,
  }) {
    final provider = Provider.of<SimplifiedSubscriptionProvider>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
        ),
        backgroundColor: colorScheme.surfaceContainerLowest,
        title: Text(
          'Confirm Deletion',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${subscription.name}"?',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () {
              provider.deleteSubscription(subscription.id);
              Navigator.of(context).pop(true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// --- Weekday Header ---
class _WeekdayHeaderWidget extends StatelessWidget {
  const _WeekdayHeaderWidget();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Use MediaQuery to make sure it scales well on all screens
    final daysOfWeek = List.generate(7, (index) {
      final weekday = DateFormat.E().format(DateTime(2023, 1, 2 + index)); // Mon → Sun
      return Expanded(
        child: Center(
          child: Text(
            weekday.characters.first.toUpperCase(), // capitalized single letter
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    });

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSystem.spacing10,
        vertical: DesignSystem.spacing12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: daysOfWeek,
      ),
    );
  }

}

// --- Month Selector Item ---
// --- Month Selector Item ---
class _MonthSelectorItemWidget extends StatelessWidget {
  final DateTime monthDate;
  final bool isSelected;
  final bool isTodayMonth;
  final double itemWidth;
  final double itemMargin;
  final VoidCallback onTap;

  const _MonthSelectorItemWidget({
    required this.monthDate,
    required this.isSelected,
    required this.isTodayMonth,
    required this.itemWidth,
    required this.itemMargin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // These values are chosen to fit inside the 90.0px parent
    // (2 * 10.0) + (2 * 8.0) = 36.0px of chrome.
    // 90.0 - 36.0 = 54.0px left for the Column, which is > 39px.
    const double verticalMargin = 10.0;  // CHANGED: Was DesignSystem.spacing10
    const double verticalPadding = 8.0; // CHANGED: Was DesignSystem.spacing4

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        width: itemWidth,
        margin: EdgeInsets.symmetric(
          horizontal: itemMargin,
          vertical: verticalMargin, // Use new value
        ),
        padding: EdgeInsets.symmetric(
          horizontal: DesignSystem.spacing8,
          vertical: verticalPadding, // Use new value
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: !isSelected && isTodayMonth
              ? colorScheme.primaryContainer.withOpacity(0.4)
              : !isSelected
              ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
              : null,
          borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : isTodayMonth
                ? colorScheme.primary.withOpacity(0.6)
                : colorScheme.outline.withOpacity(0.2),
            width: isSelected || isTodayMonth ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                DateFormat.MMM().format(monthDate).toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : isTodayMonth
                      ? colorScheme.primary
                      : colorScheme.onSurface.withOpacity(0.8),
                  letterSpacing: 0.8,
                ),
              ),
            ),
            SizedBox(height: DesignSystem.spacing2),
            Text(
              '${monthDate.year}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? colorScheme.onPrimary.withOpacity(0.9)
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Calendar Day Cell ---
class _CalendarDayWidget extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final List<Subscription> subscriptions;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _CalendarDayWidget({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.subscriptions,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dailyTotal = subscriptions.fold(0.0, (sum, sub) => sum + sub.amount);
    final heatmapOpacity = CalendarHelpers.getHeatmapOpacity(dailyTotal);
    final baseHeatmapColor = CalendarHelpers.getAmountColor(dailyTotal, colorScheme);
    final heatmapColor = baseHeatmapColor.withOpacity(heatmapOpacity);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: isSelected ? 1.08 : 1.0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.0),
                gradient: isSelected
                    ? LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                color: isSelected ? null : heatmapColor,
                border: isToday && !isSelected
                    ? Border.all(width: 2.5, color: colorScheme.primary)
                    : subscriptions.isNotEmpty && !isSelected
                    ? Border.all(
                  width: 1,
                  color: colorScheme.outline.withOpacity(0.2),
                )
                    : null,
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : subscriptions.isNotEmpty
                    ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : null,
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : isToday
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            if (subscriptions.isNotEmpty)
              Positioned(
                bottom: -6,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  ignoring: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMiniLogo(subscriptions[0].logoUrl, 18, colorScheme, isSelected),
                      if (subscriptions.length > 1) ...[
                        const SizedBox(width: 3),
                        if (subscriptions.length == 2)
                          _buildMiniLogo(subscriptions[1].logoUrl, 18, colorScheme, isSelected)
                        else
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isSelected
                                    ? [
                                  colorScheme.onPrimary.withOpacity(0.9),
                                  colorScheme.onPrimary.withOpacity(0.7),
                                ]
                                    : [
                                  colorScheme.primary.withOpacity(0.9),
                                  colorScheme.secondary.withOpacity(0.9),
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? colorScheme.onPrimary : colorScheme.surface,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '+${subscriptions.length - 1}',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? colorScheme.primary : colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniLogo(String url, double size, ColorScheme colorScheme, bool isSelected) {
    final borderColor = isSelected ? colorScheme.onPrimary : colorScheme.surface;
    return Container(
      width: size + 2,
      height: size + 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => Container(
            color: colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.subscriptions_rounded,
              size: size * 0.6,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: colorScheme.surfaceContainerHighest,
              child: Center(
                child: SizedBox(
                  width: size * 0.5,
                  height: size * 0.5,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary.withOpacity(0.5),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- Actions Bottom Sheet ---
class _CalendarActionsBottomSheet extends StatelessWidget {
  final DateTime date;
  final List<Subscription> subscriptionsForDay;
  final ScrollController scrollController;
  final Function(DateTime) onAdd;
  final Function(Subscription) onEdit;
  final Function(Subscription) onDelete;

  const _CalendarActionsBottomSheet({
    required this.date,
    required this.subscriptionsForDay,
    required this.scrollController,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasSubscriptions = subscriptionsForDay.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5), width: 1),
        ),
      ),
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.fromLTRB(
          DesignSystem.spacing12,
          DesignSystem.spacing6,
          DesignSystem.spacing12,
          DesignSystem.spacing12,
        ),
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 50,
              height: 5,
              margin: EdgeInsets.only(bottom: DesignSystem.spacing8),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          // Date Title
          Text(
            DateFormat('EEEE, MMMM d').format(date),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(height: DesignSystem.spacing2),
          // Subs count
          Text(
            hasSubscriptions
                ? '${subscriptionsForDay.length} subscription${subscriptionsForDay.length > 1 ? 's' : ''}'
                : 'No subscriptions',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: DesignSystem.spacing10),
          // Action Tiles
          _buildActionTile(
            context,
            Icons.add_circle_outline,
            'Add Subscription',
            colorScheme.primaryContainer,
            colorScheme.onPrimaryContainer,
                () {
              Navigator.pop(context);
              onAdd(date);
            },
          ),
          if (hasSubscriptions) ...[
            SizedBox(height: DesignSystem.spacing6),
            _buildActionTile(
              context,
              Icons.edit_outlined,
              'Edit Subscription',
              colorScheme.secondaryContainer,
              colorScheme.onSecondaryContainer,
                  () => _handleEdit(context),
            ),
            SizedBox(height: DesignSystem.spacing6),
            _buildActionTile(
              context,
              Icons.delete_outline,
              'Delete Subscription',
              colorScheme.errorContainer,
              colorScheme.onErrorContainer,
                  () => _handleDelete(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionTile(
      BuildContext context,
      IconData icon,
      String title,
      Color tileColor,
      Color textColor,
      VoidCallback onTap,
      ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: tileColor,
      borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
        splashColor: textColor.withOpacity(0.1),
        highlightColor: textColor.withOpacity(0.05),
        child: Container(
          padding: EdgeInsets.all(DesignSystem.spacing10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: DesignSystem.iconLarge, color: textColor),
              SizedBox(width: DesignSystem.spacing10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleEdit(BuildContext context) {
    Navigator.pop(context);
    if (subscriptionsForDay.length == 1) {
      onEdit(subscriptionsForDay.first);
    } else {
      _showSelectionDialog(
        context: context,
        subscriptions: subscriptionsForDay,
        title: 'Which subscription to edit?',
        onSelected: onEdit,
      );
    }
  }

  void _handleDelete(BuildContext context) {
    Navigator.pop(context);
    if (subscriptionsForDay.length == 1) {
      onDelete(subscriptionsForDay.first);
    } else {
      _showSelectionDialog(
        context: context,
        subscriptions: subscriptionsForDay,
        title: 'Which subscription to delete?',
        onSelected: onDelete,
      );
    }
  }

  void _showSelectionDialog({
    required BuildContext context,
    required List<Subscription> subscriptions,
    required String title,
    required void Function(Subscription) onSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusXXL),
        ),
        backgroundColor: colorScheme.surfaceContainerLowest,
        title: Text(
          title,
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: subscriptions.length,
              separatorBuilder: (_, __) => Divider(
                height: DesignSystem.spacing12,
                color: colorScheme.outlineVariant.withOpacity(0.5),
              ),
              itemBuilder: (_, index) {
                final sub = subscriptions[index];
                final amountColor = CalendarHelpers.getAmountColor(sub.amount, colorScheme);
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      onSelected(sub);
                    },
                    splashColor: colorScheme.primary.withOpacity(0.1),
                    highlightColor: colorScheme.primary.withOpacity(0.05),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: DesignSystem.spacing8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            backgroundImage: sub.logoUrl.isNotEmpty
                                ? NetworkImage(sub.logoUrl)
                                : null,
                            child: sub.logoUrl.isEmpty
                                ? Icon(
                              Icons.subscriptions_outlined,
                              size: DesignSystem.iconMedium,
                              color: colorScheme.onSurfaceVariant,
                            )
                                : null,
                          ),
                          SizedBox(width: DesignSystem.spacing10),
                          Expanded(
                            child: Text(
                              sub.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          SizedBox(width: DesignSystem.spacing6),
                          Text(
                            CalendarHelpers.formatAmount(
                              sub.amount,
                              false,
                              dialogContext,
                            ),
                            style: TextStyle(
                              color: amountColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

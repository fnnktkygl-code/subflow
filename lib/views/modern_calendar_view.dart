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
  final void Function(String) onSnoozeChanged;
  final Set<String> snoozedIds;

  const ModernCalendarView({
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
  State<ModernCalendarView> createState() => _ModernCalendarViewState();
}

class _ModernCalendarViewState extends State<ModernCalendarView>
    with TickerProviderStateMixin {
  late DateTime _currentMonth;
  DateTime? _selectedDay;
  late final DateTime _today;
  bool _isAmountBlurred = false;
  int _swipeDirection = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _currentMonth = DateTime(_today.year, _today.month, 1);
    _selectedDay = _today;
  }

  List<Subscription> _getSubscriptionsForDay(
    Map<DateTime, List<Subscription>> groupedSubs,
    DateTime? day,
  ) {
    if (day == null) return [];
    final normalized = DateTime(day.year, day.month, day.day);
    return groupedSubs[normalized] ?? [];
  }

  void _changeMonth(int direction) {
    HapticFeedback.lightImpact();
    setState(() {
      _swipeDirection = direction;
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + direction, 1);
      _selectedDay = null;
    });
  }

  void _jumpToToday() {
    HapticFeedback.mediumImpact();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayMonth = DateTime(now.year, now.month, 1);

    setState(() {
      if (_currentMonth.isBefore(todayMonth)) {
        _swipeDirection = 1;
      } else if (_currentMonth.isAfter(todayMonth)) {
        _swipeDirection = -1;
      } else {
        _swipeDirection = 0;
      }
      _currentMonth = todayMonth;
      _selectedDay = today;
    });
  }

  void _selectDay(DateTime date) {
    HapticFeedback.lightImpact();
    final normalized = DateTime(date.year, date.month, date.day);
    setState(() => _selectedDay = (_selectedDay != null && DateUtils.isSameDay(_selectedDay!, normalized)) ? null : normalized);
  }

  void _toggleBlur() {
    setState(() => _isAmountBlurred = !_isAmountBlurred);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SimplifiedSubscriptionProvider>();
    final groupedSubs = provider.groupByDate();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 768;

        if (isWideScreen) {
          return _buildDesktopLayout(provider, groupedSubs);
        }

        return _buildMobileLayout(provider, groupedSubs);
      },
    );
  }

  Widget _buildDesktopLayout(
    SimplifiedSubscriptionProvider provider,
    Map<DateTime, List<Subscription>> groupedSubs,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedDate = _selectedDay ?? _today;
    final selectedDaySubs = _getSubscriptionsForDay(groupedSubs, selectedDate);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.spacing16,
            vertical: DesignSystem.spacing12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Calendar Card + Monthly Cash Flow
              Expanded(
                flex: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? colorScheme.surface : Colors.white,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.4 : 0.8),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.25)
                            : const Color(0xFF20201E).withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(DesignSystem.spacing12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModernMonthSelector(),
                      const _WeekdayHeaderWidget(),
                      _buildMonthPages(groupedSubs),
                      const SizedBox(height: DesignSystem.spacing8),
                      _buildSevenDayForecastBanner(provider),
                      _buildMonthlyTotal(provider),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: DesignSystem.spacing20),

              // Right Column: Dedicated Selected Day Agenda Pane
              Expanded(
                flex: 5,
                child: _buildDesktopAgendaPanel(
                  selectedDate,
                  selectedDaySubs,
                  colorScheme,
                  isDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopAgendaPanel(
    DateTime selectedDate,
    List<Subscription> subs,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final totalDue = subs.fold<double>(0.0, (sum, sub) => sum + sub.amount);
    final isToday = DateUtils.isSameDay(selectedDate, _today);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.4 : 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : const Color(0xFF20201E).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(DesignSystem.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Date & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            DateFormat('EEEE, d MMMM').format(selectedDate),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
                            ),
                            child: Text(
                              'TODAY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subs.isEmpty
                          ? 'No payments scheduled'
                          : '${subs.length} ${subs.length == 1 ? 'payment' : 'payments'} scheduled • €${totalDue.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  showAddSubscriptionPopup(
                    context,
                    (newSub) => context.read<SimplifiedSubscriptionProvider>().addSubscription(newSub),
                    defaultStartDate: selectedDate,
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacing16),
          const Divider(height: 1),
          const SizedBox(height: DesignSystem.spacing16),

          // Content
          if (subs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B4D3C).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        size: 40,
                        color: Color(0xFF3B4D3C),
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spacing16),
                    Text(
                      'Serene Day',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spacing6),
                    Text(
                      'No renewals or charges on this day.',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final sub = subs[index];
                return SubscriptionCardWrapper(
                  subscription: sub,
                  displayDate: selectedDate,
                  isAmountBlurred: _isAmountBlurred,
                  onEdit: widget.onEdit,
                  onDelete: widget.onDelete,
                  isSelectionMode: widget.isSelectionMode,
                  isSnoozed: widget.isSubscriptionSnoozed(sub.id),
                  onLongPress: () => widget.onLongPress(sub.id),
                  onTap: () => widget.onTap(sub.id),
                  onSnoozeChanged: (_) => widget.onSnoozeChanged(sub.id),
                  interactionsEnabled: true,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    SimplifiedSubscriptionProvider provider,
    Map<DateTime, List<Subscription>> groupedSubs,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          children: [
            _buildModernMonthSelector(),
            const _WeekdayHeaderWidget(),
            _buildMonthPages(groupedSubs),
            _buildSevenDayForecastBanner(provider),
            _buildMonthlyTotal(provider),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _selectedDay != null
                  ? _buildSelectedDayDetails(_getSubscriptionsForDay(groupedSubs, _selectedDay))
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildModernMonthSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool isCurrentMonth = DateUtils.isSameMonth(_currentMonth, _today);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DesignSystem.spacing4,
            DesignSystem.spacing10,
            DesignSystem.spacing4,
            DesignSystem.spacing4,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                iconSize: DesignSystem.iconXLarge,
                onPressed: () => _changeMonth(-1),
                tooltip: 'Previous Month',
              ),
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(_swipeDirection.toDouble() * 0.3, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      DateFormat('MMMM yyyy').format(_currentMonth),
                      key: ValueKey(_currentMonth),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                iconSize: DesignSystem.iconXLarge,
                onPressed: () => _changeMonth(1),
                tooltip: 'Next Month',
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isCurrentMonth ? 0 : 40,
          curve: Curves.easeInOut,
          child: isCurrentMonth
              ? const SizedBox.shrink()
              : OverflowBox(
            maxHeight: 40,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextButton.icon(
                onPressed: _jumpToToday,
                icon: const Icon(Icons.today_rounded, size: DesignSystem.iconMedium),
                label: const Text('Go to Today'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
                _changeMonth(1);
              } else if (details.primaryVelocity! > 200) {
                _changeMonth(-1);
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
          margin: const EdgeInsets.symmetric(horizontal: DesignSystem.spacing8),
          child: _buildCalendarGrid(groupedSubs),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(Map<DateTime, List<Subscription>> groupedSubs) {
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstDayOffset = (DateTime(_currentMonth.year, _currentMonth.month, 1).weekday + 6) % 7;

    return GridView.builder(
      padding: const EdgeInsets.all(DesignSystem.spacing8),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthlyTotal = provider.calculateCashFlowForMonth(widget.snoozedIds, _currentMonth);
    final amountColor = CalendarHelpers.getAmountColor(monthlyTotal, context);

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: DesignSystem.spacing6,
        horizontal: DesignSystem.spacing4,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: DesignSystem.spacing10,
        horizontal: DesignSystem.spacing12,
      ),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerLow : const Color(0xFFFBF9F5),
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.4 : 0.8),
          width: 1,
        ),
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
          const SizedBox(height: DesignSystem.spacing6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _toggleBlur,
                child: Container(
                  padding: const EdgeInsets.all(DesignSystem.spacing6),
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
              const SizedBox(width: DesignSystem.spacing10),
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

  Widget _buildSevenDayForecastBanner(SimplifiedSubscriptionProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subs = provider.subscriptions.where((s) => !widget.isSubscriptionSnoozed(s.id)).toList();
    final sevenDayTotal = CalendarHelpers.getNext7DaysTotal(subs);
    final count = CalendarHelpers.getNext7DaysCount(subs);

    if (count == 0 && sevenDayTotal == 0) return const SizedBox.shrink();

    final formattedAmount = _isAmountBlurred ? '••••' : '€${sevenDayTotal.toStringAsFixed(2)}';

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSystem.spacing8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHigh : const Color(0xFFF3EFEA),
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.6),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Next 7 Days ($count):',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formattedAmount,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayDetails(List<Subscription> subs) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (subs.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(
          DesignSystem.spacing12,
          0,
          DesignSystem.spacing12,
          DesignSystem.spacing12,
        ),
        padding: const EdgeInsets.all(DesignSystem.spacing20),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.4 : 0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : const Color(0xFF20201E).withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B4D3C).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  size: 36,
                  color: Color(0xFF3B4D3C),
                ),
              ),
              const SizedBox(height: DesignSystem.spacing12),
              Text(
                'Serene Day',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: DesignSystem.spacing4),
              Text(
                'No payments scheduled for this date.',
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
          padding: const EdgeInsets.fromLTRB(
            DesignSystem.spacing16,
            DesignSystem.spacing8,
            DesignSystem.spacing16,
            DesignSystem.spacing10,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DesignSystem.spacing6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: DesignSystem.iconMedium,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: DesignSystem.spacing8),
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
          padding: const EdgeInsets.fromLTRB(
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
              onSnoozeChanged: (_) => widget.onSnoozeChanged(sub.id),
              interactionsEnabled: true,
            );
          },
        ),
      ],
    );
  }

  void _showActionsBottomSheet(DateTime date, List<Subscription> subscriptionsForDay) {
    final BuildContext viewContext = context;

    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: viewContext,
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
          viewContext: viewContext,
          onAdd: (startDate) {
            showAddSubscriptionPopup(
              viewContext,
                  (newSub) =>
                  viewContext.read<SimplifiedSubscriptionProvider>().addSubscription(newSub),
              defaultStartDate: startDate,
            );
          },
          onEdit: (subToEdit) {
            showAddSubscriptionPopup(
              viewContext,
                  (updatedSub) => viewContext
                  .read<SimplifiedSubscriptionProvider>()
                  .updateSubscription(updatedSub),
              subscriptionToEdit: subToEdit,
            );
          },
          onDelete: (subToDelete) {
            _showDeleteConfirmation(context: viewContext, subscription: subToDelete);
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

    final daysOfWeek = List.generate(7, (index) {
      final weekday = DateFormat.E().format(DateTime(2023, 1, 2 + index));
      return Expanded(
        child: Center(
          child: Text(
            weekday.characters.first.toUpperCase(),
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
      padding: const EdgeInsets.symmetric(
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
    // ✅ FIX 2: Pass the full context here as well
    final baseHeatmapColor = CalendarHelpers.getAmountColor(dailyTotal, context);
    final heatmapColor = baseHeatmapColor.withValues(alpha: heatmapOpacity);

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
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                color: isSelected ? null : heatmapColor,
                border: isToday && !isSelected
                    ? Border.all(width: 2.0, color: colorScheme.primary)
                    : subscriptions.isNotEmpty && !isSelected
                    ? Border.all(
                  width: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                )
                    : null,
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
                    : subscriptions.isNotEmpty
                    ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
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
                      _buildMiniLogo(subscriptions[0].effectiveLogoUrl, 18, colorScheme, isSelected),
                      if (subscriptions.length > 1) ...[
                        const SizedBox(width: 3),
                        if (subscriptions.length == 2)
                          _buildMiniLogo(subscriptions[1].effectiveLogoUrl, 18, colorScheme, isSelected)
                        else
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isSelected
                                    ? [
                                  colorScheme.onPrimary.withValues(alpha: 0.95),
                                  colorScheme.onPrimary.withValues(alpha: 0.8),
                                ]
                                    : [
                                  colorScheme.primary,
                                  colorScheme.primary.withValues(alpha: 0.85),
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? colorScheme.onPrimary : colorScheme.surface,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
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
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
          ),
        ],
      ),
      child: ClipOval(
        child: url.isNotEmpty
            ? Image.network(
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
                    strokeWidth: 1.5,
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            );
          },
        )
            : Container(
          color: colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.subscriptions_rounded,
            size: size * 0.6,
            color: colorScheme.onSurfaceVariant,
          ),
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
  final BuildContext viewContext;

  const _CalendarActionsBottomSheet({
    required this.date,
    required this.subscriptionsForDay,
    required this.scrollController,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.viewContext,
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
          top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 1),
        ),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(
          DesignSystem.spacing12,
          DesignSystem.spacing6,
          DesignSystem.spacing12,
          DesignSystem.spacing12,
        ),
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: DesignSystem.spacing8),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Text(
            DateFormat('EEEE, MMMM d').format(date),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing2),
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
          const SizedBox(height: DesignSystem.spacing10),
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
            const SizedBox(height: DesignSystem.spacing6),
            _buildActionTile(
              context,
              Icons.edit_outlined,
              'Edit Subscription',
              colorScheme.secondaryContainer,
              colorScheme.onSecondaryContainer,
                  () => _handleEdit(context),
            ),
            const SizedBox(height: DesignSystem.spacing6),
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
        splashColor: textColor.withValues(alpha: 0.1),
        highlightColor: textColor.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.all(DesignSystem.spacing10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: DesignSystem.iconLarge, color: textColor),
              const SizedBox(width: DesignSystem.spacing10),
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
        context: viewContext,
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
        context: viewContext,
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
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              itemBuilder: (_, index) {
                final sub = subscriptions[index];
                // ✅ FIX 3: Pass the correct context (dialogContext)
                final amountColor = CalendarHelpers.getAmountColor(sub.amount, dialogContext);
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      onSelected(sub);
                    },
                    splashColor: colorScheme.primary.withValues(alpha: 0.1),
                    highlightColor: colorScheme.primary.withValues(alpha: 0.05),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: DesignSystem.spacing8),
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
                          const SizedBox(width: DesignSystem.spacing10),
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
                          const SizedBox(width: DesignSystem.spacing6),
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


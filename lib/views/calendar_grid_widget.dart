import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import '../models/subscription_model.dart';
import '/widgets/subscription_card.dart';
import 'calendar_helpers.dart';
import 'calendar_view_widgets.dart'; // Contains WeekdayHeaderWidget

// ======================================================================
// Calendar Grid Widget - Calendar Display Logic
// ======================================================================

class CalendarGridWidget extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime? selectedDay;
  final DateTime today;
  final bool isAmountBlurred;
  final int swipeDirection;
  final Map<DateTime, List<Subscription>> groupedSubs;
  final Function(DateTime?) onDaySelected;
  final Function(int) onMonthChange;
  final VoidCallback onToggleBlur;

  const CalendarGridWidget({
    super.key,
    required this.currentMonth,
    required this.selectedDay,
    required this.today,
    required this.isAmountBlurred,
    required this.swipeDirection,
    required this.groupedSubs,
    required this.onDaySelected,
    required this.onMonthChange,
    required this.onToggleBlur,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const WeekdayHeaderWidget(),
        _buildMonthPages(context),
        _buildEnhancedMonthlyTotal(context),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          child: selectedDay != null
              ? _buildSelectedDayDetails(context, groupedSubs[selectedDay!] ?? [])
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildMonthPages(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        HorizontalDragGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
              () => HorizontalDragGestureRecognizer(),
              (HorizontalDragGestureRecognizer instance) {
            instance.onEnd = (details) {
              if (details.primaryVelocity == null) return;
              if (details.primaryVelocity! < -200) {
                onMonthChange(1);
              } else if (details.primaryVelocity! > 200) {
                onMonthChange(-1);
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
            begin: Offset(swipeDirection * 0.3, 0.0),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slideAnimation, child: child),
          );
        },
        child: Container(
          key: ValueKey<DateTime>(currentMonth),
          height: 330,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildCalendarGrid(context),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(currentMonth.year, currentMonth.month);
    final firstDayOffset = DateTime(currentMonth.year, currentMonth.month, 1).weekday - 1;

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
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
        final date = DateTime(currentMonth.year, currentMonth.month, day);
        return CalendarDayWidget(
          date: date,
          isToday: DateUtils.isSameDay(date, today),
          isSelected: selectedDay != null && DateUtils.isSameDay(selectedDay!, date),
          subscriptions: groupedSubs[date] ?? [],
          onTap: () {
            HapticFeedback.lightImpact();
            final isCurrentlySelected = selectedDay != null && DateUtils.isSameDay(selectedDay!, date);
            onDaySelected(isCurrentlySelected ? null : date);
          },
        );
      },
    );
  }

  Widget _buildEnhancedMonthlyTotal(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final monthlyTotal = CalendarHelpers.calculateMonthlyTotal(groupedSubs, currentMonth);
    final Color amountColor = CalendarHelpers.getAmountColor(monthlyTotal, colorScheme);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainerHighest.withOpacity(0.8),
            colorScheme.surfaceContainer.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: amountColor.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "MONTH TOTAL",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.5,
                ),
              ),
              GestureDetector(
                onTap: () {
                  onToggleBlur();
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isAmountBlurred
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              onToggleBlur();
              HapticFeedback.lightImpact();
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Text(
                // ✅ FIXED: Added the missing 'context' argument here
                CalendarHelpers.formatAmount(monthlyTotal, isAmountBlurred, context),
                key: ValueKey<String>('$currentMonth-$isAmountBlurred'),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: amountColor,
                  letterSpacing: -1.5,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayDetails(BuildContext context, List<Subscription> subs) {
    final colorScheme = Theme.of(context).colorScheme;

    if (subs.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_busy_rounded,
                size: 40,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
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
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Row(
            children: [
              Icon(Icons.receipt_long_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '${subs.length} ${subs.length == 1 ? 'subscription' : 'subscriptions'}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: subs.length,
          itemBuilder: (context, index) {
            return SubscriptionCard(
              subscription: subs[index],
              displayDate: selectedDay!,
              isAmountBlurred: false,
            );
          },
        ),
      ],
    );
  }
}

// ======================================================================
// Calendar Day Widget - Individual day cell
// ======================================================================

class CalendarDayWidget extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final List<Subscription> subscriptions;
  final VoidCallback onTap;

  const CalendarDayWidget({
    super.key,
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.subscriptions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double dailyTotal = subscriptions.fold(0.0, (sum, sub) => sum + sub.amount);
    final double heatmapOpacity = CalendarHelpers.getHeatmapOpacity(dailyTotal);

    Color heatmapColor = Colors.transparent;
    if (dailyTotal < 0) {
      heatmapColor = colorScheme.error.withOpacity(heatmapOpacity);
    } else if (dailyTotal > 0) {
      heatmapColor = CalendarHelpers.getRevenueColor(colorScheme).withOpacity(heatmapOpacity);
    }

    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.95, end: isSelected ? 1.0 : 0.95),
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
                    ? Border.all(width: 1, color: colorScheme.outline.withOpacity(0.2))
                    : null,
                boxShadow: isSelected
                    ? [BoxShadow(color: colorScheme.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]
                    : subscriptions.isNotEmpty
                    ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
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
            // Logo indicators
            if (subscriptions.isNotEmpty)
              Positioned(
                bottom: -6,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MiniLogoWidget(
                      url: subscriptions[0].logoUrl,
                      size: 18,
                      isSelected: isSelected,
                    ),
                    if (subscriptions.length > 1) ...[
                      const SizedBox(width: 3),
                      if (subscriptions.length == 2)
                        MiniLogoWidget(
                          url: subscriptions[1].logoUrl,
                          size: 18,
                          isSelected: isSelected,
                        )
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
                              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
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
          ],
        ),
      ),
    );
  }
}
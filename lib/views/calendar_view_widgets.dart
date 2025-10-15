import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ======================================================================
// Reusable Widgets for Calendar View
// ======================================================================

/// Month Selector - Horizontal scrolling month picker
class MonthSelectorWidget extends StatelessWidget {
  final List<DateTime> months;
  final DateTime currentMonth;
  final DateTime today;
  final double itemWidth;
  final double itemMargin;
  final ScrollController scrollController;
  final Function(int) onMonthTap;
  final int centerIndex;

  const MonthSelectorWidget({
    super.key,
    required this.months,
    required this.currentMonth,
    required this.today,
    required this.itemWidth,
    required this.itemMargin,
    required this.scrollController,
    required this.onMonthTap,
    required this.centerIndex,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 90,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: months.length,
        itemBuilder: (context, index) {
          final monthDate = months[index];
          final isTodayMonth = DateUtils.isSameMonth(monthDate, today);
          final isSelectedMonth = DateUtils.isSameMonth(monthDate, currentMonth);

          return GestureDetector(
            onTap: () => onMonthTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              width: itemWidth,
              margin: EdgeInsets.symmetric(horizontal: itemMargin, vertical: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isSelectedMonth
                    ? LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                color: !isSelectedMonth && isTodayMonth
                    ? colorScheme.primaryContainer.withOpacity(0.4)
                    : !isSelectedMonth
                    ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
                    : null,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelectedMonth
                      ? Colors.transparent
                      : isTodayMonth
                      ? colorScheme.primary.withOpacity(0.6)
                      : colorScheme.outline.withOpacity(0.2),
                  width: isSelectedMonth || isTodayMonth ? 2 : 1,
                ),
                boxShadow: isSelectedMonth
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
                  Text(
                    DateFormat.MMM().format(monthDate).toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isSelectedMonth
                          ? colorScheme.onPrimary
                          : isTodayMonth
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.8),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${monthDate.year}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelectedMonth
                          ? colorScheme.onPrimary.withOpacity(0.9)
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ======================================================================
// Weekday Header Widget
// ======================================================================

/// Weekday Header - Shows M T W T F S S
class WeekdayHeaderWidget extends StatelessWidget {
  const WeekdayHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(7, (index) {
          final weekday = DateFormat.E().format(DateTime(2023, 1, 2 + index));
          return Expanded(
            child: Center(
              child: Text(
                weekday[0],
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ======================================================================
// Mini Logo Widget
// ======================================================================

/// Mini Logo Widget - Small circular logo for calendar days
class MiniLogoWidget extends StatelessWidget {
  final String url;
  final double size;
  final bool isSelected;

  const MiniLogoWidget({
    super.key,
    required this.url,
    required this.size,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size + 2,
      height: size + 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? colorScheme.onPrimary : colorScheme.surface,
          width: 1.5,
        ),
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
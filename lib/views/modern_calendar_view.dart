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
  // --- STATE VARIABLES ---
  late DateTime _currentMonth;
  DateTime? _selectedDay;
  final DateTime _today = DateTime.now();
  bool _isAmountBlurred = false;
  int _swipeDirection = 0;

  // --- CONTROLLERS ---
  late ScrollController _monthScrollController;

  // --- MONTH SELECTOR CONFIG ---
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
      _currentMonth = newSelectedMonth;
      _selectedDay = null;
      _initializeMonths(_currentMonth);
    });
    _scrollToSelectedMonth(_centerIndex);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SimplifiedSubscriptionProvider>();
    // ✅ CORRECTION : Ne pas filtrer la liste ici. Le calendrier doit toujours afficher TOUS les abonnements.
    // Le mode "what-if" ne change que l'apparence des cartes et le calcul du total, pas la présence sur la grille.
    final groupedSubs = provider.groupByDate();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      child: Column(
        children: [
          _buildModernMonthSelector(),
          _buildWeekdayHeader(),
          _buildMonthPages(groupedSubs),
          _buildGamifiedMonthlyTotal(provider),
          if (_selectedDay != null)
            _buildSelectedDayDetails(groupedSubs[_selectedDay!] ?? []),
        ],
      ),
    );
  }

  Widget _buildGamifiedMonthlyTotal(SimplifiedSubscriptionProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    // ✅ CORRECTION : Appelle la nouvelle méthode du provider qui calcule le FLUX de trésorerie du mois,
    // en tenant compte des abonnements exclus.
    final monthlyTotal = provider.calculateCashFlowForMonth(widget.snoozedIds, _currentMonth);
    final amountColor = CalendarHelpers.getAmountColor(monthlyTotal, colorScheme);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            "TOTAL FOR THIS MONTH",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withOpacity(0.7),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() => _isAmountBlurred = !_isAmountBlurred);
              HapticFeedback.lightImpact();
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
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
    );
  }

  Widget _buildModernMonthSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 90,
      child: ListView.builder(
        controller: _monthScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _months.length,
        itemBuilder: (context, index) {
          final monthDate = _months[index];
          final isTodayMonth = DateUtils.isSameMonth(monthDate, _today);
          final isSelectedMonth = DateUtils.isSameMonth(monthDate, _currentMonth);

          return GestureDetector(
            onTap: () => _changeMonth(index),
            child: Container(
              width: _itemWidth,
              margin: const EdgeInsets.symmetric(horizontal: _itemMargin, vertical: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: isSelectedMonth
                      ? LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : null,
                  color: isTodayMonth && !isSelectedMonth
                      ? colorScheme.primaryContainer.withOpacity(0.3)
                      : !isSelectedMonth
                      ? colorScheme.surfaceContainer
                      : null,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelectedMonth
                        ? Colors.transparent
                        : isTodayMonth
                        ? colorScheme.primary.withOpacity(0.5)
                        : colorScheme.outlineVariant.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        DateFormat.MMM().format(monthDate).toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelectedMonth
                              ? colorScheme.onPrimary
                              : isTodayMonth
                              ? colorScheme.primary
                              : colorScheme.onSurface.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
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
                            : colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
      child: Row(
        children: List.generate(7, (index) {
          final weekday = DateFormat.E().format(DateTime(2023, 1, 2 + index));
          return Expanded(
            child: Center(
              child: Text(
                weekday[0],
                style: TextStyle(
                  color: colorScheme.primary.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }),
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
                setState(() => _swipeDirection = 1);
                _changeMonth(_centerIndex + 1);
              } else if (details.primaryVelocity! > 200) {
                setState(() => _swipeDirection = -1);
                _changeMonth(_centerIndex - 1);
              }
            };
          },
        ),
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final slideAnimation = Tween<Offset>(
            begin: Offset(_swipeDirection.toDouble(), 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slideAnimation, child: child),
          );
        },
        child: SizedBox(
          key: ValueKey<DateTime>(_currentMonth),
          height: 320,
          child: _buildCalendarGrid(groupedSubs),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(Map<DateTime, List<Subscription>> groupedSubs) {
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstDayOffset = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday - 1;

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: daysInMonth + firstDayOffset,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < firstDayOffset) return Container();
        final day = index - firstDayOffset + 1;
        final date = DateTime(_currentMonth.year, _currentMonth.month, day);
        return _buildCalendarDay(date: date, groupedSubs: groupedSubs);
      },
    );
  }

  Widget _buildCalendarDay({
    required DateTime date,
    required Map<DateTime, List<Subscription>> groupedSubs,
  }) {
    final isToday = DateUtils.isSameDay(date, _today);
    final isSelected = _selectedDay != null && DateUtils.isSameDay(_selectedDay!, date);
    final subsOnDay = groupedSubs[date] ?? [];
    final colorScheme = Theme.of(context).colorScheme;

    final double dailyTotal = subsOnDay.fold(0.0, (sum, sub) => sum + sub.amount);
    final double heatmapOpacity = CalendarHelpers.getHeatmapOpacity(dailyTotal);
    final Color baseHeatmapColor = CalendarHelpers.getAmountColor(dailyTotal, colorScheme);
    final Color heatmapColor = baseHeatmapColor.withOpacity(heatmapOpacity);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedDay = isSelected ? null : date);
      },
      onLongPress: () {
        _showActionsBottomSheet(date, subsOnDay);
      },
      child: AnimatedScale(
        scale: isSelected ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
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
                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            if (subsOnDay.isNotEmpty)
              Positioned(
                bottom: -5,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (subsOnDay.isNotEmpty)
                      _buildMiniLogo(subsOnDay[0].logoUrl, 16, colorScheme, isSelected),
                    if (subsOnDay.length > 1) ...[
                      const SizedBox(width: 2),
                      if (subsOnDay.length == 2)
                        _buildMiniLogo(subsOnDay[1].logoUrl, 16, colorScheme, isSelected)
                      else
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.onPrimary.withOpacity(0.3)
                                : colorScheme.primary.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: isSelected ? colorScheme.onPrimary : Colors.white,
                                width: 1),
                          ),
                          child: Center(
                            child: Text(
                              '+${subsOnDay.length - 1}',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.primary,
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

  Widget _buildMiniLogo(String url, double size, ColorScheme colorScheme, bool isSelected) {
    return Container(
      width: size + 2,
      height: size + 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: isSelected ? colorScheme.onPrimary : Colors.white, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3)],
      ),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildSelectedDayDetails(List<Subscription> subs) {
    if (subs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            'No subscriptions on this day.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
        );
      },
    );
  }

  void _showActionsBottomSheet(DateTime date, List<Subscription> subscriptionsForDay) {
    HapticFeedback.mediumImpact();
    final provider = Provider.of<SimplifiedSubscriptionProvider>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;
    final hasSubscriptions = subscriptionsForDay.isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surfaceContainerHighest,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  DateFormat('EEEE, MMMM d').format(date),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasSubscriptions
                      ? '${subscriptionsForDay.length} subscription${subscriptionsForDay.length > 1 ? 's' : ''}'
                      : 'No subscriptions',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                _buildActionTile(
                  context: bottomSheetContext,
                  icon: Icons.add_circle_outline,
                  title: 'Add Subscription',
                  gradient: LinearGradient(
                    colors: [colorScheme.primaryContainer, colorScheme.secondaryContainer],
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    showAddSubscriptionPopup(
                      context,
                          (newSub) => provider.addSubscription(newSub),
                      defaultStartDate: date,
                    );
                  },
                ),
                if (hasSubscriptions) ...[
                  const SizedBox(height: 12),
                  _buildActionTile(
                    context: bottomSheetContext,
                    icon: Icons.edit_outlined,
                    title: 'Edit Subscription',
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade100, Colors.indigo.shade100],
                    ),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      if (subscriptionsForDay.length == 1) {
                        showAddSubscriptionPopup(
                          context,
                              (updatedSub) => provider.updateSubscription(updatedSub),
                          subscriptionToEdit: subscriptionsForDay.first,
                        );
                      } else {
                        _showSelectionDialog(
                          context: context,
                          subscriptions: subscriptionsForDay,
                          title: 'Which subscription to edit?',
                          onSelected: (selectedSub) {
                            showAddSubscriptionPopup(
                              context,
                                  (updatedSub) => provider.updateSubscription(updatedSub),
                              subscriptionToEdit: selectedSub,
                            );
                          },
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    context: bottomSheetContext,
                    icon: Icons.delete_outline,
                    title: 'Delete Subscription',
                    gradient: LinearGradient(
                      colors: [Colors.red.shade100, Colors.pink.shade100],
                    ),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      if (subscriptionsForDay.length == 1) {
                        _showDeleteConfirmation(
                          context: context,
                          subscription: subscriptionsForDay.first,
                        );
                      } else {
                        _showSelectionDialog(
                          context: context,
                          subscriptions: subscriptionsForDay,
                          title: 'Which subscription to delete?',
                          onSelected: (selectedSub) {
                            _showDeleteConfirmation(
                              context: context,
                              subscription: selectedSub,
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
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
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: colorScheme.surface,
          title: Text(title, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: subscriptions.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 16, color: colorScheme.outlineVariant),
              itemBuilder: (context, index) {
                final sub = subscriptions[index];
                final Color amountColor =
                CalendarHelpers.getAmountColor(sub.amount, Theme.of(dialogContext).colorScheme);

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    onSelected(sub);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(sub.logoUrl),
                          onBackgroundImageError: (_, __) {},
                          child:
                          sub.logoUrl.isEmpty ? const Icon(Icons.subscriptions, size: 20) : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child:
                          Text(sub.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                        Text(
                          CalendarHelpers.formatAmount(sub.amount, false, dialogContext),
                          style: TextStyle(
                            color: amountColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmation({
    required BuildContext context,
    required Subscription subscription,
  }) {
    final provider = Provider.of<SimplifiedSubscriptionProvider>(context, listen: false);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${subscription.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
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


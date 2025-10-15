import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quick_stat.dart';
import '../models/subscription_model.dart';
import '../provider/simplified_subscription_provider.dart';
import '../theme/custom_colors.dart';
import '../widgets/home/upcoming_payments.dart';
import '../widgets/shared/category_bottom_sheet.dart';
import '../widgets/shared/subscription_card_wrapper.dart';
import '../widgets/home/spending_card.dart';
import '../widgets/home/quick_insights_pills.dart';
import '../widgets/home/header_section.dart';
import '../widgets/home/category_chart.dart';
import '../widgets/home/smart_tip_card.dart';
import '../widgets/home/achievements_section.dart';
import '../widgets/home/empty_state.dart';
import '../widgets/shared/goal_dialog.dart';
import '../utils/home_helpers.dart';
import '../provider/simplified_gamification.dart';

class Home extends StatefulWidget {
  final bool isSelectionMode;
  final Set<String> snoozedIds;

  const Home({
    super.key,
    this.isSelectionMode = false,
    this.snoozedIds = const {},
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ValueNotifier<double> _goalNotifier = ValueNotifier<double>(250.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SimplifiedGamification>().checkDailyActivity();
    });
  }

  @override
  void dispose() {
    _goalNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gamification = context.watch<SimplifiedGamification>();
    final subProvider = context.watch<SimplifiedSubscriptionProvider>();

    if (subProvider.subscriptions.isEmpty) {
      return const Scaffold(body: EmptyState());
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) context.read<SimplifiedGamification>().checkDailyActivity();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: HeaderSection(gamification: gamification)),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  ValueListenableBuilder<double>(
                    valueListenable: _goalNotifier,
                    builder: (context, goal, _) {
                      final monthlyCost = widget.isSelectionMode
                          ? subProvider.getFilteredTotalMonthlyCost(widget.snoozedIds)
                          : subProvider.totalMonthlyCost;
                      return SpendingCard(
                        monthlyCost: monthlyCost,
                        goal: goal,
                        onEditGoal: () => _showGoalDialog(context, monthlyCost),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  QuickInsightsPills(
                    stats: _buildQuickStats(subProvider, gamification),
                  ),
                  const SizedBox(height: 16),

                  UpcomingPayments(
                    subscriptions: subProvider.subscriptions.take(3).toList(),
                    onViewAll: () {},
                  ),
                  const SizedBox(height: 16),

                  if (subProvider.categorySpending.isNotEmpty)
                    CategoryChart(
                      spending: widget.isSelectionMode
                          ? subProvider.getFilteredCategorySpending(widget.snoozedIds)
                          : subProvider.categorySpending,
                      onCategoryTap: (category) =>
                          _showCategoryDetail(context, category, subProvider),
                    ),
                  const SizedBox(height: 16),

                  if (_buildSmartTip(subProvider) != null)
                    SmartTipCard(
                      tip: _buildSmartTip(subProvider)!,
                      onExplore: () {},
                    ),
                  if (_buildSmartTip(subProvider) != null) const SizedBox(height: 16),

                  AchievementsSection(achievements: gamification.achievements),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<QuickStat> _buildQuickStats(
      SimplifiedSubscriptionProvider subProvider,
      SimplifiedGamification gamification,
      ) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>();
    final current = subProvider.totalMonthlyCost;
    final previous = current * 0.9;
    final trend = HomeHelpers.calculateTrend(current, previous);

    final expenseColor = customColors?.heatmapExpense ?? colorScheme.error;
    final incomeColor = customColors?.heatmapIncome ?? colorScheme.tertiary;

    return [
      QuickStat(
        emoji: trend > 0 ? '📈' : '📉',
        label: 'vs last month',
        value: '${trend > 0 ? '+' : ''}${trend.toStringAsFixed(0)}%',
        color: trend > 0 ? expenseColor : incomeColor,
        backgroundColor: (trend > 0 ? expenseColor : incomeColor)?.withOpacity(0.1) ?? colorScheme.surface.withOpacity(0.1),
      ),
      QuickStat(
        emoji: '🔥',
        label: 'day streak',
        value: '${gamification.level * 3}',
        color: colorScheme.secondary,
        backgroundColor: colorScheme.secondaryContainer.withOpacity(0.2),
      ),
      QuickStat(
        emoji: '💎',
        label: 'active subs',
        value: '${subProvider.subscriptions.length}',
        color: colorScheme.primary,
        backgroundColor: colorScheme.primaryContainer.withOpacity(0.2),
      ),
    ];
  }

  String? _buildSmartTip(SimplifiedSubscriptionProvider subProvider) {
    final categorySpending = widget.isSelectionMode
        ? subProvider.getFilteredCategorySpending(widget.snoozedIds)
        : subProvider.categorySpending;

    return HomeHelpers.generateSmartTip(categorySpending);
  }

  void _showGoalDialog(BuildContext context, double currentCost) {
    GoalDialog.show(
      context,
      currentGoal: _goalNotifier.value,
      currentCost: currentCost,
      onGoalSet: (newGoal) => _goalNotifier.value = newGoal,
    );
  }

  void _showCategoryDetail(
      BuildContext context, String category, SimplifiedSubscriptionProvider subProvider) {
    final categorySubs =
    subProvider.subscriptions.where((sub) => sub.category == category).toList();

    CategoryBottomSheet.show(
      context,
      category: category,
      subscriptions: categorySubs,
      onFindAlternatives: () {},
    );
  }
}

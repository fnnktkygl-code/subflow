// lib/pages/home_page.dart

import 'package:subflow_app/widgets/shared/page_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for HapticFeedback
import 'package:provider/provider.dart';
import '../provider/simplified_subscription_provider.dart';
import '../provider/user_profile_provider.dart';
import '../widgets/home/upcoming_payments.dart';
import '../widgets/shared/category_bottom_sheet.dart';
import '../widgets/home/spending_card.dart';
import '../widgets/home/category_chart.dart';
import '../widgets/home/empty_state.dart';
import '../widgets/shared/goal_dialog.dart';
import '../widgets/shared/income_setup_dialog.dart';
import '../widgets/home/income_insight_banner.dart';
import '../provider/simplified_gamification.dart';
import '../widgets/home/section_wrapper.dart';
import '../widgets/home/greeting_header.dart';
import '../models/subscription_model.dart';
import '../widgets/subscription_popup.dart';
import '../theme/design_system.dart';
import '../widgets/bottom_nav_bar.dart'; // Import for the global key

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

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late AnimationController _pageLoadController;
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _pageLoadController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SimplifiedGamification>().checkDailyActivity();
      }
    });
  }

  @override
  void dispose() {
    _pageLoadController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subProvider = context.watch<SimplifiedSubscriptionProvider>();
    final profileProvider = context.watch<UserProfileProvider>();

    if (subProvider.subscriptions.isEmpty) {
      return Scaffold(
        body: _buildEmptyStateWithAnimation(),
      );
    }

    final monthlyCost = widget.isSelectionMode
        ? subProvider.getFilteredTotalMonthlyCost(widget.snoozedIds)
        : subProvider.totalMonthlyCost;
    final hasCategories = subProvider.categorySpending.isNotEmpty;
    final incomeInsight = profileProvider.getIncomeInsight(monthlyCost);
    final incomeStatus = profileProvider.getHealthStatus(monthlyCost);

    final List<Widget> homeWidgets = [];

    homeWidgets.add(
      SpendingCard(
        monthlyCost: monthlyCost,
        goal: profileProvider.spendingGoal,
        monthlyIncome: profileProvider.monthlyIncome,
        onEditGoal: () => _showGoalDialog(context, monthlyCost, profileProvider),
        onEditIncome: () => _showIncomeDialog(context, profileProvider),
        profileProvider: profileProvider,
      ),
    );
    homeWidgets.add(const SizedBox(height: DesignSystem.spacing8));

    if (incomeInsight != null && incomeStatus != IncomeHealthStatus.unknown) {
      homeWidgets.add(
        _buildSectionWithHeader(
          'Your Income Health',
          Icons.health_and_safety_rounded,
          IncomeInsightBanner(
            message: incomeInsight,
            status: incomeStatus,
          ),
        ),
      );
      homeWidgets.add(const SizedBox(height: DesignSystem.spacing8));
    }

    homeWidgets.add(
      _buildSectionWithHeader(
        'Upcoming Payments',
        Icons.calendar_today_rounded,
        const UpcomingPayments(), // No longer needs onViewAll here
        trailing: TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            bottomNavBarKey.currentState?.onNavItemTapped(2);
          },
          child: const Text('View All'),
        ),
      ),
    );
    homeWidgets.add(const SizedBox(height: DesignSystem.spacing8));

    if (hasCategories) {
      homeWidgets.add(
        _buildSectionWithHeader(
          'Spending Breakdown',
          Icons.pie_chart_rounded,
          CategoryChart(
            spending: widget.isSelectionMode
                ? subProvider.getFilteredCategorySpending(widget.snoozedIds)
                : subProvider.categorySpending,
            onCategoryTap: (category) =>
                _showCategoryDetail(context, category, subProvider, profileProvider),
          ),
        ),
      );
    }

    return PageLayout(
      onRefresh: () async {
        final gamification = context.read<SimplifiedGamification>();
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          gamification.checkDailyActivity();
        }
      },
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            DesignSystem.spacing8,
            DesignSystem.spacing12,
            DesignSystem.spacing8,
            DesignSystem.spacing12,
          ),
          sliver: SliverToBoxAdapter(
            child: _buildAnimatedWidget(0, const GreetingHeader()),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacing8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return _buildAnimatedWidget(index + 1, homeWidgets[index]);
              },
              childCount: homeWidgets.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: _getBottomPadding(context)),
        ),
      ],
    );
  }

  Widget _buildAnimatedWidget(int index, Widget child) {
    final begin = const Offset(0, 0.3);
    final end = Offset.zero;
    final curve = Curves.easeOut;

    final tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    final delay = index * 0.1;

    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: (delay * 1000).toInt())),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SlideTransition(
            position: _staggerController.drive(tween),
            child: FadeTransition(
              opacity: _staggerController.drive(
                Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve)),
              ),
              child: child,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSectionWithHeader(
      String label,
      IconData icon,
      Widget child, {
        Widget? trailing,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEnhancedSectionHeader(label, icon, trailing: trailing),
        const SizedBox(height: DesignSystem.spacing6),
        SectionWrapper(
          child: child,
        ),
      ],
    );
  }

  Widget _buildEnhancedSectionHeader(String label, IconData icon,
      {Widget? trailing}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(DesignSystem.spacing6),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
          ),
          child: Icon(
            icon,
            size: DesignSystem.iconLarge,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: DesignSystem.spacing8),
        Expanded(
          child: Text(
            label,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  double _getBottomPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomViewInset = mediaQuery.viewInsets.bottom;
    final base = widget.isSelectionMode ? 240.0 : 120.0;
    return base + (bottomViewInset > 0 ? 0 : DesignSystem.spacing12);
  }

  Widget _buildEmptyStateWithAnimation() {
    return FadeTransition(
      opacity: _pageLoadController.drive(
        Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
      ),
      child: SlideTransition(
        position: _pageLoadController.drive(
          Tween(begin: const Offset(0, 0.2), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOut)),
        ),
        child: const EmptyState(),
      ),
    );
  }

  void _showGoalDialog(BuildContext context, double currentCost, UserProfileProvider profileProvider) {
    GoalDialog.show(
      context,
      currentGoal: profileProvider.spendingGoal,
      currentCost: currentCost,
      monthlyIncome: profileProvider.monthlyIncome,
      profileProvider: profileProvider,
      onGoalSet: (newGoal) {
        profileProvider.updateSpendingGoal(newGoal);
      },
    );
  }

  void _showIncomeDialog(BuildContext context, UserProfileProvider profileProvider) {
    IncomeSetupDialog.show(
      context,
      currentIncome: profileProvider.monthlyIncome,
      onIncomeSaved: (income) async {
        await profileProvider.updateIncome(income);
      },
    );
  }

  void _showCategoryDetail(
      BuildContext context,
      String category,
      SimplifiedSubscriptionProvider subProvider,
      UserProfileProvider profileProvider,
      ) {
    final categorySubs = subProvider.subscriptions
        .where((sub) => sub.category == category)
        .toList();

    final categoryAmount = subProvider.categorySpending[category] ?? 0.0;
    final categoryInsight = profileProvider.getCategoryInsight(
      category,
      categoryAmount,
    );

    CategoryBottomSheet.show(
      context,
      category: category,
      subscriptions: categorySubs,
      categoryInsight: categoryInsight,
      onFindAlternatives: () {},
      onEdit: (Subscription sub) {
        showAddSubscriptionPopup(
          context,
              (updatedSub) => subProvider.updateSubscription(updatedSub),
          subscriptionToEdit: sub,
        );
      },
      onDelete: (Subscription sub) {
        return _showDeleteConfirmation(
          context: context,
          subscription: sub,
          provider: subProvider,
        );
      },
    );
  }

  Future<bool> _showDeleteConfirmation({
    required BuildContext context,
    required Subscription subscription,
    required SimplifiedSubscriptionProvider provider,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
        ),
        title: const Text(
          'Confirm Deletion',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Delete "${subscription.name}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              provider.deleteSubscription(subscription.id);
              Navigator.pop(context, true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}


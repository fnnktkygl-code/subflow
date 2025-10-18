// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/simplified_subscription_provider.dart';
import '../provider/user_profile_provider.dart';
import '../views/upcoming_list_widget.dart';
import '../widgets/shared/category_bottom_sheet.dart';
import '../widgets/home/spending_card.dart';
import '../widgets/home/category_chart.dart';
import '../widgets/home/empty_state.dart';
import '../widgets/shared/goal_dialog.dart';
import '../widgets/shared/income_setup_dialog.dart';
import '../widgets/home/income_insight_banner.dart';
import '../widgets/home/income_prompt_card.dart';
import '../provider/simplified_gamification.dart';
import '../widgets/home/section_wrapper.dart';
import '../widgets/home/greeting_header.dart';
import '../models/subscription_model.dart';
import '../widgets/subscription_popup.dart';
import '../theme/design_system.dart';

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

    // Page load animation
    _pageLoadController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    // Stagger animation for list items
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
    final colorScheme = Theme.of(context).colorScheme;

    if (subProvider.subscriptions.isEmpty) {
      return Scaffold(
        body: _buildEmptyStateWithAnimation(),
      );
    }

    final monthlyCost = widget.isSelectionMode
        ? subProvider.getFilteredTotalMonthlyCost(widget.snoozedIds)
        : subProvider.totalMonthlyCost;

    final hasCategories = subProvider.categorySpending.isNotEmpty;

    final shouldShowIncomePrompt = profileProvider.shouldShowIncomePrompt(
      subProvider.subscriptions.length,
    );

    final incomeInsight = profileProvider.getIncomeInsight(monthlyCost);
    final incomeStatus = profileProvider.getHealthStatus(monthlyCost);

    final List<Widget> homeWidgets = [];

    // 0. GREETING HEADER - with animation
    homeWidgets.add(
      _buildAnimatedWidget(
        0,
        const GreetingHeader(),
      ),
    );
    homeWidgets.add(SizedBox(height: DesignSystem.spacing8));

    // 1. SPENDING CARD - hero with animation
    homeWidgets.add(
      _buildAnimatedWidget(
        1,
        SpendingCard(
          monthlyCost: monthlyCost,
          goal: profileProvider.spendingGoal,
          monthlyIncome: profileProvider.monthlyIncome,
          onEditGoal: () => _showGoalDialog(context, monthlyCost, profileProvider),
          onEditIncome: () => _showIncomeDialog(context, profileProvider),
        ),
      ),
    );
    homeWidgets.add(SizedBox(height: DesignSystem.spacing8));

    // 2. INCOME PROMPT
    if (shouldShowIncomePrompt) {
      homeWidgets.add(
        _buildAnimatedWidget(
          2,
          IncomePromptCard(
            onAddIncome: () => _showIncomeDialog(context, profileProvider),
            onDismiss: () async {
              await profileProvider.dismissIncomePrompt();
            },
          ),
        ),
      );
      homeWidgets.add(SizedBox(height: DesignSystem.spacing8));
    }

    // 3. INCOME HEALTH SECTION
    if (incomeInsight != null && incomeStatus != IncomeHealthStatus.unknown) {
      homeWidgets.add(
        _buildAnimatedWidget(
          3,
          _buildSectionWithHeader(
            'Your Income Health',
            Icons.health_and_safety_rounded,
            IncomeInsightBanner(
              message: incomeInsight,
              status: incomeStatus,
            ),
          ),
        ),
      );
      homeWidgets.add(SizedBox(height: DesignSystem.spacing8));
    }

    // 4. UPCOMING PAYMENTS
    homeWidgets.add(
      _buildAnimatedWidget(
        4,
        _buildSectionWithHeader(
          'Upcoming Payments',
          Icons.calendar_today_rounded,
          UpcomingPayments(
            subscriptions: subProvider.subscriptions.take(3).toList(),
            onViewAll: () {},
          ),
        ),
      ),
    );

    // 5. CATEGORY CHART
    if (hasCategories) {
      homeWidgets.add(SizedBox(height: DesignSystem.spacing8));
      homeWidgets.add(
        _buildAnimatedWidget(
          5,
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
        ),
      );
    }

    // 6. BOTTOM PADDING - dynamic
    homeWidgets.add(SizedBox(height: _getBottomPadding(context)));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        color: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        onRefresh: () async {
          // 1. Get the provider *before* the async gap
          final gamification = context.read<SimplifiedGamification>();

          // 2. The async gap
          await Future.delayed(const Duration(milliseconds: 800));

          // 3. Now use the variable. The 'mounted' check is still good practice.
          if (mounted) {
            gamification.checkDailyActivity();
          }
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(DesignSystem.spacing8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    return homeWidgets[index];
                  },
                  childCount: homeWidgets.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HELPER: Build staggered animated widget
  Widget _buildAnimatedWidget(int index, Widget child) {
    final begin = Offset(0, 0.3);
    final end = Offset.zero;
    final curve = Curves.easeOut;

    final tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    // Stagger delay based on index
    final delay = index * 0.1; // 100ms between each item

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
        return SizedBox(
          height: child is SizedBox ? 0 : null,
          child: child,
        );
      },
    );
  }

  // HELPER: Build section with improved header
  Widget _buildSectionWithHeader(
      String label,
      IconData icon,
      Widget child,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEnhancedSectionHeader(label, icon),
        SizedBox(height: DesignSystem.spacing6),
        SectionWrapper(
          child: child,
        ),
      ],
    );
  }

  // HELPER: Enhanced section header with better styling
  Widget _buildEnhancedSectionHeader(String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(DesignSystem.spacing6),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
          ),
          child: Icon(
            icon,
            size: DesignSystem.iconLarge,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(width: DesignSystem.spacing8),
        Text(
          label,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  // HELPER: Dynamic bottom padding
  double _getBottomPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomViewInset = mediaQuery.viewInsets.bottom;

    // Ensure minimum padding plus safe area
    final minPadding = DesignSystem.spacing20 + (bottomViewInset > 0 ? 0 : DesignSystem.spacing12);

    return minPadding;
  }

  // HELPER: Empty state with animation
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
      onGoalSet: (newGoal) {
        profileProvider.updateSpendingGoal(newGoal);
      },
      onAddIncome: () => _showIncomeDialog(context, profileProvider),
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
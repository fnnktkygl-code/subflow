// lib/widgets/bottom_nav_bar.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../provider/simplified_subscription_provider.dart';
import 'package:subflow_app/provider/simplified_gamification.dart';
import '../pages/home_page.dart';
import '../pages/settings_page.dart';
import '../pages/schedule_page.dart';
import '../pages/subscriptions_page.dart';
import '../models/subscription_model.dart';
import '../mixins/selection_mode_mixin.dart';
import '../theme/theme.dart';
import 'subscription_popup.dart' as subs_popup;
import 'smooth_scroll_behavior.dart';
import 'shared/japandi_svg_icons.dart';

// Global key for accessing the bottom nav state
final GlobalKey<BottomNavBarState> bottomNavBarKey =
GlobalKey<BottomNavBarState>();

class BottomNavBar extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ValueChanged<Color> onChangeAccentColor;
  final VoidCallback onResetAccentColor;
  final int currentThemeIndex;

  const BottomNavBar({
    super.key,
    required this.onToggleTheme,
    required this.onChangeAccentColor,
    required this.onResetAccentColor,
    required this.currentThemeIndex,
  });

  @override
  State<BottomNavBar> createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar>
    with TickerProviderStateMixin, SelectionModeMixin, SmoothScrollMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _pulseController;
  late AnimationController _fabController;

  bool isBarbieTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.colorScheme.primary == barbieThemeData.colorScheme.primary;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  // ✅ RENAMED from _onNavItemTapped to make it public
  void onNavItemTapped(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          scrollBehavior.forceShow();
        }
      });
    }
  }

  Future<bool> _showDeleteConfirmation(
      BuildContext context,
      Subscription subscription,
      SimplifiedSubscriptionProvider provider,
      ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Confirm Deletion'),
        content: Text('Delete "${subscription.name}"?'),
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
    return result ?? false;
  }

  @override
  void enterSelectionMode(String subscriptionId) {
    HapticFeedback.mediumImpact();
    super.enterSelectionMode(subscriptionId);
    scrollBehavior.forceShow();
  }

  @override
  void exitSelectionMode() {
    HapticFeedback.lightImpact();
    super.exitSelectionMode();
    scrollBehavior.forceShow();
  }

  @override
  void clearAllSelections() {
    HapticFeedback.lightImpact();
    super.clearAllSelections();
    scrollBehavior.forceShow();
  }

  @override
  void toggleSnooze(String subscriptionId) {
    HapticFeedback.selectionClick();
    super.toggleSnooze(subscriptionId);
    scrollBehavior.forceShow();
  }

  @override
  void selectAllSubscriptions(SimplifiedSubscriptionProvider provider) {
    HapticFeedback.mediumImpact();
    super.selectAllSubscriptions(provider);
    scrollBehavior.forceShow();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SimplifiedSubscriptionProvider>(
      builder: (context, provider, child) {
        final colorScheme = Theme.of(context).colorScheme;
        final topPadding = MediaQuery.of(context).padding.top;
        final bottomPadding = MediaQuery.of(context).padding.bottom;

        final pages = [
          Home(isSelectionMode: isSelectionMode, snoozedIds: snoozedIds),
          Schedule(
            onEdit: (sub) => provider.updateSubscription(sub),
            onDelete: (sub) => _showDeleteConfirmation(context, sub, provider),
            isSelectionMode: isSelectionMode,
            isSubscriptionSnoozed: isSubscriptionSnoozed,
            onLongPress: enterSelectionMode,
            onTap: toggleSnooze,
            onSnoozeChanged: toggleSnooze,
            snoozedIds: snoozedIds,
          ),
          Subscriptions(
            isSelectionMode: isSelectionMode,
            isSubscriptionSnoozed: isSubscriptionSnoozed,
            onEdit: (sub) => provider.updateSubscription(sub),
            onDelete: (sub) => _showDeleteConfirmation(context, sub, provider),
            enterSelectionMode: enterSelectionMode,
            toggleSnooze: toggleSnooze,
            snoozedIds: snoozedIds,
          ),
          Settings(
            onChangeAccentColor: widget.onChangeAccentColor,
            onResetAccentColor: widget.onResetAccentColor,
          ),
        ];

        final titles = ['Home', 'Schedule', 'Subs', 'Settings'];

        return PopScope(
          canPop: _currentIndex == 0,
          onPopInvokedWithResult: (bool didPop, dynamic result) {
            if (!didPop) onNavItemTapped(0);
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Stack(
              children: [
                Positioned.fill(
                  child: buildWithScrollBehavior(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentIndex = index);
                        scrollBehavior.forceShow();
                      },
                      children: pages,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ScrollAwareWidget(
                    animation: scrollAnimation,
                    alignment: Alignment.topCenter,
                    child: _buildGlassAppBar(
                      context,
                      titles[_currentIndex],
                      topPadding,
                      colorScheme,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ScrollAwareWidget(
                    animation: scrollAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelectionMode)
                          buildWhatIfActionBar(
                            provider: provider,
                            colorScheme: colorScheme,
                          ),
                        _buildModernNavBar(
                          context,
                          colorScheme,
                          provider,
                          bottomPadding,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassAppBar(
      BuildContext context,
      String title,
      double topPadding,
      ColorScheme colorScheme,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double backgroundOpacity = isDark ? 0.75 : 0.85;

    return RepaintBoundary(
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            padding: EdgeInsets.only(
              top: topPadding + 8,
              left: 20,
              right: 20,
              bottom: 12,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow.withValues(alpha: backgroundOpacity),
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onToggleTheme();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainer.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: themeIcon(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget themeIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = colorScheme.brightness == Brightness.dark;

    Color iconBgColor = colorScheme.primaryContainer
        .withValues(alpha: isDarkMode ? 0.4 : 0.6);
    IconData themeIconData =
    isDarkMode ? Icons.dark_mode_outlined : Icons.wb_sunny_outlined;
    Widget iconWidget = Icon(themeIconData,
        size: 22, color: colorScheme.onPrimaryContainer);

    if (!isDarkMode && isBarbieTheme(context)) {
      iconWidget =
          Image.asset('assets/icons/barbie.png', height: 22, width: 22);
      iconBgColor = colorScheme.secondaryContainer.withValues(alpha: 0.6);
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: iconBgColor,
      ),
      padding: const EdgeInsets.all(6.0),
      child: iconWidget,
    );
  }

  Widget _buildModernNavBar(
      BuildContext context,
      ColorScheme colorScheme,
      SimplifiedSubscriptionProvider provider,
      double bottomPadding,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0 + bottomPadding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: SizedBox(
              height: 80,
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  // WHAT IF BAR (pinned above nav bar)
                  if (isSelectionMode)
                    Positioned(
                      bottom: 82,
                      left: 0,
                      right: 0,
                      child: buildWhatIfActionBar(
                        provider: provider,
                        colorScheme: colorScheme,
                      ),
                    ),

                  // MODERN FLOATING NAV BAR
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          height: 68,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1C1C19).withValues(alpha: 0.90)
                                : const Color(0xFFFDFCF9).withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: colorScheme.outlineVariant
                            .withValues(alpha: isDark ? 0.4 : 0.8),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.35)
                              : const Color(0xFF20201E).withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildModernNavItem(
                          svgType: JapandiSvgType.home,
                          iconFallback: Icons.home_rounded,
                          label: 'Home',
                          index: 0,
                          colorScheme: colorScheme,
                        ),
                        _buildModernNavItem(
                          svgType: JapandiSvgType.calendar,
                          iconFallback: Icons.calendar_month_rounded,
                          label: 'Schedule',
                          index: 1,
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(width: 65), // Space for FAB
                        _buildModernNavItem(
                          svgType: JapandiSvgType.subscriptions,
                          iconFallback: Icons.view_list_rounded,
                          label: 'Subs',
                          index: 2,
                          colorScheme: colorScheme,
                        ),
                        _buildModernNavItem(
                          svgType: JapandiSvgType.settings,
                          iconFallback: Icons.settings_rounded,
                          label: 'Settings',
                          index: 3,
                          colorScheme: colorScheme,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
                  Positioned(
                    bottom: 26,
                    child: _buildGamifiedFab(context, colorScheme, provider),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernNavItem({
    required JapandiSvgType svgType,
    required IconData iconFallback,
    required String label,
    required int index,
    required ColorScheme colorScheme,
  }) {
    final isSelected = _currentIndex == index;

    return InkWell(
      key: Key('nav_item_${label.toLowerCase()}'),
      onTap: () => onNavItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            JapandiSvgIcon(
              type: svgType,
              size: 22,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamifiedFab(
      BuildContext context,
      ColorScheme colorScheme,
      SimplifiedSubscriptionProvider provider,
      ) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _fabController]),
      child: SizedBox(
        width: 58,
        height: 58,
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            _fabController.reverse().then((_) => _fabController.forward());
            subs_popup.showAddSubscriptionPopup(
              context,
                  (newSub) {
                provider.addSubscription(newSub);
                context.read<SimplifiedGamification>().onSubscriptionAdded();
              },
            );
          },
          elevation: 2.0,
          highlightElevation: 4.0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          splashColor: colorScheme.onPrimary.withValues(alpha: 0.2),
          shape: const CircleBorder(),
          child: Center(
            child: JapandiSvgIcon(
              type: JapandiSvgType.add,
              size: 24,
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      ),
      builder: (context, fabChild) {
        final pulseScale = 1.0 + (_pulseController.value * 0.03);
        final tapScale = _fabController.value;

        return Transform.scale(
          scale: pulseScale * tapScale,
          child: fabChild,
        );
      },
    );
  }
}

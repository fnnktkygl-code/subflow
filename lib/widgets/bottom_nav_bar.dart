import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../provider/simplified_subscription_provider.dart';
import 'package:aada_app/provider/simplified_gamification.dart';
import '../pages/home_page.dart';
import '../../pages/settings_page.dart';
import '../pages/schedule_page.dart';
import '../pages/subscriptions_page.dart';
import '../models/subscription_model.dart';
import '../mixins/selection_mode_mixin.dart';
import '../theme/theme.dart';
import 'subscription_popup.dart' as subs_popup;
import 'smooth_scroll_behavior.dart';

// Global key for accessing the bottom nav state
final GlobalKey<BottomNavBarState> bottomNavBarKey =
GlobalKey<BottomNavBarState>();

class BottomNavBar extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ValueChanged<Color> onChangeAccentColor;
  final VoidCallback onResetAccentColor;

  const BottomNavBar({
    super.key,
    required this.onToggleTheme,
    required this.onChangeAccentColor,
    required this.onResetAccentColor,
    required int currentThemeIndex,
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
// Inside BottomNavBarState (or as a top-level helper)
  bool isBarbieTheme(BuildContext context) {
    final theme = Theme.of(context);
    // Option 1: Compare primary color to Barbie theme's primary
    return theme.colorScheme.primary == barbieThemeData.colorScheme.primary;

    // Option 2: If you want more robust checking, you can add a
    // bool property in CustomColors and check it here.
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

  void _onNavItemTapped(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
      scrollBehavior.forceShow();
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
            if (!didPop) _onNavItemTapped(0);
          },
          child: Scaffold(
            backgroundColor: colorScheme.surface,
            body: Stack(
              children: [
                // Page content with proper padding
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: scrollAnimation,
                    builder: (context, child) {
                      final topOffset =
                          (topPadding + 70) * scrollAnimation.value;
                      final bottomOffset =
                          (100 + bottomPadding) * scrollAnimation.value;

                      return Padding(
                        padding: EdgeInsets.only(
                          top: topOffset,
                          bottom: bottomOffset,
                        ),
                        child: child,
                      );
                    },
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
                ),

                // Floating glass app bar
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

                // Bottom navbar & actions
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
              color: colorScheme.surface.withOpacity(0.85),
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                // Theme toggle button with Barbie support
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
                        color: colorScheme.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: themeIcon(context), // ✅ Barbie-ready icon
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Barbie / Light / Dark mode icon helper
  Widget themeIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = colorScheme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primaryContainer.withOpacity(0.6),
      ),
      padding: const EdgeInsets.all(8.0),
      child: isDarkMode
          ? const Icon(Icons.dark_mode, size: 24)
          : isBarbieTheme(context)
          ? Image.asset('assets/icons/barbie.png', height: 24, width: 24)
          : const Icon(Icons.wb_sunny, size: 24),
    );
  }


  Widget _buildModernNavBar(
      BuildContext context,
      ColorScheme colorScheme,
      SimplifiedSubscriptionProvider provider,
      double bottomPadding,
      ) {
    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 20.0 + bottomPadding),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Glass nav bar
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [ // ✅ FIXED
                        colorScheme.surfaceContainer.withOpacity(0.9),
                        colorScheme.surfaceContainer.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildModernNavItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        index: 0,
                        colorScheme: colorScheme,
                      ),
                      _buildModernNavItem(
                        icon: Icons.calendar_month_rounded,
                        label: 'Schedule',
                        index: 1,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(width: 70),
                      _buildModernNavItem(
                        icon: Icons.view_list_rounded,
                        label: 'Subs',
                        index: 2,
                        colorScheme: colorScheme,
                      ),
                      _buildModernNavItem(
                        icon: Icons.settings_rounded,
                        label: 'Settings',
                        index: 3,
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Floating Action Button
            Positioned(
              bottom: 30,
              child: _buildGamifiedFab(context, colorScheme, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernNavItem({
    required IconData icon,
    required String label,
    required int index,
    required ColorScheme colorScheme,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              padding: EdgeInsets.all(isSelected ? 8 : 6),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient( // ✅ FIXED
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                color: isSelected ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: isSelected ? 24 : 22,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                letterSpacing: 0.3,
              ),
              child: Text(label),
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
      builder: (context, child) {
        final pulseScale = 1.0 + (_pulseController.value * 0.04);
        final tapScale = _fabController.value;

        return Transform.scale(
          scale: pulseScale * tapScale,
          child: SizedBox(
            width: 68,
            height: 68,
            child: FloatingActionButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                subs_popup.showAddSubscriptionPopup(
                  context,
                      (newSub) {
                    provider.addSubscription(newSub);
                    context
                        .read<SimplifiedGamification>()
                        .onSubscriptionAdded();
                  },
                );
              },
              elevation: 6.0,
              child: const Icon(Icons.add_rounded, size: 32),
            ),
          ),
        );
      },
    );
  }
}
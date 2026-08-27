import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A robust and smooth scroll-to-hide/show behavior controller.
///
/// This class has been refactored to provide a much more stable experience,
/// eliminating the "janky" or "flickering" behavior seen previously.
class SmoothScrollBehavior {
  final AnimationController controller;
  final VoidCallback? onShow;
  final VoidCallback? onHide;

  bool _isVisible = true;

  SmoothScrollBehavior({
    required this.controller,
    this.onShow,
    this.onHide,
  });

  bool get isVisible => _isVisible;

  /// =======================================================================
  /// SCROLLING FLICKER & BOUNCE FIX
  /// =======================================================================
  /// PREVIOUS ISSUE:
  /// The logic `if (metrics.atEdge)` would show the nav bar whenever the
  /// scroll view was at the top, including during an overscroll "bounce".
  /// This made it impossible to scroll to the top and keep the nav bar hidden,
  /// as the bounce effect would always make it reappear.
  ///
  /// THE SOLUTION:
  /// The logic is now more nuanced.
  /// 1.  We still only listen to `UserScrollNotification` for stability.
  /// 2.  The rule for showing the bar at the bottom edge remains, as it's good UX.
  /// 3.  The main change is for the `ScrollDirection.forward` (scrolling up) case.
  ///     We now check if `metrics.pixels > 5.0`. This creates a small
  ///     "buffer zone" at the very top of the list.
  /// 4.  The bounce effect typically happens within this 5-pixel zone, so the
  ///     condition to show the nav bar isn't met, and it correctly stays hidden.
  ///     An intentional scroll down by the user will quickly pass this threshold
  ///     and show the bar as expected.
  ///
  /// This prevents the bounce from triggering an unwanted animation and provides
  /// the stable, full-screen view the user expects at the top of the page.
  void handleScroll(ScrollNotification notification) {
    // We only care about user-driven scroll direction changes for stability.
    if (notification is! UserScrollNotification) {
      return;
    }

    final metrics = notification.metrics;

    // If we've scrolled to the very bottom, always show the nav bar.
    if (metrics.atEdge && metrics.pixels == metrics.maxScrollExtent) {
      _show();
      return;
    }

    if (notification.direction == ScrollDirection.reverse) {
      // User is scrolling DOWN the list (e.g., finger moving up). Hide the bar.
      _hide();
    } else if (notification.direction == ScrollDirection.forward) {
      // User is scrolling UP the list (e.g., finger moving down).
      // Show the nav bar, but only if they've scrolled past our top buffer zone.
      // This prevents the overscroll bounce from re-showing the bar.
      if (metrics.pixels > 5.0) {
        _show();
      }
    }
  }

  void _show() {
    if (!_isVisible) {
      _isVisible = true;
      controller.forward();
      onShow?.call();
    }
  }

  void _hide() {
    if (_isVisible) {
      _isVisible = false;
      controller.reverse();
      onHide?.call();
    }
  }

  /// Force the navigation bars to appear.
  void forceShow() {
    _show();
  }

  /// Force the navigation bars to disappear.
  void forceHide() {
    _hide();
  }

  void dispose() {
    // No-op now, but kept for API consistency. Timers were removed.
  }
}

/// Mixin for easy integration of the scroll behavior into StatefulWidgets.
mixin SmoothScrollMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late final AnimationController scrollAnimationController;
  late final Animation<double> scrollAnimation;
  late final SmoothScrollBehavior scrollBehavior;

  @override
  void initState() {
    super.initState();

    scrollAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0, // Start fully visible
    );

    scrollAnimation = CurvedAnimation(
      parent: scrollAnimationController,
      curve: Curves.easeInOutCubic,
    );

    scrollBehavior = SmoothScrollBehavior(
      controller: scrollAnimationController,
      onShow: onScrollShow,
      onHide: onScrollHide,
    );
  }

  @override
  void dispose() {
    scrollAnimationController.dispose();
    scrollBehavior.dispose();
    super.dispose();
  }

  // Optional callbacks for consuming widgets.
  void onScrollShow() {}
  void onScrollHide() {}

  /// Wraps the child widget with a NotificationListener to enable scroll awareness.
  Widget buildWithScrollBehavior({required Widget child}) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        scrollBehavior.handleScroll(notification);
        return false; // Allow the notification to continue to bubble up.
      },
      child: child,
    );
  }
}

/// An animated widget that slides and fades based on the scroll animation controller.
class ScrollAwareWidget extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final Alignment alignment;

  const ScrollAwareWidget({
    super.key,
    required this.child,
    required this.animation,
    this.alignment = Alignment.bottomCenter,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final value = animation.value;
        final yOffset = alignment == Alignment.topCenter ? -(1 - value) : (1 - value);

        return IgnorePointer(
          ignoring: value == 0,
          child: Transform.translate(
            offset: Offset(0, yOffset * 60),
            child: Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
    );
  }
}


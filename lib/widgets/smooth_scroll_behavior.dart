import 'dart:async';
import 'package:flutter/material.dart';

/// Modern, fluid scroll-to-hide/show behavior with velocity detection
/// Enhanced with better state management and performance
class SmoothScrollBehavior {
  final AnimationController controller;
  final VoidCallback? onShow;
  final VoidCallback? onHide;

  // Configuration
  final double hideThreshold;
  final double showThreshold;
  final double velocityThreshold;

  // State tracking
  bool _isVisible = true;
  double _lastScrollOffset = 0;
  double _accumulatedDelta = 0;
  Timer? _hideTimer;
  DateTime? _lastScrollTime;

  SmoothScrollBehavior({
    required this.controller,
    this.onShow,
    this.onHide,
    this.hideThreshold = 50.0,
    this.showThreshold = 10.0,
    this.velocityThreshold = 200.0,
  });

  bool get isVisible => _isVisible;

  /// Call this from NotificationListener<ScrollNotification>
  void handleScroll(ScrollNotification notification) {
    // If the content is not scrollable, always show the bars.
    // This is the main fix for pages with little or no content.
    if (notification.metrics.maxScrollExtent <= 0) {
      _show();
      return;
    }

    if (notification is! UserScrollNotification &&
        notification is! ScrollUpdateNotification) {
      return;
    }

    final metrics = notification.metrics;
    final currentOffset = metrics.pixels;
    final now = DateTime.now();

    // Calculate scroll delta and velocity
    final scrollDelta = currentOffset - _lastScrollOffset;

    double velocity = 0;
    if (_lastScrollTime != null) {
      final timeDelta = now.difference(_lastScrollTime!).inMilliseconds / 1000.0;
      if (timeDelta > 0) {
        velocity = scrollDelta.abs() / timeDelta;
      }
    }

    _lastScrollOffset = currentOffset;
    _lastScrollTime = now;

    // Cancel any pending hide timer
    _hideTimer?.cancel();

    // At the top of the scroll - always show
    if (currentOffset <= 0) {
      _show();
      _accumulatedDelta = 0;
      return;
    }

    // Near the bottom - always show (for better UX)
    if (metrics.maxScrollExtent > 0 &&
        metrics.maxScrollExtent - currentOffset < 100) {
      _show();
      return;
    }

    // Fast scroll detection - hide immediately on downward scroll
    if (velocity > velocityThreshold && scrollDelta > 0) {
      _hide();
      return;
    }

    // Accumulate delta for threshold-based detection
    _accumulatedDelta += scrollDelta;

    // Threshold-based detection with accumulated delta
    if (_accumulatedDelta > hideThreshold) {
      _hide();
      _accumulatedDelta = 0;
    } else if (_accumulatedDelta < -showThreshold) {
      _show();
      _accumulatedDelta = 0;
    }

    // Idle detection - show after 2 seconds of no scrolling
    if (notification is ScrollEndNotification) {
      _hideTimer = Timer(const Duration(seconds: 2), () {
        if (!_isVisible) {
          _show();
        }
      });
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

  /// Force show (e.g., when user taps nav item)
  void forceShow() {
    _show();
    _accumulatedDelta = 0;
    _lastScrollOffset = 0;
  }

  /// Force hide
  void forceHide() {
    _hide();
  }

  void dispose() {
    _hideTimer?.cancel();
  }
}

/// Mixin for easy integration into StatefulWidgets
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
      value: 1.0,
    );

    scrollAnimation = CurvedAnimation(
      parent: scrollAnimationController,
      curve: Curves.easeInOutCubicEmphasized,
      reverseCurve: Curves.easeInOutCubicEmphasized,
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

  void onScrollShow() {}
  void onScrollHide() {}

  Widget buildWithScrollBehavior({required Widget child}) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        scrollBehavior.handleScroll(notification);
        return false;
      },
      child: child,
    );
  }
}

/// Animated widget that slides in/out based on scroll
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
      builder: (context, child) {
        final value = animation.value;
        final offset = alignment == Alignment.topCenter
            ? Offset(0, -(1 - value))
            : Offset(0, (1 - value));

        return Transform.translate(
          offset: offset * 100,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

extension ScrollNotificationExtension on ScrollNotification {
  bool get isScrollingDown {
    if (this is ScrollUpdateNotification) {
      final delta = (this as ScrollUpdateNotification).scrollDelta;
      if (delta == null) return false;
      return delta > 0;
    }
    return false;
  }

  bool get isScrollingUp {
    if (this is ScrollUpdateNotification) {
      final delta = (this as ScrollUpdateNotification).scrollDelta;
      if (delta == null) return false;
      return delta < 0;
    }
    return false;
  }

  bool get isAtTop => metrics.pixels <= 0;

  bool get isAtBottom {
    return metrics.pixels >= metrics.maxScrollExtent - 100;
  }
}
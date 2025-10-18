import 'package:flutter/material.dart';

/// A reusable widget that provides a consistent layout and scroll behavior
/// for all main pages in the app.
class PageLayout extends StatelessWidget {
  final List<Widget> slivers;
  final RefreshCallback onRefresh;
  final bool preventBounce;

  const PageLayout({
    super.key,
    required this.slivers,
    required this.onRefresh,
    this.preventBounce = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          // ✅ FIXED: This enforces the "Twitter-style" clamping scroll behavior
          // and definitively prevents the bouncing effect across the entire app.
          physics: const ClampingScrollPhysics(),
          slivers: slivers,
        ),
      ),
    );
  }
}


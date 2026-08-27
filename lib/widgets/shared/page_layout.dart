// lib/widgets/shared/page_layout.dart

import 'package:flutter/material.dart';
import '../../theme/design_system.dart'; // Import for DesignSystem constants

/// A reusable widget that provides a consistent layout and scroll behavior
/// for all main pages in the app.
class PageLayout extends StatelessWidget {
  final List<Widget> slivers;
  final RefreshCallback onRefresh;
  final bool preventBounce;
  final bool addTopPadding;

  const PageLayout({
    super.key,
    required this.slivers,
    required this.onRefresh,
    this.preventBounce = true,
    this.addTopPadding = true, // Default to true for pages with the floating app bar
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double appBarHeight = kToolbarHeight;
    final double refreshDisplacement = statusBarHeight + appBarHeight + 16.0;

    // Build the final list of slivers to render
    final List<Widget> finalSlivers = [];

    // Conditionally add the top spacer for the app bar
    if (addTopPadding) {
      finalSlivers.add(
        SliverToBoxAdapter(
          child: SizedBox(
            // Centralized "breathing room"
            height: statusBarHeight + appBarHeight + DesignSystem.spacing12,
          ),
        ),
      );
    }

    // Add all the slivers provided by the page
    finalSlivers.addAll(slivers);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: RefreshIndicator(
            onRefresh: onRefresh,
            displacement: refreshDisplacement,
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: CustomScrollView(
              physics: preventBounce
                  ? const ClampingScrollPhysics()
                  : const BouncingScrollPhysics(),
              slivers: finalSlivers,
            ),
          ),
        ),
      ),
    );
  }
}

// lib/widgets/home/greeting_header.dart

import 'package:flutter/material.dart';
import '../../utils/home_helpers.dart';
import '../../theme/design_system.dart';

class GreetingHeader extends StatefulWidget {
  const GreetingHeader({super.key});

  @override
  State<GreetingHeader> createState() => _GreetingHeaderState();
}

class _GreetingHeaderState extends State<GreetingHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final greeting = HomeHelpers.getGreeting();
    final subtitle = HomeHelpers.getSubtitle();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting with tranquil Japandi Sumi typography
            Text(
              greeting,
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: DesignSystem.spacing3),

            // Subtitle with delicate organic pill styling
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSystem.spacing8,
                vertical: DesignSystem.spacing3,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceContainerHigh
                    : colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.4 : 0.8),
                  width: 1,
                ),
              ),
              child: Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
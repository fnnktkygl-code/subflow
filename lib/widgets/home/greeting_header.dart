// lib/widgets/home/greeting_header.dart

import 'package:flutter/material.dart';
import '../../utils/home_helpers.dart';
import '../../theme/design_system.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final greeting = HomeHelpers.getGreeting();
    final subtitle = HomeHelpers.getSubtitle();

    return Container(
      margin: EdgeInsets.only(bottom: DesignSystem.spacing8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting line
          Text(
            greeting,
            style: textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              height: 1.1,
            ),
          ),
          SizedBox(height: DesignSystem.spacing4),
          // Subtitle
          Text(
            subtitle,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
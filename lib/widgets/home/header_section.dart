// lib/widgets/home/section_header.dart

import 'package:flutter/material.dart';
import '../../theme/design_system.dart';

/// Consistent section header for secondary sections
class SectionHeader extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.label,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: DesignSystem.iconLarge,
                color: colorScheme.onSurface,
              ),
              SizedBox(width: DesignSystem.spacing4),
            ],
            Text(
              label,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
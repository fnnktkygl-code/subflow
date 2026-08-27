// lib/widgets/home/section_wrapper.dart

import 'package:flutter/material.dart';
import '../../theme/design_system.dart';

/// Universal section wrapper for consistent styling
class SectionWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const SectionWrapper({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: DesignSystem.buildSectionDecoration(context),
      child: Padding(
        padding: padding ?? EdgeInsets.all(DesignSystem.spacing10),
        child: child,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../models/subscription_model.dart';
import '../../utils/home_helpers.dart';
import '../../theme/design_system.dart';

class SubscriptionLogo extends StatelessWidget {
  final Subscription subscription;
  final double size;
  final double borderRadius;

  const SubscriptionLogo({
    super.key,
    required this.subscription,
    this.size = 52,
    this.borderRadius = DesignSystem.radiusMedium,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveUrl = subscription.effectiveLogoUrl;
    final categoryColor = HomeHelpers.getCategoryColor(subscription.category);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: effectiveUrl.isNotEmpty
            ? Image.network(
          effectiveUrl,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildFallbackAvatar(categoryColor, colorScheme),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingPlaceholder(colorScheme);
          },
        )
            : _buildFallbackAvatar(categoryColor, colorScheme),
      ),
    );
  }

  Widget _buildFallbackAvatar(Color categoryColor, ColorScheme colorScheme) {
    final initial = subscription.name.trim().isNotEmpty
        ? subscription.name.trim().substring(0, 1).toUpperCase()
        : '?';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryColor.withValues(alpha: 0.85),
            categoryColor.withValues(alpha: 0.60),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.44,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Center(
        child: SizedBox(
          width: size * 0.35,
          height: size * 0.35,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

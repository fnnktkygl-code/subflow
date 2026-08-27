// lib/widgets/subscription_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/subscription_model.dart'; //
import '../utils/home_helpers.dart'; //
import '../theme/design_system.dart'; //
import '../theme/theme.dart'; //
import 'shared/subscription_logo.dart';

class SubscriptionCard extends StatefulWidget {
  final Subscription subscription; //
  final DateTime displayDate;
  final bool isAmountBlurred;
  final bool isSnoozed;
  final bool isSelectionMode;
  final ValueChanged<bool?>? onSnoozeChanged;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    required this.displayDate,
    required this.isAmountBlurred,
    this.isSnoozed = false,
    this.isSelectionMode = false,
    this.onSnoozeChanged,
  });

  @override
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Widget _buildShimmerEffect() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDark ? Colors.white : const Color(0xFFC4823F)).withValues(alpha: 0.0),
                (isDark ? Colors.white : const Color(0xFFC4823F)).withValues(alpha: isDark ? 0.06 : 0.07),
                (isDark ? Colors.white : const Color(0xFFC4823F)).withValues(alpha: 0.0),
              ],
              stops: [
                (_shimmerController.value - 0.25).clamp(0.0, 1.0),
                _shimmerController.value,
                (_shimmerController.value + 0.25).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool isOutflow = widget.subscription.amount < 0;
    final Color incomeColor = const Color(0xFF477A56); // Japandi Matcha Leaf
    final Color amountColor = isOutflow ? colorScheme.error : incomeColor;

    final categoryColor = HomeHelpers.getCategoryColor(widget.subscription.category);
    final categoryIcon = HomeHelpers.getCategoryIcon(widget.subscription.category);

    final TextDecoration textDecoration =
    widget.isSnoozed ? TextDecoration.lineThrough : TextDecoration.none;

    final daysUntil = widget.displayDate.difference(DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0)).inDays;
    final isUpcoming = daysUntil >= 0 && daysUntil <= 7;
    final isDueToday = daysUntil == 0;

    final semanticLabel =
        '${widget.subscription.name}, ${widget.subscription.amount.abs().toStringAsFixed(2)} € ${widget.subscription.cycle}, category ${widget.subscription.category}';

    return Semantics(
      label: semanticLabel,
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.selectionClick();
          setState(() => _isPressed = true);
        },
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          transform: Matrix4.diagonal3Values(
            _isPressed ? 0.985 : 1.0,
            _isPressed ? 0.985 : 1.0,
            1.0,
          ),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : const Color(0xFF20201E).withValues(alpha: 0.035),
                blurRadius: 12,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
              if (widget.isSelectionMode && widget.isSnoozed)
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
            ],
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.4 : 0.8),
              width: 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
          child: Stack(
            children: [
              // ❌ Removed solid background container, base color is set in BoxDecoration now

              // Accent color stripe
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: DesignSystem.spacing2, //
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        categoryColor,
                        categoryColor.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // Shimmer effect for urgent items
              if (isDueToday && !widget.isSnoozed) _buildShimmerEffect(),

              // Border for selected state (Keep if you like the visual cue)
              if (widget.isSelectionMode && widget.isSnoozed)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(DesignSystem.radiusXL), //
                    border: Border.all(
                      color: colorScheme.primary,
                      width: 2.0, // Reduced thickness slightly
                    ),
                  ),
                ),

              // Content
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: widget.isSnoozed && !widget.isSelectionMode ? 0.6 : 1.0, // Slightly less opaque when snoozed
                child: Padding(
                  padding: EdgeInsets.fromLTRB( // Adjust left padding for stripe
                      DesignSystem.spacing10, //
                      DesignSystem.spacing10, //
                      DesignSystem.spacing10, //
                      DesignSystem.spacing10 //
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo with category badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Hero(
                            tag: 'logo_${widget.subscription.id}_${widget.displayDate}',
                            child: SubscriptionLogo(
                              subscription: widget.subscription,
                              size: 52,
                            ),
                          ),
                          // Category badge
                          Positioned(
                            bottom: -5, // Adjusted position
                            right: -5,
                            child: Container(
                              padding: EdgeInsets.all(DesignSystem.spacing1), // Smaller padding
                              decoration: BoxDecoration(
                                color: categoryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  // Border against card background (surfaceContainerLow)
                                  color: colorScheme.surfaceContainerLow,
                                  width: 1.5, // Thinner border
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: categoryColor.withValues(alpha: 0.2), // Softer shadow
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                categoryIcon,
                                size: 11, // Smaller icon
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: DesignSystem.spacing8), // Reduced spacing

                      // Name, date, and status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.subscription.name, //
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      decoration: textDecoration,
                                      color: colorScheme.onSurface,
                                      letterSpacing: -0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isDueToday && !widget.isSnoozed) ...[
                                  SizedBox(width: DesignSystem.spacing4), //
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: DesignSystem.spacing4, //
                                      vertical: DesignSystem.spacing1, //
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.errorContainer, // Use container color
                                      borderRadius: BorderRadius.circular(DesignSystem.radiusSmall), //
                                    ),
                                    child: Text(
                                      'TODAY',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: colorScheme.onErrorContainer, // Use on container color
                                        fontWeight: FontWeight.bold, // Bolder
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: DesignSystem.spacing2), // Reduced space
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 12, // Smaller icon
                                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6), // Slightly less prominent
                                ),
                                SizedBox(width: DesignSystem.spacing2), //
                                Expanded(
                                  child: Text(
                                    DateFormat('EEE, d MMM').format(widget.displayDate),
                                    style: textTheme.bodySmall?.copyWith(
                                      decoration: textDecoration,
                                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8), // Slightly more prominent date
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500, // Semi-bold date
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isUpcoming && !isDueToday) ...[
                                  SizedBox(width: DesignSystem.spacing2), //
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: DesignSystem.spacing4, //
                                      vertical: DesignSystem.spacing1, //
                                    ),
                                    decoration: BoxDecoration(
                                      color: warningAmber.withValues(alpha: 0.15), // Use warningAmber
                                      borderRadius: BorderRadius.circular(DesignSystem.radiusSmall), //
                                    ),
                                    child: Text(
                                      'in $daysUntil d',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: warningAmber, // Use warningAmber
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: DesignSystem.spacing2), // Reduced space
                            // Subscription cycle badge
                            Container( // Wrap in container for padding
                              padding: EdgeInsets.symmetric(horizontal: DesignSystem.spacing2, vertical: DesignSystem.spacing1/2), //
                              decoration: BoxDecoration(
                                color: categoryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(DesignSystem.radiusSmall / 2), //
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min, // Fit content
                                children: [
                                  Icon(
                                    Icons.sync_rounded,
                                    size: 10, // Smaller icon
                                    color: categoryColor,
                                  ),
                                  SizedBox(width: DesignSystem.spacing1), //
                                  Text(
                                    widget.subscription.cycle.toUpperCase(), // Uppercase cycle
                                    style: textTheme.labelSmall?.copyWith(
                                      color: categoryColor,
                                      fontWeight: FontWeight.bold, // Bolder cycle
                                      fontSize: 9, // Smaller font
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: DesignSystem.spacing6), // Reduced spacing

                      // Amount or Checkbox
                      widget.isSelectionMode
                          ? Transform.scale(
                        scale: 1.1, // Slightly smaller checkbox scale
                        child: Checkbox(
                          visualDensity: VisualDensity.compact, // Make checkbox smaller
                          value: widget.isSnoozed,
                          onChanged: widget.onSnoozeChanged,
                          activeColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DesignSystem.radiusSmall / 2), //
                          ),
                        ),
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.isAmountBlurred
                                ? '•••• €' // Space before euro
                                : '${isOutflow ? '-' : '+'}${widget.subscription.amount.abs().toStringAsFixed(2)} €', // Use abs() and add sign; space before euro
                            style: textTheme.titleMedium?.copyWith( // Use titleMedium
                              color: amountColor,
                              fontWeight: FontWeight.bold, // Bolder amount
                              decoration: textDecoration,
                              letterSpacing: -0.2, // Adjust spacing
                            ),
                          ),
                          // Remove the expense/income badge if desired for cleaner look
                          // if (!widget.isAmountBlurred) ...[
                          //   SizedBox(height: DesignSystem.spacing1),
                          //   Container(
                          //     padding: EdgeInsets.symmetric(
                          //       horizontal: DesignSystem.spacing4,
                          //       vertical: DesignSystem.spacing1 / 2,
                          //     ),
                          //     decoration: BoxDecoration(
                          //       color: amountColor.withValues(alpha: 0.12),
                          //       borderRadius: BorderRadius.circular(DesignSystem.radiusSmall / 2),
                          //     ),
                          //     child: Text(
                          //       isOutflow ? 'EXPENSE' : 'INCOME', // Uppercase
                          //       style: textTheme.labelSmall?.copyWith(
                          //         fontWeight: FontWeight.bold,
                          //         color: amountColor,
                          //         fontSize: 8, // Smaller font
                          //         letterSpacing: 0.5,
                          //       ),
                          //     ),
                          //   ),
                          // ],
                        ],
                      ),
                    ],
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
}

// Helper class for data structure (can be removed if defined elsewhere)
class SubscriptionOccurrence {
  final Subscription subscription; //
  final DateTime date;
  SubscriptionOccurrence(this.subscription, this.date);
}
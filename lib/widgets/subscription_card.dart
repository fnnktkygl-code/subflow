import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subscription_model.dart';


class SubscriptionCard extends StatefulWidget {
  final Subscription subscription;
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

  Color _getCategoryColor(String category) {
    final colors = {
      'Home': Colors.orange.shade400,
      'Utilities': Colors.blue.shade400,
      'Telecom': Colors.purple.shade400,
      'Media & Entertainment': Colors.pink.shade400,
      'Health & Wellness': Colors.green.shade400,
      'Transport': Colors.cyan.shade400,
      'Insurance': Colors.indigo.shade400,
      'Financial': Colors.teal.shade400,
      'Shopping': Colors.amber.shade400,
      'Gaming': Colors.deepPurple.shade400,
      'Software': Colors.lightBlue.shade400,
    };
    return colors[category] ?? Colors.grey.shade400;
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Home': Icons.home_rounded,
      'Utilities': Icons.bolt_rounded,
      'Telecom': Icons.phone_iphone_rounded,
      'Media & Entertainment': Icons.play_circle_outline_rounded,
      'Health & Wellness': Icons.favorite_rounded,
      'Transport': Icons.directions_car_rounded,
      'Insurance': Icons.shield_rounded,
      'Financial': Icons.account_balance_rounded,
      'Shopping': Icons.shopping_bag_rounded,
      'Gaming': Icons.sports_esports_rounded,
      'Software': Icons.code_rounded,
    };
    return icons[category] ?? Icons.category_rounded;
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.0),
              ],
              stops: [
                _shimmerController.value - 0.3,
                _shimmerController.value,
                _shimmerController.value + 0.3,
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

    final bool isOutflow = widget.subscription.amount < 0;
    final Color amountColor = isOutflow
        ? colorScheme.error
        : Colors.green.shade600;

    final categoryColor = _getCategoryColor(widget.subscription.category);
    final categoryIcon = _getCategoryIcon(widget.subscription.category);

    final TextDecoration textDecoration =
    widget.isSnoozed ? TextDecoration.lineThrough : TextDecoration.none;

    final daysUntil = widget.displayDate.difference(DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0)).inDays;
    final isUpcoming = daysUntil >= 0 && daysUntil <= 7;
    final isDueToday = daysUntil == 0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        transform: Matrix4.identity()
          ..scale(_isPressed ? 0.97 : 1.0),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: widget.isSelectionMode && widget.isSnoozed
                  ? colorScheme.primary.withOpacity(0.3)
                  : colorScheme.shadow.withOpacity(0.08),
              blurRadius: _isPressed ? 12 : 24,
              offset: Offset(0, _isPressed ? 2 : 8),
              spreadRadius: widget.isSelectionMode && widget.isSnoozed ? 2 : 0,
            ),
          ],
          borderRadius: BorderRadius.circular(24),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.surfaceContainerHigh,
                      colorScheme.surfaceContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // Accent color stripe
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        categoryColor,
                        categoryColor.withOpacity(0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // Shimmer effect for urgent items
              if (isDueToday && !widget.isSnoozed) _buildShimmerEffect(),

              // Border for selected state
              if (widget.isSelectionMode && widget.isSnoozed)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colorScheme.primary,
                      width: 2.5,
                    ),
                  ),
                ),

              // Content
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: widget.isSnoozed && !widget.isSelectionMode ? 0.5 : 1.0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo with category badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Hero(
                            tag: 'logo_${widget.subscription.id}_${widget.displayDate}',
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: categoryColor.withOpacity(0.3),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  widget.subscription.logoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          categoryColor.withOpacity(0.3),
                                          categoryColor.withOpacity(0.1),
                                        ],
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: colorScheme.onSurface.withOpacity(0.4),
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Category badge
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: categoryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.surface,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: categoryColor.withOpacity(0.4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                categoryIcon,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),

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
                                    widget.subscription.name,
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      decoration: textDecoration,
                                      color: colorScheme.onSurface,
                                      fontSize: 16,
                                      letterSpacing: -0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isDueToday && !widget.isSnoozed) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.red.shade400,
                                          Colors.orange.shade400,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.3),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'TODAY',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 14,
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('EEE, d MMM').format(widget.displayDate),
                                  style: textTheme.bodyMedium?.copyWith(
                                    decoration: textDecoration,
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                                if (isUpcoming && !isDueToday) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'in $daysUntil day${daysUntil == 1 ? '' : 's'}',
                                      style: TextStyle(
                                        color: Colors.orange.shade700,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Subscription cycle badge
                            Row(
                              children: [
                                Icon(
                                  Icons.sync_rounded,
                                  size: 12,
                                  color: categoryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.subscription.cycle,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: categoryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Amount or Checkbox
                      widget.isSelectionMode
                          ? Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: widget.isSnoozed,
                          onChanged: widget.onSnoozeChanged,
                          activeColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.isAmountBlurred
                                ? 'â€¢â€¢â€¢ â‚¬'
                                : '${isOutflow ? '' : '+'}${widget.subscription.amount.toStringAsFixed(2)} \u20AC', // Replaced ' â‚¬' with ' \u20AC'
                            style: textTheme.titleLarge?.copyWith(
                              color: amountColor,
                              fontWeight: FontWeight.bold,
                              decoration: textDecoration,
                              fontSize: 20,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (!widget.isAmountBlurred) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: amountColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isOutflow ? 'expense' : 'income',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: amountColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}

// Helper class for data structure
class SubscriptionOccurrence {
  final Subscription subscription;
  final DateTime date;
  SubscriptionOccurrence(this.subscription, this.date);
}
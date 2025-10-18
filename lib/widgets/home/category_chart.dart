// lib/widgets/home/category_chart.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/home_helpers.dart';
import '../shared/category_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../provider/simplified_subscription_provider.dart';
import '../../theme/design_system.dart';

class CategoryChart extends StatefulWidget {
  final Map<String, double> spending;
  final Map<String, List<Map<String, dynamic>>>? categoryDetails;
  final Function(String)? onCategoryTap;

  const CategoryChart({
    super.key,
    required this.spending,
    this.categoryDetails,
    this.onCategoryTap,
  });

  @override
  State<CategoryChart> createState() => _CategoryChartState();
}

class _CategoryChartState extends State<CategoryChart>
    with SingleTickerProviderStateMixin {
  String? _selectedCategory;
  bool _showDetails = false;
  late AnimationController _expandController;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _selectCategory(String category) {
    HapticFeedback.mediumImpact();

    if (_selectedCategory == category) {
      _expandController.reverse();
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _selectedCategory = null;
            _showDetails = false;
          });
        }
      });
    } else {
      setState(() {
        _selectedCategory = category;
        _showDetails = false;
      });
      _expandController.forward(from: 0);
    }

    if (widget.onCategoryTap != null && _selectedCategory != category) {
      widget.onCategoryTap!(category);
    }
  }

  void _openCategoryBottomSheet(BuildContext context, String category) {
    HapticFeedback.heavyImpact();

    try {
      final provider = context.read<SimplifiedSubscriptionProvider>();
      final allSubscriptions = provider.subscriptions;

      final categorySubscriptions = allSubscriptions
          .where((sub) => sub.category == category)
          .toList();

      if (categorySubscriptions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No subscriptions found in $category'),
            duration: const Duration(milliseconds: 1500),
          ),
        );
        return;
      }

      CategoryBottomSheet.show(
        context,
        category: category,
        subscriptions: categorySubscriptions,
        onEdit: (subscription) {
          provider.updateSubscription(subscription);
          Navigator.pop(context);
        },
        onDelete: (subscription) async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
              ),
              title: const Text('Delete Subscription'),
              content: Text('Delete ${subscription.name}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ) ??
              false;

          if (confirmed) {
            await provider.deleteSubscription(subscription.id);
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
          return confirmed;
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sortedSpending = widget.spending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topSpending = sortedSpending.take(6).toList();
    final total = widget.spending.values.reduce((a, b) => a + b);
    final chartColors = topSpending
        .map((entry) => HomeHelpers.getCategoryColor(entry.key))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedCategory != null) ...[
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              _expandController.reverse();
              Future.delayed(const Duration(milliseconds: 150), () {
                if (mounted) {
                  setState(() {
                    _selectedCategory = null;
                    _showDetails = false;
                  });
                }
              });
            },
            borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignSystem.spacing4,
                vertical: DesignSystem.spacing2,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Reset',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: DesignSystem.spacing2),
                  Icon(
                    Icons.close_rounded,
                    size: DesignSystem.iconXSmall,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: DesignSystem.spacing12),
        ],
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutExpo,
          builder: (context, anim, _) {
            return _buildPieChart(
                context, topSpending, total, chartColors, anim, isDark, colorScheme);
          },
        ),
        SizedBox(height: DesignSystem.spacing12),
        if (_selectedCategory != null)
          AnimatedCrossFade(
            firstChild: _buildCategoryDetails(context),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _showDetails
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
          ),
        if (_selectedCategory != null)
          SizedBox(height: DesignSystem.spacing8),
        _buildLegend(context, sortedSpending, total),
      ],
    );
  }

  Widget _buildPieChart(
      BuildContext context,
      List<MapEntry<String, double>> topSpending,
      double total,
      List<Color> chartColors,
      double anim,
      bool isDark,
      ColorScheme colorScheme,
      ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_selectedCategory != null)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _selectedCategory != null ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(200),
                ),
              ),
            ),
          ),
        SizedBox(
          height: 280,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                enabled: true,
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  if (pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) return;

                  final touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;

                  if (event is FlTapUpEvent) {
                    if (touchedIndex >= 0 && touchedIndex < topSpending.length) {
                      _selectCategory(topSpending[touchedIndex].key);
                    }
                  }
                },
              ),
              startDegreeOffset: -90,
              sectionsSpace: 4,
              centerSpaceRadius: 75,
              borderData: FlBorderData(show: false),
              sections: topSpending.asMap().entries.map((entry) {
                final i = entry.key;
                final data = entry.value;
                final isSelected = _selectedCategory == data.key;
                final isOtherSelected = _selectedCategory != null && !isSelected;

                final color = chartColors[i];
                final expandScale = Tween<double>(begin: 1, end: 1.18)
                    .animate(_expandController);

                return PieChartSectionData(
                  color: isOtherSelected ? color.withOpacity(0.25) : color,
                  value: data.value * anim,
                  radius: isSelected ? 65 + (expandScale.value - 1) * 20 : 65,
                  title: '',
                  borderSide: isSelected
                      ? BorderSide(
                    color: isDark ? colorScheme.surface : Colors.white,
                    width: 4,
                  )
                      : BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.3),
                    width: 0.5,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeInBack,
          child: _selectedCategory != null
              ? _buildSelectedInfo(
            context,
            _selectedCategory!,
            widget.spending[_selectedCategory]!,
            total,
            HomeHelpers.getCategoryColor(_selectedCategory!),
          )
              : _buildCenterTotal(context, total),
        ),
      ],
    );
  }

  Widget _buildCategoryDetails(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categoryColor = HomeHelpers.getCategoryColor(_selectedCategory!);
    final details = widget.categoryDetails?[_selectedCategory] ?? [];

    double categoryTotal = 0;
    if (details.isNotEmpty) {
      categoryTotal = details.fold(0, (sum, item) {
        return sum + (item['amount'] as double? ?? 0);
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerLow
            : colorScheme.surfaceContainerLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        border: Border.all(
          color: categoryColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(DesignSystem.spacing8),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: DesignSystem.spacing4),
                Text(
                  'Transactions',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  '${details.length} items',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withOpacity(0.2),
          ),
          if (details.isEmpty)
            Padding(
              padding: EdgeInsets.all(DesignSystem.spacing12),
              child: Text(
                'No transaction details available',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(vertical: DesignSystem.spacing4),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: details.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    indent: DesignSystem.spacing8,
                    endIndent: DesignSystem.spacing8,
                    color: colorScheme.outlineVariant.withOpacity(0.1),
                  ),
                  itemBuilder: (context, index) {
                    final item = details[index];
                    final name = item['name'] as String? ?? 'Unknown';
                    final amount = item['amount'] as double? ?? 0;
                    final date = item['date'] as String?;
                    final percentage =
                    categoryTotal > 0 ? (amount / categoryTotal * 100) : 0;

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignSystem.spacing8,
                        vertical: DesignSystem.spacing4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (date != null)
                                  Text(
                                    date,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(width: DesignSystem.spacing6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '€${amount.toStringAsFixed(2)}',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(0)}%',
                                style: textTheme.labelSmall?.copyWith(
                                  color: categoryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedInfo(
      BuildContext context,
      String category,
      double amount,
      double total,
      Color color,
      ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasDetails = widget.categoryDetails?[category]?.isNotEmpty ?? false;

    return Container(
      key: ValueKey(category),
      padding: EdgeInsets.symmetric(
        horizontal: DesignSystem.spacing10,
        vertical: DesignSystem.spacing6,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.98),
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: DesignSystem.spacing4),
              Text(
                category,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSystem.spacing4),
          Text(
            '€${amount.toStringAsFixed(2)}',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: DesignSystem.spacing2),
          Text(
            '${((amount / total) * 100).toStringAsFixed(1)}% of total',
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (hasDetails) ...[
            SizedBox(height: DesignSystem.spacing4),
            InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _showDetails = !_showDetails);
              },
              borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSystem.spacing4,
                  vertical: DesignSystem.spacing2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _showDetails ? 'Hide' : 'Show',
                      style: textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: DesignSystem.spacing2),
                    Icon(
                      _showDetails
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: DesignSystem.iconSmall,
                      color: color,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCenterTotal(BuildContext context, double total) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: const ValueKey('total'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Total',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: DesignSystem.spacing2),
        Text(
          '€${total.toStringAsFixed(0)}',
          style: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
        SizedBox(height: DesignSystem.spacing2),
        Text(
          'Tap a slice',
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant.withOpacity(0.65),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(
      BuildContext context,
      List<MapEntry<String, double>> sortedSpending,
      double total,
      ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final legendItems = sortedSpending.take(6);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: DesignSystem.spacing6,
        horizontal: DesignSystem.spacing8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
      ),
      child: Column(
        children: legendItems.map((data) {
          final percentage = (data.value / total * 100);
          final isSelected = _selectedCategory == data.key;
          final color = HomeHelpers.getCategoryColor(data.key);

          return Padding(
            padding: EdgeInsets.only(bottom: DesignSystem.spacing4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _selectCategory(data.key);
                },
                onLongPress: () {
                  _openCategoryBottomSheet(context, data.key);
                },
                borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignSystem.spacing4,
                    vertical: DesignSystem.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius:
                    BorderRadius.circular(DesignSystem.radiusSmall),
                    border: isSelected
                        ? Border.all(
                      color: color.withOpacity(0.3),
                      width: 1,
                    )
                        : null,
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 12 : 10,
                        height: isSelected ? 12 : 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: color.withOpacity(0.35),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                              : [],
                        ),
                      ),
                      SizedBox(width: DesignSystem.spacing6),
                      Expanded(
                        child: Text(
                          data.key,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        '€${data.value.toStringAsFixed(0)}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(width: DesignSystem.spacing4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: DesignSystem.spacing4,
                          vertical: DesignSystem.spacing2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius:
                          BorderRadius.circular(DesignSystem.spacing2),
                        ),
                        child: Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                      SizedBox(width: DesignSystem.spacing4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: DesignSystem.iconXSmall,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
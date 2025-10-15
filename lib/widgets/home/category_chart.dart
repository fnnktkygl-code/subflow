import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/home_helpers.dart';

class CategoryChart extends StatefulWidget {
  final Map<String, double> spending;
  final Function(String)? onCategoryTap;

  const CategoryChart({
    super.key,
    required this.spending,
    this.onCategoryTap,
  });

  @override
  State<CategoryChart> createState() => _CategoryChartState();
}

class _CategoryChartState extends State<CategoryChart> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chartColors = HomeHelpers.generateChartColors(context);
    final total = widget.spending.values.reduce((a, b) => a + b);
    final sortedSpending = widget.spending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('📊', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 10),
                  Text(
                    'spending breakdown',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              if (_selectedCategory != null)
                InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategory = null);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'reset',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutExpo,
            builder: (context, anim, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 240,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          enabled: true,
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            if (pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) return;

                            final touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;

                            if (event is FlTapUpEvent) {
                              if (touchedIndex >= 0 && touchedIndex < sortedSpending.length) {
                                HapticFeedback.mediumImpact();
                                final tappedCategory = sortedSpending[touchedIndex].key;

                                // Open bottom sheet instead of just selecting
                                if (widget.onCategoryTap != null) {
                                  widget.onCategoryTap!(tappedCategory);
                                }

                                setState(() {
                                  _selectedCategory = _selectedCategory == tappedCategory
                                      ? null
                                      : tappedCategory;
                                });
                              }
                            }
                          },
                        ),
                        startDegreeOffset: -90,
                        sectionsSpace: 3,
                        centerSpaceRadius: 75,
                        borderData: FlBorderData(show: false),
                        sections: sortedSpending.take(6).toList().asMap().entries.map((entry) {
                          final i = entry.key;
                          final data = entry.value;
                          final isSelected = _selectedCategory == data.key;
                          final isOtherSelected = _selectedCategory != null && !isSelected;

                          return PieChartSectionData(
                            color: isOtherSelected
                                ? chartColors[i % chartColors.length].withOpacity(0.3)
                                : chartColors[i % chartColors.length],
                            value: data.value * anim,
                            radius: isSelected ? 80 : 65,
                            title: '',
                            borderSide: isSelected
                                ? BorderSide(
                              color: isDark ? colorScheme.surface : Colors.white,
                              width: 4,
                            )
                                : null,
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
                      chartColors[sortedSpending.indexWhere((e) => e.key == _selectedCategory) % chartColors.length],
                    )
                        : _buildCenterTotal(context, total),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          _buildLegend(context, sortedSpending, total, chartColors),
        ],
      ),
    );
  }

  Widget _buildSelectedInfo(BuildContext context, String category, double amount, double total, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: ValueKey(category),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? colorScheme.surface : Colors.white).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            '€${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${((amount / total) * 100).toStringAsFixed(1)}% of total',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterTotal(BuildContext context, double total) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('total'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'total',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '€${total.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: colorScheme.primary,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'tap a slice',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(
      BuildContext context,
      List<MapEntry<String, double>> sortedSpending,
      double total,
      List<Color> chartColors,
      ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surface.withOpacity(0.5)
            : colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: sortedSpending.take(6).toList().asMap().entries.map((entry) {
          final i = entry.key;
          final data = entry.value;
          final percentage = (data.value / total * 100);
          final isSelected = _selectedCategory == data.key;

          return Padding(
            padding: EdgeInsets.only(bottom: i < 5 ? 10 : 0),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedCategory = isSelected ? null : data.key;
                });
                if (widget.onCategoryTap != null && !isSelected) {
                  widget.onCategoryTap!(data.key);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? chartColors[i % chartColors.length].withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 12 : 10,
                      height: isSelected ? 12 : 10,
                      decoration: BoxDecoration(
                        color: chartColors[i % chartColors.length],
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: chartColors[i % chartColors.length].withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                            : [],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        data.key,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      '€${data.value.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: chartColors[i % chartColors.length].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: chartColors[i % chartColors.length],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
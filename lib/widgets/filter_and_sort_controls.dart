import 'package:flutter/material.dart';

// ✅ ADD THIS ENUM DEFINITION HERE
enum SortCriteria { date, name, price }

class FilterAndSortControls extends StatefulWidget {
  final String selectedFilter;
  final SortCriteria sortCriteria;
  final bool sortAscending;
  final String searchQuery;
  final ValueChanged<String?> onFilterChanged;
  final Function(SortCriteria, bool) onSortChanged;
  final ValueChanged<String> onSearchQueryChanged;

  const FilterAndSortControls({
    super.key,
    required this.selectedFilter,
    required this.sortCriteria,
    required this.sortAscending,
    required this.searchQuery,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onSearchQueryChanged,
  });

  @override
  State<FilterAndSortControls> createState() => _FilterAndSortControlsState();
}

class _FilterAndSortControlsState extends State<FilterAndSortControls> {
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _isSearchExpanded = widget.searchQuery.isNotEmpty;
  }

  void _openFilterDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // ✅ Updated with the more granular and practical list of categories.
    final List<String> categories = [
      'All', 'Home', 'Utilities', 'Telecom', 'Media & Entertainment',
      'Health & Wellness', 'Transport', 'Insurance', 'Financial',
      'Shopping', 'Gaming', 'Software', 'General'
    ];
    List<String> tempSelectedCategories = widget.selectedFilter.isEmpty ? ['All'] : widget.selectedFilter.split(', ');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: colorScheme.surface,
              title: Text("Filter by Category", style: TextStyle(color: colorScheme.onSurface)),
              content: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: categories.map((category) {
                  final bool isSelected = tempSelectedCategories.contains(category);
                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setDialogState(() {
                        if (category == 'All') {
                          tempSelectedCategories.clear();
                          if (selected) {
                            tempSelectedCategories.add('All');
                          }
                        } else {
                          tempSelectedCategories.remove('All');
                          if (selected) {
                            tempSelectedCategories.add(category);
                          } else {
                            tempSelectedCategories.remove(category);
                          }
                        }
                        if (tempSelectedCategories.isEmpty) {
                          tempSelectedCategories.add('All');
                        }
                      });
                    },
                    selectedColor: colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final filterValue = tempSelectedCategories.contains('All') ? '' : tempSelectedCategories.join(", ");
                    widget.onFilterChanged(filterValue);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: const Text("Apply"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openSortDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    SortCriteria tempCriteria = widget.sortCriteria;
    bool tempAscending = widget.sortAscending;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sort by", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    children: SortCriteria.values.map((criteria) {
                      return ChoiceChip(
                        label: Text(criteria.name[0].toUpperCase() + criteria.name.substring(1)),
                        selected: tempCriteria == criteria,
                        onSelected: (selected) {
                          if (selected) {
                            setDialogState(() => tempCriteria = criteria);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text("Direction", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text("Ascending"), icon: Icon(Icons.arrow_upward)),
                        ButtonSegment(value: false, label: Text("Descending"), icon: Icon(Icons.arrow_downward)),
                      ],
                      selected: {tempAscending},
                      onSelectionChanged: (newSelection) {
                        setDialogState(() => tempAscending = newSelection.first);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onSortChanged(tempCriteria, tempAscending);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Apply Sort"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleSearchIconTap() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (!_isSearchExpanded) {
        widget.onSearchQueryChanged('');
        _searchController.clear();
      }
    });
  }

  Widget _buildActiveFilterChip(ColorScheme colorScheme) {
    final categories = widget.selectedFilter.split(', ');
    final String label = categories.length == 1 ? categories.first : '${categories.length} Filters';

    return Material(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(30.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(30.0),
        onTap: () => _openFilterDialog(context),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.filter_alt, color: colorScheme.onPrimaryContainer),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInactiveFilterButton(ColorScheme colorScheme) {
    return Material(
      color: colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(30.0),
      child: IconButton(
        icon: Icon(Icons.filter_list, color: colorScheme.onSurfaceVariant),
        onPressed: () => _openFilterDialog(context),
      ),
    );
  }

  Widget _buildActiveSortChip(ColorScheme colorScheme) {
    final String label = widget.sortCriteria.name[0].toUpperCase() + widget.sortCriteria.name.substring(1);
    final IconData icon = widget.sortAscending ? Icons.arrow_upward : Icons.arrow_downward;

    return Material(
      color: colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(30.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(30.0),
        onTap: () => _openSortDialog(context),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: colorScheme.onSecondaryContainer, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInactiveSortButton(ColorScheme colorScheme) {
    return Material(
      color: colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(30.0),
      child: IconButton(
        icon: Icon(Icons.swap_vert, color: colorScheme.onSurfaceVariant),
        onPressed: () => _openSortDialog(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isFilterActive = widget.selectedFilter.isNotEmpty;
    final bool isSortActive = widget.sortCriteria != SortCriteria.date || !widget.sortAscending;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? colorScheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.4 : 0.8),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : const Color(0xFF20201E).withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(_isSearchExpanded ? Icons.close : Icons.search, color: colorScheme.onSurfaceVariant),
                    onPressed: _handleSearchIconTap,
                  ),
                  if (_isSearchExpanded)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: widget.onSearchQueryChanged,
                          decoration: const InputDecoration(
                            hintText: 'Search...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SizeTransition(sizeFactor: animation, axis: Axis.horizontal, child: child)),
            child: isFilterActive
                ? KeyedSubtree(key: const ValueKey('active_filter'), child: _buildActiveFilterChip(colorScheme))
                : KeyedSubtree(key: const ValueKey('inactive_filter'), child: _buildInactiveFilterButton(colorScheme)),
          ),

          const SizedBox(width: 8),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child: isSortActive
                ? KeyedSubtree(key: const ValueKey('active_sort'), child: _buildActiveSortChip(colorScheme))
                : KeyedSubtree(key: const ValueKey('inactive_sort'), child: _buildInactiveSortButton(colorScheme)),
          ),
        ],
      ),
    );
  }
}

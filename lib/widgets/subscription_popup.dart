// lib/widgets/subscription_popup.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/subscription_model.dart';
import '../provider/user_profile_provider.dart';
import '../services/preset_catalog_service.dart';
import '../utils/logo_utils.dart';
import '../utils/home_helpers.dart';
import 'shared/japandi_svg_icons.dart';

/// Shows a frictionless, single-screen zero-scroll dialog to add or edit a subscription.
void showAddSubscriptionPopup(
    BuildContext context,
    void Function(Subscription) onAddSubscription, {
      Subscription? subscriptionToEdit,
      DateTime? defaultStartDate,
    }) {
  HapticFeedback.lightImpact();
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (BuildContext context) {
      return _AddSubscriptionDialog(
        onAddSubscription: onAddSubscription,
        subscriptionToEdit: subscriptionToEdit,
        defaultStartDate: defaultStartDate,
      );
    },
  );
}

class _AddSubscriptionDialog extends StatefulWidget {
  final void Function(Subscription) onAddSubscription;
  final Subscription? subscriptionToEdit;
  final DateTime? defaultStartDate;

  const _AddSubscriptionDialog({
    required this.onAddSubscription,
    this.subscriptionToEdit,
    this.defaultStartDate,
  });

  @override
  _AddSubscriptionDialogState createState() => _AddSubscriptionDialogState();
}

class _AddSubscriptionDialogState extends State<_AddSubscriptionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late DateTime _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _logoUrl;
  String _selectedCycle = 'Monthly';
  String _selectedCategory = 'Entertainment';
  bool _isRevenue = false;
  Timer? _debounce;

  static const List<String> _categories = [
    'Entertainment',
    'General',
    'Utilities',
    'Health & Fitness',
    'Food & Dining',
    'Shopping',
    'Income',
  ];

  @override
  void initState() {
    super.initState();
    final sub = widget.subscriptionToEdit;
    _nameController = TextEditingController(text: sub?.name ?? '');
    _amountController = TextEditingController(
      text: sub != null ? sub.amount.abs().toStringAsFixed(2) : '',
    );
    _selectedStartDate = sub?.startDate ?? widget.defaultStartDate ?? DateTime.now();
    _selectedEndDate = sub?.endDate;
    _logoUrl = sub?.logoUrl;
    _selectedCycle = sub?.cycle ?? 'Monthly';
    _selectedCategory = sub?.category ?? 'Entertainment';
    _isRevenue = (sub?.amount ?? -1) > 0;

    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _amountController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onNameChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final name = _nameController.text.trim();
      if (name.isNotEmpty && mounted) {
        setState(() {
          _logoUrl = fetchLogo(name);
        });
      }
    });
  }

  void _applyPreset(SubscriptionPreset preset) {
    HapticFeedback.selectionClick();
    setState(() {
      _nameController.text = preset.name;
      _amountController.text = preset.amount.toStringAsFixed(2);
      _selectedCategory = preset.category;
      _selectedCycle = preset.cycle;
      _logoUrl = fetchLogo(preset.name);
    });
  }

  Future<void> _pickDate() async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedStartDate = picked);
    }
  }



  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.mediumImpact();
      final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;
      final finalAmount = _isRevenue ? amount.abs() : -amount.abs();
      final name = _nameController.text.trim();
      final effectiveLogo = _logoUrl?.isNotEmpty == true ? _logoUrl! : fetchLogo(name);

      widget.onAddSubscription(
        Subscription(
          id: widget.subscriptionToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          amount: finalAmount,
          startDate: _selectedStartDate,
          cycle: _selectedCycle,
          logoUrl: effectiveLogo,
          endDate: _selectedEndDate,
          category: _selectedCategory,
          areNotificationsEnabled: true,
          reminderDays: 2,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.subscriptionToEdit != null;
    final userProfile = context.watch<UserProfileProvider>();
    final quickPresets = PresetCatalogService.getPresetsForCountry(userProfile.effectiveCountryCode);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.4 : 0.8),
          width: 1.0,
        ),
      ),
      backgroundColor: isDark ? colorScheme.surface : Colors.white,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                // 1. Header with Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Subscription' : 'New Subscription',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: JapandiSvgIcon(
                        type: JapandiSvgType.close,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 2. 1-Tap Quick Presets (Only when adding new)
                if (!isEditing) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: quickPresets.map((preset) {
                        final isSelected = _nameController.text.toLowerCase() == preset.name.toLowerCase();
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            key: Key('preset_${preset.name}'),
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => _applyPreset(preset),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primary
                                    : (isDark ? colorScheme.surfaceContainerHigh : colorScheme.surfaceContainer),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.6),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    preset.name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    preset.formattedPrice,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      color: isSelected
                                          ? colorScheme.onPrimary.withValues(alpha: 0.85)
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // 3. Name Field with Live Logo Preview
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Subscription Name',
                    hintText: 'e.g. Netflix, Spotify',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(10),
                      child: _logoUrl != null && _logoUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                _logoUrl!,
                                width: 22,
                                height: 22,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => JapandiSvgIcon(
                                  type: JapandiSvgType.subscriptions,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                              ),
                            )
                          : JapandiSvgIcon(
                              type: JapandiSvgType.subscriptions,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 10),

                // 4. Amount & Billing Cycle Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount Field
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          prefixText: '€ ',
                          hintText: '0.00',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter amount';
                          final num = double.tryParse(val.replaceAll(',', '.'));
                          if (num == null || num <= 0) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Segmented Billing Cycle Selector
                    Expanded(
                      flex: 6,
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: ['Monthly', 'Yearly', 'Weekly'].map((cycle) {
                            final isSelected = _selectedCycle == cycle;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedCycle = cycle);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected ? colorScheme.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    cycle == 'Monthly' ? 'Mo' : cycle == 'Yearly' ? 'Yr' : 'Wk',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 5. Date Picker Pill & Category Picker Row
                Row(
                  children: [
                    // Start Date Button
                    Expanded(
                      flex: 5,
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            children: [
                              JapandiSvgIcon(
                                type: JapandiSvgType.calendar,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  DateFormat('dd MMM yyyy').format(_selectedStartDate),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Category Picker Tile with Bespoke Japandi Popup Menu
                    Expanded(
                      flex: 6,
                      child: PopupMenuButton<String>(
                        key: const Key('category_picker_tile'),
                        tooltip: 'Select Category',
                        initialValue: _selectedCategory,
                        offset: const Offset(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.6),
                            width: 1,
                          ),
                        ),
                        color: isDark ? colorScheme.surface : Colors.white,
                        elevation: 6,
                        onSelected: (cat) {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCategory = cat);
                        },
                        itemBuilder: (ctx) => _categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          final catColor = HomeHelpers.getCategoryColor(cat);
                          final catIcon = HomeHelpers.getCategoryIcon(cat);

                          return PopupMenuItem<String>(
                            key: Key('cat_option_$cat'),
                            value: cat,
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: catColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Icon(catIcon, size: 14, color: catColor),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_rounded, size: 16, color: colorScheme.primary),
                              ],
                            ),
                          );
                        }).toList(),
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: HomeHelpers.getCategoryColor(_selectedCategory).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  HomeHelpers.getCategoryIcon(_selectedCategory),
                                  size: 13,
                                  color: HomeHelpers.getCategoryColor(_selectedCategory),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _selectedCategory,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 6. 1-Tap Save Button
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isEditing ? 'Save Changes' : 'Save Subscription',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}

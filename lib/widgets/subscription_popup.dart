// lib/widgets/subscription_popup.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/subscription_model.dart';
import '../utils/logo_utils.dart';
import '../utils/home_helpers.dart';
import '../theme/design_system.dart';

/// Shows a modern, multi-step dialog to add or edit a subscription.
void showAddSubscriptionPopup(
    BuildContext context,
    void Function(Subscription) onAddSubscription, {
      Subscription? subscriptionToEdit,
      DateTime? defaultStartDate,
    }) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (BuildContext context) {
      return _AddSubscriptionDialog(
        onAddSubscription: onAddSubscription,
        subscriptionToEdit: subscriptionToEdit,
        defaultStartDate: defaultStartDate,
      );
    },
  );
}

// --- The Dialog Widget ---
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
  final List<GlobalKey<FormState>> _formKeys =
  List.generate(3, (_) => GlobalKey<FormState>());
  int _currentStep = 0;
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _logoUrl;
  String _selectedCycle = 'Monthly';
  String _selectedCategory = 'General';
  late Set<String> _revenueExpenseSelection;
  File? _customImageFile;
  Timer? _debounce;
  bool _areNotificationsEnabled = true;
  int _reminderDays = 2;

  @override
  void initState() {
    super.initState();
    final sub = widget.subscriptionToEdit;
    _nameController = TextEditingController(text: sub?.name ?? '');
    _amountController = TextEditingController(
      text: sub != null ? sub.amount.abs().toStringAsFixed(2) : '',
    );
    _selectedStartDate =
        sub?.startDate ?? widget.defaultStartDate ?? DateTime.now();
    _selectedEndDate = sub?.endDate;
    _logoUrl = sub?.logoUrl;
    _selectedCycle = sub?.cycle ?? 'Monthly';
    _selectedCategory = sub?.category ?? 'General';
    bool isRevenue = (sub?.amount ?? 0) > 0;
    _revenueExpenseSelection = {isRevenue ? 'Revenue' : 'Expense'};
    _areNotificationsEnabled = sub?.areNotificationsEnabled ?? true;
    _reminderDays = sub?.reminderDays ?? 2;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _goToNextStep() {
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      if (_currentStep < 2) {
        setState(() => _currentStep++);
      } else {
        final isRevenue = _revenueExpenseSelection.first == 'Revenue';
        final amount = double.tryParse(_amountController.text) ?? 0.0;

        widget.onAddSubscription(
          Subscription(
            id: widget.subscriptionToEdit?.id ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            name: _nameController.text.trim(),
            amount: amount * (isRevenue ? 1 : -1),
            startDate: _selectedStartDate!,
            cycle: _selectedCycle,
            logoUrl: _customImageFile?.path ?? _logoUrl ?? '',
            endDate: _selectedEndDate,
            category: _selectedCategory,
            areNotificationsEnabled: _areNotificationsEnabled,
            reminderDays: _reminderDays,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusXXL),
      ),
      backgroundColor: colorScheme.surfaceContainerLow,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.spacing12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStepIndicator(),
                const SizedBox(height: DesignSystem.spacing16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Container(
                    key: ValueKey<int>(_currentStep),
                    child: [
                      _buildStep1(context),
                      _buildStep2(context),
                      _buildStep3(context),
                    ][_currentStep],
                  ),
                ),
                const SizedBox(height: DesignSystem.spacing16),
                _buildNavigationButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacing10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacing4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive || isCompleted
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    boxShadow: isActive
                        ? [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(
                        color: isActive || isCompleted
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {IconData? icon}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(
        top: DesignSystem.spacing12,
        bottom: DesignSystem.spacing10,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(DesignSystem.spacing6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
              ),
              child: Icon(
                icon,
                size: DesignSystem.iconMedium,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: DesignSystem.spacing8),
          ],
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: _currentStep == 0
          ? MainAxisAlignment.end
          : MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0)
          TextButton(
            onPressed: _goToPreviousStep,
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSystem.spacing12,
                vertical: DesignSystem.spacing8,
              ),
            ),
            child: const Text("Previous"),
          ),
        FilledButton(
          onPressed: _goToNextStep,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.spacing16,
              vertical: DesignSystem.spacing10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            ),
          ),
          child: Text(
            _currentStep < 2 ? "Next" : "Save Subscription",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSectionHeader(
            "Subscription Details",
            icon: Icons.subscriptions_rounded,
          ),
          const SizedBox(height: DesignSystem.spacing10),
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 1.5,
                    ),
                  ),
                  child: _customImageFile != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                    child: Image.file(
                      _customImageFile!,
                      fit: BoxFit.cover,
                    ),
                  )
                      : _logoUrl != null && _logoUrl!.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                    child: Image.network(
                      _logoUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.subscriptions_outlined,
                        size: 40,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                      : Icon(
                    Icons.subscriptions_outlined,
                    size: 40,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Positioned(
                  bottom: -8,
                  right: -8,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final pickedFile = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          _customImageFile = File(pickedFile.path);
                          _logoUrl = '';
                        });
                      }
                    },
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(DesignSystem.spacing6),
                      backgroundColor: colorScheme.primary,
                    ),
                    icon: const Icon(
                      Icons.edit,
                      size: DesignSystem.iconSmall,
                    ),
                    label: const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignSystem.spacing16),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Subscription Name",
              prefixIcon: const Icon(
                Icons.label_rounded,
                size: DesignSystem.iconMedium,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              ),
            ),
            validator: (v) =>
            v == null || v.trim().isEmpty ? "Please enter a name" : null,
            onChanged: (value) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                if (value.isNotEmpty && _customImageFile == null) {
                  setState(() => _logoUrl = fetchLogo(value.trim()));
                }
              });
            },
          ),
          const SizedBox(height: DesignSystem.spacing12),
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: "Amount",
              suffixText: "€",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) => v == null || double.tryParse(v) == null
                ? "Enter a valid amount"
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSectionHeader(
            "Transaction Type",
            icon: Icons.account_balance_rounded,
          ),
          const SizedBox(height: DesignSystem.spacing10),
          Container(
            padding: const EdgeInsets.all(DesignSystem.spacing8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
            ),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'Expense',
                    label: Text('Expense'),
                    icon: Icon(Icons.remove_rounded),
                  ),
                  ButtonSegment(
                    value: 'Revenue',
                    label: Text('Revenue'),
                    icon: Icon(Icons.add_rounded),
                  ),
                ],
                selected: _revenueExpenseSelection,
                onSelectionChanged: (newSelection) {
                  setState(() => _revenueExpenseSelection = newSelection);
                },
              ),
            ),
          ),
          _buildSectionHeader(
            "Category",
            icon: Icons.category_rounded,
          ),
          const SizedBox(height: DesignSystem.spacing10),
          Wrap(
            spacing: DesignSystem.spacing6,
            runSpacing: DesignSystem.spacing6,
            children: [
              for (String category in HomeHelpers.getCategoryMap().keys)
                ChoiceChip(
                  label: Text(category),
                  avatar: Icon(
                    HomeHelpers.getCategoryIcon(category),
                    size: 16,
                    color: _selectedCategory == category
                        ? Colors.white
                        : HomeHelpers.getCategoryColor(category),
                  ),
                  selected: _selectedCategory == category,
                  onSelected: (selected) =>
                      setState(() => _selectedCategory = category),
                  selectedColor: HomeHelpers.getCategoryColor(category),
                  labelStyle: TextStyle(
                    color: _selectedCategory == category
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: _selectedCategory == category
                          ? Colors.transparent
                          : colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  backgroundColor: colorScheme.surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSystem.spacing8,
                    vertical: DesignSystem.spacing6,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSectionHeader(
            "Billing & Reminders",
            icon: Icons.schedule_rounded,
          ),
          const SizedBox(height: DesignSystem.spacing10),
          GestureDetector(
            onTap: () => _showAgendaPopup(_selectedStartDate, (date) {
              setState(() => _selectedStartDate = date);
            }),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: "Start Date",
                prefixIcon: const Icon(
                  Icons.calendar_today_outlined,
                  size: DesignSystem.iconMedium,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                ),
              ),
              child: Text(
                DateFormat('d MMMM yyyy').format(_selectedStartDate!),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spacing12),
          GestureDetector(
            onTap: () => _showAgendaPopup(_selectedEndDate ?? _selectedStartDate, (date) {
              setState(() => _selectedEndDate = date);
            }),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: "End Date (Optional)",
                prefixIcon: const Icon(
                  Icons.event_busy_outlined,
                  size: DesignSystem.iconMedium,
                ),
                suffixIcon: _selectedEndDate != null
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _selectedEndDate = null;
                    });
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                ),
              ),
              child: Text(
                _selectedEndDate != null
                    ? DateFormat('d MMMM yyyy').format(_selectedEndDate!)
                    : "Ongoing",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: _selectedEndDate == null
                      ? colorScheme.onSurfaceVariant.withOpacity(0.7)
                      : colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spacing12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Billing Cycle",
              prefixIcon: const Icon(
                Icons.repeat_rounded,
                size: DesignSystem.iconMedium,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              ),
            ),
            value: _selectedCycle,
            items: ['Weekly', 'Monthly', 'Yearly']
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCycle = v!),
          ),
          const SizedBox(height: DesignSystem.spacing12),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
            ),
            child: SwitchListTile(
              title: Text(
                "Enable Reminders",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              value: _areNotificationsEnabled,
              onChanged: (bool value) {
                setState(() => _areNotificationsEnabled = value);
              },
              secondary: Icon(
                _areNotificationsEnabled
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_outlined,
                color: colorScheme.primary,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: DesignSystem.spacing12,
                vertical: DesignSystem.spacing4,
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spacing10),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _areNotificationsEnabled
                ? DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: "Remind me before",
                prefixIcon: const Icon(
                  Icons.alarm_rounded,
                  size: DesignSystem.iconMedium,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(DesignSystem.radiusMedium),
                ),
              ),
              value: _reminderDays,
              items: [1, 2, 3, 7]
                  .map((days) => DropdownMenuItem(
                value: days,
                child: Text(
                  days == 1
                      ? "1 day"
                      : days == 7
                      ? "1 week"
                      : "$days days",
                ),
              ))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _reminderDays = value!),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _showAgendaPopup(DateTime? initialDate, Function(DateTime) onDateSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime focusedDay = initialDate ?? DateTime.now();
        DateTime? selectedDay = initialDate;
        final colorScheme = Theme.of(context).colorScheme;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusXXL),
              ),
              backgroundColor: colorScheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spacing12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(DesignSystem.spacing8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
                      ),
                      child: Text(
                        'Select Date',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spacing12),
                    TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: focusedDay,
                      currentDay: DateTime.now(),
                      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                      onDaySelected: (newSelectedDay, newFocusedDay) {
                        onDateSelected(newSelectedDay);
                        Navigator.of(context).pop();
                      },
                      calendarFormat: CalendarFormat.month,
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle:
                        Theme.of(context).textTheme.titleMedium!,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        selectedDecoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        todayTextStyle:
                        TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                        selectedTextStyle: TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        weekendTextStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spacing10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

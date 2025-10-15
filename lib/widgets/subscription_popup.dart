// lib/widgets/subscription_popup.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/subscription_model.dart';
import '../utils/logo_utils.dart';

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
  final List<GlobalKey<FormState>> _formKeys = List.generate(3, (_) => GlobalKey<FormState>());
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
      text: sub != null ? sub.amount.abs().toString() : '',
    );
    _selectedStartDate = sub?.startDate ?? widget.defaultStartDate ?? DateTime.now();
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
        widget.onAddSubscription(
          Subscription(
            id: widget.subscriptionToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
            name: _nameController.text,
            amount: double.parse(_amountController.text) * (isRevenue ? 1 : -1),
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

  void _showAgendaPopup(DateTime? initialDate, Function(DateTime) onDateSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime focusedDay = initialDate ?? DateTime.now();
        DateTime? selectedDay = initialDate;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  // ✅ FIXED: Replaced helper with direct theme access
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Select Date',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 16),
                        TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: focusedDay,
                          currentDay: DateTime.now(),
                          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                          onDaySelected: (newSelectedDay, newFocusedDay) {
                            onDateSelected(newSelectedDay);
                            Navigator.of(context).pop(); // Close after selecting
                          },
                          calendarFormat: CalendarFormat.month,
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                          ),
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          // ✅ FIXED: Replaced helper with direct theme access
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStepIndicator(),
                    const SizedBox(height: 24),
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
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: _currentStep == 0 ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentStep > 0)
                          TextButton(onPressed: _goToPreviousStep, child: const Text("Previous")),
                        ElevatedButton(
                          onPressed: _goToNextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: Text(_currentStep < 2 ? "Next" : "Save"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8,
          width: index == _currentStep ? 24 : 8,
          decoration: BoxDecoration(
            color: index == _currentStep ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
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
          _buildSectionHeader("Logo & Name"),
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              child: _customImageFile != null
                  ? ClipOval(child: Image.file(_customImageFile!, fit: BoxFit.cover, width: 80, height: 80))
                  : _logoUrl != null && _logoUrl!.isNotEmpty
                  ? ClipOval(
                child: Image.network(
                  _logoUrl!,
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                  errorBuilder: (_, __, ___) => Icon(Icons.subscriptions, size: 40, color: colorScheme.primary),
                ),
              )
                  : Icon(Icons.subscriptions, size: 40, color: colorScheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.upload_file_outlined, size: 18),
              label: const Text("Upload Image"),
              onPressed: () async {
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _customImageFile = File(pickedFile.path);
                    _logoUrl = '';
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Subscription Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            validator: (v) => v == null || v.isEmpty ? "Please enter a name" : null,
            onChanged: (value) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                if (value.isNotEmpty) {
                  setState(() {
                    _logoUrl = fetchLogo(value.trim());
                    _customImageFile = null;
                  });
                }
              });
            },
          ),
          const SizedBox(height: 16),
          _buildSectionHeader("Amount"),
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(labelText: "Amount", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixText: "\$ "),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) => v == null || double.tryParse(v) == null ? "Please enter a valid amount" : null,
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
          _buildSectionHeader("Type"),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Revenue', label: Text('Revenue'), icon: Icon(Icons.add)),
                ButtonSegment(value: 'Expense', label: Text('Expense'), icon: Icon(Icons.remove)),
              ],
              selected: _revenueExpenseSelection,
              onSelectionChanged: (newSelection) {
                setState(() => _revenueExpenseSelection = newSelection);
              },
            ),
          ),
          _buildSectionHeader("Category"),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (String category in [
                'Home', 'Utilities', 'Telecom', 'Media & Entertainment',
                'Health & Wellness', 'Transport', 'Insurance', 'Financial',
                'Shopping', 'Gaming', 'Software', 'General'
              ])
                ChoiceChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) => setState(() => _selectedCategory = category),
                  selectedColor: colorScheme.primary,
                  labelStyle: TextStyle(
                    color: _selectedCategory == category ? colorScheme.onPrimary : colorScheme.onSurface,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(BuildContext context) {
    final labelTextStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface);
    return Form(
      key: _formKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSectionHeader("Billing Information"),
          GestureDetector(
            onTap: () => _showAgendaPopup(_selectedStartDate, (date) {
              setState(() => _selectedStartDate = date);
            }),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: "Start Date",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              child: Text(DateFormat('d MMMM yyyy').format(_selectedStartDate!), style: labelTextStyle),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showAgendaPopup(_selectedEndDate, (date) {
              setState(() => _selectedEndDate = date);
            }),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: "End Date (optional)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              child: Text(_selectedEndDate != null ? DateFormat('d MMMM yyyy').format(_selectedEndDate!) : 'Not set', style: labelTextStyle),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: "Billing Cycle", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            value: _selectedCycle,
            items: ['Weekly', 'Monthly', 'Yearly']
                .map((v) => DropdownMenuItem(value: v, child: Text(v, style: labelTextStyle)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCycle = v!),
            dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(height: 16),
          _buildSectionHeader("Reminders"),
          SwitchListTile(
            title: Text("Enable Reminders", style: labelTextStyle),
            value: _areNotificationsEnabled,
            onChanged: (bool value) {
              setState(() => _areNotificationsEnabled = value);
            },
            secondary: Icon(
              _areNotificationsEnabled ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _areNotificationsEnabled
                ? DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: "Remind me before", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              value: _reminderDays,
              items: [1, 2, 3, 7]
                  .map((days) => DropdownMenuItem(
                value: days,
                child: Text(days == 7 ? "1 week" : "$days day(s)", style: labelTextStyle),
              ))
                  .toList(),
              onChanged: (value) => setState(() => _reminderDays = value!),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
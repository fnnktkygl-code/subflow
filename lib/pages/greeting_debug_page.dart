// lib/pages/greeting_debug_page.dart

import 'package:flutter/material.dart';
import '../utils/home_helpers.dart';
import '../theme/design_system.dart';

class GreetingDebugPage extends StatefulWidget {
  const GreetingDebugPage({super.key});

  @override
  State<GreetingDebugPage> createState() => _GreetingDebugPageState();
}

class _GreetingDebugPageState extends State<GreetingDebugPage> {
  int _selectedHour = DateTime.now().hour;
  int _selectedDay = DateTime.now().weekday; // 1-7 (Mon-Sun)
  double? _spendingRatio;
  int? _daysUntilPayment;
  bool? _isOverBudget;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Generate greeting based on current settings
    final greeting = _getGreetingForSettings();
    final subtitle = _getSubtitleForSettings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Greeting Debug'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignSystem.spacing8),
        children: [
          // Preview Card
          Container(
            padding: const EdgeInsets.all(DesignSystem.spacing12),
            decoration: DesignSystem.buildSectionDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      color: colorScheme.primary,
                      size: DesignSystem.iconMedium,
                    ),
                    const SizedBox(width: DesignSystem.spacing4),
                    Text(
                      'Preview',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignSystem.spacing12),
                // Greeting
                Text(
                  greeting,
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: DesignSystem.spacing4),
                // Subtitle
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSystem.spacing8,
                    vertical: DesignSystem.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
                  ),
                  child: Text(
                    subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignSystem.spacing12),

          // Time Settings
          _buildSection(
            context,
            'Time Settings',
            Icons.schedule_rounded,
            [
              _buildSliderTile(
                context,
                'Hour of Day',
                _selectedHour.toDouble(),
                0,
                23,
                    (value) => setState(() => _selectedHour = value.toInt()),
                suffix: ':00',
              ),
              _buildDaySelector(context),
            ],
          ),
          const SizedBox(height: DesignSystem.spacing12),

          // Context Settings
          _buildSection(
            context,
            'Context Settings',
            Icons.tune_rounded,
            [
              _buildSliderTile(
                context,
                'Spending Ratio',
                _spendingRatio ?? -1,
                -1,
                1.5,
                    (value) => setState(() => _spendingRatio = value < 0 ? null : value),
                suffix: _spendingRatio != null ? '${(_spendingRatio! * 100).toInt()}%' : 'None',
              ),
              _buildSliderTile(
                context,
                'Days Until Payment',
                _daysUntilPayment?.toDouble() ?? -1,
                -1,
                7,
                    (value) => setState(() => _daysUntilPayment = value < 0 ? null : value.toInt()),
                suffix: _daysUntilPayment != null ? '$_daysUntilPayment days' : 'None',
              ),
              ListTile(
                title: const Text('Over Budget'),
                subtitle: Text(_isOverBudget == null ? 'Not set' : (_isOverBudget! ? 'Yes' : 'No')),
                trailing: SegmentedButton<bool?>(
                  segments: const [
                    ButtonSegment(value: null, label: Text('None')),
                    ButtonSegment(value: false, label: Text('No')),
                    ButtonSegment(value: true, label: Text('Yes')),
                  ],
                  selected: {_isOverBudget},
                  onSelectionChanged: (Set<bool?> newSelection) {
                    setState(() => _isOverBudget = newSelection.first);
                  },
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacing12),

          // Quick Actions
          _buildSection(
            context,
            'Quick Actions',
            Icons.flash_on_rounded,
            [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedHour = DateTime.now().hour;
                    _selectedDay = DateTime.now().weekday;
                    _spendingRatio = null;
                    _daysUntilPayment = null;
                    _isOverBudget = null;
                  });
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reset to Current Time'),
              ),
              const SizedBox(height: DesignSystem.spacing4),
              OutlinedButton.icon(
                onPressed: () => _showAllVariations(context),
                icon: const Icon(Icons.list_alt_rounded),
                label: const Text('Show All Possible Greetings'),
              ),
            ],
          ),
          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacing12),
      decoration: DesignSystem.buildSectionDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: DesignSystem.iconMedium),
              const SizedBox(width: DesignSystem.spacing4),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacing8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSliderTile(
      BuildContext context,
      String label,
      double value,
      double min,
      double max,
      ValueChanged<double> onChanged, {
        String suffix = '',
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(suffix, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDaySelector(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: DesignSystem.spacing4,
      runSpacing: DesignSystem.spacing4,
      children: List.generate(7, (index) {
        final dayIndex = index + 1;
        final isSelected = _selectedDay == dayIndex;
        return ChoiceChip(
          label: Text(days[index]),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) setState(() => _selectedDay = dayIndex);
          },
          selectedColor: colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }),
    );
  }

  String _getGreetingForSettings() {
    // Temporarily override DateTime for testing
    final testDate = DateTime(2025, 1, 1 + _selectedDay - 1, _selectedHour);
    final dayOfWeek = testDate.weekday;
    final hour = testDate.hour;

    // Weekend logic
    if (dayOfWeek >= 6) {
      final isSaturday = dayOfWeek == 6;
      if (hour >= 5 && hour < 12) return "weekend mode 🌅";
      if (hour >= 12 && hour < 17) {
        return isSaturday ? "chill saturday vibes ✨" : "sunday funday ✨";
      }
      if (hour >= 17 && hour < 22) return "weekend nights 🌙";
      return "late night thoughts 💭";
    }

    // Weekday logic
    if (hour >= 5 && hour < 12) return "rise & grind 🔥";
    if (hour >= 12 && hour < 17) return "main character energy ✨";
    if (hour >= 17 && hour < 22) return "vibe check 🌙";
    return "night owl 🦉";
  }

  String _getSubtitleForSettings() {
    return HomeHelpers.getSubtitle(
      spendingRatio: _spendingRatio,
      daysUntilNextPayment: _daysUntilPayment,
      isOverBudget: _isOverBudget,
    );
  }

  void _showAllVariations(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final variations = <String, List<String>>{
      'Morning (Weekday)': ['rise & grind 🔥', 'morning energy ☀️', 'fresh start 🌱'],
      'Afternoon (Weekday)': ['main character energy ✨', 'afternoon hustle 💪', 'halfway there 🎯'],
      'Evening (Weekday)': ['vibe check 🌙', 'evening wind-down 🌆', 'reflect & relax 🧘'],
      'Night (Weekday)': ['night owl 🦉'],
      'Morning (Weekend)': ['weekend mode 🌅'],
      'Afternoon (Saturday)': ['chill saturday vibes ✨'],
      'Afternoon (Sunday)': ['sunday funday ✨'],
      'Evening (Weekend)': ['weekend nights 🌙'],
      'Night (Weekend)': ['late night thoughts 💭'],
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignSystem.radiusXXL)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(DesignSystem.spacing12),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: DesignSystem.spacing12),
            Text(
              'All Greeting Variations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: DesignSystem.spacing8),
            ...variations.entries.map((entry) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: DesignSystem.spacing8),
                Text(
                  entry.key,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: DesignSystem.spacing4),
                ...entry.value.map((greeting) => Padding(
                  padding: const EdgeInsets.only(left: DesignSystem.spacing8, top: DesignSystem.spacing2),
                  child: Text('• $greeting'),
                )),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
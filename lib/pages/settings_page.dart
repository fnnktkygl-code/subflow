import 'package:flutter/material.dart';

import '../main.dart'; // Make sure this path is correct

class Settings extends StatelessWidget {
  // ✅ REFACTORED: Removed the obsolete accent color parameters.
  const Settings({super.key, required ValueChanged<Color> onChangeAccentColor, required VoidCallback onResetAccentColor});

  // ✅ REFACTORED: Removed the _showColorPickerDialog method as it's no longer needed.

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          const SizedBox(height: 16),
          // --- ✅ REFACTORED: Removed the entire "Appearance" section ---
          // The ListTile for changing accent color has been deleted.

          // --- Developer Tools Section ---
          Text(
            "Developer Tools",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Use these buttons to test the notification system.",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),

          // --- Test Buttons (Unchanged) ---
          ElevatedButton.icon(
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Test Notification (Now)'),
            onPressed: () => notificationService.showNowNotification(),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.timer_outlined),
            label: const Text('Test Notification (in 5s)'),
            onPressed: () => notificationService.scheduleTestNotification(),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.list_alt),
            label: const Text('Show Pending Notifications (in Console)'),
            onPressed: () => notificationService.showPendingNotifications(),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: colorScheme.error),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancel All Notifications'),
            onPressed: () {
              notificationService.cancelAllNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'All scheduled notifications have been cancelled.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
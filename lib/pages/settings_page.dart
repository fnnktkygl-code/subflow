import 'package:aada_app/widgets/shared/page_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../provider/simplified_subscription_provider.dart';
import '../theme/design_system.dart';
import 'country_selection_page.dart';
import 'debug_api_page.dart';

class Settings extends StatelessWidget {
  const Settings(
      {super.key,
        required ValueChanged<Color> onChangeAccentColor,
        required VoidCallback onResetAccentColor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // =========================================================================
    // ARCHITECTURAL FIX:
    // We now wrap the page content in the reusable `PageLayout` widget.
    // This ensures that this page uses the same `CustomScrollView` structure
    // as all other pages, guaranteeing consistent scroll behavior.
    // =========================================================================
    return PageLayout(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                const SizedBox(height: 16),
                // --- Bank Connection Section ---
                Text(
                  "Bank Connection",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Connect your bank account to automatically import your recurring payments.",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.account_balance),
                  label: const Text('Connect to Bank'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: DesignSystem.spacing10,
                      horizontal: DesignSystem.spacing12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CountrySelectionPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // --- Developer Tools Section ---
                Text(
                  "Developer Tools",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Use these buttons to test the notification system and debug bank connections.",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.bug_report),
                  label: const Text('View True Layer API Debug'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: DesignSystem.spacing10,
                      horizontal: DesignSystem.spacing12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                    ),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DebugApiPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                ElevatedButton.icon(
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text('Test Notification (Now)'),
                  onPressed: () => notificationService.showNowNotification(),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.timer_outlined),
                  label: const Text('Test Notification (in 5s)'),
                  onPressed: () =>
                      notificationService.scheduleTestNotification(),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.list_alt),
                  label:
                  const Text('Show Pending Notifications (in Console)'),
                  onPressed: () =>
                      notificationService.showPendingNotifications(),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel All Notifications'),
                  onPressed: () async {
                    // --- Get everything from context BEFORE the await ---
                    final provider = context.read<SimplifiedSubscriptionProvider>();
                    final messenger = ScaffoldMessenger.of(context);
                    final mounted = context.mounted; // Check mounted state *before*

                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        title: const Text('Are you sure?'),
                        content: const Text(
                            'This will permanently delete all of your subscriptions. This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.error),
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete All'),
                          ),
                        ],
                      ),
                    );

                    // --- Use the variables AFTER the await ---
                    if (confirmed == true && mounted) {
                      await provider.clearAllSubscriptions();
                      messenger.showSnackBar(
                        SnackBar(
                          content:
                          const Text('All subscriptions have been deleted.'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),

                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error),
                  icon: const Icon(Icons.delete_forever_outlined),
                  label: const Text('Reset All Subscriptions'),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        title: const Text('Are you sure?'),
                        content: const Text(
                            'This will permanently delete all of your subscriptions. This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.error),
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete All'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && context.mounted) {
                      // Get everything you need from context BEFORE the await
                      final provider = context.read<SimplifiedSubscriptionProvider>();
                      final messenger = ScaffoldMessenger.of(context);

                      // The async gap
                      await provider.clearAllSubscriptions();

                      // Check 'mounted' AGAIN after the await before using the messenger
                      if (!context.mounted) return;

                      messenger.showSnackBar(
                        SnackBar(
                          content: const Text('All subscriptions have been deleted.'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    }                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

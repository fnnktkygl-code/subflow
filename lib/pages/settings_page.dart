// lib/pages/settings_page.dart

import 'package:aada_app/widgets/shared/page_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../provider/simplified_subscription_provider.dart';
import '../provider/user_profile_provider.dart'; // ✅ Import User Profile Provider
import '../theme/design_system.dart';
import 'country_selection_page.dart';
import 'debug_api_page.dart';
import 'greeting_debug_page.dart';

class Settings extends StatelessWidget {
  const Settings({
    super.key,
    required ValueChanged<Color> onChangeAccentColor,
    required VoidCallback onResetAccentColor,
  });

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      onRefresh: () async =>
      await Future.delayed(const Duration(milliseconds: 500)),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate.fixed(
            [
              // --- Account Section ---
              _buildSectionHeader(context, "Account"),
              _buildSettingsCard(
                context,
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.account_balance_rounded,
                    title: "Bank Connection",
                    subtitle: "Connect your bank to import subscriptions",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CountrySelectionPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // --- Developer Tools Section ---
              _buildSectionHeader(context, "Developer Tools"),
              _buildSettingsCard(
                context,
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.bug_report_rounded,
                    title: "TrueLayer API Debug",
                    subtitle: "View raw data from the bank connection API",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DebugApiPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16, height: 1),
                  _buildSettingsTile(
                    context,
                    icon: Icons.message_rounded,
                    title: "Test Greeting Messages",
                    subtitle: "Cycle through homepage greetings",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const GreetingDebugPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16, height: 1),
                  _buildSettingsTile(
                    context,
                    icon: Icons.notifications_active_rounded,
                    title: "Test Notifications",
                    subtitle: "Send test notifications now or scheduled",
                    onTap: () => _showNotificationTestDialog(context),
                  ),
                ],
              ),

              // --- Data Management (Danger Zone) ---
              _buildSectionHeader(context, "Data Management"),
              _buildSettingsCard(
                context,
                isDangerZone: true,
                children: [
                  // ✅ ADD: New tile for resetting financial data
                  _buildSettingsTile(
                    context,
                    icon: Icons.paid_rounded,
                    title: "Reset Income & Goal",
                    subtitle: "Removes income and resets spend limit",
                    isDanger: true,
                    onTap: () => _showResetFinancialsConfirmationDialog(context),
                  ),
                  const Divider(indent: 16, endIndent: 16, height: 1),
                  _buildSettingsTile(
                    context,
                    icon: Icons.delete_forever_rounded,
                    title: "Reset All Subscriptions",
                    subtitle: "Permanently delete all your data",
                    isDanger: true,
                    onTap: () => _showResetSubscriptionsConfirmationDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }

  // --- WIDGET BUILDER HELPERS ---

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignSystem.spacing10,
        DesignSystem.spacing12,
        DesignSystem.spacing10,
        DesignSystem.spacing6,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context,
      {required List<Widget> children, bool isDangerZone = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        side: BorderSide(
          color: isDangerZone
              ? colorScheme.error.withOpacity(0.3)
              : colorScheme.outlineVariant.withOpacity(0.7),
          width: 1,
        ),
      ),
      margin:
      const EdgeInsets.symmetric(horizontal: DesignSystem.spacing8),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
        bool isDanger = false,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = isDanger ? colorScheme.error : colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: textTheme.bodyLarge
            ?.copyWith(fontWeight: FontWeight.w600, color: color),
      ),
      subtitle: Text(
        subtitle,
        style: textTheme.bodySmall
            ?.copyWith(color: color.withOpacity(0.7)),
      ),
      trailing:
      Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
      onTap: onTap,
      splashColor: (isDanger ? colorScheme.error : colorScheme.primary)
          .withOpacity(0.1),
    );
  }

  // --- DIALOGS ---

  void _showNotificationTestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Test Notifications"),
        content: const Text(
            "Would you like to send a notification now or schedule one for 5 seconds from now?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              notificationService.showNowNotification();
            },
            child: const Text("Send Now"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              notificationService.scheduleTestNotification();
            },
            child: const Text("Schedule (5s)"),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmationDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    // Get providers and scaffold messenger before the async gap
    final provider = context.read<SimplifiedSubscriptionProvider>();
    final messenger = ScaffoldMessenger.of(context);

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

    if (confirmed == true) {
      await provider.clearAllSubscriptions();
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
    }
  }


  // ✅ ADD: New confirmation dialog for resetting financials
  void _showResetFinancialsConfirmationDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.read<UserProfileProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Reset Financials?'),
        content: const Text(
            'This will remove your monthly income and reset your spending goal to the default. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.resetIncomeAndGoal();
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Income and spending goal have been reset.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showResetSubscriptionsConfirmationDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.read<SimplifiedSubscriptionProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Are you sure?'),
        content: const Text(
            'This will permanently delete all of your subscriptions. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.clearAllSubscriptions();
      messenger.showSnackBar(
        SnackBar(
          content: const Text('All subscriptions have been deleted.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}

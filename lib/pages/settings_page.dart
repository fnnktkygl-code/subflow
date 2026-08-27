// lib/pages/settings_page.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/shared/page_layout.dart';
import '../main.dart';
import '../provider/simplified_subscription_provider.dart';
import '../provider/user_profile_provider.dart'; // ✅ Import User Profile Provider
import '../services/truelayer_service.dart';
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
                  const Divider(indent: 16, endIndent: 16, height: 1),
                  _buildSettingsTile(
                    context,
                    icon: Icons.public_rounded,
                    title: "Country & Presets",
                    subtitle: "Active region: ${context.watch<UserProfileProvider>().effectiveCountryCode} (Tailored subscription prices)",
                    onTap: () => _showCountrySelectionDialog(context),
                  ),
                ],
              ),

              // --- Developer Tools Section (Debug Mode Only) ---
              if (kDebugMode) ...[
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
              ],

              // --- Data Management & Privacy (GDPR) ---
              _buildSectionHeader(context, "Data & Privacy"),
              _buildSettingsCard(
                context,
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.file_download_outlined,
                    title: "Export My Data (JSON)",
                    subtitle: "Download all subscriptions and profile data",
                    onTap: () => _exportData(context),
                  ),
                  const Divider(indent: 16, endIndent: 16, height: 1),
                  _buildSettingsTile(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: "Privacy Policy & Security",
                    subtitle: "Local-first storage, encryption, zero trackers",
                    onTap: () => _showPrivacyPolicyDialog(context),
                  ),
                ],
              ),

              // --- Danger Zone ---
              _buildSectionHeader(context, "Danger Zone"),
              _buildSettingsCard(
                context,
                isDangerZone: true,
                children: [
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
                    title: "Delete All Data (Right to Erasure)",
                    subtitle: "Permanently erase all subscriptions and settings",
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
              ? colorScheme.error.withValues(alpha: 0.3)
              : colorScheme.outlineVariant.withValues(alpha: 0.7),
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
            ?.copyWith(color: color.withValues(alpha: 0.7)),
      ),
      trailing:
      Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
      onTap: onTap,
      splashColor: (isDanger ? colorScheme.error : colorScheme.primary)
          .withValues(alpha: 0.1),
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
      await TruelayerService().clearTokens();
      messenger.showSnackBar(
        SnackBar(
          content: const Text('All subscriptions and tokens have been securely deleted.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _exportData(BuildContext context) async {
    final provider = context.read<SimplifiedSubscriptionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final json = await provider.exportData();

    if (json != null && context.mounted) {
      await Clipboard.setData(ClipboardData(text: json));
      messenger.showSnackBar(
        SnackBar(
          content: const Text('All your data has been exported and copied to clipboard! (JSON)'),
          backgroundColor: Colors.blueAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_outlined, color: Colors.blueAccent),
            SizedBox(width: 8),
            Flexible(child: Text('Privacy & Security')),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🔒 Local-First Architecture',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'SubFlow stores your subscriptions, income, and goals locally on your device. No financial data is sent to private analytics servers.',
              ),
              SizedBox(height: 12),
              Text(
                '🛡️ Open Banking (PSD2) Compliance',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Bank connections use encrypted OAuth links and system-level secure token storage. We never store or access your bank credentials.',
              ),
              SizedBox(height: 12),
              Text(
                '🇪🇺 GDPR Data Rights (Articles 17 & 20)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'You have full control: you can export all your data at any time (JSON) or permanently delete it with one click.',
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showCountrySelectionDialog(BuildContext context) {
    final userProfile = context.read<UserProfileProvider>();
    final currentCode = userProfile.effectiveCountryCode;

    const countries = [
      {'code': 'FR', 'name': 'France', 'flag': '🇫🇷', 'currency': 'EUR (€)'},
      {'code': 'GB', 'name': 'United Kingdom', 'flag': '🇬🇧', 'currency': 'GBP (£)'},
      {'code': 'US', 'name': 'United States', 'flag': '🇺🇸', 'currency': 'USD (\$)'},
      {'code': 'DE', 'name': 'Germany', 'flag': '🇩🇪', 'currency': 'EUR (€)'},
      {'code': 'ES', 'name': 'Spain', 'flag': '🇪🇸', 'currency': 'EUR (€)'},
      {'code': 'IT', 'name': 'Italy', 'flag': '🇮🇹', 'currency': 'EUR (€)'},
      {'code': 'NL', 'name': 'Netherlands', 'flag': '🇳🇱', 'currency': 'EUR (€)'},
      {'code': 'CA', 'name': 'Canada', 'flag': '🇨🇦', 'currency': 'CAD (CA\$)'},
      {'code': 'AU', 'name': 'Australia', 'flag': '🇦🇺', 'currency': 'AUD (A\$)'},
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actionsOverflowButtonSpacing: 8,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.public_rounded, color: Colors.blueAccent),
            SizedBox(width: 8),
            Flexible(child: Text('Select Country & Region')),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: countries.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final c = countries[index];
              final code = c['code']!;
              final isSelected = code == currentCode;

              return ListTile(
                leading: Text(c['flag']!, style: const TextStyle(fontSize: 24)),
                title: Text(c['name']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(c['currency']!),
                trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Colors.green) : null,
                onTap: () {
                  userProfile.setCountryCode(code);
                  Navigator.of(dialogContext).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              userProfile.setCountryCode(null); // Reset to auto-detect
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Auto-Detect'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

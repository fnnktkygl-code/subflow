// lib/pages/country_selection_page.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/design_system.dart';
import 'provider_selection_page.dart';
import 'truelayer_connect_page.dart'; // ✅ Add this import

class CountrySelectionPage extends StatelessWidget {
  const CountrySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Country'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ✅ ADD THIS: Direct Boursorama button for testing
          Card(
            color: Colors.blue.shade50,
            child: ListTile(
              leading: const Icon(Icons.science, color: Colors.blue, size: 32),
              title: const Text(
                'Test: Boursorama (Direct)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Skip provider selection and connect directly'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (kDebugMode) {
                  print("=== DIRECT CONNECT TO BOURSORAMA ===");
                }
                // Try both possible provider IDs
                final providerId = 'stet-boursorama';
                if (kDebugMode) {
                  print("Using provider ID: $providerId");
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TruelayerConnectPage(
                      countryCode: 'FR',
                      providerId: providerId,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Or select country to browse all banks:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          _buildCountryCard(
            context,
            countryCode: 'FR',
            countryName: 'France',
            flagEmoji: '🇫🇷',
          ),
          const SizedBox(height: 12),
          _buildCountryCard(
            context,
            countryCode: 'GB',
            countryName: 'United Kingdom',
            flagEmoji: '🇬🇧',
          ),
          const SizedBox(height: 12),
          _buildCountryCard(
            context,
            countryCode: 'DE',
            countryName: 'Germany',
            flagEmoji: '🇩🇪',
          ),
          const SizedBox(height: 12),
          _buildCountryCard(
            context,
            countryCode: 'ES',
            countryName: 'Spain',
            flagEmoji: '🇪🇸',
          ),
          const SizedBox(height: 12),
          _buildCountryCard(
            context,
            countryCode: 'IT',
            countryName: 'Italy',
            flagEmoji: '🇮🇹',
          ),
          const SizedBox(height: 12),
          _buildCountryCard(
            context,
            countryCode: 'NL',
            countryName: 'Netherlands',
            flagEmoji: '🇳🇱',
          ),
          const SizedBox(height: 12),
          _buildCountryCard(
            context,
            countryCode: 'IE',
            countryName: 'Ireland',
            flagEmoji: '🇮🇪',
          ),
          const SizedBox(height: 12),
          _buildCountryCard(
            context,
            countryCode: 'PL',
            countryName: 'Poland',
            flagEmoji: '🇵🇱',
          ),
        ],
      ),
    );
  }

  Widget _buildCountryCard(
      BuildContext context, {
        required String countryCode,
        required String countryName,
        required String flagEmoji,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(DesignSystem.spacing10),
        leading: Text(
          flagEmoji,
          style: const TextStyle(fontSize: 32),
        ),
        title: Text(
          countryName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Country code: $countryCode'),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProviderSelectionPage(
                countryCode: countryCode,
              ),
            ),
          );
        },
        hoverColor: colorScheme.primary.withOpacity(isDark ? 0.1 : 0.05),
        splashColor: colorScheme.primary.withOpacity(0.1),
      ),
    );
  }
}
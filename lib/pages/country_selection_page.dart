// lib/pages/country_selection_page.dart

import 'package:subflow_app/widgets/shared/page_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/design_system.dart';
import 'provider_selection_page.dart';
import 'truelayer_connect_page.dart';

class CountrySelectionPage extends StatelessWidget {
  const CountrySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // This page has its own app bar, so we disable the automatic top padding.
    return PageLayout(
      addTopPadding: false,
      onRefresh: () async => Future.delayed(const Duration(milliseconds: 500)),
      slivers: [
        // Use a SliverAppBar for a more integrated scrolling experience.
        const SliverAppBar(
          title: Text('Select Your Country'),
          pinned: true, // The app bar will remain visible at the top.
          floating: true, // It will reappear as soon as you scroll up.
        ),
        SliverPadding(
          padding: const EdgeInsets.all(DesignSystem.spacing8),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                if (kDebugMode) ...[
                  _buildDebugCard(context),
                  const SizedBox(height: DesignSystem.spacing12),
                  const Divider(),
                  const SizedBox(height: DesignSystem.spacing4),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: DesignSystem.spacing8, vertical: DesignSystem.spacing4),
                    child: Text(
                      'Or select country to browse all banks:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignSystem.spacing8),
                ],
                _buildCountryCard(
                  context,
                  countryCode: 'FR',
                  countryName: 'France',
                  flagEmoji: '🇫🇷',
                ),
                const SizedBox(height: DesignSystem.spacing6),
                _buildCountryCard(
                  context,
                  countryCode: 'GB',
                  countryName: 'United Kingdom',
                  flagEmoji: '🇬🇧',
                ),
                const SizedBox(height: DesignSystem.spacing6),
                _buildCountryCard(
                  context,
                  countryCode: 'DE',
                  countryName: 'Germany',
                  flagEmoji: '🇩🇪',
                ),
                const SizedBox(height: DesignSystem.spacing6),
                _buildCountryCard(
                  context,
                  countryCode: 'ES',
                  countryName: 'Spain',
                  flagEmoji: '🇪🇸',
                ),
                const SizedBox(height: DesignSystem.spacing6),
                _buildCountryCard(
                  context,
                  countryCode: 'IT',
                  countryName: 'Italy',
                  flagEmoji: '🇮🇹',
                ),
                const SizedBox(height: DesignSystem.spacing6),
                _buildCountryCard(
                  context,
                  countryCode: 'NL',
                  countryName: 'Netherlands',
                  flagEmoji: '🇳🇱',
                ),
                const SizedBox(height: DesignSystem.spacing6),
                _buildCountryCard(
                  context,
                  countryCode: 'IE',
                  countryName: 'Ireland',
                  flagEmoji: '🇮🇪',
                ),
                const SizedBox(height: DesignSystem.spacing6),
                _buildCountryCard(
                  context,
                  countryCode: 'PL',
                  countryName: 'Poland',
                  flagEmoji: '🇵🇱',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Extracted debug card for clarity and distinct styling.
  Widget _buildDebugCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        side: BorderSide(
          color: colorScheme.secondary.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      elevation: 0,
      child: ListTile(
        leading: Icon(Icons.science_outlined,
            color: colorScheme.secondary, size: 32),
        title: Text(
          'Test: Boursorama (Direct)',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: colorScheme.onSecondaryContainer),
        ),
        subtitle: Text(
          'Skip provider selection and connect directly',
          style: TextStyle(color: colorScheme.onSecondaryContainer.withValues(alpha: 0.8)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TruelayerConnectPage(
                countryCode: 'FR',
                providerId: 'stet-boursorama',
              ),
            ),
          );
        },
      ),
    );
  }

  // Refined styling for country cards to match the app's theme.
  Widget _buildCountryCard(
      BuildContext context, {
        required String countryCode,
        required String countryName,
        required String flagEmoji,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignSystem.spacing10,
          vertical: DesignSystem.spacing6,
        ),
        leading: Text(
          flagEmoji,
          style: const TextStyle(fontSize: 32),
        ),
        title: Text(
          countryName,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Country code: $countryCode',
          style: textTheme.bodySmall
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
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
        splashColor: colorScheme.primary.withValues(alpha: 0.1),
      ),
    );
  }
}


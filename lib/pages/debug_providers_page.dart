// lib/pages/debug_providers_page.dart

import 'package:flutter/material.dart';
import '../services/truelayer_service.dart';
import '../theme/design_system.dart'; // ✅ This line should already be there

class DebugProvidersPage extends StatelessWidget {
  const DebugProvidersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Providers')),
      body: FutureBuilder(
        future: _fetchAllProviders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }

          final data = snapshot.data as Map<String, dynamic>;
          final allProviders = data['all'] as List;
          final groupedByCountry = data['byCountry'] as Map<String, List>;

          return ListView(
            padding: EdgeInsets.all(DesignSystem.spacing10),
            children: [
              Padding(
                padding: EdgeInsets.all(DesignSystem.spacing8),
                child: Text(
                  'Total providers: ${allProviders.length}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: DesignSystem.spacing12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: DesignSystem.spacing8),
                child: Text(
                  'Providers by country:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              SizedBox(height: DesignSystem.spacing8),
              ...groupedByCountry.entries.map((entry) {
                final countryProviders = entry.value;
                final colorScheme = Theme.of(context).colorScheme;

                return Padding(
                  padding: EdgeInsets.only(bottom: DesignSystem.spacing6),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                      side: BorderSide(
                        color: colorScheme.outlineVariant.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    elevation: 0,
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.symmetric(
                        horizontal: DesignSystem.spacing12,
                        vertical: DesignSystem.spacing6,
                      ),
                      title: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(DesignSystem.spacing6),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius:
                              BorderRadius.circular(DesignSystem.radiusSmall),
                            ),
                            child: Icon(
                              Icons.account_balance,
                              color: colorScheme.primary,
                              size: DesignSystem.iconMedium,
                            ),
                          ),
                          SizedBox(width: DesignSystem.spacing8),
                          Text(
                            '${entry.key} (${countryProviders.length} banks)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(left: DesignSystem.spacing8 * 5),
                        child: Text(
                          countryProviders
                              .take(3)
                              .map(
                                (p) => p['display_name'] ?? p['name'] ?? 'Unknown',
                          )
                              .join(', ') +
                              (countryProviders.length > 3 ? '...' : ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      children: countryProviders.map<Widget>((provider) {
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: DesignSystem.spacing12,
                            vertical: DesignSystem.spacing4,
                          ),
                          title: Text(
                            provider['display_name'] ?? provider['name'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            'ID: ${provider['provider_id'] ?? provider['id']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchAllProviders() async {
    final service = TruelayerService();

    // Use the service's method to get all providers
    // We'll fetch for multiple countries and combine
    final countries = ['FR', 'GB', 'DE', 'ES', 'IT', 'NL', 'IE', 'PL'];
    final Map<String, List> byCountry = {};
    final List<dynamic> allProviders = [];

    for (final country in countries) {
      final providers = await service.getProviders(country);
      if (providers.isNotEmpty) {
        byCountry[country] = providers.map((p) => {
          'display_name': p.name,
          'provider_id': p.id,
          'country_code': p.countryCode,
        }).toList();
        allProviders.addAll(byCountry[country]!);
      }
    }

    // Sort countries alphabetically
    final sortedByCountry = Map.fromEntries(
        byCountry.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );

    return {
      'all': allProviders,
      'byCountry': sortedByCountry,
    };
  }
}
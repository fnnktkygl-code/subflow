// lib/services/preset_catalog_service.dart

/// A preset model for quick-adding popular subscriptions with accurate local pricing.
class SubscriptionPreset {
  final String name;
  final double amount;
  final String currencySymbol;
  final String currencyCode;
  final String category;
  final String cycle;

  const SubscriptionPreset({
    required this.name,
    required this.amount,
    required this.currencySymbol,
    required this.currencyCode,
    required this.category,
    this.cycle = 'Monthly',
  });

  String get formattedPrice => '$currencySymbol${amount.toStringAsFixed(2)}';
}

/// Provides region-tailored subscription catalogs and market prices.
class PresetCatalogService {
  static const Map<String, List<SubscriptionPreset>> _regionalPresets = {
    // France (EUR)
    'FR': [
      SubscriptionPreset(
        name: 'Netflix',
        amount: 13.49,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'Spotify',
        amount: 11.12,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'iCloud',
        amount: 2.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'General',
      ),
      SubscriptionPreset(
        name: 'YouTube',
        amount: 12.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'ChatGPT',
        amount: 23.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'General',
      ),
      SubscriptionPreset(
        name: 'Amazon Prime',
        amount: 6.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'Canal+',
        amount: 22.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
    ],

    // United Kingdom (GBP)
    'GB': [
      SubscriptionPreset(
        name: 'Netflix',
        amount: 10.99,
        currencySymbol: '£',
        currencyCode: 'GBP',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'Spotify',
        amount: 11.99,
        currencySymbol: '£',
        currencyCode: 'GBP',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'iCloud',
        amount: 2.99,
        currencySymbol: '£',
        currencyCode: 'GBP',
        category: 'General',
      ),
      SubscriptionPreset(
        name: 'YouTube',
        amount: 12.99,
        currencySymbol: '£',
        currencyCode: 'GBP',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'ChatGPT',
        amount: 19.00,
        currencySymbol: '£',
        currencyCode: 'GBP',
        category: 'General',
      ),
      SubscriptionPreset(
        name: 'Amazon Prime',
        amount: 8.99,
        currencySymbol: '£',
        currencyCode: 'GBP',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'Disney+',
        amount: 7.99,
        currencySymbol: '£',
        currencyCode: 'GBP',
        category: 'Entertainment',
      ),
    ],

    // United States (USD)
    'US': [
      SubscriptionPreset(
        name: 'Netflix',
        amount: 15.49,
        currencySymbol: '\$',
        currencyCode: 'USD',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'Spotify',
        amount: 11.99,
        currencySymbol: '\$',
        currencyCode: 'USD',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'iCloud',
        amount: 2.99,
        currencySymbol: '\$',
        currencyCode: 'USD',
        category: 'General',
      ),
      SubscriptionPreset(
        name: 'YouTube',
        amount: 13.99,
        currencySymbol: '\$',
        currencyCode: 'USD',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'ChatGPT',
        amount: 20.00,
        currencySymbol: '\$',
        currencyCode: 'USD',
        category: 'General',
      ),
      SubscriptionPreset(
        name: 'Amazon Prime',
        amount: 14.99,
        currencySymbol: '\$',
        currencyCode: 'USD',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'Disney+',
        amount: 13.99,
        currencySymbol: '\$',
        currencyCode: 'USD',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'HBO Max',
        amount: 16.99,
        currencySymbol: '\$',
        currencyCode: 'USD',
        category: 'Entertainment',
      ),
    ],

    // Germany (EUR)
    'DE': [
      SubscriptionPreset(
        name: 'Netflix',
        amount: 13.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'Spotify',
        amount: 10.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'iCloud',
        amount: 2.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'General',
      ),
      SubscriptionPreset(
        name: 'YouTube',
        amount: 12.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'ChatGPT',
        amount: 22.00,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'General',
      ),
      SubscriptionPreset(
        name: 'Amazon Prime',
        amount: 8.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'DAZN',
        amount: 29.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
    ],

    // Spain (EUR)
    'ES': [
      SubscriptionPreset(
        name: 'Netflix',
        amount: 12.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'Spotify',
        amount: 10.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'iCloud',
        amount: 2.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'General',
      ),
      SubscriptionPreset(
        name: 'YouTube',
        amount: 11.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'ChatGPT',
        amount: 22.00,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'General',
      ),
      SubscriptionPreset(
        name: 'Amazon Prime',
        amount: 4.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'Movistar+',
        amount: 14.00,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
    ],

    // Italy (EUR)
    'IT': [
      SubscriptionPreset(
        name: 'Netflix',
        amount: 12.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'Spotify',
        amount: 10.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'iCloud',
        amount: 2.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'General',
      ),
      SubscriptionPreset(
        name: 'YouTube',
        amount: 11.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'ChatGPT',
        amount: 22.00,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'General',
      ),
      SubscriptionPreset(
        name: 'Amazon Prime',
        amount: 4.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'DAZN',
        amount: 30.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
    ],

    // Netherlands (EUR)
    'NL': [
      SubscriptionPreset(
        name: 'Netflix',
        amount: 13.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'Spotify',
        amount: 10.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'iCloud',
        amount: 2.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'General',
      ),
      SubscriptionPreset(
        name: 'YouTube',
        amount: 12.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'ChatGPT',
        amount: 22.00,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'General',
      ),
      SubscriptionPreset(
        name: 'Amazon Prime',
        amount: 4.99,
        currencySymbol: '€',
        currencyCode: 'EUR',
        category: 'Entertainment',
      ),
    ],

    // Canada (CAD)
    'CA': [
      SubscriptionPreset(
        name: 'Netflix',
        amount: 16.49,
        currencySymbol: 'CA\$',
        currencyCode: 'CAD',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'Spotify',
        amount: 10.99,
        currencySymbol: 'CA\$',
        currencyCode: 'CAD',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'iCloud',
        amount: 3.99,
        currencySymbol: 'CA\$',
        currencyCode: 'CAD',
        category: 'General',
      ),
      SubscriptionPreset(
        name: 'YouTube',
        amount: 12.99,
        currencySymbol: 'CA\$',
        currencyCode: 'CAD',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'ChatGPT',
        amount: 27.00,
        currencySymbol: 'CA\$',
        currencyCode: 'CAD',
        category: 'General',
      ),
      SubscriptionPreset(
        name: 'Amazon Prime',
        amount: 9.99,
        currencySymbol: 'CA\$',
        currencyCode: 'CAD',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'Crave',
        amount: 14.99,
        currencySymbol: 'CA\$',
        currencyCode: 'CAD',
        category: 'Entertainment',
      ),
    ],

    // Australia (AUD)
    'AU': [
      SubscriptionPreset(
        name: 'Netflix',
        amount: 18.99,
        currencySymbol: 'A\$',
        currencyCode: 'AUD',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'Spotify',
        amount: 13.99,
        currencySymbol: 'A\$',
        currencyCode: 'AUD',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'iCloud',
        amount: 4.49,
        currencySymbol: 'A\$',
        currencyCode: 'AUD',
        category: 'General',
      ),
      SubscriptionPreset(
        name: 'YouTube',
        amount: 16.99,
        currencySymbol: 'A\$',
        currencyCode: 'AUD',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'ChatGPT',
        amount: 30.00,
        currencySymbol: 'A\$',
        currencyCode: 'AUD',
        category: 'General',
      ),
      SubscriptionPreset(
        name: 'Amazon Prime',
        amount: 9.99,
        currencySymbol: 'A\$',
        currencyCode: 'AUD',
        category: 'Entertainment',
      ),
      SubscriptionPreset(
        name: 'Kayo Sports',
        amount: 25.00,
        currencySymbol: 'A\$',
        currencyCode: 'AUD',
        category: 'Entertainment',
      ),
    ],
  };

  static const List<SubscriptionPreset> _defaultPresets = [
    SubscriptionPreset(
      name: 'Netflix',
      amount: 13.49,
      currencySymbol: '€',
      currencyCode: 'EUR',
      category: 'Entertainment',
    ),
    SubscriptionPreset(
      name: 'Spotify',
      amount: 10.99,
      currencySymbol: '€',
      currencyCode: 'EUR',
      category: 'Entertainment',
    ),
    SubscriptionPreset(
      name: 'iCloud',
      amount: 2.99,
      currencySymbol: '€',
      currencyCode: 'EUR',
      category: 'General',
    ),
    SubscriptionPreset(
      name: 'YouTube',
      amount: 12.99,
      currencySymbol: '€',
      currencyCode: 'EUR',
      category: 'Entertainment',
    ),
    SubscriptionPreset(
      name: 'ChatGPT',
      amount: 20.00,
      currencySymbol: '€',
      currencyCode: 'EUR',
      category: 'General',
    ),
    SubscriptionPreset(
      name: 'Amazon Prime',
      amount: 6.99,
      currencySymbol: '€',
      currencyCode: 'EUR',
      category: 'Entertainment',
    ),
  ];

  /// Get presets for a given 2-letter uppercase ISO country code.
  static List<SubscriptionPreset> getPresetsForCountry(String? countryCode) {
    if (countryCode == null || countryCode.isEmpty) {
      return _defaultPresets;
    }
    final normalized = countryCode.toUpperCase().trim();
    return _regionalPresets[normalized] ?? _defaultPresets;
  }

  /// Get currency symbol for a given country code.
  static String getCurrencySymbol(String? countryCode) {
    final presets = getPresetsForCountry(countryCode);
    return presets.isNotEmpty ? presets.first.currencySymbol : '€';
  }

  /// Get primary currency code for a given country code.
  static String getCurrencyCode(String? countryCode) {
    final presets = getPresetsForCountry(countryCode);
    return presets.isNotEmpty ? presets.first.currencyCode : 'EUR';
  }
}

// lib/models/truelayer_provider.dart

class TruelayerProvider {
  final String id;
  final String name;
  final String countryCode;
  final String logoUrl;

  TruelayerProvider({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.logoUrl,
  });

  factory TruelayerProvider.fromJson(Map<String, dynamic> json) {
    return TruelayerProvider(
      id: json['provider_id'] ?? json['id'] ?? '',
      name: json['display_name'] ?? json['name'] ?? 'Unknown Bank',
      countryCode: json['country_code'] ?? json['country'] ?? 'XX',
      logoUrl: json['logo_url'] ?? json['logo_uri'] ?? '',
    );
  }

  @override
  String toString() {
    return 'TruelayerProvider(id: $id, name: $name, country: $countryCode)';
  }
}

class Country {
  final String code;
  final String name;
  final List<TruelayerProvider> providers;

  Country({required this.code, required this.name, required this.providers});
}
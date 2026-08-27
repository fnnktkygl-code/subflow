import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'security_sanitizer.dart';

/// Maps common subscription names to their official domain names
const Map<String, String> _knownBrandDomains = {
  'netflix': 'netflix.com',
  'spotify': 'spotify.com',
  'amazon': 'amazon.com',
  'amazon prime': 'amazon.com',
  'prime video': 'primevideo.com',
  'prime': 'primevideo.com',
  'apple': 'apple.com',
  'apple music': 'apple.com',
  'apple tv': 'apple.com',
  'icloud': 'apple.com',
  'disney': 'disneyplus.com',
  'disney+': 'disneyplus.com',
  'disney plus': 'disneyplus.com',
  'youtube': 'youtube.com',
  'youtube premium': 'youtube.com',
  'github': 'github.com',
  'openai': 'openai.com',
  'chatgpt': 'openai.com',
  'notion': 'notion.so',
  'figma': 'figma.com',
  'adobe': 'adobe.com',
  'playstation': 'playstation.com',
  'xbox': 'xbox.com',
  'nintendo': 'nintendo.com',
  'gym': 'basic-fit.com',
  'basic fit': 'basic-fit.com',
  'basic-fit': 'basic-fit.com',
  'fitpark': 'fitnesspark.fr',
  'fitness park': 'fitnesspark.fr',
  'canal': 'canalplus.com',
  'canal+': 'canalplus.com',
  'canal plus': 'canalplus.com',
  'deezer': 'deezer.com',
  'free': 'free.fr',
  'free mobile': 'free.fr',
  'orange': 'orange.fr',
  'sfr': 'sfr.fr',
  'bouygues': 'bouyguestelecom.fr',
  'edf': 'edf.fr',
  'engie': 'engie.fr',
  'totalenergies': 'totalenergies.fr',
  'lefigaro': 'lefigaro.fr',
  'lemonde': 'lemonde.fr',
  'mediapart': 'mediapart.fr',
  'lequipe': 'lequipe.fr',
};

/// Extracts the most likely domain name from a subscription or merchant name
String extractDomain(String subscriptionName) {
  final trimmed = subscriptionName.trim().toLowerCase();
  if (trimmed.isEmpty) return '';

  final noSpaces = trimmed.replaceAll(RegExp(r'\s+'), '');

  // Direct match in brand map
  if (_knownBrandDomains.containsKey(trimmed)) {
    return _knownBrandDomains[trimmed]!;
  }
  if (_knownBrandDomains.containsKey(noSpaces)) {
    return _knownBrandDomains[noSpaces]!;
  }

  // Check for substring matches in brand map
  for (final entry in _knownBrandDomains.entries) {
    if (trimmed.contains(entry.key) || noSpaces.contains(entry.key)) {
      return entry.value;
    }
  }

  // Strip special characters and whitespace
  final cleaned = trimmed.replaceAll(RegExp(r'[^a-z0-9\.\-]'), '');
  if (cleaned.isEmpty) return '';

  if (cleaned.contains('.')) {
    return cleaned;
  }

  return '$cleaned.com';
}

/// Generates a compliant Logo.dev Image API URL by Domain according to the official documentation.
/// Endpoint: https://img.logo.dev/{domain}
String buildLogoDevUrl({
  required String domain,
  required String token,
  int size = 128,
  String format = 'png',
  String theme = 'auto',
  bool greyscale = false,
  bool retina = true,
  String fallback = 'monogram',
}) {
  final cleanDomain = domain.trim().toLowerCase();
  final queryParams = <String, String>{
    'token': token,
    'size': size.toString(),
    'format': format,
    'fallback': fallback,
  };
  if (theme != 'auto') queryParams['theme'] = theme;
  if (greyscale) queryParams['greyscale'] = 'true';
  if (retina) queryParams['retina'] = 'true';

  final uri = Uri.https('img.logo.dev', '/$cleanDomain', queryParams);
  return uri.toString();
}

/// Generates a Logo.dev Image API URL by Company Name.
/// Endpoint: https://img.logo.dev/name/{brand_name}
String buildLogoDevNameUrl({
  required String name,
  required String token,
  int size = 128,
  String format = 'png',
  String theme = 'auto',
}) {
  final queryParams = <String, String>{
    'token': token,
    'size': size.toString(),
    'format': format,
  };
  if (theme != 'auto') queryParams['theme'] = theme;
  final uri = Uri.https('img.logo.dev', '/name/${name.trim()}', queryParams);
  return uri.toString();
}

/// Generates a Logo.dev Image API URL by Financial Ticker.
/// Endpoint: https://img.logo.dev/ticker/{symbol}
String buildLogoDevTickerUrl({
  required String symbol,
  required String token,
  int size = 128,
  String format = 'png',
}) {
  final cleanTicker = symbol.trim().toUpperCase();
  return Uri.https('img.logo.dev', '/ticker/$cleanTicker', {
    'token': token,
    'size': size.toString(),
    'format': format,
  }).toString();
}

/// Generates a Logo.dev Image API URL by Crypto Symbol.
/// Endpoint: https://img.logo.dev/crypto/{symbol}
String buildLogoDevCryptoUrl({
  required String symbol,
  required String token,
  int size = 128,
  String format = 'png',
}) {
  final cleanCrypto = symbol.trim().toUpperCase();
  return Uri.https('img.logo.dev', '/crypto/$cleanCrypto', {
    'token': token,
    'size': size.toString(),
    'format': format,
  }).toString();
}

/// Resolves the optimal logo URL for a subscription.
/// Priority:
/// 1. Direct URL if already a full http/https link
/// 2. Official Logo.dev Image API if token is provided or loaded from .env
/// 3. CORS-compliant unavatar.io CDN fallback
String fetchLogo(String subscriptionName, {String? token}) {
  final trimmed = subscriptionName.trim();
  if (trimmed.isEmpty) return '';

  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return SecuritySanitizer.sanitizeUrl(trimmed) ?? '';
  }

  final domain = extractDomain(trimmed);
  if (domain.isEmpty) return '';

  // Check if a Logo.dev publishable key (pk_...) is provided via parameter or environment
  String? logoDevToken = token;
  if (logoDevToken == null && dotenv.isInitialized) {
    logoDevToken = dotenv.env['LOGO_DEV_PUBLIC_KEY'] ?? dotenv.env['LOGO_DEV_TOKEN'];
  }

  if (logoDevToken != null && logoDevToken.trim().isNotEmpty) {
    return buildLogoDevUrl(domain: domain, token: logoDevToken.trim());
  }

  return 'https://unavatar.io/$domain';
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Represents a company/brand result from Logo.dev Search REST API
class LogoDevSearchResult {
  final String name;
  final String domain;
  final String logoUrl;

  const LogoDevSearchResult({
    required this.name,
    required this.domain,
    required this.logoUrl,
  });

  factory LogoDevSearchResult.fromJson(Map<String, dynamic> json) {
    return LogoDevSearchResult(
      name: json['name'] as String? ?? '',
      domain: json['domain'] as String? ?? '',
      logoUrl: json['logo_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'domain': domain,
    'logo_url': logoUrl,
  };
}

/// Official Logo.dev REST API Client
/// Spec: https://www.logo.dev/docs/
class LogoDevService {
  final http.Client _client;

  LogoDevService({http.Client? client}) : _client = client ?? http.Client();

  /// Searches company brands by name with autocomplete or exact matching
  /// Uses https://api.logo.dev/search?q={name}&strategy={suggest|match}
  Future<List<LogoDevSearchResult>> searchBrands(
    String query, {
    String strategy = 'match',
    bool isProfane = false,
    String? secretKeyOverride,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final secretKey = secretKeyOverride ??
        (dotenv.isInitialized ? dotenv.env['LOGO_DEV_SECRET_KEY'] : null);
    if (secretKey == null || secretKey.trim().isEmpty) return [];

    try {
      final uri = Uri.parse('https://api.logo.dev/search').replace(
        queryParameters: {
          'q': trimmed,
          'strategy': strategy,
          if (!isProfane) 'is_profane': 'false',
        },
      );

      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${secretKey.trim()}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map((item) => LogoDevSearchResult.fromJson(item))
              .toList();
        }
      }
    } catch (_) {}

    return [];
  }
}

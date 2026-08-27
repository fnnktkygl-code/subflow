import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:subflow_app/services/logo_dev_service.dart';

void main() {
  group('LogoDevService Search API Tests', () {
    test('searchBrands parses valid JSON array response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.host, equals('api.logo.dev'));
        expect(request.url.path, equals('/search'));
        expect(request.url.queryParameters['q'], equals('google'));
        expect(request.url.queryParameters['strategy'], equals('match'));
        expect(request.headers['Authorization'], equals('Bearer sk_test_secret_123'));

        final responseBody = jsonEncode([
          {
            "name": "Google",
            "domain": "google.com",
            "logo_url": "https://img.logo.dev/google.com?token=pk_QtDacf-LTiKOC0yHo15DDA"
          },
          {
            "name": "Google DeepMind",
            "domain": "deepmind.google",
            "logo_url": "https://img.logo.dev/deepmind.google?token=pk_QtDacf-LTiKOC0yHo15DDA"
          }
        ]);

        return http.Response(responseBody, 200, headers: {'content-type': 'application/json'});
      });

      final service = LogoDevService(client: mockClient);
      final results = await service.searchBrands(
        'google',
        strategy: 'match',
        secretKeyOverride: 'sk_test_secret_123',
      );

      expect(results.length, equals(2));
      expect(results[0].name, equals('Google'));
      expect(results[0].domain, equals('google.com'));
      expect(results[0].logoUrl, contains('img.logo.dev/google.com'));
      expect(results[1].name, equals('Google DeepMind'));
    });

    test('searchBrands returns empty list when query is empty or secret key is missing', () async {
      final service = LogoDevService();
      final emptyQuery = await service.searchBrands('', secretKeyOverride: 'sk_test_123');
      expect(emptyQuery, isEmpty);

      final missingKey = await service.searchBrands('google', secretKeyOverride: '');
      expect(missingKey, isEmpty);
    });

    test('searchBrands handles HTTP errors gracefully', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final service = LogoDevService(client: mockClient);
      final results = await service.searchBrands(
        'google',
        secretKeyOverride: 'sk_invalid_key',
      );

      expect(results, isEmpty);
    });
  });
}

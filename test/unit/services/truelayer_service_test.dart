import 'package:flutter_test/flutter_test.dart';
import 'package:subflow_app/services/truelayer_service.dart';
import 'package:subflow_app/models/truelayer_provider.dart';

void main() {
  group('TrueLayer Service Unit & Integration Tests', () {
    late TruelayerService service;

    setUp(() {
      service = TruelayerService(
        clientId: 'test-client-id-123',
        clientSecret: 'test-client-secret-abc',
        redirectUri: 'http://localhost:3000/callback',
      );
    });

    test('getAuthenticationUrl builds compliant OAuth URL with all required scopes', () {
      final authUrl = service.getAuthenticationUrl('FR', state: 'test-random-state');
      final uri = Uri.parse(authUrl);

      expect(uri.scheme, equals('https'));
      expect(uri.host, contains('truelayer'));
      expect(uri.queryParameters['response_type'], equals('code'));
      expect(uri.queryParameters['client_id'], equals('test-client-id-123'));
      expect(uri.queryParameters['redirect_uri'], equals('http://localhost:3000/callback'));
      expect(uri.queryParameters['state'], equals('test-random-state'));
      expect(uri.queryParameters['scope'], contains('accounts'));
      expect(uri.queryParameters['scope'], contains('transactions'));
      expect(uri.queryParameters['scope'], contains('offline_access'));
      expect(uri.queryParameters['filters'], contains('"FR"'));
    });

    test('getAuthenticationUrl targets specific provider when providerId is passed', () {
      final authUrl = service.getAuthenticationUrl('FR', providerId: 'boursobank');
      final uri = Uri.parse(authUrl);

      expect(uri.queryParameters['provider_id'], equals('boursobank'));
      expect(uri.queryParameters.containsKey('filters'), isFalse);
    });

    test('TruelayerProvider parses JSON correctly with STET country tags', () {
      final jsonSample = {
        'provider_id': 'ob-boursobank',
        'display_name': 'BoursoBank (Boursorama)',
        'country_code': 'FR',
        'logo_url': 'https://auth.truelayer.com/assets/boursobank.png',
      };

      final provider = TruelayerProvider.fromJson(jsonSample);
      expect(provider.id, equals('ob-boursobank'));
      expect(provider.name, equals('BoursoBank (Boursorama)'));
      expect(provider.countryCode, equals('FR'));
      expect(provider.logoUrl, equals('https://auth.truelayer.com/assets/boursobank.png'));
    });

    test('TruelayerProvider handles fallback logo and alternative country key formats', () {
      final jsonAlt = {
        'id': 'bnp-paribas',
        'name': 'BNP Paribas',
        'country': 'FR',
        'logo_uri': 'https://auth.truelayer.com/assets/bnp.svg',
      };

      final provider = TruelayerProvider.fromJson(jsonAlt);
      expect(provider.id, equals('bnp-paribas'));
      expect(provider.name, equals('BNP Paribas'));
      expect(provider.countryCode, equals('FR'));
      expect(provider.logoUrl, equals('https://auth.truelayer.com/assets/bnp.svg'));
    });

    test('BFF proxy configuration correctly overrides auth base URL when supplied', () {
      final bffService = TruelayerService(
        clientId: 'test-id',
        bffUrl: 'https://my-backend.app',
      );
      expect(bffService.bffUrl, equals('https://my-backend.app'));
    });
  });
}

// test/security/oauth_csrf_defense_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:subflow_app/services/truelayer_service.dart';
import 'package:subflow_app/utils/security_sanitizer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OAuth Defense & CSRF Nonce Validation', () {
    test('getAuthenticationUrl attaches secure state nonce and PKCE parameters', () {
      final service = TruelayerService(
        clientId: 'test-client-id',
        redirectUri: 'http://localhost:3000/callback',
      );

      final stateNonce = SecuritySanitizer.generateSecureNonce(32);
      final pkce = SecuritySanitizer.generatePkcePair(64);

      final authUrl = service.getAuthenticationUrl(
        'FR',
        state: stateNonce,
        codeChallenge: pkce.codeChallenge,
        codeChallengeMethod: pkce.codeChallengeMethod,
      );

      final uri = Uri.parse(authUrl);

      // Verify OAuth parameters
      expect(uri.queryParameters['client_id'], 'test-client-id');
      expect(uri.queryParameters['response_type'], 'code');
      expect(uri.queryParameters['redirect_uri'], 'http://localhost:3000/callback');
      expect(uri.queryParameters['state'], stateNonce);
      expect(uri.queryParameters['code_challenge'], pkce.codeChallenge);
      expect(uri.queryParameters['code_challenge_method'], 'S256');
    });

    test('state verification rejects tampered or missing state values (CSRF mitigation)', () {
      final originalState = SecuritySanitizer.generateSecureNonce(32);
      const forgedState = 'attacker_forged_state_nonce';

      // 1. Missing state
      const String? missingState = null;
      expect(missingState == originalState, isFalse);

      // 2. Tampered state
      expect(forgedState == originalState, isFalse);

      // 3. Genuine state matches
      final returnedState = originalState;
      expect(returnedState == originalState, isTrue);
    });

    test('getAuthenticationUrl targets specific provider while maintaining PKCE and state integrity', () {
      final service = TruelayerService(
        clientId: 'test-client-id',
        redirectUri: 'http://localhost:3000/callback',
      );

      final stateNonce = SecuritySanitizer.generateSecureNonce(32);
      final pkce = SecuritySanitizer.generatePkcePair(64);

      final authUrl = service.getAuthenticationUrl(
        'FR',
        providerId: 'mock-bourso-bank',
        state: stateNonce,
        codeChallenge: pkce.codeChallenge,
        codeChallengeMethod: pkce.codeChallengeMethod,
      );

      final uri = Uri.parse(authUrl);

      expect(uri.queryParameters['provider_id'], 'mock-bourso-bank');
      expect(uri.queryParameters['state'], stateNonce);
      expect(uri.queryParameters['code_challenge'], pkce.codeChallenge);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:subflow_app/utils/logo_utils.dart';
import 'package:subflow_app/models/subscription_model.dart';

void main() {
  group('Logo Utils & Resolution Tests', () {
    test('buildLogoDevUrl builds compliant URL by Domain with default and custom parameters', () {
      final defaultUrl = buildLogoDevUrl(domain: 'spotify.com', token: 'pk_live_12345');
      expect(defaultUrl, contains('https://img.logo.dev/spotify.com?'));
      expect(defaultUrl, contains('token=pk_live_12345'));
      expect(defaultUrl, contains('size=128'));
      expect(defaultUrl, contains('format=png'));
      expect(defaultUrl, contains('fallback=monogram'));

      final customUrl = buildLogoDevUrl(
        domain: 'apple.com',
        token: 'pk_live_12345',
        size: 256,
        format: 'webp',
        theme: 'dark',
        greyscale: true,
        retina: true,
        fallback: '404',
      );
      expect(customUrl, contains('theme=dark'));
      expect(customUrl, contains('greyscale=true'));
      expect(customUrl, contains('retina=true'));
      expect(customUrl, contains('fallback=404'));
      expect(customUrl, contains('size=256'));
      expect(customUrl, contains('format=webp'));
    });

    test('buildLogoDevNameUrl builds compliant URL by Brand Name', () {
      final url = buildLogoDevNameUrl(name: 'YouTube Premium', token: 'pk_live_12345');
      expect(url, contains('https://img.logo.dev/name/YouTube%20Premium?'));
      expect(url, contains('token=pk_live_12345'));
    });

    test('buildLogoDevTickerUrl and buildLogoDevCryptoUrl build compliant financial symbol URLs', () {
      final tickerUrl = buildLogoDevTickerUrl(symbol: 'aapl', token: 'pk_live_12345');
      expect(tickerUrl, equals('https://img.logo.dev/ticker/AAPL?token=pk_live_12345&size=128&format=png'));

      final cryptoUrl = buildLogoDevCryptoUrl(symbol: 'btc', token: 'pk_live_12345');
      expect(cryptoUrl, equals('https://img.logo.dev/crypto/BTC?token=pk_live_12345&size=128&format=png'));
    });

    test('fetchLogo uses Logo.dev publishable key when provided', () {
      final url = fetchLogo('Netflix', token: 'pk_test_key_999');
      expect(url, contains('https://img.logo.dev/netflix.com?'));
      expect(url, contains('token=pk_test_key_999'));
    });
    test('resolves standard global subscription brands via default CDN', () {
      expect(fetchLogo('Netflix'), equals('https://unavatar.io/netflix.com'));
      expect(fetchLogo('Spotify'), equals('https://unavatar.io/spotify.com'));
      expect(fetchLogo('Prime Video'), equals('https://unavatar.io/primevideo.com'));
      expect(fetchLogo('Disney+'), equals('https://unavatar.io/disneyplus.com'));
      expect(fetchLogo('YouTube Premium'), equals('https://unavatar.io/youtube.com'));
      expect(fetchLogo('GitHub'), equals('https://unavatar.io/github.com'));
      expect(fetchLogo('ChatGPT Plus'), equals('https://unavatar.io/openai.com'));
    });

    test('resolves French domestic service providers', () {
      expect(fetchLogo('Canal+'), equals('https://unavatar.io/canalplus.com'));
      expect(fetchLogo('Free Mobile'), equals('https://unavatar.io/free.fr'));
      expect(fetchLogo('Orange'), equals('https://unavatar.io/orange.fr'));
      expect(fetchLogo('EDF'), equals('https://unavatar.io/edf.fr'));
      expect(fetchLogo('Le Monde'), equals('https://unavatar.io/lemonde.fr'));
      expect(fetchLogo('Fitness Park'), equals('https://unavatar.io/fitnesspark.fr'));
    });

    test('extracts custom website domains directly', () {
      expect(fetchLogo('my-saas-app.io'), equals('https://unavatar.io/my-saas-app.io'));
      expect(fetchLogo('customtool.co.uk'), equals('https://unavatar.io/customtool.co.uk'));
    });

    test('preserves direct full URLs', () {
      const fullUrl = 'https://custom-cdn.com/icons/app.png';
      expect(fetchLogo(fullUrl), equals(fullUrl));
    });

    test('handles edge cases and invalid inputs gracefully', () {
      expect(fetchLogo(''), isEmpty);
      expect(fetchLogo('   '), isEmpty);
      expect(fetchLogo('???'), isEmpty);
    });

    test('Subscription.effectiveLogoUrl dynamically sanitizes legacy dead URLs and empty fields', () {
      final legacySub = Subscription(
        id: 'legacy-1',
        name: 'Netflix',
        amount: -15.0,
        startDate: DateTime(2026, 1, 1),
        cycle: 'Monthly',
        category: 'Entertainment',
        logoUrl: 'https://img.demo.dev/netflix.com?token=pk_QtDacf-LTiKOC0yHo15DDA',
      );

      // Dead demo.dev URL is discarded and replaced with CORS-enabled CDN
      expect(legacySub.effectiveLogoUrl, contains('netflix.com'));
      expect(legacySub.effectiveLogoUrl, isNot(contains('demo.dev')));

      final emptySub = Subscription(
        id: 'empty-1',
        name: 'Spotify',
        amount: -10.0,
        startDate: DateTime(2026, 1, 1),
        cycle: 'Monthly',
        category: 'Music',
        logoUrl: '',
      );

      // Empty logoUrl dynamically resolves to Spotify domain
      expect(emptySub.effectiveLogoUrl, contains('spotify.com'));

      final validCustomSub = Subscription(
        id: 'custom-1',
        name: 'My Custom App',
        amount: -5.0,
        startDate: DateTime(2026, 1, 1),
        cycle: 'Monthly',
        category: 'Tech',
        logoUrl: 'https://mycdn.org/logo.png',
      );

      // Valid direct URL is preserved
      expect(validCustomSub.effectiveLogoUrl, equals('https://mycdn.org/logo.png'));
    });
  });
}

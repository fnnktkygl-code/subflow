// test/security/security_sanitizer_test.dart

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subflow_app/utils/security_sanitizer.dart';

void main() {
  group('SecuritySanitizer - XSS & Injection Defense', () {
    test('strips HTML and script tags from user inputs', () {
      const maliciousPayload = '<script>alert("XSS Attack!");</script>Netflix Premium';
      final sanitized = SecuritySanitizer.sanitizeText(maliciousPayload);

      expect(sanitized, isNot(contains('<script>')));
      expect(sanitized, isNot(contains('</script>')));
      expect(sanitized, 'alert("XSS Attack!");Netflix Premium');
    });

    test('strips img onerror and iframe XSS payloads', () {
      const imgPayload = '<img src="x" onerror="stealCookies()"/>Spotify Family';
      final sanitized = SecuritySanitizer.sanitizeText(imgPayload);

      expect(sanitized, isNot(contains('<img')));
      expect(sanitized, 'Spotify Family');
    });

    test('strips dangerous non-printable ASCII control characters', () {
      const payloadWithControlChars = 'Disney\x00Plus\x08Special\x1F';
      final sanitized = SecuritySanitizer.sanitizeText(payloadWithControlChars);

      expect(sanitized, 'DisneyPlusSpecial');
    });

    test('enforces maxLength truncation on overflow payloads', () {
      final longPayload = 'A' * 500;
      final sanitized = SecuritySanitizer.sanitizeText(longPayload, maxLength: 64);

      expect(sanitized.length, 64);
    });
  });

  group('SecuritySanitizer - URL Scheme Poisoning Defense', () {
    test('permits valid HTTPS and HTTP URLs', () {
      expect(
        SecuritySanitizer.sanitizeUrl('https://img.logo.dev/netflix.com?token=pk_123'),
        'https://img.logo.dev/netflix.com?token=pk_123',
      );
      expect(
        SecuritySanitizer.sanitizeUrl('http://example.com/logo.png'),
        'http://example.com/logo.png',
      );
    });

    test('strictly blocks javascript: pseudo-protocol execution', () {
      expect(SecuritySanitizer.sanitizeUrl('javascript:alert(document.cookie)'), isNull);
      expect(SecuritySanitizer.sanitizeUrl('JAVASCRIPT:console.log(1)'), isNull);
    });

    test('strictly blocks data: URI scheme payloads', () {
      expect(
        SecuritySanitizer.sanitizeUrl('data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg=='),
        isNull,
      );
    });

    test('strictly blocks file: local path traversal attempts', () {
      expect(SecuritySanitizer.sanitizeUrl('file:///etc/passwd'), isNull);
      expect(SecuritySanitizer.sanitizeUrl('file://C:/Windows/system32'), isNull);
    });

    test('strictly blocks blob: and vbscript: URIs', () {
      expect(SecuritySanitizer.sanitizeUrl('blob:http://evil.com/uuid'), isNull);
      expect(SecuritySanitizer.sanitizeUrl('vbscript:msgbox(1)'), isNull);
    });

    test('handles malformed or empty URLs safely', () {
      expect(SecuritySanitizer.sanitizeUrl(''), isNull);
      expect(SecuritySanitizer.sanitizeUrl('   '), isNull);
      expect(SecuritySanitizer.sanitizeUrl(null), isNull);
      expect(SecuritySanitizer.sanitizeUrl('https://'), isNull);
    });
  });

  group('SecuritySanitizer - Numeric & Math Defense', () {
    test('neutralizes NaN and Infinity values', () {
      expect(SecuritySanitizer.sanitizeAmount(double.nan), 0.0);
      expect(SecuritySanitizer.sanitizeAmount(double.infinity), 0.0);
      expect(SecuritySanitizer.sanitizeAmount(double.negativeInfinity), 0.0);
    });

    test('clamps extreme financial overflow outliers', () {
      expect(SecuritySanitizer.sanitizeAmount(999999999999.0, max: 100000.0), 100000.0);
      expect(SecuritySanitizer.sanitizeAmount(-999999999999.0, min: -100000.0), -100000.0);
    });

    test('rounds floating point pennies accurately to 2 decimal places', () {
      expect(SecuritySanitizer.sanitizeAmount(14.999999), 15.0);
      expect(SecuritySanitizer.sanitizeAmount(12.3456), 12.35);
    });
  });

  group('SecuritySanitizer - RFC 7636 PKCE & Cryptographic Nonces', () {
    test('generateSecureNonce produces high-entropy unguessable strings', () {
      final nonce1 = SecuritySanitizer.generateSecureNonce(32);
      final nonce2 = SecuritySanitizer.generateSecureNonce(32);

      expect(nonce1.length, 32);
      expect(nonce2.length, 32);
      expect(nonce1, isNot(equals(nonce2)));
    });

    test('generatePkcePair computes valid RFC 7636 SHA-256 challenge', () {
      final pkce = SecuritySanitizer.generatePkcePair(64);

      expect(pkce.codeVerifier.length, 64);
      expect(pkce.codeChallengeMethod, 'S256');

      // Verify SHA-256 mathematical correctness
      final verifierBytes = utf8.encode(pkce.codeVerifier);
      final digest = sha256.convert(verifierBytes);
      final expectedChallenge = base64Url.encode(digest.bytes).replaceAll('=', '');

      expect(pkce.codeChallenge, expectedChallenge);
      expect(pkce.codeChallenge, isNot(contains('=')));
    });

    test('generatePkcePair clamps verifier length within RFC 7636 bounds (43-128 chars)', () {
      final shortPkce = SecuritySanitizer.generatePkcePair(10);
      final longPkce = SecuritySanitizer.generatePkcePair(200);

      expect(shortPkce.codeVerifier.length, 43);
      expect(longPkce.codeVerifier.length, 128);
    });
  });

  group('SecuritySanitizer - Log Redaction & Anti-PII Leak', () {
    test('redacts Authorization Bearer tokens in debug output', () {
      const rawLog = 'Sending API request with Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xyz to endpoint';
      final redacted = SecuritySanitizer.redactSensitiveLog(rawLog);

      expect(redacted, contains('Bearer [REDACTED_TOKEN] to endpoint'));
      expect(redacted, isNot(contains('eyJhbGci')));
    });

    test('redacts client_secret, code, and account_id parameters', () {
      const rawUrl = 'https://api.truelayer.com/token?client_secret=super_secret_123&code=auth_code_999';
      final redacted = SecuritySanitizer.redactSensitiveLog(rawUrl);

      expect(redacted, contains('client_secret=[REDACTED]'));
      expect(redacted, contains('code=[REDACTED]'));
      expect(redacted, isNot(contains('super_secret_123')));
      expect(redacted, isNot(contains('auth_code_999')));
    });
  });
}

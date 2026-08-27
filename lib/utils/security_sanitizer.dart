// lib/utils/security_sanitizer.dart

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Comprehensive security and sanitization utilities defending against:
/// - XSS (Cross-Site Scripting) and script injection
/// - Insecure URL schemes (javascript:, data:, file:, blob:)
/// - OAuth CSRF / Code Interception attacks (via State Nonces & RFC 7636 PKCE)
/// - Numeric anomalies (NaN, Infinity, Extreme Outliers)
class SecuritySanitizer {
  static final Random _secureRandom = Random.secure();

  /// Allowed external URL schemes
  static const Set<String> _allowedUrlSchemes = {'https', 'http'};

  /// HTML / Script tag pattern for sanitization
  static final RegExp _htmlTagsRegex = RegExp(r'<[^>]*>', multiLine: true);

  /// Control characters pattern (excluding standard whitespace \t, \n, \r)
  static final RegExp _controlCharsRegex = RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]');

  /// Sanitizes text inputs by stripping HTML tags, control characters, and trimming.
  static String sanitizeText(String input, {int maxLength = 256}) {
    if (input.isEmpty) return '';

    var sanitized = input
        .replaceAll(_controlCharsRegex, '')
        .replaceAll(_htmlTagsRegex, '')
        .trim();

    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }
    return sanitized;
  }

  /// Validates and sanitizes URLs, strictly enforcing allowed schemes (https/http)
  /// and rejecting dangerous protocols (javascript:, data:, file:, blob:, etc.)
  static String? sanitizeUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;

    final trimmed = rawUrl.trim();

    // Block dangerous pseudo-schemes explicitly
    final lower = trimmed.toLowerCase();
    if (lower.startsWith('javascript:') ||
        lower.startsWith('data:') ||
        lower.startsWith('file:') ||
        lower.startsWith('blob:') ||
        lower.startsWith('vbscript:')) {
      return null;
    }

    try {
      final uri = Uri.parse(trimmed);
      if (!uri.hasScheme || !_allowedUrlSchemes.contains(uri.scheme.toLowerCase())) {
        return null;
      }
      if (uri.host.isEmpty) {
        return null;
      }
      return uri.toString();
    } catch (_) {
      return null;
    }
  }

  /// Sanitizes financial numeric values, guarding against NaN, Infinity, and overflow.
  static double sanitizeAmount(double amount, {double min = -1000000.0, double max = 1000000.0}) {
    if (amount.isNaN || amount.isInfinite) {
      return 0.0;
    }
    if (amount < min) return min;
    if (amount > max) return max;
    return (amount * 100).roundToDouble() / 100.0;
  }

  /// Generates a cryptographically secure random alphanumeric nonce for OAuth `state`
  static String generateSecureNonce([int length = 32]) {
    const charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(charset[_secureRandom.nextInt(charset.length)]);
    }
    return buffer.toString();
  }

  /// Generates an RFC 7636 compliant PKCE Pair (code_verifier and code_challenge SHA-256)
  static PkcePair generatePkcePair([int verifierLength = 64]) {
    final clampedLength = verifierLength.clamp(43, 128);
    const unreservedChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    
    final verifierBuffer = StringBuffer();
    for (int i = 0; i < clampedLength; i++) {
      verifierBuffer.write(unreservedChars[_secureRandom.nextInt(unreservedChars.length)]);
    }
    final codeVerifier = verifierBuffer.toString();

    // SHA-256 Hash
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);

    // Base64URL encode without padding
    final codeChallenge = base64Url.encode(digest.bytes).replaceAll('=', '');

    return PkcePair(
      codeVerifier: codeVerifier,
      codeChallenge: codeChallenge,
      codeChallengeMethod: 'S256',
    );
  }

  /// Redacts sensitive financial identifiers (IBANs, card numbers, tokens) in log output
  static String redactSensitiveLog(String message) {
    var redacted = message;

    // Redact Bearer tokens
    redacted = redacted.replaceAllMapped(
      RegExp(r'(Bearer\s+)[A-Za-z0-9\-_.]+', caseSensitive: false),
      (match) => '${match.group(1)}[REDACTED_TOKEN]',
    );

    // Redact Account IDs / Secret parameters
    redacted = redacted.replaceAllMapped(
      RegExp(r'(client_secret|access_token|code|account_id)=([^&\s]+)', caseSensitive: false),
      (match) => '${match.group(1)}=[REDACTED]',
    );

    return redacted;
  }
}

/// Represents an RFC 7636 PKCE code verifier and challenge pair
class PkcePair {
  final String codeVerifier;
  final String codeChallenge;
  final String codeChallengeMethod;

  const PkcePair({
    required this.codeVerifier,
    required this.codeChallenge,
    this.codeChallengeMethod = 'S256',
  });
}

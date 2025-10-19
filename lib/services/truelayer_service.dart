// lib/services/truelayer_service.dart

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import '../models/subscription_model.dart';
import '../models/truelayer_provider.dart';
import '../utils/logo_utils.dart';

class TruelayerService {
  final String clientId = dotenv.env['TRUELAYER_CLIENT_ID']!;
  final String clientSecret = dotenv.env['TRUELAYER_CLIENT_SECRET']!;
  final String redirectUri = 'http://localhost:3000/callback';

  final _secureStorage = const FlutterSecureStorage();
  static const _userAccessTokenKey = 'truelayer_user_access_token';

  // 🔥 Set to true when using LIVE credentials, false for SANDBOX
  static const bool _isProduction = true;

  final String _authBaseUrl = _isProduction
      ? 'https://auth.truelayer.com'
      : 'https://auth.truelayer-sandbox.com';

  final String _apiBaseUrl = _isProduction
      ? 'https://api.truelayer.com'
      : 'https://api.truelayer-sandbox.com';

  /// Generates the authentication URL for the user to log in.
  String getAuthenticationUrl(String countryCode, {String? providerId}) {
    final base = '$_authBaseUrl/';
    final params = {
      'response_type': 'code',
      'client_id': clientId,
      'scope': 'info accounts balance transactions direct_debits standing_orders offline_access',
      'redirect_uri': redirectUri,
    };

    if (providerId != null && providerId.isNotEmpty) {
      params['provider_id'] = providerId;
    } else {
      params['filters'] = '{"countries":["${countryCode.toUpperCase()}"]}';
    }

    return Uri.parse(base).replace(queryParameters: params).toString();
  }

  /// Fetches the list of all available bank providers from TrueLayer's public API.
  Future<List<TruelayerProvider>> getProviders(String countryCode) async {
    try {
      final response = await http.get(
        Uri.parse('$_authBaseUrl/api/providers'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> allProviders = json.decode(response.body);

        final filteredProviders = allProviders
            .where((p) {
          final providerCountry = (p['country_code'] ?? p['country'] ?? '').toString().toUpperCase();
          return providerCountry == countryCode.toUpperCase();
        })
            .map((p) => TruelayerProvider.fromJson(p))
            .toList();

        filteredProviders.sort((a, b) => a.name.compareTo(b.name));
        return filteredProviders;
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error fetching providers: $e");
      }
    }
    return [];
  }

  /// Exchanges the user's temporary auth code for a long-lived access token.
  Future<String?> exchangeCodeForAccessToken(String code) async {
    try {
      final response = await http.post(
        Uri.parse('$_authBaseUrl/connect/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'client_id': clientId,
          'client_secret': clientSecret,
          'redirect_uri': redirectUri,
          'code': code,
        },
      );
      if (response.statusCode == 200) {
        final accessToken = json.decode(response.body)['access_token'];
        await _secureStorage.write(key: _userAccessTokenKey, value: accessToken);
        return accessToken;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception during token exchange: $e");
      }
    }
    return null;
  }

  /// Fetches all subscriptions by checking direct debits, standing orders, and transaction history.
  Future<List<Subscription>> getSubscriptions() async {
    if (kDebugMode) {
      print("\n🔍 ===== STARTING SUBSCRIPTION DETECTION =====");
    }
    final accessToken = await _secureStorage.read(key: _userAccessTokenKey);
    if (accessToken == null) throw Exception('Not authenticated with TrueLayer');

    try {
      final accountsResponse = await http.get(
        Uri.parse('$_apiBaseUrl/data/v1/accounts'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (accountsResponse.statusCode == 200) {
        final accounts = json.decode(accountsResponse.body)['results'];
        if (kDebugMode) {
          print("📊 Found ${accounts.length} account(s)");
        }

        final List<Subscription> subscriptions = [];
        final Set<String> foundNames = {};

        for (var account in accounts) {
          final accountId = account['account_id'];
          final accountName = account['display_name'] ?? 'Unknown Account';
          if (kDebugMode) {
            print("\n💳 Processing account: $accountName ($accountId)");
          }

          // Check Direct Debits
          if (kDebugMode) {
            print("  🔹 Checking direct debits...");
          }
          final directDebits = await _fetchDirectDebits(accountId, accessToken);
          if (kDebugMode) {
            print("  ✅ Found ${directDebits.length} direct debit(s)");
          }
          for (var debit in directDebits) {
            final rawName = debit['name'] ?? 'Direct Debit';
            final cleanName = _getCleanNameFromDescription(rawName);
            if (kDebugMode) {
              print("    - Raw: '$rawName' → Clean: '$cleanName'");
            }
            if (foundNames.add(cleanName)) {
              final sub = _subscriptionFromDirectDebit(debit, cleanName);
              subscriptions.add(sub);
              if (kDebugMode) {
                print("      ✓ ADDED: ${sub.name} - ${sub.amount.abs()}€/${sub.cycle}");
              }
            } else {
              if (kDebugMode) {
                print("      ⊗ SKIPPED (duplicate name)");
              }
            }
          }

          // Check Standing Orders
          if (kDebugMode) {
            print("  🔹 Checking standing orders...");
          }
          final standingOrders = await _fetchStandingOrders(accountId, accessToken);
          if (kDebugMode) {
            print("  ✅ Found ${standingOrders.length} standing order(s)");
          }
          for (var order in standingOrders) {
            final rawRef = order['reference'] ?? 'Standing Order';
            final cleanName = _getCleanNameFromDescription(rawRef);
            if (kDebugMode) {
              print("    - Raw: '$rawRef' → Clean: '$cleanName'");
            }
            if (foundNames.add(cleanName)) {
              final sub = _subscriptionFromStandingOrder(order, cleanName);
              subscriptions.add(sub);
              if (kDebugMode) {
                print("      ✓ ADDED: ${sub.name} - ${sub.amount.abs()}€/${sub.cycle}");
              }
            } else {
              if (kDebugMode) {
                print("      ⊗ SKIPPED (duplicate name)");
              }
            }
          }

          // Analyze Transactions for recurring patterns
          if (kDebugMode) {
            print("  🔹 Analyzing transaction patterns (90 days)...");
          }
          final recurring = await _analyzeTransactions(accountId, accessToken);
          if (kDebugMode) {
            print("  ✅ Found ${recurring.length} recurring pattern(s)");
          }
          for (var sub in recurring) {
            if (foundNames.add(sub.name)) {
              subscriptions.add(sub);
              if (kDebugMode) {
                print("    ✓ ADDED: ${sub.name} - ${sub.amount.abs()}€/${sub.cycle}");
              }
            } else {
              if (kDebugMode) {
                print("    ⊗ SKIPPED (duplicate name): ${sub.name}");
              }
            }
          }
        }

        if (kDebugMode) {
          print("\n🎯 TOTAL SUBSCRIPTIONS DETECTED: ${subscriptions.length}");
          print("===== DETECTION COMPLETE =====\n");
        }
        return subscriptions;
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error fetching subscriptions: $e");
      }
    }
    return [];
  }

  // --- PRIVATE HELPER METHODS ---

  Future<List<dynamic>> _fetchDirectDebits(String accountId, String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/data/v1/accounts/$accountId/direct_debits'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (response.statusCode == 200) return json.decode(response.body)['results'] ?? [];
    } catch (e) { /* silent fail */ }
    return [];
  }

  Future<List<dynamic>> _fetchStandingOrders(String accountId, String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/data/v1/accounts/$accountId/standing_orders'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (response.statusCode == 200) return json.decode(response.body)['results'] ?? [];
    } catch (e) { /* silent fail */ }
    return [];
  }

  Future<List<Subscription>> _analyzeTransactions(String accountId, String accessToken) async {
    try {
      final toDate = DateTime.now();
      final fromDate = toDate.subtract(const Duration(days: 89));
      final dateFormat = DateFormat("yyyy-MM-dd");

      final uri = Uri.parse(
          '$_apiBaseUrl/data/v1/accounts/$accountId/transactions'
              '?from=${dateFormat.format(fromDate)}'
              '&to=${dateFormat.format(toDate)}'
      );

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final transactions = json.decode(response.body)['results'] ?? [];
        if (kDebugMode) {
          print("    📝 Analyzing ${transactions.length} transaction(s)");
        }
        return _findRecurringFromTransactions(transactions);
      }
    } catch (e) { /* silent fail */ }
    return [];
  }

  // ✅ UPDATED: Set start date to first occurrence in the 90-day window
  Subscription _subscriptionFromStandingOrder(Map<String, dynamic> order, String cleanName) {
    double amount = 0.0;
    if (order['next_payment_amount'] != null) {
      amount = double.tryParse(order['next_payment_amount'].toString()) ?? 0.0;
    }
    if (amount > 0) amount = -amount;

    String cycle = 'Monthly';
    if (order['frequency'] != null) {
      final freq = (order['frequency'] as String).toLowerCase();
      if (freq.contains('week')) {
        cycle = 'Weekly';
        // ignore: curly_braces_in_flow_control_structures
      } else if (freq.contains('year')) cycle = 'Yearly';
    }

    // ✅ Use next_payment_date as the startDate since standing orders have future dates
    final startDate = order['next_payment_date'] != null
        ? DateTime.parse(order['next_payment_date'])
        : DateTime.now();

    return Subscription(
      id: order['standing_order_id'] ?? DateTime.now().toString(),
      name: cleanName,
      amount: amount,
      startDate: startDate,
      cycle: cycle,
      logoUrl: fetchLogo(cleanName),
      category: 'Finance',
    );
  }

  // ✅ UPDATED: Set start date to the last payment date we know about
  Subscription _subscriptionFromDirectDebit(Map<String, dynamic> debit, String cleanName) {
    // Use previous payment date as the reference point
    final lastPaymentDate = debit['previous_payment_timestamp'] != null
        ? DateTime.parse(debit['previous_payment_timestamp'])
        : DateTime.now();

    // For direct debits, we estimate the next payment is ~30 days after the last one
    final nextPaymentDate = DateTime(
        lastPaymentDate.year,
        lastPaymentDate.month + 1,
        lastPaymentDate.day
    );

    return Subscription(
      id: debit['direct_debit_id'] ?? DateTime.now().toString(),
      name: cleanName,
      amount: -(double.tryParse(debit['previous_payment_amount'].toString()) ?? 0.0),
      startDate: nextPaymentDate,
      cycle: 'Monthly',
      logoUrl: fetchLogo(cleanName),
      category: 'Utilities',
    );
  }

  // ✅ NEW: Smart function to extract the real merchant name
  String _getCleanNameFromDescription(String description) {
    if (description.trim().isEmpty) return 'Subscription';

    final lower = description.toLowerCase().trim();

    // ✅ PRLV (prélevement) = subscription indicator - prioritize these!
    final isPrelevement = lower.startsWith('prlv');

    // ❌ Card payments ending with space + 4 digits (e.g., "CARTE 1234")
    final endsWithCardDigits = RegExp(r'\s\d{4}$').hasMatch(description);

    // ❌ Generic card payment keywords
    final isCardPayment = RegExp(
      r'(^cb\s|^carte\s|visa|mastercard|apple pay|google pay)',
      caseSensitive: false,
    ).hasMatch(lower);

    // If it's a card payment ending with digits, exclude it
    if (!isPrelevement && (endsWithCardDigits || isCardPayment)) {
      return 'Non-subscription payment';
    }

    // --- Known recurring subscription brands ---
    const knownBrands = {
      'netflix': 'Netflix',
      'spotify': 'Spotify',
      'deezer': 'Deezer',
      'youtube premium': 'YouTube Premium',
      'apple music': 'Apple Music',
      'apple.com/bill': 'Apple',
      'microsoft': 'Microsoft',
      'google': 'Google',
      'bouygues telecom': 'Bouygues Telecom',
      'orange': 'Orange',
      'sfr': 'SFR',
      'free mobile': 'Free Mobile',
      'red by sfr': 'RED by SFR',
      'canal+': 'Canal+',
      'canal plus': 'Canal+',
      'disney+': 'Disney+',
      'disney plus': 'Disney+',
      'amazon prime': 'Amazon Prime',
      'prime video': 'Prime Video',
      'totalenergies': 'TotalEnergies',
      'edf': 'EDF',
      'engie': 'Engie',
      'le monde': 'Le Monde',
      'mediapart': 'Mediapart',
      'nordvpn': 'NordVPN',
      'ovh': 'OVH',
      'bpce': 'BPCE',
      'cdc habitat': 'CDC Habitat',
    };

    for (var key in knownBrands.keys) {
      if (lower.contains(key)) {
        return knownBrands[key]!;
      }
    }

    // --- Exclude known one-off merchants or marketplaces ---
    const ignoreKeywords = [
      'carrefour', 'auchan', 'leclerc', 'intermarche', 'casino',
      'aldi', 'lidl', 'monoprix', 'temu', 'shein', 'vinted',
      'ubereats', 'deliveroo', 'just eat', 'amzn', 'amazon.fr',
      'amazon marketplace', 'paypal', 'lydia', 'revolut',
    ];

    if (ignoreKeywords.any((word) => lower.contains(word))) {
      return 'Non-subscription payment';
    }

    // --- Clean extraneous banking noise ---
    var cleaned = description;

    // Remove card digit patterns FIRST (before other cleaning)
    cleaned = cleaned.replaceAll(RegExp(r'\s\d{4}$'), '');

    // Remove banking keywords
    cleaned = cleaned.replaceAll(RegExp(
      r'PRLV SEPA|VIR INST|CARTE|CB\s|VIREMENT|ECHEANCE|PAIEMENT|PRELEVEMENT|ACHAT CB|RETRAIT|FACTURE',
      caseSensitive: false,
    ), '');

    // Remove long alphanumeric codes
    cleaned = cleaned.replaceAll(RegExp(r'\b[A-Z0-9]{6,}\b'), '');

    // Remove numeric sequences and dates
    cleaned = cleaned.replaceAll(RegExp(r'\d{2,}[\/-]\d{2,}[\/-]\d{2,}'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\d{5,}'), '');

    // Clean remaining symbols
    cleaned = cleaned.replaceAll(RegExp(r"[^A-Za-z0-9\s+\-']"), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Keep only first 2–3 tokens to avoid long garbage
    final tokens = cleaned.split(' ').where((t) => t.isNotEmpty).toList();
    if (tokens.length > 3) {
      cleaned = tokens.take(3).join(' ');
    } else {
      cleaned = tokens.join(' ');
    }

    // Capitalize for demo API
    cleaned = cleaned
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ')
        .trim();

    return cleaned.isEmpty ? 'Subscription' : cleaned;
  }

  // ✅ UPDATED: Set start date to first transaction date in 90-day window
  List<Subscription> _findRecurringFromTransactions(List<dynamic> transactions) {
    if (transactions.length < 2) return [];
    final potentialSubscriptions = <Subscription>[];

    final outgoing = transactions.where((t) => t['amount'] < 0).toList();
    if (kDebugMode) {
      print("      💸 Analyzing ${outgoing.length} outgoing transaction(s)");
    }

    // Group by the *cleaned* name now
    final groupedByMerchant = groupBy(
      outgoing,
          (t) => _getCleanNameFromDescription(t['description']),
    );

    groupedByMerchant.forEach((merchantName, trans) {
      // Skip if it's marked as non-subscription
      if (merchantName == 'Non-subscription payment') return;

      if (kDebugMode) {
        print("      🏪 Merchant: '$merchantName' (${trans.length} transaction(s))");
      }

      // ✅ Check if these are PRLV transactions - lower threshold
      final isPrelvTransactions = trans.any((t) =>
          (t['description'] as String).toLowerCase().startsWith('prlv')
      );

      // ✅ ADJUSTED: For PRLV, we only need 2 occurrences. For others, need 3+
      final minRequired = isPrelvTransactions ? 2 : 3;

      if (trans.length < minRequired) {
        if (kDebugMode) {
          print("        ⊗ Too few transactions (need at least $minRequired)");
        }
        return;
      }

      // Stricter rule for generic card payments (but PRLV bypasses this)
      if (!isPrelvTransactions && trans.length < 4 &&
          (trans.first['description'] as String).toLowerCase().contains('carte')) {
        if (kDebugMode) {
          print("        ⊗ Generic card payment with too few occurrences (need at least 4)");
        }
        return;
      }

      trans.sort((a, b) => DateTime.parse(a['timestamp']).compareTo(DateTime.parse(b['timestamp'])));

      final intervals = <int>[];
      for (int i = 0; i < trans.length - 1; i++) {
        final dateA = DateTime.parse(trans[i]['timestamp']);
        final dateB = DateTime.parse(trans[i + 1]['timestamp']);
        final interval = dateB.difference(dateA).inDays;
        intervals.add(interval);
        if (kDebugMode) {
          print("        📅 Interval ${i + 1}: $interval days");
        }
      }
      if (intervals.isEmpty) return;

      intervals.sort();
      final medianInterval = intervals[intervals.length ~/ 2];
      if (kDebugMode) {
        print("        📊 Median interval: $medianInterval days");
      }

      // ✅ More lenient for PRLV transactions
      final allowedDeviation = isPrelvTransactions ? 5 : 3;
      final consistentIntervals = intervals.where((i) => (i - medianInterval).abs() <= allowedDeviation).length;
      final confidence = consistentIntervals / intervals.length;
      if (kDebugMode) {
        print("        🎯 Consistency: ${(confidence * 100).toStringAsFixed(1)}% (PRLV: $isPrelvTransactions)");
      }

      // ✅ Lower threshold for PRLV
      final confidenceThreshold = isPrelvTransactions ? 0.5 : 0.6;

      if (confidence >= confidenceThreshold) {
        // ✅ FIXED: Match your Subscription model cycles
        String? cycle;
        if (medianInterval >= 5 && medianInterval <= 15) {
          cycle = 'Weekly';
        } else if (medianInterval >= 16 && medianInterval <= 60) {
          cycle = 'Monthly';
        } else if (medianInterval >= 61 && medianInterval <= 227) {
          cycle = 'Quarterly';
        } else if (medianInterval >= 228 && medianInterval <= 380) {
          cycle = 'Annually';
        }

        if (cycle != null) {
          if (kDebugMode) {
            print("        ✓ Detected cycle: $cycle");
          }

          final firstTrans = trans.first;
          final firstPaymentDate = DateTime.parse(firstTrans['timestamp']);

          final latestTrans = trans.last;
          final lastPaymentDate = DateTime.parse(latestTrans['timestamp']);

          DateTime nextPaymentDate;
          switch (cycle) {
            case 'Weekly':
              nextPaymentDate = lastPaymentDate.add(Duration(days: 7));
              break;
            case 'Monthly':
              nextPaymentDate = DateTime(lastPaymentDate.year, lastPaymentDate.month + 1, lastPaymentDate.day);
              break;
            case 'Quarterly':
              nextPaymentDate = DateTime(lastPaymentDate.year, lastPaymentDate.month + 3, lastPaymentDate.day);
              break;
            case 'Yearly':
              nextPaymentDate = DateTime(lastPaymentDate.year + 1, lastPaymentDate.month, lastPaymentDate.day);
              break;
            default: return;
          }

          final avgAmount = trans.map((t) => t['amount'] as double).average;
          if (kDebugMode) {
            print("        💰 Average amount: ${avgAmount.abs().toStringAsFixed(2)}€");
            print("        📅 First payment: ${DateFormat('dd/MM/yyyy').format(firstPaymentDate)}");
            print("        📅 Next payment: ${DateFormat('dd/MM/yyyy').format(nextPaymentDate)}");
          }

          potentialSubscriptions.add(Subscription(
            id: latestTrans['transaction_id'] ?? DateTime.now().toString(),
            name: merchantName,
            amount: avgAmount,
            startDate: firstPaymentDate,
            cycle: cycle,
            logoUrl: fetchLogo(merchantName),
            category: 'General',
          ));
        } else {
          if (kDebugMode) {
            print("        ⊗ Interval doesn't match known cycles (median: $medianInterval days)");
          }
        }
      } else {
        if (kDebugMode) {
          print("        ⊗ Consistency too low (need >${(confidenceThreshold * 100).toStringAsFixed(0)}%)");
        }
      }
    });

    return potentialSubscriptions;
  }

  // Add these methods to your truelayer_service.dart file
// Place them at the end of the TruelayerService class

  /// Returns the stored access token (used by debug page)
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _userAccessTokenKey);
  }

  /// Fetches all accounts for debugging purposes
  Future<List<dynamic>> fetchAccounts(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/data/v1/accounts'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body)['results'] ?? [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching accounts: $e");
      }
    }
    return [];
  }

  /// Exposes direct debits fetching for debugging
  Future<List<dynamic>> fetchDirectDebitsRaw(String accountId, String accessToken) async {
    return await _fetchDirectDebits(accountId, accessToken);
  }

  /// Exposes standing orders fetching for debugging
  Future<List<dynamic>> fetchStandingOrdersRaw(String accountId, String accessToken) async {
    return await _fetchStandingOrders(accountId, accessToken);
  }

  /// Exposes transaction fetching for debugging
  Future<List<dynamic>> fetchTransactionsRaw(String accountId, String accessToken) async {
    try {
      final toDate = DateTime.now();
      final fromDate = toDate.subtract(const Duration(days: 89));
      final dateFormat = DateFormat("yyyy-MM-dd");

      final uri = Uri.parse(
          '$_apiBaseUrl/data/v1/accounts/$accountId/transactions'
              '?from=${dateFormat.format(fromDate)}'
              '&to=${dateFormat.format(toDate)}'
      );

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)['results'] ?? [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching transactions: $e");
      }
    }
    return [];
  }

  /// Fetches transactions for a custom date range (useful for testing limits)
  Future<List<dynamic>> fetchTransactionsForDateRange(
      String accountId,
      String accessToken,
      DateTime from,
      DateTime to,
      ) async {
    try {
      final dateFormat = DateFormat("yyyy-MM-dd");
      final uri = Uri.parse(
          '$_apiBaseUrl/data/v1/accounts/$accountId/transactions'
              '?from=${dateFormat.format(from)}'
              '&to=${dateFormat.format(to)}'
      );

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)['results'] ?? [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching transactions for date range: $e");
      }
    }
    return [];
  }
}
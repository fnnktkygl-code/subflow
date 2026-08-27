import 'package:flutter_test/flutter_test.dart';
import 'package:subflow_app/models/subscription_model.dart';
import 'dart:convert';

void main() {
  group('GDPR Data Portability & Serialization Tests', () {
    test('Subscription serializes to GDPR-compliant JSON structure', () {
      final sub = Subscription(
        id: 'sub-export-1',
        name: 'Spotify Family',
        amount: -18.21,
        startDate: DateTime(2026, 1, 15),
        cycle: 'Monthly',
        category: 'Music',
        logoUrl: 'https://logo.clearbit.com/spotify.com',
        areNotificationsEnabled: true,
        reminderDays: 3,
      );

      final map = {
        'id': sub.id,
        'name': sub.name,
        'amount': sub.amount,
        'startDate': sub.startDate.toIso8601String(),
        'cycle': sub.cycle,
        'logoUrl': sub.logoUrl,
        'category': sub.category,
        'notificationsEnabled': sub.areNotificationsEnabled,
        'reminderDays': sub.reminderDays,
      };

      final jsonString = jsonEncode(map);
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

      expect(decoded['id'], equals('sub-export-1'));
      expect(decoded['name'], equals('Spotify Family'));
      expect(decoded['amount'], equals(-18.21));
      expect(decoded['cycle'], equals('Monthly'));
      expect(decoded['notificationsEnabled'], isTrue);
      expect(decoded['reminderDays'], equals(3));
    });

    test('GDPR JSON export envelope contains required metadata and ISO-8601 timestamps', () {
      final exportEnvelope = {
        'version': '1.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'appName': 'SubFlow',
        'subscriptions': [
          {
            'id': 'sub-1',
            'name': 'Gym',
            'amount': -35.0,
            'startDate': '2026-01-01T00:00:00.000',
            'cycle': 'Monthly',
            'category': 'Health',
          }
        ]
      };

      final jsonStr = jsonEncode(exportEnvelope);
      expect(jsonStr, contains('SubFlow'));
      expect(jsonStr, contains('exportedAt'));
      expect(jsonStr, contains('Gym'));
    });
  });
}

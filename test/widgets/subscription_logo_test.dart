import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subflow_app/widgets/shared/subscription_logo.dart';
import 'package:subflow_app/models/subscription_model.dart';

void main() {
  testWidgets('SubscriptionLogo renders fallback avatar with name initial and gradient', (WidgetTester tester) async {
    final sub = Subscription(
      id: 'sub-netflix',
      name: 'Netflix',
      amount: -15.0,
      startDate: DateTime(2026, 1, 1),
      cycle: 'Monthly',
      category: 'Entertainment',
      logoUrl: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubscriptionLogo(
            subscription: sub,
            size: 52,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initial "N" rendered gracefully as fallback
    expect(find.text('N'), findsOneWidget);
  });

  testWidgets('SubscriptionLogo handles empty name without crashing', (WidgetTester tester) async {
    final sub = Subscription(
      id: 'sub-unknown',
      name: '',
      amount: -10.0,
      startDate: DateTime(2026, 1, 1),
      cycle: 'Monthly',
      category: 'Other',
      logoUrl: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubscriptionLogo(
            subscription: sub,
            size: 40,
          ),
        ),
      ),
    );

    expect(find.text('?'), findsOneWidget);
  });
}

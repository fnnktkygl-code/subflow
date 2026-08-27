import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subflow_app/models/subscription_model.dart';
import 'package:subflow_app/widgets/subscription_card.dart';

void main() {
  testWidgets('SubscriptionCard displays name and amount formatted', (WidgetTester tester) async {
    final sub = Subscription(
      id: 'sub-1',
      name: 'Netflix Premium',
      amount: -17.99,
      startDate: DateTime(2026, 1, 1),
      cycle: 'Monthly',
      category: 'Entertainment',
      logoUrl: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SubscriptionCard(
            subscription: sub,
            displayDate: DateTime(2026, 1, 1),
            isAmountBlurred: false,
          ),
        ),
      ),
    );

    expect(find.text('Netflix Premium'), findsOneWidget);
    expect(find.text('-17.99 €'), findsOneWidget);
    expect(find.text('MONTHLY'), findsOneWidget);
  });
}

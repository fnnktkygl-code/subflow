import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subflow_app/widgets/home/income_health_card.dart';
import 'package:subflow_app/provider/user_profile_provider.dart';

void main() {
  testWidgets('IncomeHealthCard displays health title, message, and status icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: IncomeHealthCard(
            title: 'Great Job!',
            message: "You're only spending 5.0% of your income on subscriptions.",
            status: IncomeHealthStatus.healthy,
          ),
        ),
      ),
    );

    expect(find.text('Great Job!'), findsOneWidget);
    expect(find.textContaining('5.0% of your income'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('IncomeHealthCard displays warning status styling', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: IncomeHealthCard(
            title: 'Attention Needed',
            message: "Subscriptions are taking 12.5% of your income.",
            status: IncomeHealthStatus.warning,
          ),
        ),
      ),
    );

    expect(find.text('Attention Needed'), findsOneWidget);
    expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subflow_app/widgets/home/spending_card.dart';
import 'package:subflow_app/provider/user_profile_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SpendingCard renders monthly and yearly totals with buffer gauge', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final userProfile = UserProfileProvider();

    bool editGoalTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SpendingCard(
            monthlyCost: 45.0,
            goal: 100.0,
            monthlyIncome: 2000.0,
            onEditGoal: () {
              editGoalTapped = true;
            },
            onEditIncome: () {},
            profileProvider: userProfile,
          ),
        ),
      ),
    );

    expect(find.text('Monthly Spending'), findsOneWidget);
    expect(find.textContaining('year'), findsOneWidget);
    expect(find.textContaining('buffer remaining'), findsOneWidget);
    expect(find.text('Target: €100/mo'), findsOneWidget);

    await tester.tap(find.textContaining('buffer remaining'));
    expect(editGoalTapped, isTrue);
  });

  testWidgets('SpendingCard renders over target status when cost exceeds goal', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final userProfile = UserProfileProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SpendingCard(
            monthlyCost: 120.0,
            goal: 100.0,
            monthlyIncome: 2000.0,
            onEditGoal: () {},
            onEditIncome: () {},
            profileProvider: userProfile,
          ),
        ),
      ),
    );

    expect(find.textContaining('over target'), findsOneWidget);
  });

  testWidgets('SpendingCard renders prompt when no goal is set', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final userProfile = UserProfileProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SpendingCard(
            monthlyCost: 45.0,
            goal: null,
            monthlyIncome: null,
            onEditGoal: () {},
            onEditIncome: () {},
            profileProvider: userProfile,
          ),
        ),
      ),
    );

    expect(find.text('Set a monthly spend target'), findsOneWidget);
  });
}

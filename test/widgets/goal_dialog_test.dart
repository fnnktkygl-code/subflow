import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subflow_app/widgets/shared/goal_dialog.dart';
import 'package:subflow_app/provider/user_profile_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GoalDialog opens with presets and allows setting target', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final userProfile = UserProfileProvider();

    double? savedGoal;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                GoalDialog.show(
                  context,
                  currentGoal: 50.0,
                  currentCost: 40.0,
                  monthlyIncome: null,
                  profileProvider: userProfile,
                  onGoalSet: (goal) {
                    savedGoal = goal;
                  },
                );
              },
              child: const Text('Open Target Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Target Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Monthly Spend Target'), findsOneWidget);
    expect(find.text('Set Target'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    expect(find.byType(ActionChip), findsWidgets);

    // Tap a preset chip
    await tester.tap(find.byType(ActionChip).first);
    await tester.pumpAndSettle();

    // Tap Set Target
    await tester.tap(find.text('Set Target'));
    await tester.pumpAndSettle();

    expect(savedGoal, isNotNull);
  });
}

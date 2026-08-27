import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subflow_app/pages/onboarding_page.dart';
import 'package:subflow_app/provider/user_profile_provider.dart';
import 'package:subflow_app/widgets/shared/japandi_svg_icons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OnboardingPage renders 1-screen Japandi layout with value pillars and Get Started', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final userProfile = UserProfileProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<UserProfileProvider>.value(
        value: userProfile,
        child: const MaterialApp(
          home: OnboardingPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Assert headline & brand
    expect(find.text('SUBFLOW'), findsOneWidget);
    expect(find.textContaining('Mindful Spending'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // Assert 3 value pillars
    expect(find.text('Frictionless Entry'), findsOneWidget);
    expect(find.text('What-If Simulation'), findsOneWidget);
    expect(find.text('100% Private & Local'), findsOneWidget);
    expect(find.byType(JapandiSvgIcon), findsWidgets);

    // Tap Get Started -> Completes onboarding
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(userProfile.hasCompletedOnboarding, isTrue);
  });

  testWidgets('OnboardingPage Skip button immediately marks onboarding complete', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final userProfile = UserProfileProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<UserProfileProvider>.value(
        value: userProfile,
        child: const MaterialApp(
          home: OnboardingPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Skip
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(userProfile.hasCompletedOnboarding, isTrue);
  });
}

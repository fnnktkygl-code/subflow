import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subflow_app/pages/settings_page.dart';
import 'package:subflow_app/provider/simplified_subscription_provider.dart';
import 'package:subflow_app/provider/user_profile_provider.dart';
import 'package:subflow_app/core/domain/repositories/subscription_repository.dart';
import 'package:subflow_app/core/error/failures.dart';
import 'package:subflow_app/core/error/result.dart';
import 'package:subflow_app/models/subscription_model.dart';

class MockSubscriptionRepository implements SubscriptionRepository {
  @override
  Future<Result<List<Subscription>, StorageFailure>> getSubscriptions() async => const Result.success([]);
  @override
  Future<Result<void, StorageFailure>> saveSubscription(Subscription subscription) async => const Result.success(null);
  @override
  Future<Result<void, StorageFailure>> updateSubscription(Subscription subscription) async => const Result.success(null);
  @override
  Future<Result<void, StorageFailure>> deleteSubscription(String id) async => const Result.success(null);
  @override
  Future<Result<String, StorageFailure>> exportDataAsJson() async => const Result.success('{"subscriptions":[]}');
  @override
  Future<Result<void, StorageFailure>> clearAllData() async => const Result.success(null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SettingsPage renders GDPR actions and opens Privacy dialog', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final userProfile = UserProfileProvider();
    final subProvider = SimplifiedSubscriptionProvider(repository: MockSubscriptionRepository());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProfileProvider>.value(value: userProfile),
          ChangeNotifierProvider<SimplifiedSubscriptionProvider>.value(value: subProvider),
        ],
        child: MaterialApp(
          home: Settings(
            onChangeAccentColor: (_) {},
            onResetAccentColor: () {},
          ),
        ),
      ),
    );

    expect(find.text('Bank Connection'), findsOneWidget);
    expect(find.text('Export My Data (JSON)'), findsOneWidget);
    expect(find.text('Privacy Policy & Security'), findsOneWidget);

    // Tap Privacy Policy tile
    await tester.tap(find.text('Privacy Policy & Security'));
    await tester.pumpAndSettle();

    expect(find.text('Privacy & Security'), findsOneWidget);
    expect(find.textContaining('Local-First Architecture'), findsOneWidget);
    expect(find.textContaining('GDPR Data Rights'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
  });

  testWidgets('SettingsPage renders Developer Tools section in debug mode', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final userProfile = UserProfileProvider();
    final subProvider = SimplifiedSubscriptionProvider(repository: MockSubscriptionRepository());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProfileProvider>.value(value: userProfile),
          ChangeNotifierProvider<SimplifiedSubscriptionProvider>.value(value: subProvider),
        ],
        child: MaterialApp(
          home: Settings(
            onChangeAccentColor: (_) {},
            onResetAccentColor: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Scroll down to reveal Developer Tools
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('DEVELOPER TOOLS'), findsOneWidget);
    expect(find.text('TrueLayer API Debug'), findsOneWidget);
    expect(find.text('Test Greeting Messages'), findsOneWidget);
  });

  testWidgets('SettingsPage allows opening Country & Region dialog and updating active country', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final userProfile = UserProfileProvider();
    final subProvider = SimplifiedSubscriptionProvider(repository: MockSubscriptionRepository());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProfileProvider>.value(value: userProfile),
          ChangeNotifierProvider<SimplifiedSubscriptionProvider>.value(value: subProvider),
        ],
        child: MaterialApp(
          home: Settings(
            onChangeAccentColor: (_) {},
            onResetAccentColor: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Country & Presets'), findsOneWidget);

    // Tap Country & Presets tile
    await tester.tap(find.text('Country & Presets'));
    await tester.pumpAndSettle();

    // Verify dialog opens
    expect(find.text('Select Country & Region'), findsOneWidget);
    expect(find.text('United Kingdom'), findsOneWidget);
    expect(find.text('United States'), findsOneWidget);

    // Tap United Kingdom
    await tester.tap(find.text('United Kingdom'));
    await tester.pumpAndSettle();

    // Verify updated country code
    expect(userProfile.effectiveCountryCode, equals('GB'));
  });
}

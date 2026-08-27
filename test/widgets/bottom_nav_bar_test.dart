import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subflow_app/widgets/bottom_nav_bar.dart';
import 'package:subflow_app/provider/simplified_subscription_provider.dart';
import 'package:subflow_app/provider/simplified_gamification.dart';
import 'package:subflow_app/provider/user_profile_provider.dart';
import 'package:subflow_app/core/domain/repositories/subscription_repository.dart';
import 'package:subflow_app/core/error/failures.dart';
import 'package:subflow_app/core/error/result.dart';
import 'package:subflow_app/models/subscription_model.dart';
import 'package:subflow_app/widgets/shared/japandi_svg_icons.dart';

class NavMockSubscriptionRepository implements SubscriptionRepository {
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

  testWidgets('BottomNavBar renders all 4 tabs and accessible semantics with JapandiSvgIcon', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final userProfile = UserProfileProvider();
    final subProvider = SimplifiedSubscriptionProvider(repository: NavMockSubscriptionRepository());
    final gamification = SimplifiedGamification();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProfileProvider>.value(value: userProfile),
          ChangeNotifierProvider<SimplifiedSubscriptionProvider>.value(value: subProvider),
          ChangeNotifierProvider<SimplifiedGamification>.value(value: gamification),
        ],
        child: MaterialApp(
          home: BottomNavBar(
            key: bottomNavBarKey,
            onToggleTheme: () {},
            onChangeAccentColor: (_) {},
            onResetAccentColor: () {},
            currentThemeIndex: 0,
          ),
        ),
      ),
    );
    await tester.pump();

    // Verify navigation item labels and Japandi SVG icons
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Schedule'), findsWidgets);
    expect(find.text('Subs'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
    expect(find.byType(JapandiSvgIcon), findsWidgets);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Switch tab programmatically
    bottomNavBarKey.currentState?.onNavItemTapped(3);
    await tester.pump(const Duration(milliseconds: 300));
  });
}

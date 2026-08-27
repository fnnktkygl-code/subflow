import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:subflow_app/widgets/home/category_chart.dart';
import 'package:subflow_app/provider/simplified_subscription_provider.dart';
import 'package:subflow_app/core/domain/repositories/subscription_repository.dart';
import 'package:subflow_app/core/error/failures.dart';
import 'package:subflow_app/core/error/result.dart';
import 'package:subflow_app/models/subscription_model.dart';
import 'package:subflow_app/utils/home_helpers.dart';

class MockSubscriptionRepository implements SubscriptionRepository {
  final List<Subscription> initialSubs;
  MockSubscriptionRepository([this.initialSubs = const []]);

  @override
  Future<Result<List<Subscription>, StorageFailure>> getSubscriptions() async => Result.success(initialSubs);
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
  testWidgets('CategoryChart renders spending breakdown with category icon badges and legend', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final testSub = Subscription(
      id: 'sub_rent',
      name: 'Apartment Rent',
      amount: -50.0,
      category: 'Home',
      cycle: 'monthly',
      logoUrl: '',
      startDate: DateTime(2026, 1, 1),
    );

    final subProvider = SimplifiedSubscriptionProvider(
      repository: MockSubscriptionRepository([testSub]),
    );
    await subProvider.init();

    final spending = {
      'Home': 50.0,
      'Utilities': 30.0,
      'Shopping': 20.0,
    };

    await tester.pumpWidget(
      ChangeNotifierProvider<SimplifiedSubscriptionProvider>.value(
        value: subProvider,
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CategoryChart(
                spending: spending,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));

    // Verify category names and values in legend
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Utilities'), findsOneWidget);
    expect(find.text('Shopping'), findsOneWidget);

    // Verify category icons exist in the legend
    expect(find.byIcon(HomeHelpers.getCategoryIcon('Home')), findsOneWidget);
    expect(find.byIcon(HomeHelpers.getCategoryIcon('Utilities')), findsOneWidget);
    expect(find.byIcon(HomeHelpers.getCategoryIcon('Shopping')), findsOneWidget);

    // Tap Home in the legend to open category bottom sheet
    await tester.tap(find.text('Home'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify Apartment Rent subscription is displayed
    expect(find.text('Apartment Rent'), findsAtLeastNWidgets(1));
    expect(find.text('1 subscription'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subflow_app/views/modern_calendar_view.dart';
import 'package:subflow_app/provider/simplified_subscription_provider.dart';
import 'package:subflow_app/provider/simplified_gamification.dart';
import 'package:subflow_app/provider/user_profile_provider.dart';
import 'package:subflow_app/core/domain/repositories/subscription_repository.dart';
import 'package:subflow_app/core/error/failures.dart';
import 'package:subflow_app/core/error/result.dart';
import 'package:subflow_app/models/subscription_model.dart';
import 'package:subflow_app/theme/theme.dart';

class CalendarMockRepo implements SubscriptionRepository {
  final List<Subscription> subs;
  CalendarMockRepo(this.subs);

  @override
  Future<Result<List<Subscription>, StorageFailure>> getSubscriptions() async => Result.success(subs);
  @override
  Future<Result<void, StorageFailure>> saveSubscription(Subscription s) async => const Result.success(null);
  @override
  Future<Result<void, StorageFailure>> updateSubscription(Subscription s) async => const Result.success(null);
  @override
  Future<Result<void, StorageFailure>> deleteSubscription(String id) async => const Result.success(null);
  @override
  Future<Result<String, StorageFailure>> exportDataAsJson() async => const Result.success('{}');
  @override
  Future<Result<void, StorageFailure>> clearAllData() async => const Result.success(null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockSubs = [
    Subscription(
      id: 'sub-1',
      name: 'Netflix',
      amount: -15.99,
      cycle: 'Monthly',
      startDate: DateTime(2026, 8, 15),
      category: 'Entertainment',
      logoUrl: 'https://img.logo.dev/netflix.com?token=pk_test',
    ),
    Subscription(
      id: 'sub-2',
      name: 'Salary',
      amount: 3200.0,
      cycle: 'Monthly',
      startDate: DateTime(2026, 8, 28),
      category: 'Income',
      logoUrl: '',
    ),
  ];

  Widget buildCalendarApp(Size surfaceSize, {SimplifiedSubscriptionProvider? customProvider}) {
    final userProfile = UserProfileProvider();
    final subProvider = customProvider ?? SimplifiedSubscriptionProvider(repository: CalendarMockRepo(mockSubs));
    final gamification = SimplifiedGamification();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProfileProvider>.value(value: userProfile),
        ChangeNotifierProvider<SimplifiedSubscriptionProvider>.value(value: subProvider),
        ChangeNotifierProvider<SimplifiedGamification>.value(value: gamification),
      ],
      child: MaterialApp(
        theme: lightThemeData,
        darkTheme: darkThemeData,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ModernCalendarView(
              onEdit: (_) {},
              onDelete: (_) async => true,
              isSelectionMode: false,
              isSubscriptionSnoozed: (_) => false,
              onLongPress: (_) {},
              onTap: (_) {},
              onSnoozeChanged: (_) {},
              snoozedIds: const {},
            ),
          ),
        ),
      ),
    );
  }

  group('ModernCalendarView Responsive Layout & Interaction Tests', () {
    testWidgets('Renders cleanly on Smartphone viewport (412x915) without overflow', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildCalendarApp(const Size(412, 915)));
      await tester.pumpAndSettle();

      // Verify month selector and weekday headers are visible
      expect(find.byType(ModernCalendarView), findsOneWidget);
      expect(find.text('CASH FLOW THIS MONTH'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('Renders side-by-side Dual-Pane on Desktop viewport (1280x800)', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildCalendarApp(const Size(1280, 800)));
      await tester.pumpAndSettle();

      // Verify desktop layout presence
      expect(find.byType(ModernCalendarView), findsOneWidget);
      expect(find.text('CASH FLOW THIS MONTH'), findsOneWidget);

      // Verify month navigation works on desktop
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();
    });

    testWidgets('Renders without issues on Laptop viewport (1024x768)', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildCalendarApp(const Size(1024, 768)));
      await tester.pumpAndSettle();

      expect(find.byType(ModernCalendarView), findsOneWidget);
      expect(find.text('CASH FLOW THIS MONTH'), findsOneWidget);
    });

    testWidgets('Tapping cash flow privacy eye toggles amount blur', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildCalendarApp(const Size(412, 915)));
      await tester.pumpAndSettle();

      final visibilityIconFinder = find.byIcon(Icons.visibility_rounded);
      expect(visibilityIconFinder, findsOneWidget);

      await tester.tap(visibilityIconFinder);
      await tester.pumpAndSettle();

      // Now hidden icon should be visible
      expect(find.byIcon(Icons.visibility_off_rounded), findsOneWidget);
    });

    testWidgets('Renders 7-day forecast ribbon when upcoming renewals exist', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final now = DateTime.now();
      final subs = [
        Subscription(
          id: 'sub-upcoming',
          name: 'Spotify',
          amount: -9.99,
          cycle: 'Monthly',
          startDate: now.add(const Duration(days: 3)),
          category: 'Entertainment',
          logoUrl: '',
        ),
      ];

      final customProvider = SimplifiedSubscriptionProvider(repository: CalendarMockRepo(subs));
      await customProvider.init();

      await tester.pumpWidget(buildCalendarApp(const Size(412, 915), customProvider: customProvider));
      await tester.pumpAndSettle();

      expect(find.textContaining('Next 7 Days'), findsOneWidget);
      expect(find.text('€9.99'), findsOneWidget);
    });
  });
}

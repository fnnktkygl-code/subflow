import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:subflow_app/mixins/selection_mode_mixin.dart';
import 'package:subflow_app/provider/simplified_subscription_provider.dart';
import 'package:subflow_app/core/domain/repositories/subscription_repository.dart';
import 'package:subflow_app/core/error/failures.dart';
import 'package:subflow_app/core/error/result.dart';
import 'package:subflow_app/models/subscription_model.dart';
import 'package:subflow_app/widgets/shared/subscription_card_wrapper.dart';

class MockSubscriptionRepository implements SubscriptionRepository {
  final List<Subscription> subs = [];
  @override
  Future<Result<List<Subscription>, StorageFailure>> getSubscriptions() async => Result.success(subs);
  @override
  Future<Result<void, StorageFailure>> saveSubscription(Subscription subscription) async {
    subs.add(subscription);
    return const Result.success(null);
  }
  @override
  Future<Result<void, StorageFailure>> updateSubscription(Subscription subscription) async => const Result.success(null);
  @override
  Future<Result<void, StorageFailure>> deleteSubscription(String id) async => const Result.success(null);
  @override
  Future<Result<String, StorageFailure>> exportDataAsJson() async => const Result.success('{"subscriptions":[]}');
  @override
  Future<Result<void, StorageFailure>> clearAllData() async => const Result.success(null);
}

class _TestSelectionWidget extends StatefulWidget {
  const _TestSelectionWidget();

  @override
  State<_TestSelectionWidget> createState() => _TestSelectionWidgetState();
}

class _TestSelectionWidgetState extends State<_TestSelectionWidget> with SelectionModeMixin {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SimplifiedSubscriptionProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            children: provider.subscriptions.map<Widget>((sub) {
              return SubscriptionCardWrapper(
                subscription: sub,
                displayDate: DateTime(2026, 8, 27),
                onEdit: (_) {},
                onDelete: (_) async => true,
                isSelectionMode: isSelectionMode,
                isSnoozed: isSubscriptionSnoozed(sub.id),
                onSnoozeChanged: (snoozed) => toggleSnooze(sub.id),
                onLongPress: () => enterSelectionMode(sub.id),
              );
            }).toList(),
          ),
          if (isSelectionMode)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: buildWhatIfActionBar(
                provider: provider,
                colorScheme: colorScheme,
              ),
            ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('Entering What-If mode has NO intrusive tutorial popup and immediately shows action bar', (WidgetTester tester) async {
    final mockRepo = MockSubscriptionRepository();
    final provider = SimplifiedSubscriptionProvider(repository: mockRepo);
    await provider.addSubscription(
      Subscription(
        id: 'sub-1',
        name: 'Netflix',
        amount: -17.99,
        startDate: DateTime(2026, 8, 1),
        cycle: 'monthly',
        logoUrl: '',
        category: 'Entertainment',
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<SimplifiedSubscriptionProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: _TestSelectionWidget(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify initial card is rendered
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('What If Mode'), findsNothing);

    // Long press subscription card to trigger What-If mode
    await tester.longPress(find.text('Netflix'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify NO tutorial dialog / popup appears
    expect(find.text('Got it!'), findsNothing);
    expect(find.text('Tap any subscription to exclude it'), findsNothing);

    // Verify What-If Mode action bar is immediately visible
    expect(find.text('What If Mode'), findsOneWidget);
    expect(find.textContaining('saved'), findsAtLeastNWidgets(1));

    // Tap expand details
    await tester.tap(find.byTooltip('Expand details'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('MONTHLY SAVINGS'), findsOneWidget);
    expect(find.text('YEARLY SAVINGS'), findsOneWidget);

    // Toggle snooze on card
    await tester.tap(find.text('Netflix'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Exit What-If Mode
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('What If Mode'), findsNothing);
  });
}

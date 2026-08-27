import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subflow_app/widgets/subscription_popup.dart';
import 'package:subflow_app/provider/user_profile_provider.dart';
import 'package:subflow_app/models/subscription_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('showAddSubscriptionPopup renders single-view form with French presets and Euro pricing when FR is selected', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'country_code': 'FR'});
    final userProfile = UserProfileProvider();
    await userProfile.setCountryCode('FR');
    Subscription? addedSub;

    await tester.pumpWidget(
      ChangeNotifierProvider<UserProfileProvider>.value(
        value: userProfile,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAddSubscriptionPopup(
                  context,
                  (sub) {
                    addedSub = sub;
                  },
                ),
                child: const Text('Open Popup'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open Dialog
    await tester.tap(find.text('Open Popup'));
    await tester.pumpAndSettle();

    // Verify 1-View layout elements
    expect(find.text('New Subscription'), findsOneWidget);
    expect(find.text('Save Subscription'), findsOneWidget);
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('€13.49'), findsOneWidget);
    expect(find.text('Spotify'), findsOneWidget);
    expect(find.text('Canal+'), findsOneWidget);

    // Tap Netflix preset chip
    await tester.tap(find.byKey(const Key('preset_Netflix')));
    await tester.pumpAndSettle();

    // Verify form auto-populated with French price
    expect(find.text('Netflix'), findsWidgets);
    expect(find.text('13.49'), findsOneWidget);

    // Tap Save Subscription
    await tester.tap(find.text('Save Subscription'));
    await tester.pumpAndSettle();

    expect(addedSub, isNotNull);
    expect(addedSub!.name, 'Netflix');
    expect(addedSub!.amount, -13.49);
  });

  testWidgets('showAddSubscriptionPopup dynamically renders UK sterling presets when region is GB', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'country_code': 'GB'});
    final userProfile = UserProfileProvider();
    await userProfile.setCountryCode('GB');
    Subscription? addedSub;

    await tester.pumpWidget(
      ChangeNotifierProvider<UserProfileProvider>.value(
        value: userProfile,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAddSubscriptionPopup(
                  context,
                  (sub) {
                    addedSub = sub;
                  },
                ),
                child: const Text('Open Popup'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open Dialog
    await tester.tap(find.text('Open Popup'));
    await tester.pumpAndSettle();

    // Verify UK presets and sterling currency
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('£10.99'), findsOneWidget);
    expect(find.text('Disney+'), findsOneWidget);

    // Tap Netflix preset chip
    await tester.tap(find.byKey(const Key('preset_Netflix')));
    await tester.pumpAndSettle();

    // Verify form auto-populated with UK price
    expect(find.text('10.99'), findsOneWidget);

    // Tap Save Subscription
    await tester.tap(find.text('Save Subscription'));
    await tester.pumpAndSettle();

    expect(addedSub, isNotNull);
    expect(addedSub!.name, 'Netflix');
    expect(addedSub!.amount, -10.99);
  });

  testWidgets('Category Picker tile opens bespoke Japandi modal sheet and updates selection', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final userProfile = UserProfileProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<UserProfileProvider>.value(
        value: userProfile,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAddSubscriptionPopup(
                  context,
                  (_) {},
                ),
                child: const Text('Open Popup'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open Dialog
    await tester.tap(find.text('Open Popup'));
    await tester.pumpAndSettle();

    // Tap Category picker tile
    await tester.tap(find.byKey(const Key('category_picker_tile')));
    await tester.pumpAndSettle();

    // Verify popup menu options appear
    expect(find.text('Utilities'), findsOneWidget);
    expect(find.text('Health & Fitness'), findsOneWidget);

    // Tap Utilities option
    await tester.tap(find.byKey(const Key('cat_option_Utilities')));
    await tester.pumpAndSettle();

    // Verify Category tile now displays Utilities
    expect(find.text('Utilities'), findsOneWidget);
  });
}

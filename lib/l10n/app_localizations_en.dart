// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SubFlow';

  @override
  String get homeNav => 'Home';

  @override
  String get scheduleNav => 'Schedule';

  @override
  String get subscriptionsNav => 'Subs';

  @override
  String get settingsNav => 'Settings';

  @override
  String get welcomeTitle => 'Welcome to SubFlow!';

  @override
  String get welcomeSubtitle =>
      'Take control of your subscriptions and see where your money is going. Let\'s start tracking.';

  @override
  String get totalMonthly => 'Total Monthly';

  @override
  String get yearlyTotal => 'Yearly Projection';

  @override
  String get upcomingBills => 'Upcoming Bills';

  @override
  String get addSubscription => 'Add Subscription';

  @override
  String get editSubscription => 'Edit Subscription';

  @override
  String get deleteSubscription => 'Delete Subscription';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get confirmDelete => 'Are you sure?';

  @override
  String get deleteWarning => 'This will permanently delete this subscription.';

  @override
  String get incomeHealth => 'Financial Health';

  @override
  String get whatIfMode => 'What If Mode';

  @override
  String get whatIfDescription =>
      'Toggle subscriptions off to see potential savings';

  @override
  String get dataAndPrivacy => 'Data & Privacy';

  @override
  String get exportData => 'Export My Data (JSON)';

  @override
  String get privacyPolicy => 'Privacy Policy & Security';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get deleteAllData => 'Delete All Data';
}

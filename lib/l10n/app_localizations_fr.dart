// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'SubFlow';

  @override
  String get homeNav => 'Accueil';

  @override
  String get scheduleNav => 'Calendrier';

  @override
  String get subscriptionsNav => 'Abonnements';

  @override
  String get settingsNav => 'Paramètres';

  @override
  String get welcomeTitle => 'Bienvenue sur SubFlow !';

  @override
  String get welcomeSubtitle =>
      'Prenez le contrôle de vos abonnements et optimisez vos dépenses récurrentes.';

  @override
  String get totalMonthly => 'Total mensuel';

  @override
  String get yearlyTotal => 'Projection annuelle';

  @override
  String get upcomingBills => 'Prochains prélèvements';

  @override
  String get addSubscription => 'Ajouter un abonnement';

  @override
  String get editSubscription => 'Modifier l\'abonnement';

  @override
  String get deleteSubscription => 'Supprimer l\'abonnement';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get confirmDelete => 'Êtes-vous sûr ?';

  @override
  String get deleteWarning =>
      'Cette action supprimera définitivement cet abonnement.';

  @override
  String get incomeHealth => 'Santé financière';

  @override
  String get whatIfMode => 'Mode Simulateur';

  @override
  String get whatIfDescription =>
      'Désactivez des abonnements pour estimer vos économies';

  @override
  String get dataAndPrivacy => 'Données & Confidentialité';

  @override
  String get exportData => 'Exporter mes données (JSON)';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get dangerZone => 'Zone de danger';

  @override
  String get deleteAllData => 'Supprimer toutes les données';
}

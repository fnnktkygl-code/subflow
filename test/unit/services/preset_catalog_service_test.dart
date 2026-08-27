import 'package:flutter_test/flutter_test.dart';
import 'package:subflow_app/services/preset_catalog_service.dart';

void main() {
  group('PresetCatalogService Tests', () {
    test('FR region returns French Euro presets and prices', () {
      final presets = PresetCatalogService.getPresetsForCountry('FR');
      expect(presets, isNotEmpty);
      expect(PresetCatalogService.getCurrencySymbol('FR'), equals('€'));
      expect(PresetCatalogService.getCurrencyCode('FR'), equals('EUR'));

      final netflix = presets.firstWhere((p) => p.name == 'Netflix');
      expect(netflix.amount, equals(13.49));
      expect(netflix.currencySymbol, equals('€'));
      expect(netflix.formattedPrice, equals('€13.49'));

      final canalPlus = presets.firstWhere((p) => p.name == 'Canal+');
      expect(canalPlus.amount, equals(22.99));
    });

    test('GB region returns UK Sterling presets and prices', () {
      final presets = PresetCatalogService.getPresetsForCountry('GB');
      expect(presets, isNotEmpty);
      expect(PresetCatalogService.getCurrencySymbol('GB'), equals('£'));
      expect(PresetCatalogService.getCurrencyCode('GB'), equals('GBP'));

      final netflix = presets.firstWhere((p) => p.name == 'Netflix');
      expect(netflix.amount, equals(10.99));
      expect(netflix.currencySymbol, equals('£'));
      expect(netflix.formattedPrice, equals('£10.99'));

      final disney = presets.firstWhere((p) => p.name == 'Disney+');
      expect(disney.amount, equals(7.99));
    });

    test('US region returns US Dollar presets and prices', () {
      final presets = PresetCatalogService.getPresetsForCountry('US');
      expect(presets, isNotEmpty);
      expect(PresetCatalogService.getCurrencySymbol('US'), equals('\$'));
      expect(PresetCatalogService.getCurrencyCode('US'), equals('USD'));

      final netflix = presets.firstWhere((p) => p.name == 'Netflix');
      expect(netflix.amount, equals(15.49));
      expect(netflix.currencySymbol, equals('\$'));
      expect(netflix.formattedPrice, equals('\$15.49'));

      final hbo = presets.firstWhere((p) => p.name == 'HBO Max');
      expect(hbo.amount, equals(16.99));
    });

    test('DE, ES, IT, NL regions return specific Euro market prices', () {
      final dePresets = PresetCatalogService.getPresetsForCountry('DE');
      final esPresets = PresetCatalogService.getPresetsForCountry('ES');
      final itPresets = PresetCatalogService.getPresetsForCountry('IT');
      final nlPresets = PresetCatalogService.getPresetsForCountry('NL');

      expect(dePresets.firstWhere((p) => p.name == 'Netflix').amount, equals(13.99));
      expect(esPresets.firstWhere((p) => p.name == 'Netflix').amount, equals(12.99));
      expect(itPresets.firstWhere((p) => p.name == 'Netflix').amount, equals(12.99));
      expect(nlPresets.firstWhere((p) => p.name == 'Netflix').amount, equals(13.99));
    });

    test('CA and AU regions return Canadian and Australian Dollar presets', () {
      final caPresets = PresetCatalogService.getPresetsForCountry('CA');
      final auPresets = PresetCatalogService.getPresetsForCountry('AU');

      expect(PresetCatalogService.getCurrencySymbol('CA'), equals('CA\$'));
      expect(PresetCatalogService.getCurrencySymbol('AU'), equals('A\$'));

      expect(caPresets.firstWhere((p) => p.name == 'Crave').amount, equals(14.99));
      expect(auPresets.firstWhere((p) => p.name == 'Kayo Sports').amount, equals(25.00));
    });

    test('Unknown or null country returns default worldwide presets without crashing', () {
      final nullPresets = PresetCatalogService.getPresetsForCountry(null);
      final unknownPresets = PresetCatalogService.getPresetsForCountry('ZZ');

      expect(nullPresets, isNotEmpty);
      expect(unknownPresets, isNotEmpty);
      expect(unknownPresets.first.name, equals('Netflix'));
    });
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:asteria_app/core/payments/catalog/product_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, Object?> configuration;

  setUpAll(() {
    final file = File('ios/Runner/Asteria.storekit');
    expect(file.existsSync(), isTrue, reason: 'StoreKit QA config is missing');
    configuration = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
  });

  test('contains every product in the app catalog exactly once', () {
    final products = _allProducts(configuration);
    final configuredIds = products
        .map((product) => product['productID'] as String)
        .toList();

    expect(configuredIds.toSet(), ProductCatalog.allIds.toSet());
    expect(configuredIds, hasLength(ProductCatalog.allIds.length));
  });

  test('provides English and Russian metadata for every product', () {
    for (final product in _allProducts(configuration)) {
      final localizations = (product['localizations'] as List<Object?>)
          .cast<Map<String, Object?>>();
      final locales = localizations
          .map((localization) => localization['locale'])
          .toSet();

      expect(
        locales,
        containsAll(<String>{'en_US', 'ru_RU'}),
        reason: '${product['productID']} has incomplete StoreKit metadata',
      );
      for (final localization in localizations) {
        expect(localization['displayName'], isNotEmpty);
        expect(localization['description'], isNotEmpty);
      }
    }
  });

  test('defines the expected auto-renewable subscription periods', () {
    final subscriptions = _subscriptions(configuration);
    final periods = <String, String>{
      for (final product in subscriptions)
        product['productID'] as String:
            product['recurringSubscriptionPeriod'] as String,
    };

    expect(periods, {
      'asteria_pro_week': 'P1W',
      'asteria_pro_month': 'P1M',
      'asteria_pro_year': 'P1Y',
    });
  });

  test('Runner debug scheme points at the local StoreKit configuration', () {
    final project = File('ios/Runner.xcodeproj/project.pbxproj');
    expect(project.existsSync(), isTrue, reason: 'Xcode project is missing');
    expect(
      project.readAsStringSync(),
      contains('Asteria.storekit'),
      reason: 'StoreKit config must be added to the Xcode project',
    );

    final scheme = File(
      'ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme',
    );
    expect(scheme.existsSync(), isTrue, reason: 'Runner scheme is missing');

    final match = RegExp(
      r'<StoreKitConfigurationFileReference\s+identifier = "([^"]+)">',
      multiLine: true,
    ).firstMatch(scheme.readAsStringSync());
    expect(match, isNotNull, reason: 'Runner scheme has no StoreKit config');

    final xcodeProjectDir = scheme.parent.parent.parent;
    final referenced = File('${xcodeProjectDir.path}/${match!.group(1)!}');
    expect(
      referenced.existsSync(),
      isTrue,
      reason: 'Runner scheme StoreKit config path does not resolve',
    );
  });
}

List<Map<String, Object?>> _allProducts(Map<String, Object?> configuration) => [
  ...(configuration['products'] as List<Object?>).cast<Map<String, Object?>>(),
  ..._subscriptions(configuration),
];

List<Map<String, Object?>> _subscriptions(Map<String, Object?> configuration) =>
    (configuration['subscriptionGroups'] as List<Object?>)
        .cast<Map<String, Object?>>()
        .expand(
          (group) => (group['subscriptions'] as List<Object?>)
              .cast<Map<String, Object?>>(),
        )
        .toList();

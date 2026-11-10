import 'dart:async';

import 'package:asteria_app/core/payments/routing/payment_provider_route.dart';
import 'package:asteria_app/core/payments/routing/google_play_country_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('routes by platform and distribution channel', () {
    expect(
      PaymentProviderRouter.fromDistribution(
        TargetPlatform.iOS,
        DistributionChannel.global,
      ),
      PaymentProviderRoute.appleStoreKit,
    );
    expect(
      PaymentProviderRouter.fromDistribution(
        TargetPlatform.android,
        DistributionChannel.global,
        playCountryCode: 'RU',
      ),
      PaymentProviderRoute.arcPay,
    );
    expect(
      PaymentProviderRouter.fromDistribution(
        TargetPlatform.android,
        DistributionChannel.global,
        playCountryCode: 'US',
      ),
      PaymentProviderRoute.googlePlay,
    );
    expect(
      PaymentProviderRouter.fromDistribution(
        TargetPlatform.android,
        DistributionChannel.ru,
      ),
      PaymentProviderRoute.arcPay,
    );
  });

  test('global Android resolves provider from Google Play country', () async {
    final playCountry = _FakeGooglePlayCountry('RU');
    final router = PaymentProviderRouter(
      _FakeStorefront('USA'),
      distributionChannel: DistributionChannel.global,
      platform: TargetPlatform.android,
      googlePlayCountry: playCountry,
    );

    expect(await router.current(), PaymentProviderRoute.arcPay);
    playCountry.current = 'US';
    expect(await router.current(), PaymentProviderRoute.googlePlay);
    playCountry.current = null;
    expect(await router.current(), PaymentProviderRoute.googlePlay);
  });

  test('selected Russian location routes iOS and Android to Arc Pay', () async {
    final selectedLocation = _FakePaymentLocationCountry('RU');
    final iosRouter = PaymentProviderRouter(
      _FakeStorefront('USA'),
      distributionChannel: DistributionChannel.global,
      platform: TargetPlatform.iOS,
      googlePlayCountry: _FakeGooglePlayCountry('US'),
      locationCountry: selectedLocation,
    );
    final androidRouter = PaymentProviderRouter(
      _FakeStorefront('USA'),
      distributionChannel: DistributionChannel.global,
      platform: TargetPlatform.android,
      googlePlayCountry: _FakeGooglePlayCountry('US'),
      locationCountry: selectedLocation,
    );

    expect(await iosRouter.current(), PaymentProviderRoute.arcPay);
    expect(await androidRouter.current(), PaymentProviderRoute.arcPay);
  });

  test('non-Russian selected location routes to platform stores', () async {
    final selectedLocation = _FakePaymentLocationCountry('KZ');
    final iosRouter = PaymentProviderRouter(
      _FakeStorefront('RUS'),
      distributionChannel: DistributionChannel.global,
      platform: TargetPlatform.iOS,
      googlePlayCountry: _FakeGooglePlayCountry('RU'),
      locationCountry: selectedLocation,
    );
    final androidRouter = PaymentProviderRouter(
      _FakeStorefront('RUS'),
      distributionChannel: DistributionChannel.global,
      platform: TargetPlatform.android,
      googlePlayCountry: _FakeGooglePlayCountry('RU'),
      locationCountry: selectedLocation,
    );

    expect(await iosRouter.current(), PaymentProviderRoute.appleStoreKit);
    expect(await androidRouter.current(), PaymentProviderRoute.googlePlay);
  });

  test('cleared selected location falls back to platform routing', () async {
    final selectedLocation = _FakePaymentLocationCountry('RU');
    final router = PaymentProviderRouter(
      _FakeStorefront('USA'),
      distributionChannel: DistributionChannel.global,
      platform: TargetPlatform.android,
      googlePlayCountry: _FakeGooglePlayCountry('US'),
      locationCountry: selectedLocation,
    );
    final values = <PaymentProviderRoute>[];
    final subscription = router.updates().listen(values.add);

    selectedLocation.controller.add('RU');
    selectedLocation.controller.add(null);
    await Future<void>.delayed(Duration.zero);

    expect(values, [
      PaymentProviderRoute.arcPay,
      PaymentProviderRoute.googlePlay,
    ]);
    await subscription.cancel();
    await selectedLocation.controller.close();
  });

  test('RU distribution does not query Google Play country', () async {
    final playCountry = _FakeGooglePlayCountry('US');
    final router = PaymentProviderRouter(
      _FakeStorefront('USA'),
      distributionChannel: DistributionChannel.ru,
      platform: TargetPlatform.android,
      googlePlayCountry: playCountry,
    );

    expect(await router.current(), PaymentProviderRoute.arcPay);
    expect(playCountry.calls, 0);
  });

  test('RUS routes to Arc Pay and unknown routes safely to Apple', () async {
    final storefront = _FakeStorefront('RUS');
    final router = PaymentProviderRouter(storefront);

    expect(await router.current(), PaymentProviderRoute.arcPay);
    storefront.current = 'USA';
    expect(await router.current(), PaymentProviderRoute.appleStoreKit);
    storefront.current = null;
    expect(await router.current(), PaymentProviderRoute.appleStoreKit);
  });

  test(
    'storefront updates change provider for users without subscription',
    () async {
      final storefront = _FakeStorefront('USA');
      final router = PaymentProviderRouter(storefront);
      final values = <PaymentProviderRoute>[];
      final subscription = router.updates().listen(values.add);

      storefront.controller.add('RUS');
      storefront.controller.add('USA');
      await Future<void>.delayed(Duration.zero);

      expect(values, [
        PaymentProviderRoute.arcPay,
        PaymentProviderRoute.appleStoreKit,
      ]);
      await subscription.cancel();
      await storefront.controller.close();
    },
  );

  test('active subscription provider wins after storefront changes', () async {
    final storefront = _FakeStorefront('RUS');
    final router = PaymentProviderRouter(storefront);

    expect(
      await router.current(
        activeSubscriptionRoute: PaymentProviderRoute.appleStoreKit,
      ),
      PaymentProviderRoute.appleStoreKit,
    );
    storefront.current = 'USA';
    expect(
      await router.current(
        activeSubscriptionRoute: PaymentProviderRoute.arcPay,
      ),
      PaymentProviderRoute.arcPay,
    );
    expect(
      await router.current(
        activeSubscriptionRoute: PaymentProviderRoute.googlePlay,
      ),
      PaymentProviderRoute.googlePlay,
    );
  });

  test(
    'maps active subscription provider string without user profile state',
    () {
      expect(
        PaymentProviderRouter.activeSubscriptionProvider('apple'),
        PaymentProviderRoute.appleStoreKit,
      );
      expect(
        PaymentProviderRouter.activeSubscriptionProvider('google'),
        PaymentProviderRoute.googlePlay,
      );
      expect(
        PaymentProviderRouter.activeSubscriptionProvider('arc_pay'),
        PaymentProviderRoute.arcPay,
      );
      expect(PaymentProviderRouter.activeSubscriptionProvider(null), isNull);
    },
  );
}

class _FakeGooglePlayCountry implements GooglePlayCountryService {
  String? current;
  int calls = 0;

  _FakeGooglePlayCountry(this.current);

  @override
  Future<String?> currentCountryCode() async {
    calls += 1;
    return current;
  }
}

class _FakeStorefront implements AppleStorefrontService {
  String? current;
  final controller = StreamController<String?>.broadcast();

  _FakeStorefront(this.current);

  @override
  Future<String?> currentCountryCode() async => current;

  @override
  Stream<String?> get countryCodeUpdates => controller.stream;
}

class _FakePaymentLocationCountry implements PaymentLocationCountryService {
  String? current;
  final controller = StreamController<String?>.broadcast();

  _FakePaymentLocationCountry(this.current);

  @override
  Future<String?> currentCountryCode() async => current;

  @override
  Stream<String?> get countryCodeUpdates => controller.stream;
}

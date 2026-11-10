import 'dart:async';

import 'package:asteria_app/core/payments/routing/google_play_country_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum PaymentProviderRoute { appleStoreKit, googlePlay, arcPay }

enum DistributionChannel { global, ru }

extension DistributionChannelConfig on DistributionChannel {
  static const _configured = String.fromEnvironment(
    'ASTERIA_DISTRIBUTION_CHANNEL',
    defaultValue: 'global',
  );

  static DistributionChannel get current => _configured == 'global'
      ? DistributionChannel.global
      : DistributionChannel.ru;
}

abstract interface class AppleStorefrontService {
  Future<String?> currentCountryCode();
  Stream<String?> get countryCodeUpdates;
}

abstract interface class PaymentLocationCountryService {
  Future<String?> currentCountryCode();
  Stream<String?> get countryCodeUpdates;
}

class StoreKitAppleStorefrontService implements AppleStorefrontService {
  static const _methodChannel = MethodChannel('asteria/storefront');
  static const _eventChannel = EventChannel('asteria/storefront-updates');
  static const _debugStorefrontOverride = String.fromEnvironment(
    'ASTERIA_STOREFRONT_OVERRIDE',
  );

  @override
  Future<String?> currentCountryCode() async {
    try {
      return await _methodChannel.invokeMethod<String>(
        kDebugMode && _debugStorefrontOverride.isNotEmpty
            ? 'debugGetCurrentStorefront:$_debugStorefrontOverride'
            : 'getCurrentStorefront',
      );
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Stream<String?> get countryCodeUpdates => _eventChannel
      .receiveBroadcastStream()
      .map((value) => value is String ? value : null)
      .handleError((_) {});
}

class PaymentProviderRouter {
  final AppleStorefrontService _storefront;
  final DistributionChannel? _distributionChannel;
  final TargetPlatform? _platform;
  final GooglePlayCountryService? _googlePlayCountry;
  final PaymentLocationCountryService? _locationCountry;

  const PaymentProviderRouter(
    this._storefront, {
    DistributionChannel? distributionChannel,
    TargetPlatform? platform,
    GooglePlayCountryService? googlePlayCountry,
    PaymentLocationCountryService? locationCountry,
  }) : _distributionChannel = distributionChannel,
       _platform = platform,
       _googlePlayCountry = googlePlayCountry,
       _locationCountry = locationCountry;

  static PaymentProviderRoute fromCountryCode(String? countryCode) =>
      _isRussia(countryCode)
      ? PaymentProviderRoute.arcPay
      : PaymentProviderRoute.appleStoreKit;

  static bool _isRussia(String? countryCode) {
    final normalized = countryCode?.trim().toUpperCase();
    return normalized == 'RU' || normalized == 'RUS';
  }

  static PaymentProviderRoute fromSelectedLocationCountryCode(
    TargetPlatform platform,
    String countryCode,
  ) {
    if (_isRussia(countryCode)) return PaymentProviderRoute.arcPay;
    return platform == TargetPlatform.android
        ? PaymentProviderRoute.googlePlay
        : PaymentProviderRoute.appleStoreKit;
  }

  Future<PaymentProviderRoute> current({
    PaymentProviderRoute? activeSubscriptionRoute,
  }) async {
    if (activeSubscriptionRoute != null) return activeSubscriptionRoute;
    final platform = _platform ?? defaultTargetPlatform;
    final locationCountryCode = await _locationCountry?.currentCountryCode();
    if (locationCountryCode != null && locationCountryCode.trim().isNotEmpty) {
      return fromSelectedLocationCountryCode(platform, locationCountryCode);
    }
    if (_distributionChannel != null) {
      if (platform == TargetPlatform.android &&
          _distributionChannel == DistributionChannel.global) {
        final countryCode = await _googlePlayCountry?.currentCountryCode();
        return fromDistribution(
          platform,
          _distributionChannel,
          playCountryCode: countryCode,
        );
      }
      return fromDistribution(platform, _distributionChannel);
    }
    return fromCountryCode(await _storefront.currentCountryCode());
  }

  Stream<PaymentProviderRoute> updates({
    PaymentProviderRoute? activeSubscriptionRoute,
  }) {
    if (activeSubscriptionRoute != null) {
      return Stream.value(activeSubscriptionRoute);
    }
    final platform = _platform ?? defaultTargetPlatform;
    final locationUpdates = _locationCountry?.countryCodeUpdates;
    if (locationUpdates != null) {
      return locationUpdates.asyncMap((countryCode) async {
        if (countryCode != null && countryCode.trim().isNotEmpty) {
          return fromSelectedLocationCountryCode(platform, countryCode);
        }
        return _fallbackRoute(platform);
      }).distinct();
    }
    return _fallbackRouteUpdates();
  }

  Future<PaymentProviderRoute> _fallbackRoute(TargetPlatform platform) async {
    if (_distributionChannel != null) {
      if (platform == TargetPlatform.android &&
          _distributionChannel == DistributionChannel.global) {
        final countryCode = await _googlePlayCountry?.currentCountryCode();
        return fromDistribution(
          platform,
          _distributionChannel,
          playCountryCode: countryCode,
        );
      }
      return fromDistribution(platform, _distributionChannel);
    }
    return fromCountryCode(await _storefront.currentCountryCode());
  }

  Stream<PaymentProviderRoute> _fallbackRouteUpdates() {
    if (_distributionChannel != null) {
      return const Stream.empty();
    }
    return _storefront.countryCodeUpdates.map(fromCountryCode).distinct();
  }

  static PaymentProviderRoute fromDistribution(
    TargetPlatform platform,
    DistributionChannel? distributionChannel, {
    String? playCountryCode,
  }) {
    if (platform == TargetPlatform.iOS) {
      return PaymentProviderRoute.appleStoreKit;
    }
    if (platform == TargetPlatform.android &&
        distributionChannel == DistributionChannel.global) {
      return playCountryCode?.toUpperCase() == 'RU'
          ? PaymentProviderRoute.arcPay
          : PaymentProviderRoute.googlePlay;
    }
    return PaymentProviderRoute.arcPay;
  }

  static PaymentProviderRoute? activeSubscriptionProvider(String? provider) {
    return switch (provider) {
      'apple' => PaymentProviderRoute.appleStoreKit,
      'google' => PaymentProviderRoute.googlePlay,
      'arc_pay' || 'arcopay' => PaymentProviderRoute.arcPay,
      null => null,
      _ => null,
    };
  }
}

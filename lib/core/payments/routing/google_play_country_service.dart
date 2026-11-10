import 'package:in_app_purchase/in_app_purchase.dart';

abstract interface class GooglePlayCountryService {
  Future<String?> currentCountryCode();
}

class BillingConfigGooglePlayCountryService
    implements GooglePlayCountryService {
  BillingConfigGooglePlayCountryService({InAppPurchase? inAppPurchase})
    : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  final InAppPurchase _inAppPurchase;

  @override
  Future<String?> currentCountryCode() async {
    try {
      final countryCode = (await _inAppPurchase.countryCode())
          .trim()
          .toUpperCase();
      return countryCode.isEmpty ? null : countryCode;
    } catch (_) {
      return null;
    }
  }
}

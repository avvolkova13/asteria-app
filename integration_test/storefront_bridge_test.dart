import 'package:asteria_app/core/payments/routing/payment_provider_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native StoreKit storefront bridge returns a safe route', (
    tester,
  ) async {
    const expectedCountryCode = String.fromEnvironment(
      'EXPECTED_STOREFRONT',
    );
    final countryCode = await StoreKitAppleStorefrontService()
        .currentCountryCode();
    if (expectedCountryCode.isNotEmpty) {
      expect(countryCode, expectedCountryCode == 'UNAVAILABLE' ? null : expectedCountryCode);
    }
    expect(
      PaymentProviderRouter.fromCountryCode(countryCode),
      countryCode?.toUpperCase() == 'RUS'
          ? PaymentProviderRoute.arcPay
          : PaymentProviderRoute.appleStoreKit,
    );
  });
}

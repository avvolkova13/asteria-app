import 'package:asteria_app/core/payments/api/arc_pay_payments_api.dart';
import 'package:asteria_app/core/payments/models/payment_product.dart';
import 'package:asteria_app/features/coins_paywall/presentation/screens/coins_paywall_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('filters Arc Pay coin packages below the required stars', () {
    final filtered = filterArcPayCoinProductsForMinimumStars(const [
      ArcPayProduct(
        productId: 'asteria_stars_10',
        name: '10',
        productType: 'stars',
        coins: 10,
        durationDays: null,
        amountMinor: 4900,
        currency: 'RUB',
      ),
      ArcPayProduct(
        productId: 'asteria_stars_120',
        name: '120',
        productType: 'stars',
        coins: 120,
        durationDays: null,
        amountMinor: 39900,
        currency: 'RUB',
      ),
    ], 100);

    expect(filtered.map((product) => product.productId), ['asteria_stars_120']);
  });

  test('filters StoreKit coin packages below the required stars', () {
    final filtered = filterStoreCoinProductsForMinimumStars(const [
      PaymentProduct(
        id: 'asteria_stars_60',
        type: ProductType.consumable,
        title: '60',
        description: '',
        localizedPrice: r'$2.99',
        rawPrice: 2.99,
        currencyCode: 'USD',
      ),
      PaymentProduct(
        id: 'asteria_stars_120',
        type: ProductType.consumable,
        title: '120',
        description: '',
        localizedPrice: r'$4.99',
        rawPrice: 4.99,
        currencyCode: 'USD',
      ),
    ], 100);

    expect(filtered.map((product) => product.id), ['asteria_stars_120']);
  });
}

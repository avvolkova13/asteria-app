import 'dart:async';
import 'package:asteria_app/core/payments/gateway/store_kit_gateway.dart';
import 'package:asteria_app/core/payments/gateway/payment_gateway.dart';
import 'package:asteria_app/core/payments/models/purchase_result.dart'
    as domain;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late StoreBillingGateway gateway;
  late _Products platform;
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final store = iap.InAppPurchase.instance;
    debugDefaultTargetPlatformOverride = null;
    platform = _Products();
    InAppPurchasePlatform.instance = platform;
    gateway = StoreBillingGateway(
      iapInstance: store,
      storeProvider: domain.StoreProvider.google,
    );
  });
  tearDown(() => platform.updates.close());

  for (final trialFirst in [true, false]) {
    test(
      'selects eligible seven day trial independent of API order ($trialFirst)',
      () async {
        final base = offer();
        final trial = offer(trial: true);
        platform.products = products(
          trialFirst ? [trial, base] : [base, trial],
        );
        final result = (await gateway.loadProducts([
          'asteria_pro_month',
        ])).single;
        expect(
          (result.rawDetails as GooglePlayProductDetails).offerToken,
          'trial-token',
        );
        expect(result.rawPrice, 0); // Checkout starts free; no phantom revenue.
      },
    );
  }
  test(
    'selects regular base plan when trial is not returned as eligible',
    () async {
      platform.products = products([offer()]);
      final result = (await gateway.loadProducts(['asteria_pro_month'])).single;
      expect(
        (result.rawDetails as GooglePlayProductDetails).offerToken,
        'base-token',
      );
      expect(result.localizedPrice, r'$9.99');
    },
  );
  test(
    'wrong base plan cannot silently replace configured monthly plan',
    () async {
      platform.products = products([offer(basePlan: 'unexpected')]);
      await expectLater(
        gateway.loadProducts(['asteria_pro_month']),
        throwsA(isA<StoreProductLoadException>()),
      );
    },
  );
  test(
    'unsupported discounted phases fall back to clearly priced base plan',
    () async {
      platform.products = products([
        offer(),
        offer(trial: true, trialPeriod: 'P1M'),
      ]);
      final result = (await gateway.loadProducts(['asteria_pro_month'])).single;
      expect(
        (result.rawDetails as GooglePlayProductDetails).offerToken,
        'base-token',
      );
    },
  );
}

List<GooglePlayProductDetails> products(
  List<SubscriptionOfferDetailsWrapper> offers,
) => GooglePlayProductDetails.fromProductDetails(
  ProductDetailsWrapper(
    description: 'PRO monthly',
    name: 'PRO',
    productId: 'asteria_pro_month',
    productType: ProductType.subs,
    subscriptionOfferDetails: offers,
    title: 'PRO',
  ),
);
SubscriptionOfferDetailsWrapper offer({
  bool trial = false,
  String basePlan = 'monthly',
  String trialPeriod = 'P7D',
}) => SubscriptionOfferDetailsWrapper(
  basePlanId: basePlan,
  offerId: trial ? 'trial-7d' : null,
  offerTags: const [],
  offerIdToken: trial ? 'trial-token' : 'base-token',
  pricingPhases: [
    if (trial)
      PricingPhaseWrapper(
        billingCycleCount: 1,
        billingPeriod: trialPeriod,
        formattedPrice: r'$0.00',
        priceAmountMicros: 0,
        priceCurrencyCode: 'USD',
        recurrenceMode: RecurrenceMode.finiteRecurring,
      ),
    const PricingPhaseWrapper(
      billingCycleCount: 0,
      billingPeriod: 'P1M',
      formattedPrice: r'$9.99',
      priceAmountMicros: 9990000,
      priceCurrencyCode: 'USD',
      recurrenceMode: RecurrenceMode.infiniteRecurring,
    ),
  ],
);

class _Products extends InAppPurchasePlatform {
  List<GooglePlayProductDetails> products = [];
  final updates = StreamController<List<PurchaseDetails>>.broadcast();
  @override
  Stream<List<PurchaseDetails>> get purchaseStream => updates.stream;
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async => ProductDetailsResponse(productDetails: products, notFoundIDs: []);
}

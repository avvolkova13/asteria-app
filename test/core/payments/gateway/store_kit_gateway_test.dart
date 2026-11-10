import 'dart:async';

import 'package:asteria_app/core/payments/gateway/payment_gateway.dart';
import 'package:asteria_app/core/payments/gateway/store_kit_gateway.dart';
import 'package:asteria_app/core/payments/models/payment_product.dart';
import 'package:asteria_app/core/payments/models/purchase_result.dart'
    as app_purchase;
import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:in_app_purchase_android/in_app_purchase_android.dart' as google;
import 'package:in_app_purchase_android/billing_client_wrappers.dart'
    as billing;
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  iap.InAppPurchase.instance;
  debugDefaultTargetPlatformOverride = null;

  test('orders StoreKit products by the requested product IDs', () {
    const requestedIds = [
      'asteria_stars_10',
      'asteria_stars_30',
      'asteria_stars_60',
      'asteria_stars_120',
      'asteria_stars_300',
    ];
    final storeProducts = [
      _product('asteria_stars_120'),
      _product('asteria_stars_300'),
      _product('asteria_stars_10'),
      _product('asteria_stars_30'),
      _product('unrequested_product'),
    ];

    final orderedProducts = orderProductDetailsByIds(
      requestedIds,
      storeProducts,
    );

    expect(orderedProducts.map((product) => product.id), [
      'asteria_stars_10',
      'asteria_stars_30',
      'asteria_stars_120',
      'asteria_stars_300',
    ]);
  });

  test('does not publish terminal updates owned by an in-flight purchase', () {
    expect(
      shouldPublishPurchaseStreamEvent(
        matchedPendingPurchase: true,
        status: iap.PurchaseStatus.purchased,
      ),
      isFalse,
    );
    expect(
      shouldPublishPurchaseStreamEvent(
        matchedPendingPurchase: true,
        status: iap.PurchaseStatus.restored,
      ),
      isFalse,
    );
    expect(
      shouldPublishPurchaseStreamEvent(
        matchedPendingPurchase: false,
        status: iap.PurchaseStatus.purchased,
      ),
      isTrue,
    );
  });

  test(
    'throws partial product load error with loaded products when store omits requested IDs',
    () async {
      final platform = _MissingProductPlatform();
      final gateway = StoreBillingGateway(
        storeProvider: app_purchase.StoreProvider.apple,
      );
      InAppPurchasePlatform.instance = platform;

      await expectLater(
        gateway.loadProducts(const ['asteria_stars_10', 'asteria_stars_30']),
        throwsA(
          isA<StoreProductLoadException>()
              .having((e) => e.code, 'code', 'store_products_partial')
              .having((e) => e.requestedIds, 'requestedIds', [
                'asteria_stars_10',
                'asteria_stars_30',
              ])
              .having((e) => e.loadedIds, 'loadedIds', ['asteria_stars_10'])
              .having(
                (e) => e.loadedProducts.map((p) => p.id),
                'loadedProducts',
                ['asteria_stars_10'],
              )
              .having((e) => e.notFoundIds, 'notFoundIds', [
                'asteria_stars_30',
              ]),
        ),
      );
    },
  );

  test(
    'computes missing product IDs when store omits them without notFoundIDs',
    () async {
      final platform = _OmittedProductWithoutNotFoundPlatform();
      final gateway = StoreBillingGateway(
        storeProvider: app_purchase.StoreProvider.apple,
      );
      InAppPurchasePlatform.instance = platform;

      await expectLater(
        gateway.loadProducts(const ['asteria_stars_10', 'asteria_stars_30']),
        throwsA(
          isA<StoreProductLoadException>()
              .having((e) => e.code, 'code', 'store_products_partial')
              .having((e) => e.loadedIds, 'loadedIds', ['asteria_stars_10'])
              .having((e) => e.notFoundIds, 'notFoundIds', [
                'asteria_stars_30',
              ]),
        ),
      );
    },
  );

  test(
    'throws structured product load error when IAP is unavailable',
    () async {
      final platform = _UnavailablePurchasePlatform();
      final gateway = StoreBillingGateway(
        storeProvider: app_purchase.StoreProvider.apple,
      );
      InAppPurchasePlatform.instance = platform;

      await expectLater(
        gateway.loadProducts(const ['asteria_stars_10']),
        throwsA(
          isA<StoreProductLoadException>()
              .having((e) => e.code, 'code', 'store_unavailable')
              .having((e) => e.requestedIds, 'requestedIds', [
                'asteria_stars_10',
              ]),
        ),
      );
    },
  );

  test(
    'Google restore returns only purchases whose underlying payment completed',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final store = iap.InAppPurchase.instance;
      debugDefaultTargetPlatformOverride = null;
      final platform = _GoogleRestorePlatform();
      InAppPurchasePlatform.instance = platform;
      final gateway = StoreBillingGateway(
        iapInstance: store,
        storeProvider: app_purchase.StoreProvider.google,
      );
      final updates = <app_purchase.PurchaseResult>[];
      final subscription = gateway.purchaseUpdates.listen(
        (update) => updates.add(update.result),
      );
      addTearDown(subscription.cancel);
      final restored = await gateway.restorePurchases();
      expect(restored, hasLength(1));
      expect(restored.single.status, app_purchase.PurchaseStatus.success);
      expect(updates.map((result) => result.status), [
        app_purchase.PurchaseStatus.pending,
        app_purchase.PurchaseStatus.success,
      ]);
    },
  );

  test(
    'Google pending payment returns immediately and completion reaches recovery',
    () {
      fakeAsync((async) {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        final store = iap.InAppPurchase.instance;
        debugDefaultTargetPlatformOverride = null;
        final platform = _SilentPurchasePlatform();
        InAppPurchasePlatform.instance = platform;
        final gateway = StoreBillingGateway(
          iapInstance: store,
          storeProvider: app_purchase.StoreProvider.google,
        );
        final recovered = <app_purchase.PurchaseResult>[];
        final subscription = gateway.purchaseUpdates.listen(
          (update) => recovered.add(update.result),
        );
        app_purchase.PurchaseResult? result;
        gateway
            .purchase(_paymentProduct('asteria_stars_10'), userToken: 'owner')
            .then((value) => result = value);
        async.flushMicrotasks();
        platform.emitPurchases([_googlePurchase('owner', pending: true)]);
        async.flushMicrotasks();
        expect(result?.status, app_purchase.PurchaseStatus.pending);
        platform.emitPurchases([_googlePurchase('owner')]);
        async.flushMicrotasks();
        expect(
          recovered.where(
            (result) => result.status == app_purchase.PurchaseStatus.success,
          ),
          hasLength(1),
        );
        unawaited(subscription.cancel());
      });
    },
  );

  test(
    'Google checkout cannot match another account purchase of same product',
    () {
      fakeAsync((async) {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        final store = iap.InAppPurchase.instance;
        debugDefaultTargetPlatformOverride = null;
        final platform = _SilentPurchasePlatform();
        InAppPurchasePlatform.instance = platform;
        final gateway = StoreBillingGateway(
          iapInstance: store,
          storeProvider: app_purchase.StoreProvider.google,
        );
        final subscription = gateway.purchaseUpdates.listen((_) {});
        app_purchase.PurchaseResult? result;
        gateway
            .purchase(_paymentProduct('asteria_stars_10'), userToken: 'owner')
            .then((value) => result = value);
        async.flushMicrotasks();
        platform.emitPurchases([_googlePurchase('other-user')]);
        async.flushMicrotasks();
        expect(result, isNull);
        platform.emitPurchases([_googlePurchase('owner')]);
        async.flushMicrotasks();
        expect(result?.status, app_purchase.PurchaseStatus.success);
        unawaited(subscription.cancel());
      });
    },
  );

  test('Google finalize leaves consumed purchase to backend', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final store = iap.InAppPurchase.instance;
    debugDefaultTargetPlatformOverride = null;
    final platform = _SilentPurchasePlatform();
    InAppPurchasePlatform.instance = platform;
    final gateway = StoreBillingGateway(
      iapInstance: store,
      storeProvider: app_purchase.StoreProvider.google,
    );
    final raw = iap.PurchaseDetails(
      productID: 'asteria_stars_10',
      verificationData: _verificationData('paid-token'),
      transactionDate: '1000',
      status: iap.PurchaseStatus.purchased,
    )..pendingCompletePurchase = true;
    // The platform fake has no completePurchase implementation: invoking it
    // would fail, as does acknowledging a token already consumed by the server.
    await gateway.finalize(
      app_purchase.PurchaseResult(
        productId: raw.productID,
        status: app_purchase.PurchaseStatus.success,
        rawPurchase: raw,
      ),
    );
  });
}

PaymentProduct _paymentProduct(String id) {
  return PaymentProduct(
    id: id,
    type: ProductType.consumable,
    title: 'Stars',
    description: 'Stars',
    localizedPrice: r'$0.99',
    rawPrice: 0.99,
    currencyCode: 'USD',
    rawDetails: _product(id),
  );
}

iap.ProductDetails _product(String id) {
  return iap.ProductDetails(
    id: id,
    title: id,
    description: '',
    price: r'$0.99',
    rawPrice: 0.99,
    currencyCode: 'USD',
  );
}

PurchaseVerificationData _verificationData(String serverVerificationData) {
  return PurchaseVerificationData(
    localVerificationData: serverVerificationData,
    serverVerificationData: serverVerificationData,
    source: 'app_store',
  );
}

class _SilentPurchasePlatform extends InAppPurchasePlatform {
  final StreamController<List<PurchaseDetails>> _controller =
      StreamController<List<PurchaseDetails>>.broadcast();
  int buyConsumableCalls = 0;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _controller.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async {
    return ProductDetailsResponse(
      productDetails: identifiers.map(_product).toList(growable: false),
      notFoundIDs: const [],
    );
  }

  @override
  Future<bool> buyConsumable({
    required PurchaseParam purchaseParam,
    bool autoConsume = true,
  }) async {
    buyConsumableCalls += 1;
    return true;
  }

  void emitPurchases(List<PurchaseDetails> purchases) {
    _controller.add(purchases);
  }
}

class _MissingProductPlatform extends _SilentPurchasePlatform {
  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async {
    return ProductDetailsResponse(
      productDetails: [_product('asteria_stars_10')],
      notFoundIDs: const ['asteria_stars_30'],
    );
  }
}

class _OmittedProductWithoutNotFoundPlatform extends _SilentPurchasePlatform {
  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async {
    return ProductDetailsResponse(
      productDetails: [_product('asteria_stars_10')],
      notFoundIDs: const [],
    );
  }
}

class _UnavailablePurchasePlatform extends _SilentPurchasePlatform {
  @override
  Future<bool> isAvailable() async => false;
}

google.GooglePlayPurchaseDetails _googlePurchase(
  String uid, {
  bool pending = false,
}) => google.GooglePlayPurchaseDetails.fromPurchase(
  billing.PurchaseWrapper(
    orderId: 'order',
    packageName: 'com.asteria',
    purchaseTime: 1000,
    purchaseToken: 'token-$uid',
    signature: 'signature',
    products: ['asteria_stars_10'],
    isAutoRenewing: false,
    originalJson: '{}',
    isAcknowledged: false,
    purchaseState: pending
        ? billing.PurchaseStateWrapper.pending
        : billing.PurchaseStateWrapper.purchased,
    obfuscatedAccountId: googlePlayObfuscatedAccountId(uid),
  ),
).single;

class _GoogleRestorePlatform extends _SilentPurchasePlatform {
  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    emitPurchases([
      _googlePurchase('owner', pending: true)
        ..status = iap.PurchaseStatus.restored,
      _googlePurchase('owner')..status = iap.PurchaseStatus.restored,
    ]);
  }
}

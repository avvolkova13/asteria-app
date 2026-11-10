import 'dart:async';
import 'dart:convert';

import 'package:asteria_app/core/payments/catalog/product_catalog.dart';
import 'package:asteria_app/core/payments/catalog/google_subscription_offers.dart';
import 'package:asteria_app/core/payments/gateway/payment_gateway.dart';
import 'package:asteria_app/core/payments/models/payment_product.dart';
import 'package:asteria_app/core/payments/models/purchase_result.dart';
import 'package:asteria_app/core/payments/models/purchase_update.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:in_app_purchase_android/in_app_purchase_android.dart' as google;
import 'package:in_app_purchase_android/billing_client_wrappers.dart'
    as billing;
import 'package:asteria_app/core/payments/apple/apple_models.dart';

@visibleForTesting
bool shouldPublishPurchaseStreamEvent({
  required bool matchedPendingPurchase,
  required iap.PurchaseStatus status,
}) {
  return !(matchedPendingPurchase && status != iap.PurchaseStatus.pending);
}

/// Cross-platform StoreKit / Google Play Billing gateway.
class StoreBillingGateway implements PaymentGateway {
  static const _purchaseTerminalUpdateTimeout = Duration(seconds: 90);

  final iap.InAppPurchase _iap;
  late final Stream<PurchaseUpdate> _purchaseUpdates;

  /// Pending completers keyed by productId, used by [purchase] to await the
  /// stream event that matches the purchase the caller initiated.
  final Map<String, _PendingStorePurchase> _pendingPurchases = {};

  StoreBillingGateway({
    iap.InAppPurchase? iapInstance,
    StoreProvider? storeProvider,
  }) : _storeProvider =
           storeProvider ??
           (defaultTargetPlatform == TargetPlatform.android
               ? StoreProvider.google
               : StoreProvider.apple),
       _iap = iapInstance ?? iap.InAppPurchase.instance {
    // Re-broadcast the global purchase stream as our domain updates. The
    // plugin's stream is broadcast already, but we map to PurchaseUpdate
    // so callers don't depend on the plugin type.
    _purchaseUpdates = _iap.purchaseStream.asyncExpand((purchases) {
      final updates = <PurchaseUpdate>[];
      for (final purchase in purchases) {
        final result = _mapPurchase(purchase);
        var matchedPendingPurchase = false;
        // Resolve any in-flight purchase awaiting this product.
        final pendingPurchase = _pendingPurchases[purchase.productID];
        if (pendingPurchase != null &&
            !pendingPurchase.completer.isCompleted &&
            _matchesPendingPurchase(purchase, pendingPurchase)) {
          if (purchase.status != iap.PurchaseStatus.pending ||
              _storeProvider == StoreProvider.google) {
            matchedPendingPurchase = true;
            _pendingPurchases.remove(purchase.productID);
            pendingPurchase.completer.complete(result);
          }
        }
        if (_storeProvider == StoreProvider.apple ||
            shouldPublishPurchaseStreamEvent(
              matchedPendingPurchase: matchedPendingPurchase,
              status: purchase.status,
            )) {
          updates.add(PurchaseUpdate(result));
        }
      }
      return Stream.fromIterable(updates);
    }).asBroadcastStream();
  }

  final StoreProvider _storeProvider;

  @override
  Stream<PurchaseUpdate> get purchaseUpdates => _purchaseUpdates;

  @override
  Future<List<PaymentProduct>> loadProducts(List<String> ids) async {
    final available = await _iap.isAvailable();
    if (!available) {
      debugPrint('[StoreKitGateway] InAppPurchase not available');
      throw StoreProductLoadException(
        code: 'store_unavailable',
        message: 'In-app purchase service is not available',
        requestedIds: ids,
      );
    }

    final response = await _iap.queryProductDetails(ids.toSet());
    if (response.error != null) {
      debugPrint(
        '[StoreKitGateway] queryProductDetails error: ${response.error}',
      );
    }
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint(
        '[StoreKitGateway] product IDs not found in App Store Connect: ${response.notFoundIDs}',
      );
    }

    final orderedProductDetails = orderProductDetailsByIds(
      ids,
      _storeProvider == StoreProvider.google
          ? selectGooglePlayOffers(response.productDetails)
          : response.productDetails,
    );
    final loadedIds = orderedProductDetails
        .map((product) => product.id)
        .toList(growable: false);
    final loadedIdSet = loadedIds.toSet();
    final responseNotFoundIds = response.notFoundIDs.toSet();
    final missingIds = [
      for (final id in ids)
        if (!loadedIdSet.contains(id) || responseNotFoundIds.contains(id)) id,
    ];
    final loadedProducts = orderedProductDetails
        .map(_mapProductDetails)
        .toList(growable: false);
    if (response.error != null) {
      throw StoreProductLoadException(
        code: 'store_product_query_error',
        message: response.error?.message ?? 'Store product query failed',
        requestedIds: ids,
        notFoundIds: missingIds,
        loadedIds: loadedIds,
        loadedProducts: loadedProducts,
        storeErrorCode: response.error?.code,
        storeErrorMessage: response.error?.message,
      );
    }

    if (orderedProductDetails.length != ids.length) {
      throw StoreProductLoadException(
        code: loadedProducts.isEmpty
            ? 'store_products_not_found'
            : 'store_products_partial',
        message: loadedProducts.isEmpty
            ? 'Store did not return requested products'
            : 'Store did not return every requested product',
        requestedIds: ids,
        notFoundIds: missingIds,
        loadedIds: loadedIds,
        loadedProducts: loadedProducts,
      );
    }

    return loadedProducts;
  }

  PaymentProduct _mapProductDetails(iap.ProductDetails details) {
    return PaymentProduct(
      id: details.id,
      type: ProductCatalog.typeFor(details.id),
      title: details.title,
      description: details.description,
      localizedPrice: details.price,
      rawPrice: details.rawPrice,
      currencyCode: details.currencyCode,
      rawDetails: details,
    );
  }

  @override
  Future<PurchaseResult> purchase(
    PaymentProduct product, {
    String? userToken,
  }) async {
    final details = product.rawDetails;
    if (details is! iap.ProductDetails) {
      return PurchaseResult(
        productId: product.id,
        status: PurchaseStatus.error,
        errorMessage: 'Missing ProductDetails for product ${product.id}',
      );
    }

    if (_storeProvider == StoreProvider.apple) {
      throw StateError('Apple purchases require ApplePurchaseCoordinator');
    }

    final purchaseParam = iap.PurchaseParam(
      productDetails: details,
      applicationUserName: _storeProvider == StoreProvider.google
          ? googlePlayObfuscatedAccountId(userToken)
          : userToken,
    );

    // Set up a completer BEFORE calling buy* so we don't miss the stream event.
    final completer = Completer<PurchaseResult>();
    _pendingPurchases[product.id] = _PendingStorePurchase(
      completer: completer,
      appAccountToken: _storeProvider == StoreProvider.apple
          ? userToken
          : googlePlayObfuscatedAccountId(userToken),
    );

    try {
      final bool launched;
      if (product.type == ProductType.consumable) {
        launched = await _iap.buyConsumable(
          purchaseParam: purchaseParam,
          // StoreKit requires consumables to use auto-consume. Google Play
          // keeps the token unconsumed until backend verification succeeds.
          autoConsume: _storeProvider == StoreProvider.apple,
        );
      } else {
        launched = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      }

      if (!launched) {
        _pendingPurchases.remove(product.id);
        return PurchaseResult(
          productId: product.id,
          status: PurchaseStatus.error,
          storeProvider: _storeProvider,
          errorMessage: 'purchase_start_returned_false',
        );
      }
    } catch (e) {
      _pendingPurchases.remove(product.id);
      final errorMessage = 'purchase_start_exception:${e.runtimeType}:$e';
      debugPrint('[StoreKitGateway] $errorMessage');
      return PurchaseResult(
        productId: product.id,
        status: PurchaseStatus.error,
        storeProvider: _storeProvider,
        errorMessage: errorMessage,
      );
    }

    // Safety timeout so a hung Apple sheet doesn't strand the cubit forever.
    return completer.future.timeout(
      _purchaseTerminalUpdateTimeout,
      onTimeout: () {
        _pendingPurchases.remove(product.id);
        return PurchaseResult(
          productId: product.id,
          status: PurchaseStatus.error,
          errorMessage: 'purchase_timeout',
        );
      },
    );
  }

  @override
  Future<void> finalize(PurchaseResult result) async {
    // Google verification succeeds only after the backend acknowledges or
    // consumes the token. A second client acknowledgement can fail after
    // consumption and incorrectly leave an already delivered purchase pending.
    if (_storeProvider == StoreProvider.google) return;
    throw StateError('Apple finish requires ApplePurchaseCoordinator');
  }

  @override
  Future<List<PurchaseResult>> restorePurchases() async {
    if (_storeProvider == StoreProvider.apple) {
      throw StateError('Apple restore requires ApplePurchaseCoordinator');
    }
    final collected = <PurchaseResult>[];

    late final StreamSubscription<List<iap.PurchaseDetails>> sub;
    sub = _iap.purchaseStream.listen((purchases) {
      for (final p in purchases) {
        if (p.status == iap.PurchaseStatus.restored) {
          final result = _mapPurchase(p);
          if (_storeProvider != StoreProvider.google ||
              result.status == PurchaseStatus.success) {
            collected.add(result);
          }
        }
      }
    });

    try {
      await _iap.restorePurchases().timeout(const Duration(seconds: 30));
      // Preserve the settling window for restored purchase stream updates.
      await Future<void>.delayed(const Duration(seconds: 5));
      return collected;
    } finally {
      await sub.cancel();
    }
  }

  @override
  Future<String?> currentStorefrontCountry() async {
    // TODO: in_app_purchase_storekit doesn't expose storefront country yet
    // in version 3.2.x. Revisit when the plugin surfaces it.
    return null;
  }

  PurchaseResult _mapPurchase(iap.PurchaseDetails details) {
    var status = switch (details.status) {
      iap.PurchaseStatus.purchased => PurchaseStatus.success,
      iap.PurchaseStatus.restored => PurchaseStatus.success,
      iap.PurchaseStatus.pending => PurchaseStatus.pending,
      iap.PurchaseStatus.canceled => PurchaseStatus.canceled,
      iap.PurchaseStatus.error => PurchaseStatus.error,
    };

    if (_storeProvider == StoreProvider.google &&
        details is google.GooglePlayPurchaseDetails &&
        status == PurchaseStatus.success) {
      // The Android plugin labels every restore result "restored", including
      // pending payments. The underlying Billing state controls fulfillment.
      status = switch (details.billingClientPurchase.purchaseState) {
        billing.PurchaseStateWrapper.purchased => PurchaseStatus.success,
        billing.PurchaseStateWrapper.pending => PurchaseStatus.pending,
        billing.PurchaseStateWrapper.unspecified_state => PurchaseStatus.error,
      };
    }

    final verificationData = details.verificationData.serverVerificationData;

    AppleReceipt? apple;
    if (_storeProvider == StoreProvider.apple && verificationData.isNotEmpty) {
      try {
        apple = AppleReceipt.fromJws(verificationData);
      } catch (_) {}
    }
    return PurchaseResult(
      productId: details.productID,
      status: status,
      transactionId: apple?.transactionId ?? details.purchaseID,
      originalTransactionId: apple?.originalTransactionId ?? details.purchaseID,
      signedTransactionJws:
          _storeProvider == StoreProvider.apple && verificationData.isNotEmpty
          ? verificationData
          : null,
      serverVerificationData: verificationData.isNotEmpty
          ? verificationData
          : null,
      storeProvider: _storeProvider,
      errorMessage: details.error?.message,
      rawPurchase: details,
    );
  }

  bool _matchesPendingPurchase(
    iap.PurchaseDetails purchase,
    _PendingStorePurchase pendingPurchase,
  ) {
    if (_storeProvider == StoreProvider.google) {
      // Cancellation/error updates may have no transaction. Successful Google
      // transactions must belong to the account that opened this checkout.
      if (purchase.status == iap.PurchaseStatus.canceled ||
          purchase.status == iap.PurchaseStatus.error) {
        return true;
      }
      return purchase is google.GooglePlayPurchaseDetails &&
          pendingPurchase.appAccountToken != null &&
          purchase.billingClientPurchase.obfuscatedAccountId ==
              pendingPurchase.appAccountToken;
    }
    return false;
  }
}

typedef StoreKitGateway = StoreBillingGateway;

class _PendingStorePurchase {
  final Completer<PurchaseResult> completer;
  final String? appAccountToken;

  const _PendingStorePurchase({
    required this.completer,
    required this.appAccountToken,
  });
}

String? googlePlayObfuscatedAccountId(String? userId) {
  if (userId == null || userId.isEmpty) return null;
  return sha256.convert(utf8.encode(userId)).toString();
}

@visibleForTesting
List<iap.ProductDetails> orderProductDetailsByIds(
  List<String> ids,
  List<iap.ProductDetails> products,
) {
  final productsById = {for (final product in products) product.id: product};
  final orderedProducts = <iap.ProductDetails>[];

  for (final id in ids) {
    final product = productsById.remove(id);
    if (product != null) {
      orderedProducts.add(product);
    }
  }

  return orderedProducts;
}

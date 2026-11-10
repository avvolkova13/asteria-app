import 'dart:async';
import 'package:asteria_app/core/payments/apple/apple_purchase_coordinator.dart';

import 'package:asteria_app/core/payments/api/store_payments_api.dart';
import 'package:asteria_app/core/payments/gateway/payment_gateway.dart';
import 'package:asteria_app/core/payments/models/payment_product.dart';
import 'package:asteria_app/core/payments/models/purchase_result.dart';
import 'package:asteria_app/core/payments/storage/pending_purchases_store.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/paywall_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaywallCubit extends Cubit<PaywallState> {
  final PaymentGateway _storeGateway;
  final StorePaymentsApi? _googlePaymentsApi;
  StorePaymentsApi get _storePaymentsApi => _googlePaymentsApi!;
  final ApplePurchaseCoordinator? appleCoordinator;
  StreamSubscription<ApplePurchaseState>? _appleStates;
  final PendingPurchasesStore _pendingPurchasesStore;
  final MonetizationProvider _monetizationProvider;
  final AuthSessionService _authSession;
  bool _purchaseInProgress = false;
  final Future<Map<String, Object?>?> Function(String productId, String uid)?
  analyticsContext;

  PaywallCubit({
    required PaymentGateway storeGateway,
    StorePaymentsApi? storePaymentsApi,
    this.appleCoordinator,
    required PendingPurchasesStore pendingPurchasesStore,
    required MonetizationProvider monetizationProvider,
    required AuthSessionService authSession,
    this.analyticsContext,
  }) : _storeGateway = storeGateway,
       _googlePaymentsApi = storePaymentsApi,
       _pendingPurchasesStore = pendingPurchasesStore,
       _monetizationProvider = monetizationProvider,
       _authSession = authSession,
       super(const PaywallInitial()) {
    _appleStates = appleCoordinator?.states.listen(_onAppleState);
  }

  void _onAppleState(ApplePurchaseState state) {
    if (isClosed) return;
    final product = state.productId ?? '';
    switch (state.phase) {
      case ApplePurchasePhase.idle:
        emit(const PaywallInitial());
      case ApplePurchasePhase.checking:
        emit(
          product.isEmpty
              ? const PaywallRestoring()
              : PaywallPurchasing(product),
        );
      case ApplePurchasePhase.purchasing:
        emit(PaywallPurchasing(product));
      case ApplePurchasePhase.verifying:
        emit(PaywallVerifying(product));
      case ApplePurchasePhase.canceled:
        emit(PaywallFailed(PaywallFailureCode.canceled, productId: product));
      case ApplePurchasePhase.success:
        final entitlement = state.entitlement;
        if (entitlement != null) {
          emit(
            PaywallSuccess(
              productId: product,
              newBalance: entitlement.balance,
              subscriptionExpiresAt: entitlement.subscriptionExpiresAt,
            ),
          );
        }
      case ApplePurchasePhase.restored:
        emit(PaywallRestored(state.restoredProducts));
      case ApplePurchasePhase.waiting ||
          ApplePurchasePhase.approval ||
          ApplePurchasePhase.accountAction ||
          ApplePurchasePhase.error:
        emit(PaywallAppleStatus(product, state.phase, state.errorCode));
    }
  }

  Future<void> refreshAppleStatus() async =>
      appleCoordinator?.recover(restore: true);

  @override
  Future<void> close() async {
    await _appleStates?.cancel();
    return super.close();
  }

  Future<void> loadProducts(List<String> productIds) async {
    emit(const PaywallLoading());
    try {
      final userId = _authSession.currentUid;
      if (userId != null && userId.isNotEmpty) {
        await _recordDiagnostic(
          userId: userId,
          stage: 'load_products_start',
          details: {'product_ids': productIds},
        );
      }
      final products = await _storeGateway.loadProducts(productIds);
      if (userId != null && userId.isNotEmpty) {
        await _recordDiagnostic(
          userId: userId,
          stage: 'load_products_result',
          details: {
            'requested_count': productIds.length,
            'loaded_count': products.length,
            'loaded_ids': products.map((product) => product.id).toList(),
          },
        );
      }
      emit(PaywallProductsLoaded(products));
    } on StoreProductLoadException catch (e) {
      debugPrint('[PaywallCubit] load products failed: $e');
      final userId = _authSession.currentUid;
      final partialProducts = e.code == 'store_products_partial'
          ? e.loadedProducts
          : const <PaymentProduct>[];
      if (userId != null && userId.isNotEmpty) {
        await _recordDiagnostic(
          userId: userId,
          stage: partialProducts.isEmpty
              ? 'load_products_error'
              : 'load_products_partial',
          details: e.toDiagnosticDetails(),
        );
      }
      if (partialProducts.isNotEmpty) {
        emit(PaywallProductsLoaded(partialProducts));
        return;
      }
      emit(const PaywallFailed(PaywallFailureCode.productsLoad));
    } catch (e) {
      debugPrint('[PaywallCubit] load products failed: $e');
      final userId = _authSession.currentUid;
      if (userId != null && userId.isNotEmpty) {
        await _recordDiagnostic(
          userId: userId,
          stage: 'load_products_error',
          details: {'error': e.toString()},
        );
      }
      emit(const PaywallFailed(PaywallFailureCode.productsLoad));
    }
  }

  Future<void> purchase(PaymentProduct product) async {
    if (appleCoordinator case final coordinator?) {
      await coordinator.purchase(product);
      return;
    }
    if (_purchaseInProgress || state is PaywallRestoring) return;
    final userId = _authSession.currentUid;
    if (userId == null || userId.isEmpty) {
      emit(
        PaywallFailed(
          PaywallFailureCode.notAuthenticated,
          productId: product.id,
        ),
      );
      return;
    }

    _purchaseInProgress = true;
    emit(PaywallPurchasing(product.id));
    try {
      final checkoutContext = await analyticsContext?.call(product.id, userId);
      await _purchase(
        product,
        userId: userId,
        checkoutContext: checkoutContext,
        recoveredTransactions: {},
      );
    } finally {
      _purchaseInProgress = false;
    }
  }

  Future<void> _purchase(
    PaymentProduct product, {
    required String userId,
    required Map<String, Object?>? checkoutContext,
    required Set<String> recoveredTransactions,
  }) async {
    if (_authSession.currentUid != userId) {
      emit(
        PaywallFailed(
          PaywallFailureCode.notAuthenticated,
          productId: product.id,
        ),
      );
      return;
    }
    // Bound recovery even if StoreKit keeps returning unfinished history.
    if (recoveredTransactions.length >= 10) {
      emit(PaywallPending(product.id));
      return;
    }
    emit(PaywallPurchasing(product.id));
    await _recordDiagnostic(
      userId: userId,
      stage: 'purchase_start',
      productId: product.id,
      details: _productProbe(product),
    );

    final PurchaseResult purchaseResult;
    try {
      final purchaseUserToken = await _storePaymentsApi
          .preparePurchaseUserToken(userId);
      await _recordDiagnostic(
        userId: userId,
        stage: 'account_binding_ok',
        productId: product.id,
        details: {'user_token_length': purchaseUserToken.length},
      );
      purchaseResult = await _storeGateway.purchase(
        product,
        userToken: purchaseUserToken,
      );
      await _recordDiagnostic(
        userId: userId,
        stage: 'store_purchase_result',
        productId: product.id,
        details: _purchaseProbe(purchaseResult),
      );
    } catch (e) {
      debugPrint('[PaywallCubit] purchase start failed: $e');
      await _recordDiagnostic(
        userId: userId,
        stage: 'purchase_start_error',
        productId: product.id,
        details: {'error': e.toString()},
      );
      emit(
        PaywallFailed(PaywallFailureCode.purchaseStart, productId: product.id),
      );
      return;
    }

    if (purchaseResult.storeProvider == StoreProvider.google &&
        purchaseResult.status == PurchaseStatus.pending) {
      // Google may await an external payment method. The lifecycle recovery
      // verifies and delivers only after Play reports the purchase as paid.
      emit(PaywallPending(product.id));
      return;
    }

    if (purchaseResult.status == PurchaseStatus.canceled) {
      await _recordDiagnostic(
        userId: userId,
        stage: 'purchase_canceled',
        productId: product.id,
        details: _purchaseProbe(purchaseResult),
      );
      emit(PaywallFailed(PaywallFailureCode.canceled, productId: product.id));
      return;
    }
    if (purchaseResult.status != PurchaseStatus.success) {
      await _recordDiagnostic(
        userId: userId,
        stage: 'purchase_failed',
        productId: product.id,
        details: _purchaseProbe(purchaseResult),
      );
      emit(
        PaywallFailed(PaywallFailureCode.purchaseFailed, productId: product.id),
      );
      return;
    }

    final verificationData = purchaseResult.verificationData;
    if (verificationData == null || verificationData.isEmpty) {
      await _recordDiagnostic(
        userId: userId,
        stage: 'verification_missing',
        productId: product.id,
        details: _purchaseProbe(purchaseResult),
      );
      emit(
        PaywallFailed(
          PaywallFailureCode.verificationMissing,
          productId: product.id,
        ),
      );
      return;
    }

    final originalTxId = purchaseResult.originalTransactionId ?? product.id;
    final verificationContext = checkoutContext;

    // Save pending BEFORE verify so a crash mid-verify still recovers.
    await _pendingPurchasesStore.save(
      PendingPurchase(
        originalTransactionId: originalTxId,
        productId: product.id,
        signedTransactionJws: verificationData,
        userId: userId,
        createdAt: DateTime.now(),
        storeProvider: purchaseResult.storeProvider ?? StoreProvider.apple,
        analyticsContext: verificationContext,
      ),
    );
    await _recordDiagnostic(
      userId: userId,
      stage: 'pending_saved',
      productId: product.id,
      details: {
        'original_transaction_id': originalTxId,
        'verification_data_length': verificationData.length,
      },
    );

    if (_authSession.currentUid != userId) {
      debugPrint(
        '[PaywallCubit] account changed before verify; keeping pending',
      );
      await _recordDiagnostic(
        userId: userId,
        stage: 'account_changed_before_verify',
        productId: product.id,
        details: {'current_uid': _authSession.currentUid},
      );
      emit(PaywallPending(product.id));
      return;
    }

    emit(PaywallVerifying(product.id));
    await _recordDiagnostic(
      userId: userId,
      stage: 'verify_start',
      productId: product.id,
      details: {
        'original_transaction_id': originalTxId,
        'verification_data_length': verificationData.length,
      },
    );

    try {
      final response = await _storePaymentsApi.verify(
        userId: userId,
        verificationData: verificationData,
        productId: product.id,
        analyticsContext: verificationContext,
      );

      // Apple-side finalize first — only after backend ack to avoid losing
      // unverified transactions.
      await _storeGateway.finalize(purchaseResult);
      await _pendingPurchasesStore.delete(originalTxId);

      if (_authSession.currentUid != userId) {
        emit(
          PaywallFailed(
            PaywallFailureCode.notAuthenticated,
            productId: product.id,
          ),
        );
        return;
      }
      await _syncUserState(response);
      if (_authSession.currentUid != userId) {
        emit(
          PaywallFailed(
            PaywallFailureCode.notAuthenticated,
            productId: product.id,
          ),
        );
        return;
      }
      await _recordDiagnostic(
        userId: userId,
        stage: 'verify_success',
        productId: product.id,
        details: {
          'transaction_id': response.transactionId,
          'status': response.status,
          'balance': response.balance,
          'subscription_type': response.subscriptionType,
          'subscription_expires_at': response.subscriptionExpiresAt
              ?.toIso8601String(),
          'subscription_provider': response.subscriptionProvider,
          'product_type': response.productType,
        },
      );

      emit(
        PaywallSuccess(
          productId: product.id,
          newBalance: response.balance,
          subscriptionExpiresAt: response.subscriptionExpiresAt,
        ),
      );
    } on StoreVerifyInvalidPurchaseException catch (e) {
      debugPrint('[PaywallCubit] invalid JWS: $e');
      await _pendingPurchasesStore.markFailed(originalTxId);
      await _recordDiagnostic(
        userId: userId,
        stage: 'verify_invalid_purchase',
        productId: product.id,
        details: {'error': e.toString()},
      );
      emit(
        PaywallFailed(
          PaywallFailureCode.verificationRejected,
          productId: product.id,
        ),
      );
    } on StoreVerifyBadRequestException catch (e) {
      debugPrint('[PaywallCubit] bad request: $e');
      await _pendingPurchasesStore.markFailed(originalTxId);
      await _recordDiagnostic(
        userId: userId,
        stage: 'verify_bad_request',
        productId: product.id,
        details: {'error': e.toString()},
      );
      emit(
        PaywallFailed(
          PaywallFailureCode.supportRequired,
          productId: product.id,
        ),
      );
    } on StoreVerifyServerException catch (e) {
      debugPrint('[PaywallCubit] server error, will retry on next launch: $e');
      // Keep entry in Hive (not marked failed) — pending resync on next
      // app launch will retry.
      await _recordDiagnostic(
        userId: userId,
        stage: 'verify_server_error',
        productId: product.id,
        details: {'error': e.toString()},
      );
      emit(PaywallPending(product.id));
    } catch (e) {
      debugPrint('[PaywallCubit] unexpected verify error: $e');
      await _recordDiagnostic(
        userId: userId,
        stage: 'verify_unexpected_error',
        productId: product.id,
        details: {'error': e.toString()},
      );
      emit(PaywallPending(product.id));
    }
  }

  Future<void> restorePurchases() async {
    if (appleCoordinator case final coordinator?) {
      await coordinator.recover(restore: true);
      return;
    }
    if (state is PaywallLoading ||
        state is PaywallPurchasing ||
        state is PaywallVerifying) {
      return;
    }
    emit(const PaywallRestoring());

    final userId = _authSession.currentUid;
    if (userId == null || userId.isEmpty) {
      emit(const PaywallFailed(PaywallFailureCode.notAuthenticated));
      return;
    }

    final List<PurchaseResult> restored;
    try {
      restored = await _storeGateway.restorePurchases();
    } catch (e) {
      debugPrint('[PaywallCubit] restore failed: $e');
      emit(const PaywallFailed(PaywallFailureCode.restoreFailed));
      return;
    }

    if (_authSession.currentUid != userId) {
      emit(const PaywallFailed(PaywallFailureCode.notAuthenticated));
      return;
    }

    final restoredProductIds = <String>{};
    var verificationFailed = false;
    for (final result in restored) {
      final verificationData = result.verificationData;
      if (verificationData == null || verificationData.isEmpty) {
        verificationFailed = true;
        continue;
      }
      if (_authSession.currentUid != userId) {
        debugPrint(
          '[PaywallCubit] account changed during restore; stopping verify',
        );
        emit(const PaywallFailed(PaywallFailureCode.notAuthenticated));
        return;
      }
      try {
        final response = await _storePaymentsApi.verify(
          userId: userId,
          verificationData: verificationData,
          productId: result.productId,
        );
        if (_authSession.currentUid != userId) {
          emit(const PaywallFailed(PaywallFailureCode.notAuthenticated));
          return;
        }
        await _storeGateway.finalize(result);
        if (result.storeProvider == StoreProvider.google &&
            _authSession.currentUid != userId) {
          emit(const PaywallFailed(PaywallFailureCode.notAuthenticated));
          return;
        }
        await _syncUserState(response);
        restoredProductIds.add(result.productId);
      } catch (e) {
        verificationFailed = true;
        debugPrint(
          '[PaywallCubit] restore verify failed for ${result.productId}: $e',
        );
      }
    }

    emit(
      verificationFailed
          ? const PaywallFailed(PaywallFailureCode.restoreFailed)
          : PaywallRestored(restoredProductIds.toList()),
    );
  }

  Future<void> _syncUserState(StoreVerifyResponse response) async {
    await _monetizationProvider.refreshAfterVerify(response);
  }

  Future<void> _recordDiagnostic({
    required String userId,
    required String stage,
    String? productId,
    Map<String, Object?> details = const {},
  }) async {
    if (appleCoordinator != null) return;
    try {
      await _storePaymentsApi.recordClientDiagnostic(
        userId: userId,
        stage: stage,
        productId: productId,
        details: details,
      );
    } catch (e) {
      debugPrint('[PaywallCubit] diagnostic failed: $e');
    }
  }

  Map<String, Object?> _productProbe(PaymentProduct product) => {
    'id': product.id,
    'type': product.type.name,
    'localized_price': product.localizedPrice,
    'raw_price': product.rawPrice,
    'currency_code': product.currencyCode,
  };

  Map<String, Object?> _purchaseProbe(PurchaseResult result) => {
    'product_id': result.productId,
    'status': result.status.name,
    'original_transaction_id': result.originalTransactionId,
    'has_verification_data': result.verificationData?.isNotEmpty == true,
    'verification_data_length': result.verificationData?.length ?? 0,
    'signed_transaction_jws_length': result.signedTransactionJws?.length ?? 0,
    'server_verification_data_length':
        result.serverVerificationData?.length ?? 0,
    'store_provider': result.storeProvider?.name,
    'error_message': result.errorMessage,
  };
}

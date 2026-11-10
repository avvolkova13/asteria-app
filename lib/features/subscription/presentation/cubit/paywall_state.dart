import 'package:asteria_app/core/payments/apple/apple_purchase_coordinator.dart';
import 'package:asteria_app/core/payments/models/payment_product.dart';
import 'package:equatable/equatable.dart';

sealed class PaywallState extends Equatable {
  const PaywallState();

  @override
  List<Object?> get props => const [];
}

enum PaywallFailureCode {
  productsLoad,
  notAuthenticated,
  purchaseStart,
  canceled,
  purchaseFailed,
  verificationMissing,
  verificationRejected,
  supportRequired,
  restoreFailed,
}

class PaywallInitial extends PaywallState {
  const PaywallInitial();
}

class PaywallLoading extends PaywallState {
  const PaywallLoading();
}

class PaywallRestoring extends PaywallLoading {
  const PaywallRestoring();
}

class PaywallProductsLoaded extends PaywallState {
  final List<PaymentProduct> products;
  const PaywallProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class PaywallPurchasing extends PaywallState {
  final String productId;
  const PaywallPurchasing(this.productId);

  @override
  List<Object?> get props => [productId];
}

class PaywallVerifying extends PaywallState {
  final String productId;
  const PaywallVerifying(this.productId);

  @override
  List<Object?> get props => [productId];
}

class PaywallSuccess extends PaywallState {
  final String productId;
  final int newBalance;
  final DateTime? subscriptionExpiresAt;

  const PaywallSuccess({
    required this.productId,
    required this.newBalance,
    this.subscriptionExpiresAt,
  });

  @override
  List<Object?> get props => [productId, newBalance, subscriptionExpiresAt];
}

class PaywallPending extends PaywallState {
  final String productId;
  const PaywallPending(this.productId);

  @override
  List<Object?> get props => [productId];
}

class PaywallRestored extends PaywallState {
  final List<String> restoredProductIds;
  const PaywallRestored(this.restoredProductIds);

  @override
  List<Object?> get props => [restoredProductIds];
}

class PaywallFailed extends PaywallState {
  final PaywallFailureCode code;
  final String? productId;
  const PaywallFailed(this.code, {this.productId});

  @override
  List<Object?> get props => [code, productId];
}

class PaywallAppleStatus extends PaywallPending {
  final ApplePurchasePhase phase;
  final String? errorCode;
  const PaywallAppleStatus(super.productId, this.phase, this.errorCode);
  @override
  List<Object?> get props => [productId, phase, errorCode];
}

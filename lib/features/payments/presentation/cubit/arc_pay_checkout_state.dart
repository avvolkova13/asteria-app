import 'package:asteria_app/core/payments/api/arc_pay_payments_api.dart';
import 'package:equatable/equatable.dart';

sealed class ArcPayCheckoutState extends Equatable {
  const ArcPayCheckoutState();

  @override
  List<Object?> get props => const [];
}

enum ArcPayCheckoutErrorCode {
  productsUnavailable,
  authenticationRequired,
  noPendingPayment,
  createPayment,
}

final class ArcPayCheckoutInitial extends ArcPayCheckoutState {
  const ArcPayCheckoutInitial();
}

final class ArcPayProductsLoading extends ArcPayCheckoutState {
  const ArcPayProductsLoading();
}

final class ArcPayProductsLoaded extends ArcPayCheckoutState {
  final List<ArcPayProduct> products;

  const ArcPayProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

final class ArcPayCheckoutCreating extends ArcPayCheckoutState {
  final String productId;

  const ArcPayCheckoutCreating(this.productId);

  @override
  List<Object?> get props => [productId];
}

final class ArcPayCheckoutReady extends ArcPayCheckoutState {
  final ArcPayPendingCheckout checkout;
  final bool restored;

  const ArcPayCheckoutReady(this.checkout, {this.restored = false});

  @override
  List<Object?> get props => [checkout, restored];
}

final class ArcPayCheckoutPending extends ArcPayCheckoutState {
  final ArcPayOrder order;

  const ArcPayCheckoutPending(this.order);

  @override
  List<Object?> get props => [order];
}

final class ArcPayCheckoutConfirming extends ArcPayCheckoutState {
  final ArcPayOrder order;

  const ArcPayCheckoutConfirming(this.order);

  @override
  List<Object?> get props => [order];
}

final class ArcPayCheckoutFulfilled extends ArcPayCheckoutState {
  final ArcPayOrder order;

  const ArcPayCheckoutFulfilled(this.order);

  @override
  List<Object?> get props => [order];
}

final class ArcPayCheckoutTerminalFailure extends ArcPayCheckoutState {
  final ArcPayOrder order;

  const ArcPayCheckoutTerminalFailure(this.order);

  @override
  List<Object?> get props => [order];
}

final class ArcPayCheckoutAbandoned extends ArcPayCheckoutState {
  final bool serverConfirmed;

  const ArcPayCheckoutAbandoned({required this.serverConfirmed});

  @override
  List<Object?> get props => [serverConfirmed];
}

final class ArcPayCheckoutFailure extends ArcPayCheckoutState {
  final ArcPayCheckoutErrorCode code;

  const ArcPayCheckoutFailure(this.code);

  @override
  List<Object?> get props => [code];
}

class ArcPayPendingCheckout extends Equatable {
  final String orderId;
  final String productId;
  final String userId;
  final Uri checkoutUrl;

  const ArcPayPendingCheckout({
    required this.orderId,
    required this.productId,
    required this.userId,
    required this.checkoutUrl,
  });

  @override
  List<Object?> get props => [orderId, productId, userId, checkoutUrl];
}

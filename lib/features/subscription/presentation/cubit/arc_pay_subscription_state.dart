import 'package:asteria_app/core/payments/api/arc_pay_subscriptions_api.dart';
import 'package:equatable/equatable.dart';

sealed class ArcPaySubscriptionState extends Equatable {
  const ArcPaySubscriptionState();

  @override
  List<Object?> get props => const [];
}

enum ArcPaySubscriptionErrorCode {
  productsUnavailable,
  createSubscription,
  cancelSubscription,
  subscriptionNotFound,
  retryPayment,
}

final class ArcPaySubscriptionInitial extends ArcPaySubscriptionState {
  const ArcPaySubscriptionInitial();
}

final class ArcPaySubscriptionProductsLoading extends ArcPaySubscriptionState {
  const ArcPaySubscriptionProductsLoading();
}

final class ArcPaySubscriptionProductsLoaded extends ArcPaySubscriptionState {
  final List<ArcPaySubscriptionProduct> products;

  const ArcPaySubscriptionProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

final class ArcPaySubscriptionCreating extends ArcPaySubscriptionState {
  const ArcPaySubscriptionCreating();
}

final class ArcPaySubscriptionCheckoutReady extends ArcPaySubscriptionState {
  final ArcPaySubscription subscription;
  final bool restored;

  const ArcPaySubscriptionCheckoutReady(
    this.subscription, {
    this.restored = false,
  });

  @override
  List<Object?> get props => [subscription, restored];
}

final class ArcPaySubscriptionPending extends ArcPaySubscriptionState {
  final ArcPaySubscription subscription;

  const ArcPaySubscriptionPending(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

final class ArcPaySubscriptionActive extends ArcPaySubscriptionState {
  final ArcPaySubscription subscription;

  const ArcPaySubscriptionActive(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

final class ArcPaySubscriptionCancelled extends ArcPaySubscriptionState {
  final ArcPaySubscription subscription;

  const ArcPaySubscriptionCancelled(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

final class ArcPaySubscriptionTerminal extends ArcPaySubscriptionState {
  final ArcPaySubscription subscription;

  const ArcPaySubscriptionTerminal(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

final class ArcPaySubscriptionFailure extends ArcPaySubscriptionState {
  final ArcPaySubscriptionErrorCode code;

  const ArcPaySubscriptionFailure(this.code);

  @override
  List<Object?> get props => [code];
}

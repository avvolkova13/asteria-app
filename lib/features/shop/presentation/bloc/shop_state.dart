part of 'shop_bloc.dart';

abstract class ShopState extends Equatable {
  const ShopState();

  @override
  List<Object?> get props => [];
}

class ShopInitial extends ShopState {}

class ShopLoading extends ShopState {}

class ShopLoaded extends ShopState {
  final List<ShopItemModel> products;

  const ShopLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class ShopError extends ShopState {
  const ShopError();
}

class ShopPurchaseLoading extends ShopState {
  final List<ShopItemModel> products;

  const ShopPurchaseLoading({required this.products});

  @override
  List<Object?> get props => [products];
}

class ShopPurchaseSuccess extends ShopState {
  final List<ShopItemModel> products;

  const ShopPurchaseSuccess({required this.products});

  @override
  List<Object?> get props => [products];
}

class ShopPurchaseError extends ShopState {
  final List<ShopItemModel> products;

  const ShopPurchaseError({required this.products});

  @override
  List<Object?> get props => [products];
}

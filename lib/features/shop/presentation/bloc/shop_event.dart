part of 'shop_bloc.dart';

abstract class ShopEvent extends Equatable {
  const ShopEvent();

  @override
  List<Object?> get props => [];
}

class ShopLoadProducts extends ShopEvent {
  const ShopLoadProducts();
}

class ShopPurchaseProduct extends ShopEvent {
  final String productId;
  final String productName;
  final String productPrice;

  const ShopPurchaseProduct({
    required this.productId,
    required this.productName,
    required this.productPrice,
  });

  @override
  List<Object?> get props => [productId, productName, productPrice];
}

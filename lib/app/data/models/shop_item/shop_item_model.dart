class ShopItemModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final int price;
  final int? purchasedQuantity;
  final String? route;
  final ShopItemPurchaseModel? purchase;

  const ShopItemModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.price,
    this.purchasedQuantity,
    this.route,
    this.purchase,
  });

  factory ShopItemModel.fromJson(Map<String, dynamic> json) {
    return ShopItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      purchasedQuantity: json['purchased_quantity'] as int?,
      route: json['route'] as String?,
      purchase: json['purchase'] is Map
          ? ShopItemPurchaseModel.fromJson(
              Map<String, dynamic>.from(json['purchase'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'price': price,
      'purchased_quantity': purchasedQuantity,
      'route': route,
      'purchase': purchase?.toJson(),
    };
  }

  ShopItemModel copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    int? price,
    int? purchasedQuantity,
    String? route,
    ShopItemPurchaseModel? purchase,
  }) {
    return ShopItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      purchasedQuantity: purchasedQuantity ?? this.purchasedQuantity,
      route: route ?? this.route,
      purchase: purchase ?? this.purchase,
    );
  }
}

class ShopItemPurchaseModel {
  final String type;
  final String featureKey;
  final int creditQuantity;

  const ShopItemPurchaseModel({
    required this.type,
    required this.featureKey,
    required this.creditQuantity,
  });

  factory ShopItemPurchaseModel.fromJson(Map<String, dynamic> json) {
    return ShopItemPurchaseModel(
      type: json['type']?.toString() ?? '',
      featureKey: json['feature_key']?.toString() ?? '',
      creditQuantity: json['credit_quantity'] is int
          ? json['credit_quantity'] as int
          : int.tryParse(json['credit_quantity']?.toString() ?? '') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'feature_key': featureKey,
      'credit_quantity': creditQuantity,
    };
  }
}

enum ProductType { subscription, consumable, nonConsumable }

class PaymentProduct {
  final String id;
  final ProductType type;
  final String title;
  final String description;
  final String localizedPrice;
  final double rawPrice;
  final String currencyCode;
  final Object? rawDetails;

  const PaymentProduct({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.localizedPrice,
    required this.rawPrice,
    required this.currencyCode,
    this.rawDetails,
  });
}

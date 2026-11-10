import 'package:asteria_app/core/const/pricing_catalog.dart';

class PurchaseProduct {
  final String title;
  final int price;

  const PurchaseProduct({required this.title, required this.price});
}

class PurchaseProductsConst {
  PurchaseProductsConst._();

  static const loveDeck = PurchaseProduct(
    title: 'Любовный расклад',
    price: PricingCatalog.paidTarotSpread,
  );
  static const keltDeck = PurchaseProduct(
    title: 'Кельтский крест',
    price: PricingCatalog.paidTarotSpread,
  );
  static const natalCard = PurchaseProduct(
    title: 'Натальная карта',
    price: PricingCatalog.natalChart,
  );
}

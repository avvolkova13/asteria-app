import 'package:asteria_app/core/payments/models/payment_product.dart';

class ProductCatalog {
  static const Map<String, ProductType> _types = {
    'asteria_pro_week': ProductType.subscription,
    'asteria_pro_month': ProductType.subscription,
    'asteria_pro_year': ProductType.subscription,
    'asteria_stars_10': ProductType.consumable,
    'asteria_stars_30': ProductType.consumable,
    'asteria_stars_60': ProductType.consumable,
    'asteria_stars_120': ProductType.consumable,
    'asteria_stars_300': ProductType.consumable,
  };

  static ProductType typeFor(String productId) =>
      _types[productId] ?? ProductType.nonConsumable;

  static const List<String> subscriptionIds = [
    'asteria_pro_week',
    'asteria_pro_month',
    'asteria_pro_year',
  ];

  static const List<String> consumableIds = [
    'asteria_stars_10',
    'asteria_stars_30',
    'asteria_stars_60',
    'asteria_stars_120',
    'asteria_stars_300',
  ];

  static const List<String> allIds = [...subscriptionIds, ...consumableIds];
}

import 'package:asteria_app/core/services/hive/hive_service.dart';

class ArcPayPendingOrder {
  final String orderId;
  final String productId;
  final int amountMinor;
  final String currency;
  final String userId;
  final Uri checkoutUrl;

  const ArcPayPendingOrder({
    required this.orderId,
    required this.productId,
    required this.amountMinor,
    required this.currency,
    required this.userId,
    required this.checkoutUrl,
  });

  Map<String, dynamic> toMap() => {
    'order_id': orderId,
    'product_id': productId,
    'amount_minor': amountMinor,
    'currency': currency,
    'user_id': userId,
    'checkout_url': checkoutUrl.toString(),
  };

  factory ArcPayPendingOrder.fromMap(Map<dynamic, dynamic> map) =>
      ArcPayPendingOrder(
        orderId: map['order_id'] as String,
        productId: map['product_id'] as String,
        amountMinor: map['amount_minor'] as int,
        currency: map['currency'] as String,
        userId: map['user_id'] as String,
        checkoutUrl: Uri.parse(map['checkout_url'] as String),
      );
}

class ArcPayPendingOrderStore {
  static const _key = 'arc_pay_pending_order';

  ArcPayPendingOrder? read() {
    final value = HiveService.appSettingsBox.get(_key);
    if (value == null) return null;
    try {
      return ArcPayPendingOrder.fromMap(value);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(ArcPayPendingOrder order) =>
      HiveService.appSettingsBox.put(_key, order.toMap());

  Future<void> clear() => HiveService.appSettingsBox.delete(_key);
}

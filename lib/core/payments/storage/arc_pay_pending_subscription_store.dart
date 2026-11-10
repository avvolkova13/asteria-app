import 'package:asteria_app/core/services/hive/hive_service.dart';

class ArcPayPendingSubscription {
  final String subscriptionId;
  final String productId;
  final String? userId;
  final Uri checkoutUrl;

  const ArcPayPendingSubscription({
    required this.subscriptionId,
    required this.productId,
    required this.userId,
    required this.checkoutUrl,
  });

  Map<String, dynamic> toMap() => {
    'subscription_id': subscriptionId,
    'product_id': productId,
    'user_id': userId,
    'checkout_url': checkoutUrl.toString(),
  };

  factory ArcPayPendingSubscription.fromMap(Map<dynamic, dynamic> map) =>
      ArcPayPendingSubscription(
        subscriptionId: map['subscription_id'] as String,
        productId: map['product_id'] as String,
        userId: map['user_id'] as String?,
        checkoutUrl: Uri.parse(map['checkout_url'] as String),
      );
}

class ArcPayPendingSubscriptionStore {
  static const _key = 'arc_pay_pending_subscription';

  ArcPayPendingSubscription? read() {
    final value = HiveService.appSettingsBox.get(_key);
    if (value == null) return null;
    try {
      return ArcPayPendingSubscription.fromMap(value);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(ArcPayPendingSubscription subscription) =>
      HiveService.appSettingsBox.put(_key, subscription.toMap());

  Future<void> clear() => HiveService.appSettingsBox.delete(_key);
}

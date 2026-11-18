import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:asteria_app/core/services/hive/hive_service.dart';

class ArcPayPendingOrder {
  final String orderId;
  final String productId;
  final int amountMinor;
  final String currency;
  final String userId;
  final Uri checkoutUrl;
  final String? requestKey;
  final String? requestId;

  const ArcPayPendingOrder({
    required this.orderId,
    required this.productId,
    required this.amountMinor,
    required this.currency,
    required this.userId,
    required this.checkoutUrl,
    this.requestKey,
    this.requestId,
  });

  Map<String, dynamic> toMap() => {
    'order_id': orderId,
    'product_id': productId,
    'amount_minor': amountMinor,
    'currency': currency,
    'user_id': userId,
    'checkout_url': checkoutUrl.toString(),
    if (requestKey != null) 'request_key': requestKey,
    if (requestId != null) 'request_id': requestId,
  };

  factory ArcPayPendingOrder.fromMap(Map<dynamic, dynamic> map) =>
      ArcPayPendingOrder(
        orderId: map['order_id'] as String,
        productId: map['product_id'] as String,
        amountMinor: map['amount_minor'] as int,
        currency: map['currency'] as String,
        userId: map['user_id'] as String,
        checkoutUrl: Uri.parse(map['checkout_url'] as String),
        requestKey: map['request_key'] as String?,
        requestId: map['request_id'] as String?,
      );
}

class ArcPayCheckoutRequest {
  const ArcPayCheckoutRequest({
    required this.key,
    required this.requestId,
    this.analyticsContext,
  });

  final String key;
  final String requestId;
  final Map<String, Object?>? analyticsContext;

  static String keyFor({
    required String userId,
    required String productId,
    required int amountMinor,
    required String currency,
    required String platform,
  }) =>
      'arc_pay_checkout_request:${jsonEncode([userId, productId, amountMinor, currency, platform])}';

  Map<String, dynamic> toMap() => {
    'request_id': requestId,
    if (analyticsContext != null) 'analytics_context': analyticsContext,
  };

  factory ArcPayCheckoutRequest.fromMap(
    String key,
    Map<dynamic, dynamic> map,
  ) => ArcPayCheckoutRequest(
    key: key,
    requestId: map['request_id'] as String,
    analyticsContext: map['analytics_context'] == null
        ? null
        : Map<String, Object?>.from(map['analytics_context'] as Map),
  );
}

class ArcPayPendingOrderStore {
  ArcPayPendingOrderStore({Box<Map>? box}) : _box = box;

  static const _key = 'arc_pay_pending_order';
  final Box<Map>? _box;
  Box<Map> get _settings => _box ?? HiveService.appSettingsBox;

  ArcPayCheckoutRequest? readCheckoutRequest(String key) {
    final value = _settings.get(key);
    return value == null ? null : ArcPayCheckoutRequest.fromMap(key, value);
  }

  Future<ArcPayCheckoutRequest> saveCheckoutRequestIfAbsent(
    ArcPayCheckoutRequest request,
  ) async {
    final selected = readCheckoutRequest(request.key) ?? request;
    // Hive updates its cache synchronously. Every caller awaits its own write,
    // including a concurrent retry that observes the first write in that cache.
    await _settings.put(selected.key, selected.toMap());
    return selected;
  }

  Future<void> _clearRequest(ArcPayPendingOrder order) async {
    final key = order.requestKey;
    if (key == null || order.requestId == null) return;
    if (readCheckoutRequest(key)?.requestId == order.requestId) {
      await _settings.delete(key);
    }
  }

  ArcPayPendingOrder? read() {
    final value = _settings.get(_key);
    if (value == null) return null;
    try {
      return ArcPayPendingOrder.fromMap(value);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(ArcPayPendingOrder order) async {
    // The order must be recoverable before releasing its creation marker.
    await _settings.put(_key, order.toMap());
    await _clearRequest(order);
  }

  Future<void> clear() async {
    final observedPayload = jsonEncode(_settings.get(_key));
    final order = read();
    if (order != null) await _clearRequest(order);
    // Cleanup may yield while another screen saves a replacement. No await
    // separates this comparison from Hive's synchronous cache deletion.
    if (jsonEncode(_settings.get(_key)) != observedPayload) return;
    await _settings.delete(_key);
  }
}

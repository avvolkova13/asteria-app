import 'dart:io';

import 'package:asteria_app/core/payments/storage/arc_pay_pending_order_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory directory;
  late Box<Map> box;
  late ArcPayPendingOrderStore store;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('arc-pay-requests');
    Hive.init(directory.path);
    box = await Hive.openBox<Map>('settings');
    store = ArcPayPendingOrderStore(box: box);
  });
  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  String key({
    String user = 'user-1',
    String product = 'stars',
    int price = 4900,
    String currency = 'RUB',
    String platform = 'ios',
  }) => ArcPayCheckoutRequest.keyFor(
    userId: user,
    productId: product,
    amountMinor: price,
    currency: currency,
    platform: platform,
  );

  test('request ID and analytics context survive a process restart', () async {
    final request = ArcPayCheckoutRequest(
      key: key(),
      requestId: 'stable-id',
      analyticsContext: const {'attempt_id': 'analytics-attempt'},
    );
    await store.saveCheckoutRequestIfAbsent(request);
    await box.close();
    box = await Hive.openBox<Map>('settings');
    store = ArcPayPendingOrderStore(box: box);
    final restored = store.readCheckoutRequest(key());
    expect(restored?.requestId, 'stable-id');
    expect(restored?.analyticsContext, {'attempt_id': 'analytics-attempt'});
    final retry = await store.saveCheckoutRequestIfAbsent(
      ArcPayCheckoutRequest(key: key(), requestId: 'replacement'),
    );
    expect(retry.requestId, 'stable-id');
    for (final differentKey in [
      key(user: 'user-2'),
      key(product: 'pro'),
      key(price: 9900),
      key(currency: 'USD'),
      key(platform: 'android'),
    ]) {
      expect(store.readCheckoutRequest(differentKey), isNull);
    }
  });

  test('recoverable order replaces only its own creation marker', () async {
    final request = ArcPayCheckoutRequest(key: key(), requestId: 'stable-id');
    await store.saveCheckoutRequestIfAbsent(request);
    final order = ArcPayPendingOrder(
      orderId: 'order-1',
      productId: 'stars',
      amountMinor: 4900,
      currency: 'RUB',
      userId: 'user-1',
      checkoutUrl: Uri.parse('https://checkout.example/1'),
      requestKey: request.key,
      requestId: request.requestId,
    );
    await store.save(order);
    expect(store.read()?.orderId, 'order-1');
    expect(store.readCheckoutRequest(key()), isNull);
    await store.saveCheckoutRequestIfAbsent(
      ArcPayCheckoutRequest(key: key(), requestId: 'new-request'),
    );
    await store.clear();
    expect(store.read(), isNull);
    expect(store.readCheckoutRequest(key())?.requestId, 'new-request');
  });

  test(
    'clearing an old order cannot remove a concurrently saved order',
    () async {
      ArcPayPendingOrder order(String id, String user) => ArcPayPendingOrder(
        orderId: id,
        productId: 'stars',
        amountMinor: 4900,
        currency: 'RUB',
        userId: user,
        checkoutUrl: Uri.parse('https://checkout.example/$id'),
        requestKey: key(user: user),
        requestId: 'request-$id',
      );
      await store.save(order('A', 'user-1'));
      final clearing = store.clear();
      // clear has observed A and yields while cleaning its request marker.
      // Hive puts B in its synchronous cache before clear resumes.
      final saving = store.save(order('B', 'user-2'));
      await Future.wait([clearing, saving]);
      expect(store.read()?.orderId, 'B');
      expect(store.read()?.userId, 'user-2');
      expect(store.read()?.requestId, 'request-B');
    },
  );

  test('legacy orders without request metadata remain readable', () async {
    await box.put('arc_pay_pending_order', {
      'order_id': 'legacy',
      'product_id': 'stars',
      'amount_minor': 4900,
      'currency': 'RUB',
      'user_id': 'user-1',
      'checkout_url': 'https://checkout.example/legacy',
    });
    expect(store.read()?.orderId, 'legacy');
    expect(store.read()?.requestId, isNull);
    await store.clear();
    expect(store.read(), isNull);
  });
}

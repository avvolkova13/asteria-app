import 'dart:io';
import 'package:asteria_app/core/payments/storage/pending_purchases_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory directory;
  late PendingPurchasesStore store;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('apple-journal');
    Hive.init(directory.path);
    store = PendingPurchasesStore();
    await store.init();
  });
  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });
  PendingPurchase receipt(String jws) => PendingPurchase(
    originalTransactionId: 'chain',
    productId: 'asteria_pro_month',
    signedTransactionJws: jws,
    userId: 'old-account',
    createdAt: DateTime.utc(2026),
    failed: true,
  );
  test(
    'actual legacy key and failed receipt remain readable across identities',
    () async {
      await Hive.box<Map>(
        'pending_purchases',
      ).put('legacy-chain-key', receipt('old').toMap());
      final entry = store.entries.single;
      expect(entry.key, 'legacy-chain-key');
      expect(entry.purchase.failed, isTrue);
      expect(await store.deleteObserved(entry), isTrue);
      expect(store.entries, isEmpty);
    },
  );
  test(
    'late finish cannot delete a newer value stored at the same actual key',
    () async {
      await store.saveApple(
        receipt('old'),
        environment: 'test',
        transactionId: 'exact',
      );
      final old = store.entries.single;
      await store.saveApple(
        receipt('new'),
        environment: 'test',
        transactionId: 'exact',
      );
      expect(await store.deleteObserved(old), isFalse);
      expect(store.entries.single.purchase.signedTransactionJws, 'new');
    },
  );
}

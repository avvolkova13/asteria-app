import 'package:asteria_app/core/payments/apple/apple_models.dart';
import 'package:asteria_app/core/payments/models/purchase_result.dart';
import 'package:asteria_app/core/payments/storage/pending_purchases_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'old journal owner is context only and exact receipt identity stays separate',
    () {
      final entry = PendingPurchase(
        originalTransactionId: 'chain',
        productId: 'asteria_pro_month',
        signedTransactionJws: 'old-jws',
        userId: 'old-user',
        createdAt: DateTime.utc(2026),
        storeProvider: StoreProvider.apple,
        failed: true,
      );
      final decoded = PendingPurchase.fromMap(entry.toMap());
      expect(decoded.failed, isTrue);
      expect(decoded.userId, 'old-user');
      const receipt = AppleReceipt(
        jws: 'jws',
        productId: 'asteria_pro_month',
        transactionId: 'exact',
        originalTransactionId: 'chain',
        environment: 'test',
      );
      expect(receipt.transactionId, isNot(receipt.originalTransactionId));
      // Authenticated all-UID replay is exercised against real Hive in coordinator tests.
    },
  );
}

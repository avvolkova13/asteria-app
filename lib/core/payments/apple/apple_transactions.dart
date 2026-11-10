import 'package:asteria_app/core/payments/apple/apple_models.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart' as sk2;

enum AppleNativePurchaseOutcome { success, unverified, canceled, pending }

enum AppleFinishOutcome { finished, alreadyFinished, notPresent }

abstract interface class AppleTransactions {
  Future<List<AppleReceipt>> currentEntitlements();
  Future<List<AppleReceipt>> unfinished();
  Future<AppleNativePurchaseOutcome> purchase(String productId, String token);
  Future<AppleFinishOutcome> finish(String transactionId);
}

class StoreKitAppleTransactions implements AppleTransactions {
  static const _channel = MethodChannel('asteria/apple-transactions');
  @override
  Future<List<AppleReceipt>> currentEntitlements() async {
    final snapshot = await _channel.invokeListMethod<String>(
      'currentEntitlements',
    );
    if (snapshot == null) throw StateError('Incomplete Apple snapshot');
    return snapshot.map(AppleReceipt.fromJws).toList();
  }

  @override
  Future<List<AppleReceipt>> unfinished() async => [
    for (final transaction in await sk2.SK2Transaction.unfinishedTransactions())
      if (transaction.receiptData case final String jws)
        AppleReceipt.fromJws(jws)
      else
        throw StateError('Unfinished transaction missing JWS'),
  ];
  @override
  Future<AppleNativePurchaseOutcome> purchase(
    String productId,
    String token,
  ) async => switch (await sk2.SK2Product.purchase(
    productId,
    options: sk2.SK2ProductPurchaseOptions(appAccountToken: token),
  )) {
    sk2.SK2ProductPurchaseResult.success => AppleNativePurchaseOutcome.success,
    sk2.SK2ProductPurchaseResult.unverified =>
      AppleNativePurchaseOutcome.unverified,
    sk2.SK2ProductPurchaseResult.userCancelled =>
      AppleNativePurchaseOutcome.canceled,
    sk2.SK2ProductPurchaseResult.pending => AppleNativePurchaseOutcome.pending,
  };
  @override
  Future<AppleFinishOutcome> finish(String transactionId) async =>
      switch (await _channel.invokeMethod<String>('finish', {
        'transactionId': transactionId,
      })) {
        'finished' => AppleFinishOutcome.finished,
        'already_finished' => AppleFinishOutcome.alreadyFinished,
        'not_present' => AppleFinishOutcome.notPresent,
        _ => throw StateError('Unconfirmed Apple finish'),
      };
}

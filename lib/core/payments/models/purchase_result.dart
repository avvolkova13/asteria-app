enum PurchaseStatus { success, pending, error, canceled }

enum StoreProvider { apple, google }

class PurchaseResult {
  final String productId;
  final PurchaseStatus status;

  /// Exact transaction identity; distinct from Apple subscription chain identity.
  final String? transactionId;
  final String? originalTransactionId;
  final String? signedTransactionJws;
  final String? serverVerificationData;
  final StoreProvider? storeProvider;
  final String? errorMessage;
  final Object? rawPurchase;
  final bool recoveredFromUnfinished;

  const PurchaseResult({
    required this.productId,
    required this.status,
    this.transactionId,
    this.originalTransactionId,
    this.signedTransactionJws,
    this.serverVerificationData,
    this.storeProvider,
    this.errorMessage,
    this.rawPurchase,
    this.recoveredFromUnfinished = false,
  });

  String? get verificationData =>
      serverVerificationData ?? signedTransactionJws;
}

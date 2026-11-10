class StoreVerifyResponse {
  final String transactionId;
  final String status;
  final int balance;
  final String? subscriptionType;
  final DateTime? subscriptionExpiresAt;
  final String? subscriptionProvider;
  final String? productId;
  final String? productType;

  const StoreVerifyResponse({
    required this.transactionId,
    required this.status,
    required this.balance,
    this.subscriptionType,
    this.subscriptionExpiresAt,
    this.subscriptionProvider,
    this.productId,
    this.productType,
  });

  factory StoreVerifyResponse.fromJson(Map<String, dynamic> json) {
    final expires = json['subscription_expires_at'];
    return StoreVerifyResponse(
      transactionId: json['transaction_id'] as String,
      status: json['status'] as String,
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      subscriptionType: json['subscription_type'] as String?,
      subscriptionExpiresAt: expires is String && expires.isNotEmpty
          ? DateTime.tryParse(expires)
          : null,
      subscriptionProvider: json['subscription_provider'] as String?,
      productId: json['product_id'] as String?,
      productType: json['product_type'] as String?,
    );
  }
}

abstract interface class StorePaymentsApi {
  Future<String> preparePurchaseUserToken(String userId);

  Future<void> recordClientDiagnostic({
    required String userId,
    required String stage,
    String? productId,
    Map<String, Object?> details = const {},
  });

  Future<StoreVerifyResponse> verify({
    required String userId,
    required String verificationData,
    required String productId,
    Map<String, Object?>? analyticsContext,
  });
}

class StoreVerifyInvalidPurchaseException implements Exception {
  const StoreVerifyInvalidPurchaseException(this.message);
  final String message;
  @override
  String toString() => 'StoreVerifyInvalidPurchaseException: $message';
}

class StoreVerifyBadRequestException implements Exception {
  const StoreVerifyBadRequestException(this.message);
  final String message;
  @override
  String toString() => 'StoreVerifyBadRequestException: $message';
}

class StoreVerifyServerException implements Exception {
  const StoreVerifyServerException(this.message);
  final String message;
  @override
  String toString() => 'StoreVerifyServerException: $message';
}

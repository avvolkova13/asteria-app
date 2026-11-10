import 'dart:convert';

class AppleEntitlement {
  final int balance;
  final String subscriptionType;
  final DateTime? subscriptionExpiresAt;
  const AppleEntitlement({
    required this.balance,
    required this.subscriptionType,
    this.subscriptionExpiresAt,
  });
  factory AppleEntitlement.fromJson(Map<String, dynamic> json) =>
      AppleEntitlement(
        balance: (json['balance'] as num).toInt(),
        subscriptionType: json['subscription_type'] as String,
        subscriptionExpiresAt: DateTime.tryParse(
          json['subscription_expires_at'] as String? ?? '',
        ),
      );
}

enum AppleCheckoutAction {
  proceed,
  alreadyActive,
  accountActionRequired,
  retry,
}

AppleCheckoutAction _action(Object? value) => switch (value) {
  'continue' => AppleCheckoutAction.proceed,
  'already_active' => AppleCheckoutAction.alreadyActive,
  'account_action_required' => AppleCheckoutAction.accountActionRequired,
  'retry' => AppleCheckoutAction.retry,
  _ => throw const FormatException('Unknown Apple checkout action'),
};

class AppleCheckout {
  final String attemptId;
  final String appAccountToken;
  final AppleCheckoutAction action;
  const AppleCheckout({
    required this.attemptId,
    required this.appAccountToken,
    required this.action,
  });
  factory AppleCheckout.fromJson(Map<String, dynamic> json) => AppleCheckout(
    attemptId: json['attempt_id'] as String,
    appAccountToken: json['app_account_token'] as String,
    action: _action(json['checkout_action']),
  );
}

class AppleReconciliation {
  final String transactionId;
  final String originalTransactionId;
  final String environment;
  final String productId;
  final String disposition;
  final bool finishAllowed;
  final String finishState;
  final AppleCheckoutAction action;
  final AppleEntitlement entitlement;
  const AppleReconciliation({
    required this.transactionId,
    required this.originalTransactionId,
    required this.environment,
    required this.productId,
    required this.disposition,
    required this.finishAllowed,
    required this.finishState,
    required this.action,
    required this.entitlement,
  });
  bool get delivered =>
      disposition == 'delivered' || disposition == 'already_delivered';
  factory AppleReconciliation.fromJson(Map<String, dynamic> json) =>
      AppleReconciliation(
        transactionId: json['transaction_id'] as String,
        originalTransactionId: json['original_transaction_id'] as String,
        environment: json['environment'] as String,
        productId: json['product_id'] as String,
        disposition: json['disposition'] as String,
        finishAllowed: json['finish_allowed'] as bool,
        finishState: json['finish_state'] as String,
        action: _action(json['checkout_action']),
        entitlement: AppleEntitlement.fromJson(
          json['entitlement'] as Map<String, dynamic>,
        ),
      );
}

class AppleAttemptStatus {
  final String attemptId;
  final String productId;
  final AppleReconciliation? result;
  const AppleAttemptStatus({
    required this.attemptId,
    required this.productId,
    this.result,
  });
  factory AppleAttemptStatus.fromJson(Map<String, dynamic> json) =>
      AppleAttemptStatus(
        attemptId: json['attempt_id'] as String,
        productId: json['product_id'] as String,
        result: json['result'] == null
            ? null
            : AppleReconciliation.fromJson(
                json['result'] as Map<String, dynamic>,
              ),
      );
}

/// Decoded fields are routing hints ONLY. Server verification is the authority.
/// Keep the original JWS even if hints cannot be decoded (legacy journal replay).
class AppleReceipt {
  final String jws;
  final String productId;
  final String transactionId;
  final String originalTransactionId;
  final String environment;
  final String? appAccountToken;
  const AppleReceipt({
    required this.jws,
    required this.productId,
    required this.transactionId,
    required this.originalTransactionId,
    required this.environment,
    this.appAccountToken,
  });
  factory AppleReceipt.fromJws(String jws, {String? productId}) {
    final payload =
        jsonDecode(
              utf8.decode(
                base64Url.decode(base64Url.normalize(jws.split('.')[1])),
              ),
            )
            as Map<String, dynamic>;
    final environment = switch (payload['environment']) {
      'Sandbox' || 'Xcode' || 'test' => 'test',
      'Production' || 'production' => 'production',
      _ => throw const FormatException('Missing Apple environment'),
    };
    return AppleReceipt(
      jws: jws,
      productId: payload['productId'] as String? ?? productId!,
      transactionId: payload['transactionId'] as String,
      originalTransactionId: payload['originalTransactionId'] as String,
      environment: environment,
      appAccountToken: payload['appAccountToken'] as String?,
    );
  }
}

/// Controlled vocabulary for the `failure_reason` analytics parameter.
///
/// Kept as a class of string constants (not an enum) because the list is
/// open-ended and may grow with new payment / auth flows. Never send raw
/// exception messages.
abstract final class FailureReasons {
  FailureReasons._();

  static const String userCancelled = 'user_cancelled';
  static const String paymentDeclined = 'payment_declined';
  static const String networkError = 'network_error';
  static const String qrExpired = 'qr_expired';
  static const String invalidCode = 'invalid_code';
  static const String serverError = 'server_error';
  static const String insufficientBalance = 'insufficient_balance';
  static const String unknown = 'unknown';
}

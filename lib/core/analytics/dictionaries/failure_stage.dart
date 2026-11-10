/// Controlled vocabulary for the `failure_stage` analytics parameter.
///
/// Kept as a class of string constants (not an enum) because the list is
/// open-ended and may grow with new payment / auth flows.
abstract final class FailureStages {
  FailureStages._();

  static const String checkoutStart = 'checkout_start';
  static const String providerRedirect = 'provider_redirect';
  static const String confirmation = 'confirmation';
  static const String requestOtp = 'request_otp';
  static const String verifyCode = 'verify_code';
  static const String saveUser = 'save_user';
  static const String unknown = 'unknown';
}

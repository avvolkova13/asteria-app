/// Controlled vocabulary for the `payment_method_type` analytics parameter.
///
/// High-level payment method category — never raw card details / provider
/// payload.
enum PaymentMethodType {
  card('card'),
  sbp('sbp'),
  qr('qr'),
  applePay('apple_pay'),
  googlePay('google_pay'),
  unknown('unknown');

  const PaymentMethodType(this.value);

  final String value;
}

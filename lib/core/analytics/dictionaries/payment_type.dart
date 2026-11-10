/// Controlled vocabulary for the `payment_type` analytics parameter.
///
/// Describes how the transaction is paid for.
enum PaymentType {
  realMoney('real_money'),
  subscription('subscription'),
  internalCoins('internal_coins');

  const PaymentType(this.value);

  final String value;
}

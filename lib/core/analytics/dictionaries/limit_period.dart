/// Controlled vocabulary for the `limit_period` analytics parameter.
///
/// Describes the recharge cadence of the underlying limit.
enum LimitPeriod {
  day('day'),
  week('week'),
  month('month'),
  lifetime('lifetime'),
  unknown('unknown');

  const LimitPeriod(this.value);

  final String value;
}

/// Controlled vocabulary for the `birth_time_precision` analytics parameter.
///
/// Describes how precise the user's birth time input is — without sending
/// the actual time of birth.
enum BirthTimePrecision {
  exact('exact'),
  approxDay('approx_day'),
  approxNight('approx_night'),
  unknown('unknown');

  const BirthTimePrecision(this.value);

  final String value;
}

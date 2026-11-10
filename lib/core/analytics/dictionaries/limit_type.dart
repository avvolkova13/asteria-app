/// Controlled vocabulary for the `limit_type` analytics parameter.
///
/// Describes what exactly ran out on a `limit_reached` event.
enum LimitType {
  freeAttempts('free_attempts'),
  requests('requests'),
  messages('messages'),
  dailyLimit('daily_limit'),
  weeklyLimit('weekly_limit');

  const LimitType(this.value);

  final String value;
}

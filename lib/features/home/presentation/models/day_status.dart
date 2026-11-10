import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';

enum DayStatus {
  favorable,
  unfavorable,
  neutral;

  factory DayStatus.fromValue(int value) {
    if (value > 0) return DayStatus.favorable;
    if (value < 0) return DayStatus.unfavorable;
    return DayStatus.neutral;
  }

  factory DayStatus.fromRecommendation(RecommendationStatus value) {
    return switch (value) {
      RecommendationStatus.favorable => DayStatus.favorable,
      RecommendationStatus.neutral => DayStatus.neutral,
      RecommendationStatus.unfavorable => DayStatus.unfavorable,
    };
  }
}

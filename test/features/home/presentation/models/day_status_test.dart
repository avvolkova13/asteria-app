import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/models/day_status_assets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('classifies positive zero and negative values by sign', () {
    expect(DayStatus.fromValue(3), DayStatus.favorable);
    expect(DayStatus.fromValue(0), DayStatus.neutral);
    expect(DayStatus.fromValue(-2), DayStatus.unfavorable);
  });

  test('maps backend recommendation statuses semantically', () {
    expect(
      DayStatus.fromRecommendation(RecommendationStatus.favorable),
      DayStatus.favorable,
    );
    expect(
      DayStatus.fromRecommendation(RecommendationStatus.neutral),
      DayStatus.neutral,
    );
    expect(
      DayStatus.fromRecommendation(RecommendationStatus.unfavorable),
      DayStatus.unfavorable,
    );
  });

  test('maps each status to the new Figma star asset only', () {
    expect(
      DayStatus.favorable.iconAssetPath,
      'assets/icons/day_status_favorable_star.png',
    );
    expect(
      DayStatus.neutral.iconAssetPath,
      'assets/icons/day_status_neutral_star.png',
    );
    expect(
      DayStatus.unfavorable.iconAssetPath,
      'assets/icons/day_status_unfavorable_star.png',
    );
    expect(
      DayStatus.values.map((status) => status.iconAssetPath),
      everyElement(
        allOf(startsWith('assets/icons/day_status_'), endsWith('_star.png')),
      ),
    );
  });
}

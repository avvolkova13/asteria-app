import 'dart:io';

import 'package:asteria_app/app/data/models/lunar_calendar/lunar_month_model.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';
import 'package:asteria_app/features/scenarios/calendar_plan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  test(
    'uses the actual activity status and both transplanting API spellings',
    () {
      const favorable = TaskRecommendationModel(
        status: RecommendationStatus.favorable,
        description: 'Suitable for repotting today.',
      );
      for (final key in [
        'transplanting_pricking',
        'transplanting_and_pricking',
      ]) {
        final day = LunarDayModel(
          date: DateTime.utc(2026, 12, 1),
          lunarContext: const LunarDayContextModel(
            lunarDayNumber: 11,
            moonAgeDays: 10,
            moonAgeDayIndex: 10,
            moonPhaseCode: 'test',
            phaseEvent: null,
            moonPhaseName: 'test',
            moonSignCode: 'test',
            moonSignName: 'test',
          ),
          dailyBackground: const DailyBackgroundModel(
            tone: PhaseTone.action,
            title: 'Overall',
            summary: 'General only',
          ),
          spheres: {
            'gardening': SphereRecommendationModel(
              status: RecommendationStatus.unfavorable,
              tasks: {key: favorable},
            ),
          },
        );
        expect(
          CalendarActivity.transplant.recommendation(day),
          same(favorable),
        );
        expect(CalendarActivity.planting.recommendation(day), isNull);
        expect(CalendarActivity.haircut.recommendation(day), isNull);
      }
    },
  );

  test(
    'saved plan survives reopening, is user-scoped and retry is idempotent',
    () async {
      final dir = await Directory.systemTemp.createTemp('asteria_plans_test_');
      Hive.init(dir.path);
      addTearDown(() async {
        await Hive.close();
        await dir.delete(recursive: true);
      });
      const rec = TaskRecommendationModel(
        status: RecommendationStatus.neutral,
        description: 'Calendar excerpt',
      );
      for (final owner in ['a', 'a', 'b']) {
        await CalendarPlans.save(
          CalendarPlan(
            id: 'same-action',
            owner: owner,
            day: DateTime(2026, 12, 1),
            activity: CalendarActivity.transplant,
            title: 'Repot ficus $owner',
            recommendation: rec,
          ),
        );
      }
      await Hive.close();
      final box = await CalendarPlans.open();
      expect(box.length, 2);
      final own = CalendarPlans.read(box, 'a').single;
      expect(own.day, DateTime.utc(2026, 12, 1));
      expect(own.title, 'Repot ficus a');
      expect(own.recommendation.description, rec.description);
      expect(CalendarPlans.read(box, 'unknown'), isEmpty);
    },
  );
}

import 'package:asteria_app/app/data/models/lunar_calendar/lunar_month_model.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/scenarios/calendar_scenario.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  testWidgets(
    'compares dates across months and retains a selection when replacing a date without data',
    (tester) async {
      await initializeDateFormatting('en');
      final now = DateTime.now();
      final month = DateTime(now.year, now.month);
      final next = DateTime(now.year, now.month + 1);
      di.registerSingleton<ContentProvider>(_Calendar());
      addTearDown(() => di.unregister<ContentProvider>());
      final messenger = tester.binding.defaultBinaryMessenger;
      const channel = MethodChannel('asteria/calendar');
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.arguments, 'Europe/Moscow');
        return month.toIso8601String().substring(0, 10);
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocaleService.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          builder: (c, child) =>
              Theme(data: AppThemeDark.instance.getThemeData(c), child: child!),
          home: const CalendarScenarioScreen(),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> tap(Finder finder) async {
        await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
        await tester.pumpAndSettle();
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      await tap(find.text('Repotting plants'));
      await tap(find.text('12').first);
      await tap(find.byTooltip('Next month'));
      await tap(find.text('13').first);
      await tap(find.text('Compare dates'));
      expect(find.text('Repotting on ${month.month}/12'), findsOneWidget);
      expect(
        find.text(
          'There is no recommendation for this activity on this date yet.',
        ),
        findsOneWidget,
      );
      await tap(find.text('Change date'));
      await tap(find.text('12').first);
      await tap(find.text('Compare dates'));
      expect(
        find.text('Both dates have the same rating for this activity.'),
        findsOneWidget,
      );
      expect(find.text('Repotting on ${month.month}/12'), findsOneWidget);
      expect(find.text('Repotting on ${next.month}/12'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

class _Calendar extends Fake implements ContentProvider {
  @override
  Future<LunarMonthModel> loadPersonalizedLunarMonth(
    DateTime month, {
    bool forceRefresh = false,
  }) async => LunarMonthModel(
    year: month.year,
    month: month.month,
    timezone: 'Europe/Moscow',
    anchorLocalTime: '12:00',
    days: [
      LunarDayModel(
        date: DateTime.utc(month.year, month.month, 12),
        lunarContext: const LunarDayContextModel(
          lunarDayNumber: 2,
          moonAgeDays: 1,
          moonAgeDayIndex: 1,
          moonPhaseCode: 'waxing',
          moonPhaseName: 'Waxing',
          moonSignCode: 'a',
          moonSignName: 'A',
          phaseEvent: null,
        ),
        dailyBackground: const DailyBackgroundModel(
          tone: PhaseTone.growth,
          title: 'Growth',
          summary: 'Overview',
        ),
        spheres: {
          'gardening': SphereRecommendationModel(
            status: RecommendationStatus.unfavorable,
            tasks: {
              'transplanting_pricking': TaskRecommendationModel(
                status: RecommendationStatus.favorable,
                description: 'Repotting on ${month.month}/12',
              ),
            },
          ),
        },
      ),
    ],
  );
}

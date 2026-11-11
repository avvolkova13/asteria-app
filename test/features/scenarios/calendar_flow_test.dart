import 'package:asteria_app/app/data/models/lunar_calendar/lunar_month_model.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/services/hive/hive_service.dart';
import 'package:hive/hive.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_cubit.dart';
import 'package:asteria_app/features/home/presentation/screens/moon_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  testWidgets(
    'starts from lunar tab, compares two months, replaces missing data and returns to the tab and its saved plans',
    (tester) async {
      await initializeDateFormatting('en');
      final now = DateTime.now();
      final month = DateTime(now.year, now.month);
      final next = DateTime(now.year, now.month + 1);
      final calendar = _Calendar();
      final analytics = _SilentAnalytics();
      final user = UserProvider(userRepository: _UnusedUserRepository())
        ..applyServerUserSnapshot(
          UserModel.empty().copyWith(id: 'test-calendar-user'),
        );
      await Hive.openBox<Map>(HiveBoxNames.appSettings, bytes: Uint8List(0));
      await Hive.openBox<Map>('calendar_plans_v1', bytes: Uint8List(0));
      di.registerSingleton<UserProvider>(user);
      di.registerSingleton<ContentProvider>(calendar);
      di.registerFactory<MoonScreenCubit>(
        () => MoonScreenCubit(contentProvider: calendar),
      );
      di.registerSingleton<AnalyticsFacade>(analytics);
      di.registerSingleton<ProductAnalyticsService>(
        ProductAnalyticsService(analytics),
      );
      addTearDown(() async {
        await di.unregister<ContentProvider>();
        await di.unregister<MoonScreenCubit>();
        await di.unregister<AnalyticsFacade>();
        await di.unregister<ProductAnalyticsService>();
        await di.unregister<UserProvider>();
        await Hive.close();
        user.dispose();
      });
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
          home: ChangeNotifierProvider<UserProvider>.value(
            value: user,
            child: const MoonScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> tap(Finder finder) async {
        await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
        await tester.pumpAndSettle();
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      final start = find.text('Find a day for an activity');
      expect(start.hitTestable(), findsOneWidget);
      expect(find.text('My plans').hitTestable(), findsOneWidget);
      await tap(start);
      expect(find.text('What are you planning?'), findsOneWidget);
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
      Future<void> back() async {
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }

      await back(); // Comparison → selected dates.
      expect(find.text('Compare dates'), findsOneWidget);
      await back(); // Dates → the same activity list and scroll position.
      expect(find.text('Repotting plants').hitTestable(), findsOneWidget);
      await back(); // Activity → original lunar tab.
      expect(find.text('Lunar calendar'), findsOneWidget);
      await tap(find.text('My plans'));
      expect(
        find.text('Activities you schedule will appear here.'),
        findsOneWidget,
      );
      await back();
      expect(start.hitTestable(), findsOneWidget);
      final originalTab = tester.state(find.byType(MoonScreen));
      await tap(start);
      await tap(find.text('Repotting plants'));
      await tap(find.text('12').first);
      await tap(find.text('View this day'));
      await tap(find.text('Choose this day'));
      await tester.enterText(find.byType(TextField), 'Repot the ficus');
      await tap(find.text('Save'));
      expect(find.text('Plan saved'), findsOneWidget);
      await tap(find.text('Back to calendar'));
      expect(tester.state(find.byType(MoonScreen)), same(originalTab));
      await tap(find.text('My plans'));
      await tap(find.text('Repot the ficus'));
      expect(find.text('Repotting on ${month.month}/12'), findsOneWidget);
      await tap(find.text('Back to calendar'));
      expect(tester.state(find.byType(MoonScreen)), same(originalTab));
      expect(Navigator.of(tester.element(start)).canPop(), isFalse);
      calendar.empty = true;
      await tap(start);
      await tap(find.text('Haircuts'));
      await tap(find.text('12').first);
      await tap(find.text('13').first);
      await tap(find.text('Compare dates'));
      expect(
        find.text(
          'There is no recommendation for this activity on this date yet.',
        ),
        findsNWidgets(2),
      );
      expect(
        find.text('Both dates have the same rating for this activity.'),
        findsNothing,
      );
      await tap(find.text('Choose this day').first);
      await tester.enterText(
        find.byType(TextField),
        'Trim without lunar rating',
      );
      await tap(find.text('Save'));
      await tap(find.text('Back to calendar'));
      await tap(find.text('My plans'));
      await tap(find.text('Trim without lunar rating'));
      expect(find.text('Haircuts'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

class _SilentAnalytics extends Fake implements AnalyticsFacade {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {}
}

class _UnusedUserRepository extends Fake implements UserRepository {}

class _Calendar extends Fake implements ContentProvider {
  bool empty = false;
  @override
  LunarDayModel? getPersonalizedLunarDayByDate(DateTime date) => null;
  @override
  Future<LunarMonthModel> loadPersonalizedLunarMonth(
    DateTime month, {
    bool forceRefresh = false,
  }) async => LunarMonthModel(
    year: month.year,
    month: month.month,
    timezone: 'Europe/Moscow',
    anchorLocalTime: '12:00',
    days: empty
        ? []
        : [
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

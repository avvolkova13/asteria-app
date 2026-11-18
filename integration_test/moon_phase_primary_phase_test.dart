import 'package:asteria_app/app/data/models/lunar_calendar/lunar_month_model.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';
import 'package:asteria_app/app/data/repositories/lunar_calendar/personalized_lunar_calendar_repository.dart';

import 'dart:io';

import 'package:asteria_app/app/data/models/moon_phase/moon_phase_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/content/content_repository.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/compatibility/domain/repositories/compatibility_repository.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_phase_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders primary moon phase event time on device', (
    tester,
  ) async {
    await di.reset();

    final moonPhase = MoonPhaseModel(
      date: _formatDate(DateTime.now()),
      lunarDay: 15,
      moonSign: 'aries',
      moonPhase: 'full_moon',
      moonPhaseRu: 'Полнолуние',
      moonriseLocal: '12:00',
      phaseEvent: const MoonPhaseEventModel(
        phase: 'full_moon',
        phaseRu: 'Полнолуние',
        exactUtc: '2026-05-01T17:23:00Z',
        exactLocal: '2026-05-01T20:23:00+03:00',
        localDate: '2026-05-01',
      ),
    );
    final userProvider = UserProvider(userRepository: _UnusedUserRepository())
      ..applyServerUserSnapshot(
        UserModel.empty().copyWith(
          moonPhase: moonPhase,
          currentLocation: const CurrentLocationModel(
            location: 'Амстердам, Нидерланды',
            latitude: 52.3676,
            longitude: 4.9041,
            source: CurrentLocationSource.manual,
          ),
        ),
      );
    final contentProvider = ContentProvider(
      contentRepository: _MoonPhaseContentRepository(moonPhase),
      userProvider: userProvider,
      compatibilityRepository: _UnusedCompatibilityRepository(),
      personalizedLunarCalendarRepository: const _PersonalizedRepository(),
    );
    final homeCubit = HomeCubit(
      userRepository: _UnusedUserRepository(),
      contentProvider: contentProvider,
      userProvider: userProvider,
    );
    di.registerSingleton<UserProvider>(userProvider);
    di.registerSingleton<ContentProvider>(contentProvider);
    addTearDown(() async {
      await homeCubit.close();
      contentProvider.dispose();
      userProvider.dispose();
      await di.reset();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<UserProvider>.value(
        value: userProvider,
        child: BlocProvider<HomeCubit>.value(
          value: homeCubit,
          child: MaterialApp(
            locale: const Locale('ru'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocaleService.supportedLocales,
            home: Builder(
              builder: (context) => Theme(
                data: AppThemeDark.instance.getThemeData(context),
                child: const Scaffold(
                  body: SingleChildScrollView(child: MoonPhaseWidget()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Полнолуние'), findsOneWidget);
    expect(find.text('Наступает в 20:23 по вашему времени'), findsOneWidget);
    expect(tester.takeException(), isNull);

    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pump();
    }
    final screenshot = await binding.takeScreenshot(
      'moon-primary-phase-${Platform.operatingSystem}',
    );
    expect(screenshot, isNotEmpty);
    final dir = Directory('${Directory.systemTemp.path}/moon-primary-phase')
      ..createSync(recursive: true);
    await File('${dir.path}/primary.png').writeAsBytes(screenshot);
    debugPrint('MOON_SCREENSHOTS=${dir.path}');
  });
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}

class _MoonPhaseContentRepository implements ContentRepository {
  const _MoonPhaseContentRepository(this.moonPhase);

  final MoonPhaseModel moonPhase;

  @override
  Future<MoonPhaseModel> getMoonPhase(
    int year,
    int month,
    int day,
    int hour,
    int minute,
    int timezoneOffsetMinutes,
    double lat,
    double lon,
  ) async {
    return moonPhase.copyWith(date: _formatDate(DateTime(year, month, day)));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedUserRepository implements UserRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedCompatibilityRepository implements CompatibilityRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PersonalizedRepository implements PersonalizedLunarCalendarRepository {
  const _PersonalizedRepository();
  @override
  Future<LunarMonthModel> loadMonth({
    required DateTime month,
    required CurrentLocationModel location,
  }) async {
    if (location.latitude != 52.3676 || location.longitude != 4.9041) {
      throw StateError('The fixture must use the selected Amsterdam location');
    }
    final today = DateTime.now();
    return LunarMonthModel(
      year: month.year,
      month: month.month,
      timezone: 'Europe/Amsterdam',
      anchorLocalTime: '12:00',
      days: [
        for (
          var day = 1;
          day <= DateTime(month.year, month.month + 1, 0).day;
          day++
        )
          LunarDayModel(
            date: DateTime(month.year, month.month, day),
            lunarContext: LunarDayContextModel(
              lunarDayNumber: day == today.day ? 15 : day,
              moonAgeDays: 14,
              moonAgeDayIndex: 14,
              moonPhaseCode: day == today.day ? 'full_moon' : 'waxing_gibbous',
              moonPhaseName: 'Фаза',
              moonSignCode: 'aries',
              moonSignName: 'Овен',
              phaseEvent: null,
            ),
            dailyBackground: const DailyBackgroundModel(
              tone: PhaseTone.recovery,
              title: 'Восстановление',
              summary: 'Уделите время отдыху и привычным делам.',
            ),
            spheres: const {},
          ),
      ],
    );
  }
}

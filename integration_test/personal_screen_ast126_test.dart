import 'package:go_router/go_router.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/analytics/dictionaries/funnel_type.dart';

import '../test/features/compatibility/support/selection_test_support.dart';

import 'dart:io';

import 'package:asteria_app/app/data/models/horoscope/horoscope_day_model.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_shared_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/content/content_repository.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/compatibility/domain/repositories/compatibility_repository.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:asteria_app/features/home/presentation/screens/personal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Readings tools render and navigate while legacy forecasts stay hidden',
    (tester) async {
      await di.reset();

      final userProvider = UserProvider(
        userRepository: _UnusedUserRepository(),
      );
      userProvider.applyServerUserSnapshot(
        UserModel.empty().copyWith(
          name: 'Анастасия',
          horoscopeDay: _horoscopeDay(),
        ),
      );
      final contentProvider = ContentProvider(
        contentRepository: _UnusedContentRepository(),
        userProvider: userProvider,
        compatibilityRepository: _UnusedCompatibilityRepository(),
      );
      final homeCubit = HomeCubit(
        userRepository: _UnusedUserRepository(),
        contentProvider: contentProvider,
        userProvider: userProvider,
      );
      di.registerSingleton<UserProvider>(userProvider);
      registerTestCompatibilityProvider(userProvider);
      di.registerSingleton<ProductAnalyticsService>(_FixtureAnalytics());
      addTearDown(() async {
        await homeCubit.close();
        contentProvider.dispose();
        userProvider.dispose();
        await di.reset();
      });

      final router = GoRouter(
        initialLocation: '/readings',
        routes: [
          GoRoute(path: '/readings', builder: (_, _) => const PersonalScreen()),
          GoRoute(
            path: NatalCardRoute.routeName,
            name: NatalCardRoute.routeName,
            builder: (_, _) =>
                const Scaffold(body: Text('Natal chart destination')),
          ),
          GoRoute(
            path: CompatibilityRoutes.createCompatibilityInitialRouteName,
            name: CompatibilityRoutes.createCompatibilityInitialRouteName,
            builder: (_, _) =>
                const Scaffold(body: Text('Compatibility destination')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: userProvider,
          child: BlocProvider<HomeCubit>.value(
            value: homeCubit,
            child: MaterialApp.router(
              routerConfig: router,
              locale: const Locale('ru'),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              supportedLocales: AppLocaleService.supportedLocales,
              builder: (context, child) => Theme(
                data: AppThemeDark.instance.getThemeData(context),
                child: child!,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Разборы'), findsOneWidget);
      expect(find.text('Натальная карта'), findsOneWidget);
      expect(find.text('Открыть карту'), findsOneWidget);
      expect(find.text('Влияние на сферы'), findsNothing);
      expect(find.text('Совет на день'), findsNothing);
      expect(tester.takeException(), isNull);
      if (Platform.isAndroid) {
        await binding.convertFlutterSurfaceToImage();
        await tester.pump();
      }
      final dir = Directory('${Directory.systemTemp.path}/ast126')
        ..createSync(recursive: true);
      await File('${dir.path}/top.png').writeAsBytes(
        await binding.takeScreenshot(
          'readings-${Platform.operatingSystem}-top',
        ),
      );
      await tester.tap(find.text('Открыть карту'));
      await tester.pumpAndSettle();
      expect(find.text('Natal chart destination'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      final l = AppLocalizations.of(
        tester.element(find.byType(PersonalScreen)),
      );
      await tester.ensureVisible(find.text(l.compatibilityCheck));
      await tester.pumpAndSettle();
      await File('${dir.path}/compatibility.png').writeAsBytes(
        await binding.takeScreenshot(
          'readings-${Platform.operatingSystem}-compatibility',
        ),
      );
      await tester.tap(find.text(l.compatibilityCheck));
      await tester.pumpAndSettle();
      expect(find.text('Compatibility destination'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(l.adDecode));
      await tester.pumpAndSettle();
      await File('${dir.path}/lower.png').writeAsBytes(
        await binding.takeScreenshot(
          'readings-${Platform.operatingSystem}-lower',
        ),
      );
      expect(find.text('Влияние на сферы'), findsNothing);
      expect(find.text('Совет на день'), findsNothing);
      expect(tester.takeException(), isNull);
      debugPrint('AST126_SCREENSHOTS=${dir.path}');
    },
  );
}

HoroscopeDayModel _horoscopeDay({DateTime? dateUntil}) {
  const area = HoroscopeAreaModel(
    keyTheme: 'Отношения',
    themeTitle: 'Отношения',
    description: 'Описание',
  );
  return HoroscopeDayModel(
    dateUntil: dateUntil ?? DateTime.now().add(const Duration(days: 1)),
    focus:
        'День благоприятен для общения, укрепления связей и проявления чувств.',
    risk: 'Избегайте финансовых решений.',
    personalArea: area,
    personalWeakPoints: const [],
    personalAreaPercentage: '71%',
    loveArea: area,
    loveWeakPoints: const [],
    loveAreaPercentage: '89%',
    financeArea: area,
    financeWeakPoints: const [],
    financeAreaPercentage: '64%',
    spotlight: 'В центре внимания — отношения',
  );
}

class _UnusedContentRepository implements ContentRepository {
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

class _FixtureAnalytics extends Fake implements ProductAnalyticsService {
  @override
  Future<void> trackHomeCardClick({
    required FunnelType funnelType,
    String? entryPointId,
    int? position,
    String? ctaName,
  }) async {}
}

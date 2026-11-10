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

  testWidgets('AST-126 renders the open daily horoscope on device', (
    tester,
  ) async {
    await di.reset();

    final userProvider = UserProvider(userRepository: _UnusedUserRepository());
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
    addTearDown(() async {
      await homeCubit.close();
      contentProvider.dispose();
      userProvider.dispose();
      await di.reset();
    });

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocaleService.supportedLocales,
        home: Builder(
          builder: (context) => Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: ChangeNotifierProvider<UserProvider>.value(
              value: userProvider,
              child: BlocProvider<HomeCubit>.value(
                value: homeCubit,
                child: const PersonalScreen(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Влияние на сферы'), findsOneWidget);
    expect(find.text('Совет на день'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('personal-impact-ring-love')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('personal-impact-ring-finances')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('personal-impact-ring-energy')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('personal-unlock-lock-heart-glyph')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('personal-unlock-lock-sphere-glyph')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pump();
    }

    final topScreenshot = await binding.takeScreenshot(
      'ast126-${Platform.operatingSystem}-top',
    );
    expect(topScreenshot, isNotEmpty);

    await tester.ensureVisible(find.text('Совет на день'));
    await tester.pumpAndSettle();
    final forecastScreenshot = await binding.takeScreenshot(
      'ast126-${Platform.operatingSystem}-forecast',
    );
    expect(forecastScreenshot, isNotEmpty);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final lowerContentScreenshot = await binding.takeScreenshot(
      'ast126-${Platform.operatingSystem}-lower-content',
    );
    expect(lowerContentScreenshot, isNotEmpty);

    userProvider.applyServerUserSnapshot(
      UserModel.empty().copyWith(
        name: 'Анастасия',
        horoscopeDay: _horoscopeDay(
          dateUntil: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 2000));
    await tester.pumpAndSettle();

    expect(find.text('Открой прогноз'), findsOneWidget);
    expect(find.text('Открыть бесплатно'), findsOneWidget);
    expect(find.text('Влияние на сферы'), findsNothing);
    expect(find.text('Совет на день'), findsNothing);
    expect(tester.takeException(), isNull);
    final lockedScreenshot = await binding.takeScreenshot(
      'ast126-${Platform.operatingSystem}-locked',
    );
    expect(lockedScreenshot, isNotEmpty);
  });
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

import '../test/features/compatibility/support/selection_test_support.dart';
import 'dart:io';

import 'package:asteria_app/app/data/models/prompt_response.dart';
import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/content/content_repository.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/compatibility/domain/repositories/compatibility_repository.dart';
import 'package:asteria_app/features/compatibility/presentation/widgets/compability_results.dart';
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

  testWidgets('AST-127 matches compatibility Figma on device', (tester) async {
    await di.reset();

    final userProvider = UserProvider(userRepository: _UnusedUserRepository());
    userProvider.applyServerUserSnapshot(
      UserModel.empty().copyWith(
        name: 'Анастасия',
        compatibilityHistory: [_savedCompatibility()],
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

    final compatibilityCard = find.byKey(
      const ValueKey('personal-compatibility-card'),
    );
    await tester.ensureVisible(compatibilityCard);
    await tester.pumpAndSettle();

    expect(compatibilityCard, findsOneWidget);
    expect(
      find.byKey(const ValueKey('personal-compatibility-background')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('personal-compatibility-zodiac-telec')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('personal-compatibility-zodiac-bliznecy')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pump();
    }

    final personalScreenshot = await binding.takeScreenshot(
      'ast127-${Platform.operatingSystem}-personal-compatibility',
    );
    expect(personalScreenshot, isNotEmpty);

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
            child: const Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(14),
                  child: CompabilityResults(
                    compatibilityData: _compatibilityData,
                    hisBirthdate: '13-05-1995',
                    herBirthdate: '22-05-1994',
                    onHistoryPressed: _noop,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('69%'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final resultScreenshot = await binding.takeScreenshot(
      'ast127-${Platform.operatingSystem}-compatibility-result',
    );
    expect(resultScreenshot, isNotEmpty);
  });
}

void _noop() {}

SavedCompatibilityModel _savedCompatibility() {
  return SavedCompatibilityModel(
    id: 'ast-127-compatibility',
    firstBirthdate: DateTime(1995, 5, 13),
    secondBirthdate: DateTime(1994, 5, 22),
    generalPercentage: '69%',
    createdAt: DateTime(2026, 8, 14),
    compatibilityData: _compatibilityData,
  );
}

const _compatibilityData = CompatibilityData(
  generalCompatibility: 'Общее описание совместимости.',
  loveCompatibility: 'Любовь',
  loveCompatibilityPercentage: '82%',
  familyCompatibility: 'Семья',
  familyCompatibilityPercentage: '80%',
  conflicts: 'Конфликты',
  conflictsPercentage: '30%',
  percentage: '69%',
  phrase: 'Стабильность встречает переменчивость.',
  introduction:
      'Эта пара может быть интересной, но требует терпения и гибкости',
);

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

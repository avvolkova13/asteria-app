import 'package:provider/provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/features/compatibility/presentation/provider/compatibility_provider.dart';
import 'package:asteria_app/features/compatibility/presentation/screens/create_compatibility_initial_screen.dart';
import 'package:asteria_app/features/compatibility/presentation/widgets/compability_results.dart';
import 'package:asteria_app/app/data/models/prompt_response.dart';
import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/scenarios/free_conflict_scenario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

final example = SavedCompatibilityModel(
  id: 'pair-id',
  firstBirthdate: DateTime(1990, 5, 1),
  secondBirthdate: DateTime(1994, 1, 2),
  createdAt: DateTime(2026, 1, 1),
  generalPercentage: '82',
  compatibilityData: CompatibilityData.fromJson({
    'conflicts': 'Сохранённый ответ о ваших разногласиях.',
    'general_compatibility': 'A different section',
  }),
);

class _Analytics extends Fake implements AnalyticsFacade {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {}
}

class _Selection extends Fake implements CompatibilityProvider {
  @override
  Future<void> selectCompatibility(SavedCompatibilityModel item) async {}
}

class _Users extends ChangeNotifier implements UserProvider {
  @override
  UserModel? currentUser = UserModel.empty().copyWith(
    id: 'first',
    personalInfo: PersonalInfoModel(
      birthDate: BirthDateModel(birthDate: DateTime(1993, 8, 17)),
    ),
  );
  void switchAccount() {
    currentUser = UserModel.empty().copyWith(id: 'second');
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Access extends Fake implements MonetizationProvider {
  int free = 0, paid = 0, checks = 0;
  @override
  bool effectivePro = false;
  @override
  Map<String, RequestQuotaModel> get requestQuotas => {
    'compatibility': requestQuota('compatibility'),
  };
  @override
  Future<void> refreshForAccess() async {
    checks++;
  }

  @override
  bool isCurrentUser(String uid) => true;
  @override
  bool isFeatureEnabled(String feature) => feature == 'compatibility';
  @override
  RequestQuotaModel requestQuota(String feature) => RequestQuotaModel.fromJson({
    'feature': feature,
    'free_remaining': free,
    'paid_remaining': paid,
  });
}

class _Content extends Fake implements ContentProvider {
  final calls = <List<String>>[];
  @override
  Future<SavedCompatibilityModel> createCompatibility({
    required String firstName,
    required String firstDate,
    required String secondName,
    required String secondDate,
  }) async {
    calls.add([firstName, firstDate, secondName, secondDate]);
    return example;
  }
}

void main() {
  late _Users users;
  late _Access access;
  late _Content content;
  late int tarot;
  setUp(() {
    di.pushNewScope();
    users = _Users();
    access = _Access();
    content = _Content();
    di.registerSingleton<UserProvider>(users);
    di.registerSingleton<MonetizationProvider>(access);
    di.registerSingleton<ContentProvider>(content);
    final analytics = _Analytics();
    di.registerSingleton<AnalyticsFacade>(analytics);
    di.registerSingleton<ProductAnalyticsService>(
      ProductAnalyticsService(analytics),
    );
    di.registerSingleton<GlobalLoaderService>(GlobalLoaderService());
    di.registerSingleton<CompatibilityProvider>(_Selection());
    tarot = 0;
  });
  tearDown(() => di.popScope());

  Future<void> mount(WidgetTester tester, {String language = 'ru'}) async {
    await tester.binding.setSurfaceSize(const Size(320, 680));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ChangeNotifierProvider<UserProvider>.value(
        value: users,
        child: MaterialApp(
          locale: Locale(language),
          supportedLocales: AppLocaleService.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: child!,
            ),
          ),
          home: FreeConflictScenario(onOpenTarot: () => tarot++),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String text) async {
    final label = find.text(text);
    await tester.ensureVisible(label);
    await tester.pumpAndSettle();
    await tester.tap(label);
    await tester.pumpAndSettle();
  }

  Future<void> fill(WidgetTester tester) async {
    expect(find.byType(CreateCompatibilityInitialScreen), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Ваша дата рождения'), findsNothing);
    expect(find.text('Дата рождения'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Саша');
    await tap(tester, 'Дата рождения');
    expect(find.text('Дата рождения партнера'), findsOneWidget);
    await tap(tester, 'Выбрать');
  }

  testWidgets('PRO opens a new pair analysis with zero free requests', (
    tester,
  ) async {
    access.effectivePro = true;
    await mount(tester);
    expect(
      find.text('Расчёт использует одну бесплатную попытку.'),
      findsNothing,
    );
    await fill(tester);
    await tap(tester, 'Рассчитать');
    expect(content.calls, hasLength(1));
    expect(access.checks, 2);
    expect(find.byType(CompabilityResults), findsOneWidget);
  });

  testWidgets(
    'saved conflicts open without any generation and reset on account change',
    (tester) async {
      users.currentUser = users.currentUser!.copyWith(
        compatibilityHistory: [example],
      );
      access.paid = 3;
      await mount(tester);
      await tap(tester, 'Посмотреть историю');
      await tap(tester, '82');
      expect(
        find.text(example.compatibilityData.conflicts.trim()),
        findsOneWidget,
      );
      expect(
        find.text(example.compatibilityData.generalCompatibility),
        findsOneWidget,
      );
      expect(content.calls, isEmpty);
      users.switchAccount();
      await tester.pumpAndSettle();
      expect(find.text(example.compatibilityData.conflicts), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(CreateCompatibilityInitialScreen), findsNothing);
      await tap(tester, 'Открыть карту для двоих');
      expect(tarot, 1);
    },
  );

  testWidgets(
    'free calculation uses both dates and displays the generated conflict section',
    (tester) async {
      access.free = 1;
      await mount(tester);
      await fill(tester);
      await tap(tester, 'Рассчитать');
      expect(content.calls, hasLength(1));
      expect(content.calls.single.sublist(1), [
        '1993-08-17',
        'Саша',
        '2000-01-01',
      ]);
      expect(
        find.text(example.compatibilityData.conflicts.trim()),
        findsOneWidget,
      );
      expect(find.byType(CompabilityResults), findsOneWidget);
      expect(access.checks, 2);
    },
  );

  testWidgets(
    'quota used elsewhere while typing never submits the generation',
    (tester) async {
      access.free = 1;
      await mount(tester);
      await fill(tester);
      access.free = 0;
      access.paid = 1;
      await tap(tester, 'Рассчитать');
      expect(content.calls, isEmpty);
      await tap(tester, 'Открыть карту для двоих');
      expect(tarot, 1);
    },
  );

  testWidgets('a missing profile date cannot be supplied in compatibility', (
    tester,
  ) async {
    users.currentUser = UserModel.empty().copyWith(id: 'new');
    access.free = 1;
    await mount(tester);
    expect(find.text('Заполните дату рождения в профиле'), findsOneWidget);
    expect(find.byType(CreateCompatibilityInitialScreen), findsNothing);
    await tap(tester, 'Открыть карту для двоих');
    expect(tarot, 1);
    expect(content.calls, isEmpty);
  });

  testWidgets('paid balance alone cannot open the pair form in English', (
    tester,
  ) async {
    access.paid = 1;
    await mount(tester, language: 'en');
    expect(find.byType(CreateCompatibilityInitialScreen), findsNothing);
    await tap(tester, 'Open a card for the two of you');
    expect(tarot, 1);
    expect(content.calls, isEmpty);
  });
}

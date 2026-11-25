import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/features/sonnik/presentation/provider/sonnik_provider.dart';
import 'package:asteria_app/features/sonnik/presentation/screens/create_sonnik_initial_screen.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:asteria_app/features/sonnik/data/dream_journal.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/scenarios/free_dream_scenario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

final _dream = SonnikModel(
  id: 'dream',
  dateGenerated: DateTime(2026),
  title: 'Знакомый берег',
  interpretation: 'Берег во сне может напомнить о доме.',
);

class _User extends ChangeNotifier implements UserProvider {
  @override
  UserModel currentUser = UserModel.empty().copyWith(id: 'reader');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  void switchTo(UserModel next) {
    currentUser = next;
    notifyListeners();
  }
}

class _Access extends ChangeNotifier implements MonetizationProvider {
  int remaining = 1, paid = 0, checks = 0;
  bool throwOnRefresh = false;
  @override
  int get balance => 0;
  @override
  bool effectivePro = false;
  @override
  Future<void> refreshForAccess() async {
    checks++;
    if (throwOnRefresh) throw StateError('offline');
  }

  @override
  int requestsLeft(String key) => remaining + paid;
  @override
  bool isCurrentUser(String uid) => uid == 'reader';
  @override
  bool isFeatureEnabled(String key) => true;
  @override
  Map<String, RequestQuotaModel> get requestQuotas => {
    'sonnik': requestQuota('sonnik'),
  };
  @override
  RequestQuotaModel requestQuota(String key) => RequestQuotaModel.fromJson({
    'feature': key,
    'free_remaining': remaining,
    'paid_remaining': paid,
  });
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Content extends ChangeNotifier implements ContentProvider {
  final requests = <String>[];
  @override
  Future<SonnikModel> createSonnik(String text) async {
    requests.add(text);
    return _dream;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Analytics extends Fake implements AnalyticsFacade {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {}
}

void main() {
  setUpAll(() => Hive.openBox<Map>('dream_journal_v1', bytes: Uint8List(0)));
  setUp(() => Hive.box<Map>('dream_journal_v1').clear());
  tearDownAll(Hive.close);
  late _Access access;
  late _User user;
  late _Content content;
  setUp(() async {
    await di.reset();
    access = _Access();
    user = _User();
    content = _Content();
    final facade = _Analytics();
    di.registerSingleton<ContentProvider>(content);
    di.registerSingleton<UserProvider>(user);
    di.registerSingleton<SonnikProvider>(SonnikProvider());
    di.registerSingleton<GlobalLoaderService>(GlobalLoaderService());
    di.registerSingleton<AnalyticsFacade>(facade);
    di.registerSingleton<ProductAnalyticsService>(
      ProductAnalyticsService(facade),
    );
    addTearDown(di.reset);
  });
  Future<void> mount(WidgetTester tester, {String lang = 'ru'}) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(lang),
        supportedLocales: AppLocaleService.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        builder: (context, child) => Theme(
          data: AppThemeDark.instance.getThemeData(context),
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider<UserProvider>.value(value: user),
              ChangeNotifierProvider<MonetizationProvider>.value(value: access),
              ChangeNotifierProvider<ContentProvider>.value(value: content),
            ],
            child: child!,
          ),
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (context) => FreeDreamScenario(
                    onOpenRunes: () => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) =>
                            const Scaffold(body: Text('Rune spread')),
                      ),
                    ),
                  ),
                ),
              ),
              child: const Text('Open dreams'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open dreams'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateSonnikInitialScreen), findsOneWidget);
    expect(find.byType(SonnikLiveyaAvatar), findsOneWidget);
  }

  Future<void> tap(WidgetTester tester, Finder control) async {
    await tester.ensureVisible(control);
    await tester.pumpAndSettle();
    await tester.tap(control);
    await tester.pumpAndSettle();
  }

  for (final pro in [false, true]) {
    testWidgets('shares the interpreter and returns to the dream, PRO=$pro', (
      tester,
    ) async {
      access.effectivePro = pro;
      access.remaining = pro ? 0 : 1;
      await mount(tester);
      await tester.enterText(find.byType(TextField), '  Дом у реки  ');
      await tester.pumpAndSettle();
      await tap(tester, find.text('Расшифровать'));
      expect(access.checks, greaterThanOrEqualTo(1));
      expect(content.requests, ['Дом у реки']);
      expect(find.text(_dream.interpretation), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(CreateSonnikInitialScreen), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byType(TextField))
            .controller!
            .text
            .trim(),
        'Дом у реки',
      );
      expect((await DreamJournal('reader').read()).single.text, 'Дом у реки');
    });
  }

  for (final offline in [false, true]) {
    testWidgets(
      'offers runes and preserves the draft without spending a paid attempt, offline=$offline',
      (tester) async {
        await mount(tester, lang: 'en');
        await tester.enterText(find.byType(TextField), 'A quiet river');
        await tester.pumpAndSettle();
        access.remaining = 0;
        access.paid = 3;
        access.throwOnRefresh = offline;
        await tap(tester, find.text('Interpret'));
        expect(content.requests, isEmpty);
        await tap(tester, find.text('Open three runes'));
        expect(find.text('Rune spread'), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'A quiet river',
        );
        await tap(tester, find.text('Interpret'));
        await tap(tester, find.text('Back to my dream'));
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'A quiet river',
        );
        expect(content.requests, isEmpty);
      },
    );
  }

  testWidgets(
    'saving and exiting skips quota and returns to the scenario picker',
    (tester) async {
      access.remaining = 0;
      access.throwOnRefresh = true;
      await mount(tester, lang: 'en');
      await tester.enterText(find.byType(TextField), 'A dream about the coast');
      await tester.pumpAndSettle();
      final lastCheck = access.checks;
      await tap(tester, find.text('Save and exit'));
      expect(find.text('Open dreams'), findsOneWidget);
      expect(content.requests, isEmpty);
      expect(access.checks, lastCheck);
      expect(
        (await DreamJournal('reader').read()).single.text,
        'A dream about the coast',
      );
    },
  );

  testWidgets(
    'journal from the free scenario includes earlier readings offline',
    (tester) async {
      access.throwOnRefresh = true;
      user.currentUser = user.currentUser.copyWith(sonnikHistory: [_dream]);
      await mount(tester);
      await tap(tester, find.text('Дневник снов'));
      await tap(tester, find.text(_dream.title));
      expect(find.text(_dream.interpretation), findsOneWidget);
      expect(content.requests, isEmpty);
      user.switchTo(UserModel.empty().copyWith(id: 'another'));
      await tester.pumpAndSettle();
      expect(find.text(_dream.interpretation), findsNothing);
    },
  );
}

import 'dart:async';
import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';
import 'package:asteria_app/features/sonnik/presentation/provider/sonnik_provider.dart';
import 'package:asteria_app/features/sonnik/presentation/screens/create_sonnik_loaded_screen.dart';
import 'package:flutter/cupertino.dart' show CupertinoAlertDialog;
import 'package:asteria_app/features/home/presentation/widgets/advertising_block_widget.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/widgets/dictation_button.dart';
import 'package:asteria_app/features/sonnik/presentation/screens/dream_journal_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/features/sonnik/data/dream_journal.dart';
import 'package:hive/hive.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/sonnik/presentation/screens/create_sonnik_initial_screen.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final family in ['Lora', 'Onest']) {
      final loader = FontLoader(family)
        ..addFont(
          rootBundle.load(
            'assets/fonts/${family.toLowerCase()}/$family-VariableFont_wght.ttf',
          ),
        );
      await loader.load();
    }
  });
  for (final pro in [false, true]) {
    testWidgets(
      'intro stays beside Liveya and input remains usable with keyboard, PRO=$pro',
      (tester) async {
        await di.reset();
        final facade = _Analytics();
        final user = _User();
        await Hive.openBox<Map>('dream_journal_v1', bytes: Uint8List(0));
        addTearDown(Hive.close);
        final monetization = _Monetization(pro);
        final content = _Content();
        di.registerSingleton<ContentProvider>(content);
        di.registerSingleton<SonnikProvider>(SonnikProvider());
        di.registerSingleton<GlobalLoaderService>(GlobalLoaderService());
        di.registerSingleton<AnalyticsFacade>(facade);
        di.registerSingleton<ProductAnalyticsService>(
          ProductAnalyticsService(facade),
        );
        addTearDown(() async {
          user.dispose();
          monetization.dispose();
          await di.reset();
        });
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) =>
                  const Scaffold(body: AdvertisingBlockWidget()),
            ),
            CreateSonnikInitialRoute(),
            GoRoute(
              name: SonnikRoutes.createSonnikLoadedRouteName,
              path: SonnikRoutes.createSonnikLoadedRouteName,
              builder: (_, __) =>
                  const Scaffold(body: Text('Interpretation result')),
            ),
            GoRoute(
              name: SonnikRoutes.createSonnikRequestsLeftRouteName,
              path: SonnikRoutes.createSonnikRequestsLeftRouteName,
              builder: (_, __) => const Scaffold(body: Text('Quota reached')),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<UserProvider>.value(value: user),
              ChangeNotifierProvider<MonetizationProvider>.value(
                value: monetization,
              ),
            ],
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
        );
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.current;
        await tester.tap(find.text(l10n.adDecode));
        await tester.pumpAndSettle();
        expect(find.byType(CreateSonnikInitialScreen), findsOneWidget);
        expect(find.byType(DreamJournalScreen), findsNothing);
        expect(find.byType(DictationButton), findsOneWidget);
        final prompt = find.text(l10n.dreamTellPrompt);
        final avatar = find.byType(SonnikLiveyaAvatar);
        expect(
          tester.getTopLeft(prompt).dx,
          lessThan(tester.getTopLeft(avatar).dx),
        );
        expect(
          tester.getTopLeft(prompt).dy,
          lessThan(tester.getBottomLeft(avatar).dy),
        );
        expect(
          tester.getTopLeft(find.byType(SonnikTextArea)).dy,
          lessThan(390),
        );
        expect(
          find.byType(SonnikQuotaBadge),
          pro ? findsNothing : findsOneWidget,
        );
        await tester.enterText(find.byType(TextField), 'Мне приснилось море');
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(SonnikGradientButton));
        await tester.pumpAndSettle();
        expect(
          tester.getBottomLeft(find.byType(SonnikGradientButton)).dy,
          lessThanOrEqualTo(544),
        );
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'Мне приснилось море',
        );
        if (!pro) {
          monetization.allowed = false;
          tester.view.resetViewInsets();
          await tester.pumpAndSettle();
          final save = find.text('Сохранить и выйти');
          await tester.ensureVisible(save);
          await tester.tap(save);
          await tester.pumpAndSettle();
          expect(find.byType(CreateSonnikInitialScreen), findsNothing);
          final records = await DreamJournal('test-user').read();
          expect(records.single.text, 'Мне приснилось море');
          expect(content.requests, isEmpty);
          expect(await DreamJournal('another-user').read(), isEmpty);

          await tester.tap(find.text('Дневник снов'));
          await tester.pumpAndSettle();
          final openJournal = tester.state(find.byType(DreamJournalScreen));
          await tester.tap(find.text('Мне приснилось море'));
          await tester.pumpAndSettle();
          expect(find.byType(CreateSonnikInitialScreen), findsOneWidget);
          monetization.allowed = true;
          await tester.enterText(find.byType(TextField), 'Море и маяк');
          await tester.ensureVisible(find.byType(SonnikGradientButton));
          await tester.tap(find.byType(SonnikGradientButton));
          await tester.pumpAndSettle();
          expect(find.byType(CreateSonnikLoadedScreen), findsOneWidget);
          expect(find.text('meaning'), findsOneWidget);
          expect(content.requests, ['Море и маяк']);
          final interpreted = (await DreamJournal('test-user').read()).single;
          expect(interpreted.id, records.single.id);
          expect(interpreted.currentInterpretation?.id, 'generated');
          await tester.tap(find.byTooltip('Назад'));
          await tester.pumpAndSettle();
          expect(find.text('Открыть расшифровку'), findsOneWidget);
          await tester.ensureVisible(find.text('Открыть расшифровку'));
          await tester.tap(find.text('Открыть расшифровку'));
          await tester.pumpAndSettle();
          expect(content.requests, hasLength(1));
          await tester.ensureVisible(find.text('Дневник снов'));
          await tester.tap(find.text('Дневник снов'));
          await tester.pumpAndSettle();
          expect(
            tester.state(find.byType(DreamJournalScreen)),
            same(openJournal),
          );
          await tester.tap(find.text('Море и маяк'));
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byType(TextField),
            'Сон с другой концовкой',
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Назад'));
          await tester.pumpAndSettle();
          expect(find.byType(CupertinoAlertDialog), findsOneWidget);
          await tester.tap(find.text('Продолжить редактирование'));
          await tester.pumpAndSettle();
          expect(
            tester.widget<TextField>(find.byType(TextField)).controller!.text,
            'Сон с другой концовкой',
          );
          await tester.tap(find.byTooltip('Назад'));
          await tester.pumpAndSettle();
          await tester.tap(
            find.descendant(
              of: find.byType(CupertinoAlertDialog),
              matching: save,
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(DreamJournalScreen), findsOneWidget);
          expect(
            (await DreamJournal('test-user').read()).single.text,
            'Сон с другой концовкой',
          );
        } else {
          tester.view.resetViewInsets();
          final params = CreateSonnikInitialRouteParams(
            initialEntry: DreamEntry(
              id: 'existing',
              text: 'Тихий лес',
              recordedAt: DateTime(2026),
            ),
            ownerId: user.id,
            autoInterpret: true,
          );
          monetization.allowed = false;
          router.pushNamed(
            SonnikRoutes.createSonnikInitialRouteName,
            extra: params,
          );
          await tester.pumpAndSettle();
          expect(content.requests, isEmpty);
          expect(find.text('Quota reached'), findsOneWidget);
          router.pop();
          await tester.pumpAndSettle();
          expect(
            tester.widget<TextField>(find.byType(TextField)).controller!.text,
            'Тихий лес',
          );
          monetization.allowed = true;
          content.failNext = true;
          await tester.ensureVisible(find.byType(SonnikGradientButton));
          await tester.tap(find.byType(SonnikGradientButton));
          await tester.pumpAndSettle();
          expect(content.requests, ['Тихий лес']);
          expect(find.text(l10n.dreamCalculationError), findsOneWidget);
          monetization.gate = Completer<void>();
          await tester.tap(find.byType(SonnikGradientButton));
          await tester.pump();
          user.switchAccount();
          monetization.gate!.complete();
          await tester.pumpAndSettle();
          expect(content.requests, ['Тихий лес']);
          expect(
            tester.widget<TextField>(find.byType(TextField)).controller!.text,
            isEmpty,
          );
          user.switchAccount();
          await tester.pumpAndSettle();
          expect(content.requests, ['Тихий лес']);
          expect(
            tester.widget<TextField>(find.byType(TextField)).controller!.text,
            isEmpty,
          );
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}

class _Content extends Fake implements ContentProvider {
  final requests = <String>[];
  bool failNext = false;
  @override
  Future<SonnikModel> createSonnik(String text) async {
    requests.add(text);
    if (failNext) {
      failNext = false;
      throw StateError('offline');
    }
    return SonnikModel(
      id: 'generated',
      dateGenerated: DateTime(2026),
      title: 'result',
      interpretation: 'meaning',
    );
  }
}

class _User extends ChangeNotifier implements UserProvider {
  String id = 'test-user';
  void switchAccount() {
    id = id == 'test-user' ? 'another-user' : 'test-user';
    notifyListeners();
  }

  @override
  UserModel get currentUser => UserModel.empty().copyWith(id: id);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Monetization extends ChangeNotifier implements MonetizationProvider {
  _Monetization(this.effectivePro);
  bool allowed = true;
  Completer<void>? gate;
  @override
  Future<void> refreshForAccess() async {
    await gate?.future;
  }

  @override
  bool isFeatureEnabled(String feature) => true;
  @override
  bool canMakeRequest(String feature) => allowed;
  @override
  final bool effectivePro;
  @override
  int get balance => 1005;
  @override
  int requestsLeft(String feature) => 2;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Analytics extends Fake implements AnalyticsFacade {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {}
}

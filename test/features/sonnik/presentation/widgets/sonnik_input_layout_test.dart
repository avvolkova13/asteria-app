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
        di.registerSingleton<ContentProvider>(_Content());
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
              builder: (_, __) => const Scaffold(
                body: Column(
                  children: [DreamCaptureButton(), AdvertisingBlockWidget()],
                ),
              ),
            ),
            CreateSonnikInitialRoute(),
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
        expect(find.byType(DreamJournalScreen), findsOneWidget);
        Navigator.of(tester.element(find.byType(DreamJournalScreen))).pop();
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.dreamDecode));
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
          tester.view.resetViewInsets();
          await tester.pumpAndSettle();
          final journal = find.text('Открыть дневник снов');
          final save = find.textContaining('Сохранить на');
          await tester.ensureVisible(save);
          await tester.tap(save);
          await tester.pumpAndSettle();
          expect(find.textContaining('Сохранено в'), findsOneWidget);
          final records = await DreamJournal('test-user').read();
          expect(records.single.text, 'Мне приснилось море');
          expect(await DreamJournal('another-user').read(), isEmpty);
          await tester.enterText(find.byType(TextField), '');
          await tester.pumpAndSettle();
          await tester.ensureVisible(journal);
          await tester.tap(journal);
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text('Мне приснилось море'));
          await tester.tap(find.text('Мне приснилось море'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byType(TextField), 'Море и маяк');
          await tester.pumpAndSettle();
          await tester.tap(find.text('Сохранить сон'));
          await tester.pumpAndSettle();
          expect(
            (await DreamJournal('test-user').read()).single.id,
            records.single.id,
          );
          await tester.ensureVisible(find.text('Спросить Ливею'));
          await tester.tap(find.text('Спросить Ливею'));
          await tester.pumpAndSettle();
          expect(find.byType(SonnikTextArea), findsOneWidget);
          expect(
            tester.widget<TextField>(find.byType(TextField)).controller!.text,
            'Море и маяк',
          );
          expect(find.textContaining('Сохранено в'), findsOneWidget);
          expect(await DreamJournal('test-user').read(), hasLength(1));
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}

class _Content extends Fake implements ContentProvider {}

class _User extends ChangeNotifier implements UserProvider {
  @override
  UserModel get currentUser => UserModel.empty().copyWith(id: 'test-user');
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Monetization extends ChangeNotifier implements MonetizationProvider {
  _Monetization(this.effectivePro);
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

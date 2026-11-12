import 'dart:async';

import 'package:asteria_app/app/data/models/natal_card/natal_card_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/widgets/shared_purchase_modal.dart';
import 'package:asteria_app/features/monetization/data/monetization_api.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/natal_card/natal_card_screen.dart';
import 'package:asteria_app/features/natal_card/widgets/natal_card_empty_screen.dart';
import 'package:asteria_app/features/natal_card/widgets/natal_card_loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('Lora')..addFont(
          rootBundle.load('assets/fonts/lora/Lora-VariableFont_wght.ttf'),
        ))
        .load();
    await (FontLoader('Onest')..addFont(
          rootBundle.load('assets/fonts/onest/Onest-VariableFont_wght.ttf'),
        ))
        .load();
  });
  tearDown(() async => di.reset());

  testWidgets(
    'PRO with zero balance generates without purchase or coin events',
    (tester) async {
      final h = await _pump(tester, pro: true);
      expect(find.text('Включено в PRO'), findsOneWidget);
      expect(find.text('Купить'), findsNothing);
      await Scrollable.ensureVisible(
        tester.element(find.text('Создать натальную карту')),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Создать натальную карту'));
      await tester.pumpAndSettle();
      expect(h.content.calls, 1);
      expect(h.content.lastRequirePro, isTrue);
      expect(h.user.currentUser.natalCard, isNotNull);
      expect(find.byType(SharedPurchaseModal), findsNothing);
      expect(find.byType(NatalCardEmptyScreen), findsNothing);
      expect(
        h.analytics.events.where(
          (e) =>
              e.contains('paywall') ||
              e.contains('purchase') ||
              e.contains('coin_spend'),
        ),
        isEmpty,
      );
    },
  );

  testWidgets('without PRO the purchase still requires 100 stars', (
    tester,
  ) async {
    final h = await _pump(tester, pro: false, balance: 150);
    expect(find.textContaining('100'), findsWidgets);
    await Scrollable.ensureVisible(
      tester.element(find.text('Купить')),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Купить'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SharedPurchaseModal>(find.byType(SharedPurchaseModal))
          .price,
      100,
    );
    expect(h.content.calls, 0);
    await tester.tap(
      find.descendant(
        of: find.byType(SharedPurchaseModal),
        matching: find.text('Купить'),
      ),
    );
    await tester.pumpAndSettle();
    expect(h.content.calls, 1);
    expect(find.byType(NatalCardEmptyScreen), findsNothing);
  });

  testWidgets('expired PRO requires confirmation before generating', (
    tester,
  ) async {
    final h = await _pump(tester, pro: true, balance: 150);
    h.api.pro = false; // The visible PRO snapshot has become stale.
    await Scrollable.ensureVisible(
      tester.element(find.text('Создать натальную карту')),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Создать натальную карту'));
    await tester.pumpAndSettle();
    expect(h.content.calls, 0);
    expect(find.byType(SharedPurchaseModal), findsOneWidget);
  });

  testWidgets('subscription activation updates the open offer', (tester) async {
    final h = await _pump(tester, pro: false);
    expect(find.text('Купить'), findsOneWidget);
    h.api.pro = true;
    await h.monetization.refresh();
    await tester.pumpAndSettle();
    expect(find.text('Купить'), findsNothing);
    expect(find.text('Создать натальную карту'), findsOneWidget);
    expect(h.content.calls, 0);
  });

  testWidgets('unknown subscription state never shows a purchase', (
    tester,
  ) async {
    final pending = Completer<MonetizationStateModel>();
    final h = await _pump(tester, pro: true, pending: pending);
    expect(find.text('Купить'), findsNothing);
    expect(find.byType(NatalCardLoadingOverlay), findsOneWidget);
    pending.complete(h.api.snapshot);
    await tester.pumpAndSettle();
    expect(find.text('Включено в PRO'), findsOneWidget);
  });

  testWidgets('generated chart stays available after PRO expires', (
    tester,
  ) async {
    final h = await _pump(tester, pro: true, existing: true);
    h.api.pro = false;
    await h.monetization.refresh();
    await tester.pumpAndSettle();
    expect(find.byType(NatalCardEmptyScreen), findsNothing);
    expect(h.content.calls, 0);
  });

  testWidgets('saved chart opens without PRO or an entitlement request', (
    tester,
  ) async {
    final h = await _pump(
      tester,
      pro: false,
      existing: true,
      pending: Completer<MonetizationStateModel>(),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NatalCardEmptyScreen), findsNothing);
    expect(find.byType(NatalCardLoadingOverlay), findsNothing);
    expect(h.api.calls, 0);
    expect(h.content.calls, 0);
  });

  testWidgets('failed subscription check offers retry instead of purchase', (
    tester,
  ) async {
    final pending = Completer<MonetizationStateModel>();
    final h = await _pump(tester, pro: true, pending: pending);
    pending.completeError(StateError('offline'));
    await tester.pumpAndSettle();
    expect(find.text('Купить'), findsNothing);
    expect(find.text('Создать натальную карту'), findsNothing);
    expect(
      find.text('Не удалось проверить подписку. Попробуй ещё раз.'),
      findsOneWidget,
    );
    h.api.pending = null;
    await tester.tap(find.text(AppLocalizations.current.retry));
    await tester.pumpAndSettle();
    expect(find.text('Включено в PRO'), findsOneWidget);
  });

  for (final throwsError in [true, false]) {
    testWidgets(
      'unavailable translation stays readable and retries (throws: $throwsError)',
      (tester) async {
        final h = await _pump(
          tester,
          pro: true,
          existing: true,
          locale: const Locale('en'),
          failTranslation: throwsError,
          omitTranslation: !throwsError,
        );
        expect(
          find.text(AppLocalizations.current.contentTranslationUnavailable),
          findsOneWidget,
        );
        expect(find.byType(NatalCardEmptyScreen), findsNothing);
        final background = tester
            .widget<Scaffold>(find.byType(Scaffold))
            .backgroundColor!;
        final errorText = tester.widget<Text>(
          find.text(AppLocalizations.current.contentTranslationUnavailable),
        );
        final textLuminance = errorText.style!.color!.computeLuminance();
        expect(
          (textLuminance + 0.05) / (background.computeLuminance() + 0.05),
          greaterThanOrEqualTo(4.5),
        );
        h.content
          ..failTranslation = false
          ..omitTranslation = false;
        await tester.tap(find.text(AppLocalizations.current.retry));
        await tester.pumpAndSettle();
        expect(h.content.translationCalls, 2);
        expect(h.content.calls, 0);
        expect(h.user.currentUser.natalCard!.hasLanguage('en'), isTrue);
        expect(
          find.text(AppLocalizations.current.contentTranslationUnavailable),
          findsNothing,
        );
        expect(find.byType(NatalCardEmptyScreen), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('PRO generation prevents duplicate taps and survives closing', (
    tester,
  ) async {
    final h = await _pump(tester, pro: true);
    final pending = Completer<void>();
    h.content.pending = pending;
    await Scrollable.ensureVisible(
      tester.element(find.text('Создать натальную карту')),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Создать натальную карту'));
    await tester.tap(find.text('Создать натальную карту'));
    await tester.pump();
    expect(h.content.calls, 1);
    expect(find.byType(NatalCardLoadingOverlay), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    pending.complete();
    await tester.pumpAndSettle();
    expect(h.user.currentUser.natalCard, isNotNull);
    expect(tester.takeException(), isNull);
  });

  for (final locale in [const Locale('ru'), const Locale('en')]) {
    testWidgets('PRO offer fits compact screens in ${locale.languageCode}', (
      tester,
    ) async {
      await _pump(tester, pro: true, width: 320, locale: locale);
      final createButton = find.text(AppLocalizations.current.natalCreateCard);
      await Scrollable.ensureVisible(
        tester.element(createButton),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      expect(createButton.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'failed PRO generation can be retried without offering purchase',
    (tester) async {
      final h = await _pump(tester, pro: true);
      h.content.fail = true;
      await Scrollable.ensureVisible(
        tester.element(find.text('Создать натальную карту')),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Создать натальную карту'));
      await tester.pumpAndSettle();
      expect(find.text('Купить'), findsNothing);
      expect(find.byType(NatalCardEmptyScreen), findsOneWidget);
      h.content.fail = false;
      await Scrollable.ensureVisible(
        tester.element(find.text('Создать натальную карту')),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Создать натальную карту'));
      await tester.pumpAndSettle();
      expect(h.content.calls, 2);
      expect(find.byType(NatalCardEmptyScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

Future<
  ({
    _User user,
    _Content content,
    _Api api,
    MonetizationProvider monetization,
    _Analytics analytics,
  })
>
_pump(
  WidgetTester tester, {
  required bool pro,
  int balance = 0,
  bool existing = false,
  bool failTranslation = false,
  bool omitTranslation = false,
  double width = 390,
  Locale locale = const Locale('ru'),
  Completer<MonetizationStateModel>? pending,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final user = _User(
    UserModel.empty().copyWith(
      id: 'natal-user',
      natalCard: existing ? _card : null,
    ),
  );
  final content = _Content(user)
    ..failTranslation = failTranslation
    ..omitTranslation = omitTranslation;
  final api = _Api(pro: pro, balance: balance, pending: pending);
  final monetization = MonetizationProvider(api: api, userProvider: user);
  final analytics = _Analytics();
  di.registerSingleton<UserProvider>(user);
  di.registerSingleton<ContentProvider>(content);
  di.registerSingleton<MonetizationProvider>(monetization);
  di.registerSingleton<AnalyticsFacade>(analytics);
  di.registerSingleton<ProductAnalyticsService>(
    ProductAnalyticsService(analytics),
  );
  di.registerSingleton<GlobalLoaderService>(GlobalLoaderService());
  di.registerSingleton<AppLocaleService>(
    AppLocaleService(platformLocales: [locale]),
  );
  if (pending == null) await monetization.ensureLoaded();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: user),
        ChangeNotifierProvider<MonetizationProvider>.value(value: monetization),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocaleService.supportedLocales,
        builder: (context, child) => Theme(
          data: AppThemeDark.instance.getThemeData(context),
          child: child!,
        ),
        home: const NatalCardScreen(),
      ),
    ),
  );
  if (pending == null) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return (
    user: user,
    content: content,
    api: api,
    monetization: monetization,
    analytics: analytics,
  );
}

final _card = NatalCardModel.fromJson({
  'source_language': 'ru',
  'interpretations': {
    'ru': {'final_conclusion': 'Готовый разбор'},
  },
});

class _User extends ChangeNotifier implements UserProvider {
  _User(this.currentUser);
  @override
  UserModel currentUser;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Content implements ContentProvider {
  @override
  Future<PlanetsHousesDataModel?> loadPurchasedNatalGeometry() async => null;

  _Content(this.user);
  final _User user;
  int calls = 0;
  int translationCalls = 0;
  bool failTranslation = false;
  bool omitTranslation = false;
  bool fail = false;
  @override
  Future<void> translateNatalCardIfNeeded() async {
    translationCalls++;
    if (failTranslation) throw StateError('translation unavailable');
    if (omitTranslation) return;
    user.currentUser = user.currentUser.copyWith(
      natalCard: _card.copyWithInterpretation(
        language: 'en',
        interpretation: _card.interpretationFor('ru'),
      ),
    );
  }

  bool? lastRequirePro;
  Completer<void>? pending;
  @override
  Future<void> buyNatalCard({bool requirePro = false}) async {
    lastRequirePro = requirePro;
    calls++;
    await pending?.future;
    if (fail) throw StateError('generation failed');
    user.currentUser = user.currentUser.copyWith(natalCard: _card);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Api implements MonetizationApi {
  _Api({required this.pro, required this.balance, this.pending});
  bool pro;
  final int balance;
  Completer<MonetizationStateModel>? pending;
  int calls = 0;
  MonetizationStateModel get snapshot => MonetizationStateModel.fromJson({
    'uid': 'natal-user',
    'catalog_revision': 2,
    'effective_pro': pro,
    'wallet': {
      'uid': 'natal-user',
      'balance': balance,
      'debt': 0,
      'sequence': 1,
    },
  });
  @override
  Future<MonetizationStateModel> getCurrent() async {
    calls++;
    return pending == null ? snapshot : pending!.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Analytics implements AnalyticsFacade {
  final events = <String>[];
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {
    events.add(name);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

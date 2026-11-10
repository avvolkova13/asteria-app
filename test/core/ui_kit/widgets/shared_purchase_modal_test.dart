import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/features/monetization/presentation/contextual_purchase_page.dart';
import 'package:go_router/go_router.dart';
import 'package:asteria_app/features/monetization/presentation/feature_access_flow.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/widgets/shared_buy_requests_screen.dart';
import 'package:asteria_app/core/ui_kit/widgets/shared_purchase_modal.dart';
import 'package:asteria_app/features/monetization/data/feature_execution_api.dart';
import 'package:asteria_app/features/monetization/data/monetization_api.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserProvider userProvider;
  late _FakeMonetizationApi api;
  late MonetizationProvider monetizationProvider;

  setUp(() async {
    await di.reset();
    userProvider = UserProvider(
      userRepository: _FakeUserRepository(),
      authSessionService: _FakeSession(),
    )..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
    api = _FakeMonetizationApi([_state(balance: 100), _state(balance: 60)]);
    monetizationProvider = MonetizationProvider(
      api: api,
      userProvider: userProvider,
    );
    await monetizationProvider.ensureLoaded();

    final analytics = _RecordingAnalyticsFacade();
    di.registerSingleton<GlobalLoaderService>(GlobalLoaderService());
    di.registerSingleton<AnalyticsFacade>(analytics);
    di.registerSingleton<ProductAnalyticsService>(
      ProductAnalyticsService(analytics),
    );
  });

  tearDown(() async {
    userProvider.dispose();
    monetizationProvider.dispose();
    await di.reset();
  });

  for (final pro in [true, false]) {
    testWidgets('one-off flow with PRO=$pro does not silently spend', (
      tester,
    ) async {
      api.states
        ..clear()
        ..add(_state(balance: 100).copyWith(effectivePro: pro));
      var executions = 0;
      await tester.pumpWidget(
        ChangeNotifierProvider<MonetizationProvider>.value(
          value: monetizationProvider,
          child: MaterialApp(
            locale: const Locale('ru'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocaleService.supportedLocales,
            home: Builder(
              builder: (context) => Theme(
                data: AppThemeLight.instance.getThemeData(context),
                child: Scaffold(
                  body: Builder(
                    builder: (context) => TextButton(
                      onPressed: () => showFeaturePurchaseModal(
                        context: context,
                        builder: (_) => SharedPurchaseModal(
                          purchaseTitle: 'Расклад',
                          price: 30,
                          featureKey: 'tarot_spread',
                          offerType: OfferType.oneOffUnlock,
                          onAccessPurchase: (requirePro, _) async {
                            executions++;
                            expect(requirePro, pro);
                          },
                        ),
                      ),
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(executions, pro ? 1 : 0);
      expect(
        find.text('Подтвердите покупку'),
        pro ? findsNothing : findsOneWidget,
      );
      if (!pro) {
        await tester.tap(find.text('Купить'));
        await tester.pumpAndSettle();
        expect(executions, 1);
      }
    });
  }

  for (final subscription in [false, true]) {
    testWidgets(
      'checkout returns without executing: subscription=$subscription',
      (tester) async {
        api.states
          ..clear()
          ..add(_state(balance: 0));
        var executions = 0;
        final editor = TextEditingController(text: 'Мой исходный вопрос');
        addTearDown(editor.dispose);
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, _) => Scaffold(
                body: Column(
                  children: [
                    TextField(controller: editor),
                    TextButton(
                      child: const Text('Open'),
                      onPressed: () => showFeaturePurchaseModal(
                        context: context,
                        builder: (_) => SharedPurchaseModal(
                          purchaseTitle: 'Расклад',
                          price: 30,
                          featureKey: 'tarot_spread',
                          offerType: OfferType.oneOffUnlock,
                          onAccessPurchase: (requirePro, _) async {
                            executions++;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GoRoute(
              path: subscription
                  ? SubscriptionRoute.routeName
                  : CoinsPaywallRoute.routeName,
              name: subscription
                  ? SubscriptionRoute.routeName
                  : CoinsPaywallRoute.routeName,
              builder: (context, state) {
                final uid = subscription
                    ? (state.extra! as SubscriptionRouteParams).returnUid
                    : (state.extra! as CoinsPaywallRouteParams).returnUid;
                if (!subscription) {
                  expect(
                    (state.extra! as CoinsPaywallRouteParams).minimumStars,
                    30,
                  );
                }
                return ContextualPurchasePage(
                  returnUid: uid,
                  subscription: subscription,
                  child: Builder(
                    builder: (context) => Scaffold(
                      body: Column(
                        children: [
                          const Text('Checkout'),
                          TextButton(
                            child: const Text('Verified'),
                            onPressed: () {
                              api.states
                                ..clear()
                                ..add(
                                  _state(
                                    balance: 100,
                                  ).copyWith(effectivePro: subscription),
                                );
                              PurchaseVerifiedNotification().dispatch(context);
                            },
                          ),
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => context.pop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          ChangeNotifierProvider<MonetizationProvider>.value(
            value: monetizationProvider,
            child: MaterialApp.router(
              routerConfig: router,
              locale: const Locale('ru'),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              supportedLocales: AppLocaleService.supportedLocales,
              builder: (context, child) => Theme(
                data: AppThemeLight.instance.getThemeData(context),
                child: child!,
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final cta = subscription
            ? AppLocalizations.current.openSubscription
            : AppLocalizations.current.balanceBuy;
        await tester.tap(find.text(cta));
        await tester.pumpAndSettle();
        expect(find.text('Checkout'), findsOneWidget);
        // Cancel must retain both the original input and selected purchase.
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(executions, 0);
        await tester.tap(find.text(cta));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Verified'));
        await tester.pumpAndSettle();
        expect(find.text('Checkout'), findsNothing);
        expect(executions, 0);
        expect(editor.text, 'Мой исходный вопрос');
        if (subscription) {
          expect(find.text('Подтвердите покупку'), findsNothing);
          expect(find.text('Open'), findsOneWidget);
        } else {
          expect(find.text('Подтвердите покупку'), findsOneWidget);
          await tester.tap(find.text('Купить'));
          await tester.pumpAndSettle();
          expect(executions, 1);
        }
      },
    );
  }

  testWidgets('verified notification cannot return for another account', (
    tester,
  ) async {
    api.states
      ..clear()
      ..add(_state(balance: 100).copyWith(effectivePro: true));
    await tester.pumpWidget(
      ChangeNotifierProvider<MonetizationProvider>.value(
        value: monetizationProvider,
        child: MaterialApp(
          home: ContextualPurchasePage(
            returnUid: 'user-1',
            subscription: true,
            child: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  child: const Text('Verified'),
                  onPressed: () =>
                      PurchaseVerifiedNotification().dispatch(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    userProvider.applyServerUserSnapshot(
      UserModel.empty().copyWith(id: 'user-2'),
    );
    await tester.tap(find.text('Verified'));
    await tester.pumpAndSettle();
    expect(find.text('Verified'), findsOneWidget);
    expect(api.getCurrentCalls, 1);
  });

  testWidgets('shows not enough stars when backend rejects stale balance', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<MonetizationProvider>.value(
        value: monetizationProvider,
        child: MaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocaleService.supportedLocales,
          home: Builder(
            builder: (context) => Theme(
              data: AppThemeLight.instance.getThemeData(context),
              child: Scaffold(
                body: SharedPurchaseModal(
                  purchaseTitle: 'Натальная карта',
                  price: 100,
                  onPurchase: () async {
                    throw const FeatureExecutionInsufficientStarsException(
                      'insufficient_stars',
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Купить'));
    await tester.pumpAndSettle();

    expect(find.text('Недостаточно звёздочётов'), findsOneWidget);
    expect(find.textContaining('60', findRichText: true), findsOneWidget);
    expect(api.getCurrentCalls, 3);
  });

  testWidgets('request pack modal title does not duplicate purchase noun', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<MonetizationProvider>.value(
        value: monetizationProvider,
        child: MaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocaleService.supportedLocales,
          home: Builder(
            builder: (context) => Theme(
              data: AppThemeLight.instance.getThemeData(context),
              child: Scaffold(
                body: SharedBuyRequestsScreen(
                  title: 'Выбор пакета',
                  originSurface: 'anakra',
                  packages: const [
                    PurchasePackage(price: 55, requestQuantity: 10),
                  ],
                  onPurchase: (_, __) async {},
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Купить'));
    await tester.pumpAndSettle();

    expect(find.text('Купить 10 запросов за 55'), findsOneWidget);
    expect(find.text('Купить Покупка 10 запросов за 55'), findsNothing);
  });
}

MonetizationStateModel _state({required int balance}) {
  final now = DateTime.parse('2026-08-30T12:00:00Z');
  return MonetizationStateModel(
    uid: 'user-1',
    catalogRevision: 1,
    wallet: WalletSnapshotModel(
      uid: 'user-1',
      balance: balance,
      debt: 0,
      sequence: balance,
      version: balance,
      updatedAt: now,
    ),
    effectivePro: false,
    effectiveGrants: const [],
    rewards: const [],
    requestQuotas: const {},
    rolloutPolicy: const {
      'enabled': true,
      'supported_features': [
        'tarot_spread',
        'weekly_horoscope',
        'monthly_horoscope',
        'yearly_personal_horoscope',
        'natal_chart',
        'day_horoscope_key_theme',
        'day_horoscope_weaknesses',
        'sonnik',
        'compatibility',
        'anakra',
      ],
    },
  );
}

class _FakeMonetizationApi extends MonetizationApi {
  _FakeMonetizationApi(this.states) : super.forDio(Dio(), _FakeSession());

  final List<MonetizationStateModel> states;
  int getCurrentCalls = 0;

  @override
  Future<MonetizationStateModel> getCurrent() async {
    final index = getCurrentCalls.clamp(0, states.length - 1);
    getCurrentCalls += 1;
    return states[index];
  }
}

class _RecordingAnalyticsFacade implements AnalyticsFacade {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserRepository implements UserRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSession implements AuthSessionService {
  @override
  String? get currentEmail => 'user@example.com';

  @override
  String? get currentUid => 'user-1';

  @override
  bool get hasRecentSignIn => true;

  @override
  bool get hasSession => true;

  @override
  Future<String?> getAccessToken({bool forceRefresh = false}) async =>
      'access-token';

  Future<String?> getAccessTokenForUid(
    String expectedUid, {
    bool forceRefresh = false,
  }) async => expectedUid == currentUid ? 'access-token' : null;

  @override
  Future<void> deleteCurrentIdentity() async {}

  @override
  Future<void> saveSession({
    required String uid,
    required String? email,
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {}

  @override
  Future<void> signOut() async {}
}

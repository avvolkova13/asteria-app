import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/widgets/shared_buy_requests_screen.dart';
import 'package:asteria_app/core/ui_kit/widgets/shared_purchase_modal.dart';
import 'package:asteria_app/features/anakra_chat/presentation/screens/create_anakra_requests_left_screen.dart';
import 'package:asteria_app/features/monetization/data/monetization_api.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final fonts = {
      'Urbanist': 'assets/fonts/urbanist/Urbanist-Regular.ttf',
      'PlayfairDisplay': 'assets/fonts/playfair/PlayfairDisplay-Regular.ttf',
    };
    for (final entry in fonts.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(rootBundle.load(entry.value));
      await loader.load();
    }
  });

  setUp(() async {
    await di.reset();
    final analytics = _RecordingAnalyticsFacade();
    di.registerSingleton<AnalyticsFacade>(analytics);
    di.registerSingleton<ProductAnalyticsService>(
      ProductAnalyticsService(analytics),
    );
    di.registerSingleton<GlobalLoaderService>(GlobalLoaderService());
  });

  tearDown(() async {
    await di.reset();
  });

  testWidgets('shows total available Anakra requests without weekly fraction', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _anakraRequestsLeftApp(quota: _quota(freeRemaining: 2, paidRemaining: 1)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Осталось 3 запроса'), findsOneWidget);
    expect(find.textContaining('/3'), findsNothing);
  });

  testWidgets('buys requests with existing stars and unlocks a quota command', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final flow = await _PurchaseFlow.create(balance: 230);
    addTearDown(flow.dispose);
    await tester.pumpWidget(flow.app());
    await _openRequestPurchase(tester);
    expect(find.text('Купить 10 запросов за 55'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(SharedPurchaseModal),
        matching: find.text('Купить'),
      ),
    );
    await tester.pumpAndSettle();
    expect(flow.provider.balance, 175);
    expect(flow.provider.requestsLeft('anakra'), 10);
    expect(flow.api.purchases.single.quantity, 10);
    expect(flow.api.purchases.single.key, isNotEmpty);
    expect(find.byType(SharedPurchaseModal), findsNothing);
    expect(flow.router.state.uri.path, AnakraChatRoutes.anakraChatRouteName);
    expect(await flow.provider.canMakeRequestFresh('anakra'), isTrue);
    final result = await flow.provider.executeRequestQuotaCommand(
      'anakra',
      payload: const {'message': 'Вопрос'},
    );
    expect(result.result['response'], 'Ответ');
    expect(flow.provider.requestsLeft('anakra'), 9);
  });

  testWidgets(
    'top-up preserves the request purchase and charges only on confirmation',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final flow = await _PurchaseFlow.create(balance: 50);
      addTearDown(flow.dispose);
      await tester.pumpWidget(flow.app());
      await _openRequestPurchase(tester);
      expect(find.text('Недостаточно звёздочётов'), findsOneWidget);
      await tester.tap(find.text('Купить звёздочёты'));
      await tester.pumpAndSettle();
      expect(flow.router.state.uri.path, CoinsPaywallRoute.routeName);
      expect(
        (flow.router.state.extra as CoinsPaywallRouteParams).minimumStars,
        5,
      );
      expect(flow.api.purchases, isEmpty);
      // The external checkout credits stars; it does not purchase a request pack.
      flow.api.state = flow.api.state.copyWith(
        wallet: flow.api.state.wallet.copyWith(balance: 60),
      );
      await flow.provider.refresh();
      flow.router.pop();
      await tester.pumpAndSettle();
      expect(flow.provider.requestsLeft('anakra'), 0);
      expect(find.text('Купить 10 запросов за 55'), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(SharedPurchaseModal),
          matching: find.text('Купить'),
        ),
      );
      await tester.pumpAndSettle();
      expect(flow.provider.balance, 5);
      expect(flow.provider.requestsLeft('anakra'), 10);
      expect(flow.api.purchases, hasLength(1));
    },
  );

  testWidgets('request pack deep link can return to chat after purchase', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final flow = await _PurchaseFlow.create(balance: 230, deepLink: true);
    addTearDown(flow.dispose);
    await tester.pumpWidget(flow.app());
    await tester.pumpAndSettle();
    await _tapBuy(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(SharedPurchaseModal),
        matching: find.text('Купить'),
      ),
    );
    await tester.pumpAndSettle();

    expect(flow.router.state.uri.path, AnakraChatRoutes.anakraChatRouteName);
  });

  testWidgets('keeps the existing Anakra request pack price in the offer', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _anakraRequestsLeftApp(quota: _quota(freeRemaining: 0, paidRemaining: 0)),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 вопрос = 7 '), findsOneWidget);
    expect(find.text('1 вопрос = 10 '), findsNothing);
  });
}

Widget _anakraRequestsLeftApp({
  required RequestQuotaModel quota,
  ValueChanged<Object?>? onCoinsRoute,
}) {
  final authSession = _FakeSession();
  final userProvider = UserProvider(
    userRepository: _FakeUserRepository(),
    authSessionService: authSession,
  )..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
  final monetizationProvider = _FixedMonetizationProvider(
    userProvider: userProvider,
    quota: quota,
  );

  final router = GoRouter(
    initialLocation: AnakraChatRoutes.createAnakraRequestsLeftRouteName,
    routes: [
      GoRoute(
        path: AnakraChatRoutes.createAnakraRequestsLeftRouteName,
        name: AnakraChatRoutes.createAnakraRequestsLeftRouteName,
        builder: (context, state) => MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: userProvider),
            ChangeNotifierProvider<MonetizationProvider>.value(
              value: monetizationProvider,
            ),
          ],
          child: const CreateAnakraRequestsLeftScreen(),
        ),
      ),
      GoRoute(
        path: SubscriptionRoute.routeName,
        name: SubscriptionRoute.routeName,
        builder: (context, state) =>
            const Scaffold(body: Text('subscription destination')),
      ),
      GoRoute(
        path: AnakraChatRoutes.createAnakraSubscriptionRouteName,
        name: AnakraChatRoutes.createAnakraSubscriptionRouteName,
        builder: (context, state) =>
            const Scaffold(body: Text('old request pack destination')),
      ),
      GoRoute(
        path: CoinsPaywallRoute.routeName,
        name: CoinsPaywallRoute.routeName,
        builder: (context, state) {
          onCoinsRoute?.call(state.extra);
          return const Scaffold(body: Text('coins destination'));
        },
      ),
      GoRoute(
        path: BalanceRoute.routeName,
        name: BalanceRoute.routeName,
        builder: (context, state) =>
            const Scaffold(body: Text('balance destination')),
      ),
    ],
  );

  return MaterialApp.router(
    locale: const Locale('ru'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocaleService.supportedLocales,
    routerConfig: router,
    builder: (context, child) {
      return Theme(
        data: AppThemeDark.instance.getThemeData(context),
        child: child ?? const SizedBox.shrink(),
      );
    },
  );
}

Future<void> _tapBuy(WidgetTester tester) async {
  expect(find.byType(SharedBuyRequestsScreen), findsOneWidget);
  await tester.scrollUntilVisible(find.text('Купить'), 200);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Купить'));
  await tester.pumpAndSettle();
}

Future<void> _openRequestPurchase(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(find.text('limits'));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(find.text('Купи попытки'), 200);
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Купи попытки'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Купи попытки'));
  await tester.pumpAndSettle();
  await _tapBuy(tester);
}

class _PurchaseFlow {
  _PurchaseFlow(this.user, this.api, this.provider, {required bool deepLink}) {
    router = GoRouter(
      initialLocation: deepLink
          ? AnakraChatRoutes.createAnakraSubscriptionRouteName
          : AnakraChatRoutes.anakraChatRouteName,
      routes: [
        GoRoute(
          path: AnakraChatRoutes.anakraChatRouteName,
          name: AnakraChatRoutes.anakraChatRouteName,
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => CreateAnakraRequestsLeftRoute.push(context),
              child: const Text('limits'),
            ),
          ),
        ),
        CreateAnakraRequestsLeftRoute(),
        CreateAnakraSubscriptionRoute(),
        GoRoute(
          path: CoinsPaywallRoute.routeName,
          name: CoinsPaywallRoute.routeName,
          builder: (_, __) => const Scaffold(body: Text('external checkout')),
        ),
      ],
    );
  }

  final UserProvider user;
  final _PurchaseApi api;
  final MonetizationProvider provider;
  late final GoRouter router;

  static Future<_PurchaseFlow> create({
    required int balance,
    bool deepLink = false,
  }) async {
    final user = UserProvider(
      userRepository: _FakeUserRepository(),
      authSessionService: _FakeSession(),
    )..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
    final api = _PurchaseApi(balance);
    final provider = MonetizationProvider(api: api, userProvider: user);
    await provider.ensureLoaded();
    di.registerSingleton<MonetizationProvider>(provider);
    return _PurchaseFlow(user, api, provider, deepLink: deepLink);
  }

  Widget app() => MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>.value(value: user),
      ChangeNotifierProvider<MonetizationProvider>.value(value: provider),
    ],
    child: MaterialApp.router(
      locale: const Locale('ru'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocaleService.supportedLocales,
      routerConfig: router,
      builder: (context, child) => Theme(
        data: AppThemeDark.instance.getThemeData(context),
        child: child!,
      ),
    ),
  );

  void dispose() {
    router.dispose();
    provider.dispose();
    user.dispose();
  }
}

class _PurchaseApi extends MonetizationApi {
  _PurchaseApi(int balance) : super.forDio(Dio(), _FakeSession()) {
    state = MonetizationStateModel(
      uid: 'user-1',
      catalogRevision: 1,
      wallet: WalletSnapshotModel(
        uid: 'user-1',
        balance: balance,
        debt: 0,
        sequence: 0,
        version: 0,
        updatedAt: DateTime.now(),
      ),
      effectivePro: false,
      effectiveGrants: const [],
      rewards: const [],
      requestQuotas: {'anakra': _quota(freeRemaining: 0, paidRemaining: 0)},
      rolloutPolicy: const {},
    );
  }

  late MonetizationStateModel state;
  final purchases = <({int quantity, String key})>[];

  @override
  Future<MonetizationStateModel> getCurrent() async => state;

  @override
  Future<RequestQuotaPurchaseResultModel> purchaseRequestPack({
    required String feature,
    required int quantity,
    required String idempotencyKey,
  }) async {
    expect(feature, 'anakra');
    expect(quantity, 10);
    purchases.add((quantity: quantity, key: idempotencyKey));
    state = state.copyWith(
      wallet: state.wallet.copyWith(balance: state.balance - 55),
      requestQuotas: {'anakra': _quota(freeRemaining: 0, paidRemaining: 10)},
    );
    return RequestQuotaPurchaseResultModel(
      feature: feature,
      quantity: quantity,
      price: 55,
      replayed: false,
      wallet: state.wallet,
      quota: state.requestQuota('anakra'),
    );
  }

  @override
  Future<RequestQuotaCommandResultModel> executeRequestQuotaCommand({
    required String feature,
    required Map<String, dynamic> payload,
    required String idempotencyKey,
  }) async {
    expect(feature, 'anakra');
    expect(payload['message'], 'Вопрос');
    state = state.copyWith(
      requestQuotas: {'anakra': _quota(freeRemaining: 0, paidRemaining: 9)},
    );
    return RequestQuotaCommandResultModel(
      uid: 'user-1',
      feature: feature,
      source: 'paid',
      replayed: false,
      quota: state.requestQuota('anakra'),
      result: const {'response': 'Ответ'},
      user: UserModel.empty().copyWith(id: 'user-1'),
    );
  }
}

RequestQuotaModel _quota({
  required int freeRemaining,
  required int paidRemaining,
}) {
  final now = DateTime.now();
  return RequestQuotaModel(
    feature: 'anakra',
    freeRemaining: freeRemaining,
    paidRemaining: paidRemaining,
    freeLimit: 3,
    periodStartedAt: now.subtract(const Duration(days: 4)),
    periodEndsAt: now.add(const Duration(days: 3)),
    updatedAt: now,
  );
}

class _FixedMonetizationProvider extends MonetizationProvider {
  _FixedMonetizationProvider({required super.userProvider, required this.quota})
    : super(api: _FakeMonetizationApi());

  final RequestQuotaModel quota;

  @override
  int get balance => 230;

  @override
  bool get effectivePro => false;

  @override
  RequestQuotaModel requestQuota(String feature) => quota;
}

class _RecordingAnalyticsFacade implements AnalyticsFacade {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMonetizationApi extends MonetizationApi {
  _FakeMonetizationApi() : super.forDio(Dio(), _FakeSession());
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

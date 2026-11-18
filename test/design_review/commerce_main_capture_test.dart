import 'commerce_review_capture_test.dart'
    show capture, captureKey, bottom, ReviewBinding;

import 'dart:io';

import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';
import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/balance/data/reward_event_store.dart';
import 'package:asteria_app/features/balance/data/reward_share_service.dart';
import 'package:asteria_app/features/balance/data/rewards_api.dart';
import 'package:asteria_app/features/balance/domain/reward_models.dart';
import 'package:asteria_app/features/balance/presentation/provider/rewards_provider.dart';
import 'package:asteria_app/features/balance/presentation/screens/balance_screen.dart';
import 'package:asteria_app/features/monetization/data/monetization_api.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/shop/domain/shop_repository.dart';
import 'package:asteria_app/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:asteria_app/features/shop/presentation/shop_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

String reviewLang = 'ru';
bool reviewCompact = false;
bool reviewShopError = false;
void main() {
  ReviewBinding();
  setUpAll(() async {
    Directory('/private/tmp/asteria-design-review/commerce')
        .createSync(recursive: true);
    for (final f in [
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
      ('Lora', 'assets/fonts/lora/Lora-VariableFont_wght.ttf'),
      ('Onest', 'assets/fonts/onest/Onest-VariableFont_wght.ttf'),
    ]) {
      await (FontLoader(f.$1)..addFont(rootBundle.load(f.$2))).load();
    }
  });
  for (final lang in ['ru', 'en']) {
    for (final compact in [false, true]) {
      testWidgets('shop and balance $lang compact=$compact', (t) async {
        reviewLang = lang;
        reviewCompact = compact;
        t.view.devicePixelRatio = 1;
        t.view.physicalSize = compact
            ? const Size(320, 568)
            : const Size(390, 844);
        final suffix = '${lang}_${compact ? '320_text2' : '390'}';
        addTearDown(() async {
          await t.pumpWidget(const SizedBox());
          await t.runAsync(() => di.reset());
          t.view.reset();
        });
        for (final state in ['loaded', 'empty', 'error']) {
          await t.pumpWidget(const SizedBox());
          await t.runAsync(() => di.reset());
          reviewShopError = state == 'error';
          await t.pumpWidget(
            await reviewShopApp(
              effectivePro: false,
              products: state == 'empty'
                  ? []
                  : const [
                      ShopItemModel(
                        id: UserProvider.shopItemAnakraId,
                        title: 'Вопрос Анакре',
                        category: 'Запросы',
                        description: 'узнай свой путь',
                        price: 10,
                      ),
                      ShopItemModel(
                        id: '464ef852-f767-49f1-b8d7-724f188f90c4',
                        title: 'Любовный расклад',
                        category: 'Таро',
                        description: 'Расклад таро о любви',
                        price: 10,
                      ),
                    ],
            ),
          );
          await t.pumpAndSettle();
          await capture(t, 'shop_${state}_$suffix');
          await bottom(t, 'shop_${state}_$suffix');
          await t.pumpWidget(const SizedBox());
        }
        await t.runAsync(() => di.reset());
        await t.pumpWidget(reviewBalanceApp());
        await t.pumpAndSettle();
        await capture(t, 'balance_loaded_$suffix');
        await bottom(t, 'balance_loaded_$suffix');
        final l10n = AppLocalizations.current;
        for (final entry in <(String, Finder)>[
          ('spend', find.text(l10n.balanceWhereToSpend)),
          ('spend_middle', find.text(l10n.balanceServiceCompatibility)),
          ('spend_bottom', find.text(l10n.balanceServiceNatal)),
          (
            'reward_onboarding',
            find.byKey(const ValueKey('reward_card_onboarding')),
          ),
          ('reward_tarot', find.byKey(const ValueKey('reward_card_tarot'))),
          (
            'reward_articles',
            find.byKey(const ValueKey('reward_card_articles')),
          ),
          ('reward_share', find.byKey(const ValueKey('reward_card_share'))),
          (
            'reward_streak',
            find.byKey(const ValueKey('reward_card_login_streak')),
          ),
        ]) {
          await Scrollable.ensureVisible(t.element(entry.$2), alignment: 0);
          await t.pump();
          await capture(t, 'balance_${entry.$1}_$suffix');
        }
      });
    }
  }
}

Future<Widget> reviewShopApp({
  required bool effectivePro,
  List<ShopItemModel> products = const [
    ShopItemModel(
      id: UserProvider.shopItemSonnikId,
      title: 'Сонник',
      category: 'Запросы',
      description: 'Пакет запросов',
      price: 7,
    ),
  ],
  ValueChanged<Object?>? onSubscriptionRoute,
}) async {
  final userProvider = UserProvider(
    userRepository: _ShopFakeUserRepository(),
    authSessionService: _ShopFakeSession(),
  )..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
  final monetizationProvider = MonetizationProvider(
    api: _ShopFakeMonetizationApi(_shopState(effectivePro: effectivePro)),
    userProvider: userProvider,
  );
  await monetizationProvider.ensureLoaded();
  final shopBloc = ShopBloc(
    shopRepository: _ShopFakeShopRepository(products),
    monetizationProvider: monetizationProvider,
  );
  final analytics = _ShopRecordingAnalyticsFacade();

  di.registerSingleton<AnalyticsFacade>(analytics);
  di.registerSingleton<ProductAnalyticsService>(
    ProductAnalyticsService(analytics),
  );
  di.registerSingleton<ShopBloc>(shopBloc, dispose: (bloc) => bloc.close());

  final router = GoRouter(
    initialLocation: ShopRoute.routeName,
    routes: [
      GoRoute(
        path: ShopRoute.routeName,
        name: ShopRoute.routeName,
        builder: (context, state) => MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: userProvider),
            ChangeNotifierProvider<MonetizationProvider>.value(
              value: monetizationProvider,
            ),
          ],
          child: BlocProvider<ShopBloc>.value(
            value: shopBloc,
            child: const ShopScreen(),
          ),
        ),
      ),
      GoRoute(
        path: SubscriptionRoute.routeName,
        name: SubscriptionRoute.routeName,
        builder: (context, state) {
          onSubscriptionRoute?.call(state.extra);
          return const Scaffold(body: Text('subscription destination'));
        },
      ),
    ],
  );

  return MaterialApp.router(
    locale: Locale(reviewLang),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocaleService.supportedLocales,
    routerConfig: router,
    builder: (context, child) {
      return Theme(
        data: AppThemeDark.instance.getThemeData(context),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(reviewCompact ? 2 : 1),
            disableAnimations: true,
            padding: EdgeInsets.only(
              top: reviewCompact ? 20 : 59,
              bottom: reviewCompact ? 0 : 34,
            ),
          ),
          child: RepaintBoundary(
            key: captureKey,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      );
    },
  );
}

MonetizationStateModel _shopState({required bool effectivePro}) {
  final now = DateTime.parse('2026-09-06T12:00:00Z');
  return MonetizationStateModel(
    uid: 'user-1',
    catalogRevision: 1,
    wallet: WalletSnapshotModel(
      uid: 'user-1',
      balance: 0,
      debt: 0,
      sequence: 0,
      version: 0,
      updatedAt: now,
    ),
    effectivePro: effectivePro,
    effectiveGrants: const [],
    rewards: const [],
    requestQuotas: const {},
    rolloutPolicy: const {},
  );
}

class _ShopFakeMonetizationApi extends MonetizationApi {
  _ShopFakeMonetizationApi(this.state)
    : super.forDio(Dio(), _ShopFakeSession());

  final MonetizationStateModel state;

  @override
  Future<MonetizationStateModel> getCurrent() async => state;
}

class _ShopFakeShopRepository implements ShopRepository {
  const _ShopFakeShopRepository(this.products);

  final List<ShopItemModel> products;

  @override
  Future<List<ShopItemModel>> getShopItems() async {
    if (reviewShopError) throw StateError('offline');
    return products;
  }
}

class _ShopRecordingAnalyticsFacade implements AnalyticsFacade {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ShopFakeSession implements AuthSessionService {
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

class _ShopFakeUserRepository implements UserRepository {
  @override
  Future<void> addCompatibilityToHistory(
    SavedCompatibilityModel compatibility,
  ) async {}

  @override
  Future<void> clearCurrentUser() async {}

  @override
  Future<void> deleteUser(String userId) async {}

  @override
  Future<UserModel?> getCurrentUser() async => null;

  @override
  Stream<UserModel?> getMe() => const Stream.empty();

  @override
  Future<UserModel?> getUserById(String userId) async => null;

  @override
  Future<void> setCurrentUser(UserModel user) async {}

  @override
  Future<void> updateCurrentUser(UserModel user) async {}

  @override
  Future<void> updateUserShopItems(
    String userId,
    List<ShopItemModel> shopItems,
  ) async {}
}

Widget reviewBalanceApp({ValueChanged<Object?>? onSubscriptionRoute}) {
  final authSession = _BalanceFakeSession();
  final userProvider = UserProvider(
    userRepository: _BalanceFakeUserRepository(),
    authSessionService: authSession,
  )..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
  final monetizationProvider = MonetizationProvider(
    api: _BalanceFakeMonetizationApi(_balanceState()),
    userProvider: userProvider,
  );
  final rewardsProvider = RewardsProvider(
    api: _BalanceFakeRewardsApi(),
    store: _BalanceFakeRewardEventStore(),
    shareService: _BalanceFakeRewardShareService(),
    userProvider: userProvider,
    monetizationProvider: monetizationProvider,
  );

  final router = GoRouter(
    initialLocation: BalanceRoute.routeName,
    routes: [
      GoRoute(
        path: BalanceRoute.routeName,
        name: BalanceRoute.routeName,
        builder: (context, state) => MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: userProvider),
            ChangeNotifierProvider<MonetizationProvider>.value(
              value: monetizationProvider,
            ),
            ChangeNotifierProvider<RewardsProvider>.value(
              value: rewardsProvider,
            ),
          ],
          child: const BalanceScreen(),
        ),
      ),
      GoRoute(
        path: SubscriptionRoute.routeName,
        name: SubscriptionRoute.routeName,
        builder: (context, state) {
          onSubscriptionRoute?.call(state.extra);
          return const Scaffold(body: Text('subscription destination'));
        },
      ),
      GoRoute(
        path: BalanceHistoryRoute.routeName,
        name: BalanceHistoryRoute.routeName,
        builder: (context, state) =>
            const Scaffold(body: Text('history destination')),
      ),
      GoRoute(
        path: CoinsPaywallRoute.routeName,
        name: CoinsPaywallRoute.routeName,
        builder: (context, state) =>
            const Scaffold(body: Text('coins destination')),
      ),
    ],
  );

  return MaterialApp.router(
    locale: Locale(reviewLang),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocaleService.supportedLocales,
    routerConfig: router,
    builder: (context, child) {
      return Theme(
        data: AppThemeDark.instance.getThemeData(context),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(reviewCompact ? 2 : 1),
            disableAnimations: true,
            padding: EdgeInsets.only(
              top: reviewCompact ? 20 : 59,
              bottom: reviewCompact ? 0 : 34,
            ),
          ),
          child: RepaintBoundary(
            key: captureKey,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      );
    },
  );
}

MonetizationStateModel _balanceState() {
  final now = DateTime.parse('2026-09-07T12:00:00Z');
  return MonetizationStateModel(
    uid: 'user-1',
    catalogRevision: 1,
    wallet: WalletSnapshotModel(
      uid: 'user-1',
      balance: 1116,
      debt: 0,
      sequence: 0,
      version: 0,
      updatedAt: now,
    ),
    effectivePro: false,
    effectiveGrants: const [],
    rewards: defaultRewardStatuses,
    requestQuotas: const {},
    rolloutPolicy: const {},
  );
}

class _BalanceFakeRewardsApi extends RewardsApi {
  _BalanceFakeRewardsApi() : super.forDio(Dio(), _BalanceFakeSession());

  @override
  Future<RewardsResponseModel> getRewards({
    required String userId,
    required int timezoneOffsetMinutes,
  }) async => const RewardsResponseModel(
    uid: 'user-1',
    balance: 1116,
    grantedAmount: 0,
    grantedRewardId: null,
    items: defaultRewardStatuses,
  );
}

class _BalanceFakeRewardEventStore extends RewardEventStore {
  @override
  Future<void> init() async {}

  @override
  Future<List<PendingRewardEvent>> eventsFor(String userId) async => const [];

  @override
  Future<void> save(PendingRewardEvent event) async {}

  @override
  Future<void> delete(String eventId) async {}
}

class _BalanceFakeRewardShareService extends RewardShareService {
  @override
  Future<bool> shareInvite({
    required String text,
    required String subject,
    Rect? origin,
  }) async => false;
}

class _BalanceFakeMonetizationApi extends MonetizationApi {
  _BalanceFakeMonetizationApi(this.state)
    : super.forDio(Dio(), _BalanceFakeSession());

  final MonetizationStateModel state;

  @override
  Future<MonetizationStateModel> getCurrent() async => state;
}

class _BalanceFakeSession implements AuthSessionService {
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

class _BalanceFakeUserRepository implements UserRepository {
  @override
  Future<void> addCompatibilityToHistory(
    SavedCompatibilityModel compatibility,
  ) async {}

  @override
  Future<void> clearCurrentUser() async {}

  @override
  Future<void> deleteUser(String userId) async {}

  @override
  Future<UserModel?> getCurrentUser() async => null;

  @override
  Stream<UserModel?> getMe() => const Stream.empty();

  @override
  Future<UserModel?> getUserById(String userId) async => null;

  @override
  Future<void> setCurrentUser(UserModel user) async {}

  @override
  Future<void> updateCurrentUser(UserModel user) async {}

  @override
  Future<void> updateUserShopItems(
    String userId,
    List<ShopItemModel> shopItems,
  ) async {}
}

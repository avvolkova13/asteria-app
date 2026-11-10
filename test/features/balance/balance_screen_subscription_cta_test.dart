import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';
import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
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
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opens subscription screen from balance subscription CTA', (
    tester,
  ) async {
    Object? subscriptionExtra;

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _balanceApp(onSubscriptionRoute: (extra) => subscriptionExtra = extra),
    );
    await tester.pumpAndSettle();

    final cta = find.text('Выбрать подписку');
    await tester.ensureVisible(cta);
    await tester.tap(cta);
    await tester.pumpAndSettle();

    expect(find.text('subscription destination'), findsOneWidget);
    expect(subscriptionExtra, isA<SubscriptionRouteParams>());
    expect(
      (subscriptionExtra as SubscriptionRouteParams).originSurface,
      'balance_subscription_banner',
    );
  });
}

Widget _balanceApp({ValueChanged<Object?>? onSubscriptionRoute}) {
  final authSession = _FakeSession();
  final userProvider = UserProvider(
    userRepository: _FakeUserRepository(),
    authSessionService: authSession,
  )..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
  final monetizationProvider = MonetizationProvider(
    api: _FakeMonetizationApi(_state()),
    userProvider: userProvider,
  );
  final rewardsProvider = RewardsProvider(
    api: _FakeRewardsApi(),
    store: _FakeRewardEventStore(),
    shareService: _FakeRewardShareService(),
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

MonetizationStateModel _state() {
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

class _FakeRewardsApi extends RewardsApi {
  _FakeRewardsApi() : super.forDio(Dio(), _FakeSession());

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

class _FakeRewardEventStore extends RewardEventStore {
  @override
  Future<void> init() async {}

  @override
  Future<List<PendingRewardEvent>> eventsFor(String userId) async => const [];

  @override
  Future<void> save(PendingRewardEvent event) async {}

  @override
  Future<void> delete(String eventId) async {}
}

class _FakeRewardShareService extends RewardShareService {
  @override
  Future<bool> shareInvite({
    required String text,
    required String subject,
    Rect? origin,
  }) async => false;
}

class _FakeMonetizationApi extends MonetizationApi {
  _FakeMonetizationApi(this.state) : super.forDio(Dio(), _FakeSession());

  final MonetizationStateModel state;

  @override
  Future<MonetizationStateModel> getCurrent() async => state;
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

class _FakeUserRepository implements UserRepository {
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

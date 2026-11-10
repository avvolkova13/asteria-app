import 'dart:async';

import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';
import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/payments/api/store_payments_api.dart';
import 'package:asteria_app/features/monetization/data/monetization_api.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'PRO can request with exhausted quotas, but rollout still blocks it',
    () async {
      final user = UserProvider(
        userRepository: _FakeUserRepository(),
        authSessionService: _FakeSession(),
      )..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
      final api = _FakeMonetizationApi(
        _stateWithQuota(
          feature: 'sonnik',
          freeRemaining: 0,
        ).copyWith(effectivePro: true),
      );
      final provider = MonetizationProvider(api: api, userProvider: user);
      addTearDown(provider.dispose);
      expect(await provider.canMakeRequestFresh('sonnik'), isTrue);
      expect(provider.requestsLeft('sonnik'), 0);
      api.state = api.state.copyWith(rolloutPolicy: {'kill_switch': true});
      expect(await provider.canMakeRequestFresh('sonnik'), isFalse);
    },
  );

  test('failed access refresh does not reuse stale paid access', () async {
    final user = UserProvider(
      userRepository: _FakeUserRepository(),
      authSessionService: _FakeSession(),
    )..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
    final api = _FakeMonetizationApi(
      _stateWithQuota(feature: 'sonnik', freeRemaining: 1),
    );
    final provider = MonetizationProvider(api: api, userProvider: user);
    addTearDown(provider.dispose);
    await provider.ensureLoaded();
    api.fail = true;
    await expectLater(provider.canMakeRequestFresh('sonnik'), throwsException);
  });

  for (final existingPro in [false, true]) {
    test(
      'historical fulfilled transaction preserves authoritative PRO=$existingPro',
      () async {
        final userProvider = UserProvider(
          userRepository: _FakeUserRepository(),
          authSessionService: _FakeSession(),
        )..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
        final api = _FakeMonetizationApi(
          _stateWithQuota(
            feature: 'sonnik',
            freeRemaining: 1,
          ).copyWith(effectivePro: existingPro),
        );
        final provider = MonetizationProvider(
          api: api,
          userProvider: userProvider,
        );
        addTearDown(provider.dispose);
        await provider.ensureLoaded();
        final observed = <bool>[];
        provider.addListener(() => observed.add(provider.effectivePro));

        await provider.refreshAfterVerify(
          const StoreVerifyResponse(
            transactionId: 'expired-weekly',
            status: 'fulfilled',
            balance: 0,
            productType: 'subscription',
            subscriptionType: 'free',
          ),
        );

        expect(observed, isNotEmpty);
        expect(observed, everyElement(existingPro));
        expect(provider.effectivePro, existingPro);
      },
    );
  }

  test(
    'PRO becomes active from refreshed server state after a new purchase',
    () async {
      final userProvider = UserProvider(
        userRepository: _FakeUserRepository(),
        authSessionService: _FakeSession(),
      )..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
      final api = _FakeMonetizationApi(
        _stateWithQuota(feature: 'sonnik', freeRemaining: 1),
      );
      final provider = MonetizationProvider(
        api: api,
        userProvider: userProvider,
      );
      addTearDown(provider.dispose);
      await provider.ensureLoaded();
      api.state = api.state.copyWith(effectivePro: true);

      await provider.refreshAfterVerify(
        const StoreVerifyResponse(
          transactionId: 'new-weekly',
          status: 'fulfilled',
          balance: 0,
          productType: 'subscription',
          subscriptionType: 'pro',
        ),
      );

      expect(provider.effectivePro, isTrue);
      expect(api.getCurrentCalls, 2);
    },
  );

  test(
    'fresh request check loads quota snapshot before denying access',
    () async {
      final userProvider = UserProvider(
        userRepository: _FakeUserRepository(),
        authSessionService: _FakeSession(),
      )..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
      final api = _FakeMonetizationApi(
        _stateWithQuota(feature: 'sonnik', freeRemaining: 1),
      );
      final provider = MonetizationProvider(
        api: api,
        userProvider: userProvider,
      );

      final canMakeRequest = await provider.canMakeRequestFresh('sonnik');

      expect(canMakeRequest, isTrue);
      expect(api.getCurrentCalls, 1);
      expect(provider.requestsLeft('sonnik'), 1);
    },
  );

  test(
    'fresh request check refreshes an already loaded quota snapshot',
    () async {
      final userProvider = UserProvider(
        userRepository: _FakeUserRepository(),
        authSessionService: _FakeSession(),
      )..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
      final api = _FakeMonetizationApi(
        _stateWithQuota(feature: 'sonnik', freeRemaining: 1),
      );
      final provider = MonetizationProvider(
        api: api,
        userProvider: userProvider,
      );

      await provider.ensureLoaded();
      api.state = _stateWithQuota(feature: 'sonnik', freeRemaining: 0);

      final canMakeRequest = await provider.canMakeRequestFresh('sonnik');

      expect(canMakeRequest, isFalse);
      expect(api.getCurrentCalls, 2);
      expect(provider.requestsLeft('sonnik'), 0);
    },
  );

  test(
    'Apple refresh fences the real mutation seam after A logout login A',
    () async {
      final user = UserProvider(
        userRepository: _FakeUserRepository(),
        authSessionService: _FakeSession(),
      )..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
      final deferred = Completer<MonetizationStateModel>();
      final provider = MonetizationProvider(
        api: _CompleterMonetizationApi(deferred),
        userProvider: user,
      );
      var generation = 1;
      final refresh = provider.refreshAppleEntitlements(
        'user-1',
        isCurrent: () => generation == 1,
      );
      generation = 2;
      deferred.complete(
        _stateWithQuota(
          feature: 'sonnik',
          freeRemaining: 1,
        ).copyWith(effectivePro: true),
      );
      await refresh;
      expect(provider.state, isNull);
      expect(provider.balance, 0);
      expect(provider.effectivePro, isFalse);
      provider.dispose();
    },
  );

  test(
    'Apple refresh releases shared loading state after superseding another refresh',
    () async {
      final user = UserProvider(
        userRepository: _FakeUserRepository(),
        authSessionService: _FakeSession(),
      )..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
      final deferred = Completer<MonetizationStateModel>();
      final provider = MonetizationProvider(
        api: _CompleterMonetizationApi(deferred),
        userProvider: user,
      );
      final generic = provider.refresh();
      final apple = provider.refreshAppleEntitlements(
        'user-1',
        isCurrent: () => true,
      );
      deferred.complete(_stateWithQuota(feature: 'sonnik', freeRemaining: 1));
      await Future.wait([generic, apple]);
      expect(provider.isLoading, isFalse);
      provider.dispose();
    },
  );

  test('ignores stale refresh response after current user changes', () async {
    final userProvider = UserProvider(
      userRepository: _FakeUserRepository(),
      authSessionService: _FakeSession(),
    )..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
    final completer = Completer<MonetizationStateModel>();
    final api = _CompleterMonetizationApi(completer);
    final provider = MonetizationProvider(api: api, userProvider: userProvider);

    final refresh = provider.refresh();
    userProvider.applyServerUserSnapshot(
      UserModel.empty().copyWith(id: 'user-2'),
    );
    completer.complete(_stateWithQuota(feature: 'sonnik', freeRemaining: 1));
    await refresh;

    expect(provider.state, isNull);
    expect(provider.isLoading, isFalse);
  });

  test('quota command applies quota and authoritative user snapshot', () async {
    final userProvider = UserProvider(
      userRepository: _FakeUserRepository(),
      authSessionService: _FakeSession(),
    )..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
    final now = DateTime.parse('2026-08-30T12:00:00Z');
    final api = _FakeMonetizationApi(
      _stateWithQuota(feature: 'sonnik', freeRemaining: 1),
    );
    api.commandResult = RequestQuotaCommandResultModel(
      uid: 'user-1',
      feature: 'sonnik',
      source: 'free',
      replayed: false,
      quota: RequestQuotaModel(
        feature: 'sonnik',
        freeRemaining: 0,
        paidRemaining: 0,
        freeLimit: 3,
        periodStartedAt: now,
        periodEndsAt: now.add(const Duration(days: 7)),
        updatedAt: now,
      ),
      result: const {'title': 'Сон про море'},
      user: UserModel.empty().copyWith(
        id: 'user-1',
        sonnikHistory: [
          SonnikModel(
            id: 'sonnik-1',
            dateGenerated: now,
            title: 'Сон про море',
            interpretation: 'Море показывает движение.',
          ),
        ],
      ),
    );
    final provider = MonetizationProvider(api: api, userProvider: userProvider);

    await provider.ensureLoaded();
    final result = await provider.executeRequestQuotaCommand(
      'sonnik',
      payload: const {'text': 'море'},
      idempotencyKey: 'command-key-1',
    );

    expect(result.replayed, isFalse);
    expect(api.commandCalls, 1);
    expect(provider.requestsLeft('sonnik'), 0);
    expect(userProvider.currentUser?.sonnikHistory.single.id, 'sonnik-1');
  });

  test('rollout kill switch blocks request quota commands on client', () async {
    final userProvider = UserProvider(
      userRepository: _FakeUserRepository(),
      authSessionService: _FakeSession(),
    )..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
    final api = _FakeMonetizationApi(
      _stateWithQuota(
        feature: 'sonnik',
        freeRemaining: 1,
        rolloutPolicy: const {
          'enabled': false,
          'kill_switch': true,
          'supported_features': ['sonnik'],
        },
      ),
    );
    final provider = MonetizationProvider(api: api, userProvider: userProvider);

    await provider.ensureLoaded();

    expect(provider.canMakeRequest('sonnik'), isFalse);
    await expectLater(
      provider.executeRequestQuotaCommand(
        'sonnik',
        payload: const {'text': 'море'},
      ),
      throwsException,
    );
    expect(api.commandCalls, 0);
  });
}

MonetizationStateModel _stateWithQuota({
  required String feature,
  required int freeRemaining,
  Map<String, dynamic> rolloutPolicy = const {},
}) {
  final now = DateTime.parse('2026-08-30T12:00:00Z');
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
    effectivePro: false,
    effectiveGrants: const [],
    rewards: const [],
    requestQuotas: {
      feature: RequestQuotaModel(
        feature: feature,
        freeRemaining: freeRemaining,
        paidRemaining: 0,
        freeLimit: 3,
        periodStartedAt: now,
        periodEndsAt: now.add(const Duration(days: 7)),
        updatedAt: now,
      ),
    },
    rolloutPolicy: rolloutPolicy,
  );
}

class _FakeMonetizationApi extends MonetizationApi {
  _FakeMonetizationApi(this.state) : super.forDio(Dio(), _FakeSession());

  MonetizationStateModel state;
  RequestQuotaCommandResultModel? commandResult;
  int getCurrentCalls = 0;
  bool fail = false;
  int commandCalls = 0;

  @override
  Future<MonetizationStateModel> getCurrent() async {
    getCurrentCalls += 1;
    if (fail) throw Exception('offline');
    return state;
  }

  @override
  Future<RequestQuotaCommandResultModel> executeRequestQuotaCommand({
    required String feature,
    required Map<String, dynamic> payload,
    required String idempotencyKey,
  }) async {
    commandCalls += 1;
    return commandResult!;
  }
}

class _CompleterMonetizationApi extends MonetizationApi {
  _CompleterMonetizationApi(this.completer)
    : super.forDio(Dio(), _FakeSession());

  final Completer<MonetizationStateModel> completer;

  @override
  Future<MonetizationStateModel> getCurrent() => completer.future;
}

class _FakeSession implements AuthSessionService {
  @override
  String? get currentUid => 'user-1';

  @override
  String? get currentEmail => 'user@example.com';

  @override
  bool get hasRecentSignIn => true;

  @override
  bool get hasSession => true;

  @override
  Future<String?> getAccessToken({bool forceRefresh = false}) async =>
      'user-token';

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

  @override
  Future<void> deleteCurrentIdentity() async {}
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

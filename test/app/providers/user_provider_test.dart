import 'dart:async';

import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';
import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/utils/enums.dart';
import 'package:asteria_app/features/monetization/data/feature_execution_api.dart';
import 'package:asteria_app/features/monetization/data/pending_feature_execution_store.dart';
import 'package:asteria_app/features/monetization/domain/feature_execution_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserProvider.updateUser', () {
    test('updates currentUser when repository update succeeds', () async {
      final repository = _FakeUserRepository();
      final provider = UserProvider(userRepository: repository);
      final previousUser = _user(id: 'user-1', balance: 10);
      final nextUser = previousUser.copyWith(balance: 20);

      provider.applyServerUserSnapshot(previousUser);

      await provider.updateUser(nextUser);

      expect(provider.currentUser, same(nextUser));
      expect(repository.updatedUser, same(nextUser));
      expect(provider.error, isNull);
    });

    test(
      'rolls back currentUser and rethrows when repository update fails',
      () async {
        final repository = _FakeUserRepository(throwOnUpdate: true);
        final provider = UserProvider(userRepository: repository);
        final previousUser = _user(id: 'user-1', balance: 10);
        final nextUser = previousUser.copyWith(balance: 20);

        provider.applyServerUserSnapshot(previousUser);

        await expectLater(
          provider.updateUser(nextUser),
          throwsA(isA<Exception>()),
        );

        expect(provider.currentUser, same(previousUser));
        expect(provider.error, contains('update failed'));
      },
    );

    test('does not publish a late profile update after user changes', () async {
      final repository = _FakeUserRepository();
      final provider = UserProvider(userRepository: repository);
      final userA = _user(id: 'user-a', balance: 10);
      final userB = _user(id: 'user-b', balance: 30);
      final completer = Completer<void>();
      repository.updateCompleter = completer;

      provider.applyServerUserSnapshot(userA);
      final update = provider.updateUser(userA.copyWith(balance: 20));
      provider.applyServerUserSnapshot(userB);
      completer.complete();
      await update;

      expect(provider.currentUser?.id, 'user-b');
      expect(provider.currentUser?.balance, 30);
    });
  });

  test(
    'achievement response preserves rollback of an unrelated optimistic edit',
    () async {
      final repository = _FakeUserRepository();
      final provider = UserProvider(userRepository: repository);
      addTearDown(provider.dispose);
      final initial = _user(id: 'a', balance: 10).copyWith(name: 'Before');
      provider.applyServerUserSnapshot(initial);
      repository.updateCompleter = Completer<void>();
      final update = provider.updateUser(initial.copyWith(name: 'Optimistic'));
      provider.applyAchievementStatistics(
        'a',
        const UserStatisticsModel(tarotCardsOpened: 1),
      );
      final assertion = expectLater(update, throwsException);
      repository.updateCompleter!.completeError(Exception('network failed'));
      await assertion;
      expect(provider.currentUser!.name, 'Before');
      expect(provider.currentUser!.statistics.tarotCardsOpened, 1);
      provider.applyServerUserSnapshot(initial);
      expect(provider.currentUser!.statistics.tarotCardsOpened, 1);
      provider.applyServerUserSnapshot(initial.copyWith(id: 'b'));
      expect(provider.currentUser!.statistics.tarotCardsOpened, 0);
      provider.applyAchievementStatistics(
        'a',
        const UserStatisticsModel(tarotCardsOpened: 2),
      );
      expect(provider.currentUser!.statistics.tarotCardsOpened, 0);
    },
  );

  test(
    'late profile stream cannot decrease acknowledged counters or leak across accounts',
    () async {
      final repository = _StreamUserRepository();
      final provider = UserProvider(userRepository: repository);
      addTearDown(provider.dispose);
      addTearDown(repository.snapshots.close);
      await provider.initialize();
      final initial = _user(id: 'a', balance: 10);
      repository.snapshots.add(initial);
      await Future<void>.delayed(Duration.zero);
      provider.applyAchievementStatistics(
        'a',
        const UserStatisticsModel(runesOpened: 2),
      );
      repository.snapshots.add(initial.copyWith(name: 'Late PATCH response'));
      await Future<void>.delayed(Duration.zero);
      expect(provider.currentUser!.statistics.runesOpened, 2);
      expect(provider.currentUser!.name, 'Late PATCH response');
      repository.snapshots.add(initial.copyWith(id: 'b'));
      await Future<void>.delayed(Duration.zero);
      expect(provider.currentUser!.statistics.runesOpened, 0);
      repository.snapshots.add(null);
      await Future<void>.delayed(Duration.zero);
      expect(provider.currentUser, isNull);
    },
  );

  group('UserProvider.updateCurrentLocation', () {
    test(
      'does not replace a manual location with an automatic update',
      () async {
        final repository = _FakeUserRepository();
        final provider = UserProvider(userRepository: repository);
        final manualLocation = const CurrentLocationModel(
          location: 'Алматы, Казахстан',
          latitude: 43.2389,
          longitude: 76.8897,
          source: CurrentLocationSource.manual,
        );
        provider.applyServerUserSnapshot(
          _user(
            id: 'user-1',
            balance: 10,
          ).copyWith(currentLocation: manualLocation),
        );

        await provider.updateCurrentLocation(
          const CurrentLocationModel(
            location: 'Текущая геолокация',
            latitude: 55.7558,
            longitude: 37.6173,
            source: CurrentLocationSource.auto,
          ),
        );

        expect(
          provider.currentUser?.currentLocation?.location,
          'Алматы, Казахстан',
        );
        expect(
          provider.currentUser?.currentLocation?.source,
          CurrentLocationSource.manual,
        );
        expect(repository.updatedUser, isNull);
      },
    );

    test(
      'replaces a manual location when automatic update is explicitly requested',
      () async {
        final repository = _FakeUserRepository();
        final provider = UserProvider(userRepository: repository);
        final manualLocation = const CurrentLocationModel(
          location: 'Алматы, Казахстан',
          latitude: 43.2389,
          longitude: 76.8897,
          source: CurrentLocationSource.manual,
        );
        provider.applyServerUserSnapshot(
          _user(
            id: 'user-1',
            balance: 10,
          ).copyWith(currentLocation: manualLocation),
        );

        await provider.updateCurrentLocation(
          const CurrentLocationModel(
            location: 'Текущая геолокация',
            latitude: 42.3417,
            longitude: 69.5901,
            source: CurrentLocationSource.auto,
          ),
          preserveManualLocation: false,
        );

        expect(
          provider.currentUser?.currentLocation?.location,
          'Текущая геолокация',
        );
        expect(
          provider.currentUser?.currentLocation?.source,
          CurrentLocationSource.auto,
        );
        expect(
          repository.updatedUser?.currentLocation?.source,
          CurrentLocationSource.auto,
        );
      },
    );
  });

  group('UserProvider.buyDeck', () {
    test(
      'applies server Tarot result without saving deck through profile',
      () async {
        final repository = _FakeUserRepository();
        final featureApi = _FakeFeatureExecutionApi(
          result: TarotSpreadResultModel(
            executionId: 'execution-love',
            spreadType: 'love',
            cardIds: List.generate(6, (index) => 'card-$index'),
          ),
        );
        final provider = UserProvider(
          userRepository: repository,
          featureExecutionApi: featureApi,
          pendingFeatureExecutionStore: _FakePendingFeatureExecutionStore(),
          catalogRevisionLoader: () async => 3,
        );
        provider.applyServerUserSnapshot(_user(id: 'user-1', balance: 100));

        await provider.buyDeck(DeckType.love);

        expect(featureApi.spreadType, 'love');
        expect(featureApi.expectedCatalogRevision, 3);
        expect(featureApi.idempotencyKey, isNotEmpty);
        expect(repository.updatedUser, isNull);
        expect(provider.currentUser?.loveDeck?.executionId, 'execution-love');
        expect(provider.currentUser?.loveDeck?.loveDeckCards.keys, [
          'card-0',
          'card-1',
          'card-2',
          'card-3',
          'card-4',
          'card-5',
        ]);
        expect(provider.currentUser?.loveDeck?.loveDeckCards.values.toSet(), {
          false,
        });
      },
    );

    test(
      'reuses pending Tarot command when execution result is not applied',
      () async {
        final repository = _FakeUserRepository();
        final featureApi = _FakeFeatureExecutionApi(
          result: TarotSpreadResultModel(
            executionId: 'execution-love',
            spreadType: 'love',
            cardIds: List.generate(6, (index) => 'card-$index'),
          ),
        );
        final pendingStore = _FakePendingFeatureExecutionStore();
        final provider = UserProvider(
          userRepository: repository,
          featureExecutionApi: featureApi,
          pendingFeatureExecutionStore: pendingStore,
          catalogRevisionLoader: () async => 3,
        );
        provider.applyServerUserSnapshot(_user(id: 'user-1', balance: 100));

        featureApi.throwOnCreate = true;
        await expectLater(
          provider.buyDeck(DeckType.love),
          throwsA(isA<Exception>()),
        );
        final firstKey = featureApi.idempotencyKeys.single;
        expect(pendingStore.hasPending, isTrue);
        expect(provider.currentUser?.loveDeck, isNull);

        featureApi.throwOnCreate = false;
        await provider.buyDeck(DeckType.love);

        expect(featureApi.idempotencyKeys, [firstKey, firstKey]);
        expect(pendingStore.hasPending, isFalse);
        expect(provider.currentUser?.loveDeck?.executionId, 'execution-love');
        expect(repository.updatedUser, isNull);
      },
    );
  });

  group('UserProvider.loadLatestDeck', () {
    test('hydrates existing celtic result without profile update', () async {
      final repository = _FakeUserRepository();
      final featureApi = _FakeFeatureExecutionApi(
        result: TarotSpreadResultModel(
          executionId: 'new-celtic',
          spreadType: 'celtic',
          cardIds: List.generate(10, (index) => 'celtic-$index'),
        ),
        latestResult: TarotSpreadResultModel(
          executionId: 'existing-celtic',
          spreadType: 'celtic',
          cardIds: List.generate(10, (index) => 'existing-$index'),
        ),
      );
      final provider = UserProvider(
        userRepository: repository,
        featureExecutionApi: featureApi,
        pendingFeatureExecutionStore: _FakePendingFeatureExecutionStore(),
        catalogRevisionLoader: () async => 3,
      );
      provider.applyServerUserSnapshot(_user(id: 'user-1', balance: 100));

      final loaded = await provider.loadLatestDeck(DeckType.kelt);

      expect(loaded, isTrue);
      expect(featureApi.latestSpreadType, 'celtic');
      expect(provider.currentUser?.keltDeck?.executionId, 'existing-celtic');
      expect(provider.currentUser?.keltDeck?.keltDeckCards.keys, [
        'existing-0',
        'existing-1',
        'existing-2',
        'existing-3',
        'existing-4',
        'existing-5',
        'existing-6',
        'existing-7',
        'existing-8',
        'existing-9',
      ]);
      expect(repository.updatedUser, isNull);
    });
  });
}

UserModel _user({required String id, required int balance}) {
  return UserModel.empty().copyWith(
    id: id,
    phoneNumber: '+10000000000',
    balance: balance,
  );
}

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository({this.throwOnUpdate = false});

  bool throwOnUpdate;
  Completer<void>? updateCompleter;
  UserModel? _currentUser;
  UserModel? updatedUser;

  @override
  Future<void> updateCurrentUser(UserModel user) async {
    if (throwOnUpdate) {
      throw Exception('update failed');
    }
    await updateCompleter?.future;
    updatedUser = user;
    _currentUser = user;
  }

  @override
  Stream<UserModel?> getMe() => Stream<UserModel?>.value(_currentUser);

  @override
  Future<UserModel?> getCurrentUser() async => _currentUser;

  @override
  Future<void> setCurrentUser(UserModel user) async {
    _currentUser = user;
  }

  @override
  Future<void> clearCurrentUser() async {
    _currentUser = null;
  }

  @override
  Future<UserModel?> getUserById(String userId) async => _currentUser;

  @override
  Future<void> deleteUser(String userId) async {}

  @override
  Future<void> updateUserShopItems(
    String userId,
    List<ShopItemModel> shopItems,
  ) async {}

  @override
  Future<void> addCompatibilityToHistory(
    SavedCompatibilityModel compatibility,
  ) async {}
}

class _FakeFeatureExecutionApi extends FeatureExecutionApi {
  _FakeFeatureExecutionApi({required this.result, this.latestResult})
    : super.forDio(Dio(), _FakeSession());

  final TarotSpreadResultModel result;
  final TarotSpreadResultModel? latestResult;
  bool throwOnCreate = false;
  String? spreadType;
  String? latestSpreadType;
  int? expectedCatalogRevision;
  String? idempotencyKey;
  final List<String> idempotencyKeys = [];

  @override
  Future<TarotSpreadResultModel> createTarotSpread({
    required String spreadType,
    required int expectedCatalogRevision,
    required String idempotencyKey,
    bool requirePro = false,
  }) async {
    this.spreadType = spreadType;
    this.expectedCatalogRevision = expectedCatalogRevision;
    this.idempotencyKey = idempotencyKey;
    idempotencyKeys.add(idempotencyKey);
    if (throwOnCreate) {
      throw Exception('create failed');
    }
    return result;
  }

  @override
  Future<TarotSpreadResultModel?> getLatestTarotSpread({
    required String spreadType,
  }) async {
    latestSpreadType = spreadType;
    return latestResult;
  }
}

class _FakePendingFeatureExecutionStore extends PendingFeatureExecutionStore {
  PendingFeatureExecution? pending;

  bool get hasPending => pending != null;

  @override
  Future<PendingFeatureExecution> findOrCreate({
    required String userId,
    required String featureKey,
    required String payloadKey,
    String? idempotencyKey,
    Map<String, dynamic>? result,
  }) async {
    pending ??= PendingFeatureExecution(
      operationId: '$userId:$featureKey:$payloadKey',
      userId: userId,
      featureKey: featureKey,
      payloadKey: payloadKey,
      idempotencyKey: idempotencyKey ?? 'pending-key',
      createdAt: DateTime.parse('2026-08-30T12:00:00Z'),
    );
    return pending!;
  }

  @override
  Future<void> delete({
    required String userId,
    required String featureKey,
    required String payloadKey,
  }) async {
    pending = null;
  }
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

class _StreamUserRepository extends _FakeUserRepository {
  final snapshots = StreamController<UserModel?>.broadcast();
  @override
  Stream<UserModel?> getMe() => snapshots.stream;
}

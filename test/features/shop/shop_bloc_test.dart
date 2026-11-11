import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';
import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/features/monetization/data/monetization_api.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/shop/domain/shop_repository.dart';
import 'package:asteria_app/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'loads fresh request-pack quantities and omits horoscope offers',
    () async {
      final userProvider = UserProvider(
        userRepository: _FakeUserRepository(),
        authSessionService: _FakeSession(),
      )..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
      final api = _FakeMonetizationApi(
        _stateWithQuota(feature: 'sonnik', paidRemaining: 4),
      );
      final bloc = ShopBloc(
        shopRepository: _FakeShopRepository(),
        monetizationProvider: MonetizationProvider(
          api: api,
          userProvider: userProvider,
        ),
      );

      final states = <ShopState>[];
      final subscription = bloc.stream.listen(states.add);
      bloc.add(const ShopLoadProducts());
      await Future<void>.delayed(Duration.zero);

      expect(api.getCurrentCalls, 1);
      expect(
        states.whereType<ShopLoaded>().single.products.single.purchasedQuantity,
        4,
      );
      await subscription.cancel();
      await bloc.close();
    },
  );
}

MonetizationStateModel _stateWithQuota({
  required String feature,
  required int paidRemaining,
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
        freeRemaining: 0,
        paidRemaining: paidRemaining,
        freeLimit: 3,
        periodStartedAt: now,
        periodEndsAt: now.add(const Duration(days: 7)),
        updatedAt: now,
      ),
    },
    rolloutPolicy: const {},
  );
}

class _FakeMonetizationApi extends MonetizationApi {
  _FakeMonetizationApi(this.state) : super.forDio(Dio(), _FakeSession());

  final MonetizationStateModel state;
  int getCurrentCalls = 0;

  @override
  Future<MonetizationStateModel> getCurrent() async {
    getCurrentCalls += 1;
    return state;
  }
}

class _FakeShopRepository implements ShopRepository {
  @override
  Future<List<ShopItemModel>> getShopItems() async => const [
    ShopItemModel(
      id: 'archived',
      title: 'Персональный прогноз на год',
      category: 'Покупки',
      description: '',
      price: 30,
    ),
    ShopItemModel(
      id: 'older',
      title: 'Разбор',
      category: 'Покупки',
      description: '',
      price: 10,
      purchase: ShopItemPurchaseModel(
        type: 'feature_credit',
        featureKey: 'weekly_horoscope',
        creditQuantity: 1,
      ),
    ),
    ShopItemModel(
      id: 'shop-sonnik',
      title: 'Сонник',
      category: 'Запросы',
      description: 'Пакет запросов',
      price: 7,
      purchase: ShopItemPurchaseModel(
        type: 'feature_credit',
        featureKey: 'sonnik',
        creditQuantity: 1,
      ),
    ),
  ];
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

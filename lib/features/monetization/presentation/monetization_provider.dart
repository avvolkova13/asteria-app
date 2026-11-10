import 'dart:async';

import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/payments/api/store_payments_api.dart';
import 'package:asteria_app/features/balance/domain/reward_models.dart';
import 'package:asteria_app/features/monetization/data/monetization_api.dart';
import 'package:asteria_app/features/monetization/data/pending_feature_execution_store.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:flutter/widgets.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class MonetizationProvider extends ChangeNotifier {
  final MonetizationApi _api;
  final UserProvider _userProvider;
  final PendingFeatureExecutionStore? _pendingStore;

  MonetizationProvider({
    required MonetizationApi api,
    required UserProvider userProvider,
    PendingFeatureExecutionStore? pendingStore,
  }) : _api = api,
       _userProvider = userProvider,
       _pendingStore = pendingStore;

  MonetizationStateModel? _state;
  bool _isLoading = false;
  String? _activeUserId;
  bool _isStarted = false;
  int _refreshGeneration = 0;

  MonetizationStateModel? get state => _state;
  bool get isLoading => _isLoading;
  int get balance => _state?.balance ?? 0;
  bool get effectivePro => _state?.effectivePro ?? false;
  List<RewardStatusModel> get rewards =>
      _state?.rewards ?? defaultRewardStatuses;
  Map<String, RequestQuotaModel> get requestQuotas =>
      _state?.requestQuotas ?? const {};

  static MonetizationProvider? maybeOf(
    BuildContext context, {
    bool listen = true,
  }) {
    try {
      return Provider.of<MonetizationProvider>(context, listen: listen);
    } on ProviderNotFoundException {
      return null;
    }
  }

  bool canSpend(int price) => balance >= price;
  int balanceAfterSpend(int price) => (balance - price).clamp(0, balance);
  int neededBalanceFor(int price) => price > balance ? price - balance : 0;
  RequestQuotaModel requestQuota(String feature) =>
      _state?.requestQuota(feature) ?? RequestQuotaModel.empty(feature);
  int requestsLeft(String feature) => requestQuota(feature).totalRemaining;
  bool isFeatureEnabled(String feature) {
    final policy = _state?.rolloutPolicy;
    if (policy == null || policy.isEmpty) return true;
    if (policy['enabled'] == false || policy['kill_switch'] == true) {
      return false;
    }
    final supported = policy['supported_features'];
    if (supported is List && supported.isNotEmpty) {
      return supported.map((item) => item.toString()).contains(feature);
    }
    return true;
  }

  bool canMakeRequest(String feature) =>
      isFeatureEnabled(feature) && (effectivePro || requestsLeft(feature) > 0);
  int daysUntilReset(String feature) => requestQuota(feature).daysUntilReset;

  Future<bool> canMakeRequestFresh(String feature) async {
    await refreshForAccess();
    return canMakeRequest(feature);
  }

  Future<void> ensureLoaded() async {
    if (_state != null) return;
    await refresh();
  }

  Future<void> start() async {
    if (_isStarted) return;
    _isStarted = true;
    _userProvider.addListener(_handleUserChanged);
    _handleUserChanged();
  }

  void _handleUserChanged() {
    final userId = _userProvider.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      _refreshGeneration += 1;
      if (_activeUserId != null || _state != null) {
        _activeUserId = null;
        _state = null;
        notifyListeners();
      }
      return;
    }
    if (_activeUserId == userId && _state != null) return;
    _refreshGeneration += 1;
    _activeUserId = userId;
    unawaited(refresh());
  }

  /// Access checks must not treat an unavailable or stale snapshot as zero balance.
  Future<void> refreshForAccess() async {
    final uid = _userProvider.currentUser?.id;
    await refresh(requireFresh: true);
    if (uid == null ||
        uid != _userProvider.currentUser?.id ||
        _state?.uid != uid) {
      throw StateError('Monetization identity changed');
    }
  }

  bool isCurrentUser(String uid) =>
      _userProvider.currentUser?.id == uid && _state?.uid == uid;

  Future<void> refresh({bool requireFresh = false}) async {
    final userId = _userProvider.currentUser?.id;
    if (userId == null || userId.isEmpty) return;
    final generation = ++_refreshGeneration;
    _isLoading = true;
    notifyListeners();
    try {
      final nextState = await _api.getCurrent();
      final currentUserId = _userProvider.currentUser?.id;
      if (generation != _refreshGeneration ||
          currentUserId != userId ||
          nextState.uid != userId) {
        if (requireFresh) throw StateError('Stale monetization response');
        return;
      }
      _state = nextState;
    } catch (error) {
      debugPrint('[MonetizationProvider] refresh failed: $error');
      if (requireFresh) rethrow;
    } finally {
      if (generation == _refreshGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void applyRewardResponse(RewardsResponseModel response) {
    final current = _state;
    if (current == null) return;
    final userId = _userProvider.currentUser?.id;
    if (response.uid != null && response.uid != userId) return;
    _state = current.copyWith(
      wallet: current.wallet.copyWith(balance: response.balance),
      rewards: response.items,
    );
    notifyListeners();
  }

  Future<void> purchaseRequestPack({
    required String feature,
    required int quantity,
    String? idempotencyKey,
  }) async {
    final userId = _userProvider.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('User session is required');
    }
    if (!isFeatureEnabled(feature)) {
      throw Exception('Функция временно недоступна');
    }
    final pending = await _pendingCommand(
      userId: userId,
      featureKey: 'request_pack_purchase',
      payloadKey: '$feature:$quantity',
      idempotencyKey: idempotencyKey,
    );
    final result = await _api.purchaseRequestPack(
      feature: feature,
      quantity: quantity,
      idempotencyKey:
          pending?.idempotencyKey ?? idempotencyKey ?? const Uuid().v4(),
    );
    if (_userProvider.currentUser?.id != userId ||
        result.wallet.uid != userId) {
      throw StateError('Purchase identity changed');
    }
    final current = _state;
    if (current == null) {
      await _deletePendingCommand(pending);
      await refresh();
      return;
    }
    _state = current.copyWith(
      wallet: result.wallet,
      requestQuotas: {...current.requestQuotas, result.feature: result.quota},
    );
    await _deletePendingCommand(pending);
    notifyListeners();
  }

  Future<void> purchaseShopRequestPack({
    required String productId,
    required int quantity,
    required int expectedPrice,
    String? feature,
    String? idempotencyKey,
  }) async {
    final userId = _userProvider.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('User session is required');
    }
    if (feature != null && !isFeatureEnabled(feature)) {
      throw Exception('Функция временно недоступна');
    }
    final pending = await _pendingCommand(
      userId: userId,
      featureKey: 'shop_request_pack_purchase',
      payloadKey: '$productId:$quantity',
      idempotencyKey: idempotencyKey,
    );
    final result = await _api.purchaseShopRequestPack(
      productId: productId,
      quantity: quantity,
      expectedPrice: expectedPrice,
      idempotencyKey:
          pending?.idempotencyKey ?? idempotencyKey ?? const Uuid().v4(),
    );
    if (_userProvider.currentUser?.id != userId ||
        result.wallet.uid != userId) {
      throw StateError('Purchase identity changed');
    }
    final current = _state;
    if (current == null) {
      await _deletePendingCommand(pending);
      await refresh();
      return;
    }
    _state = current.copyWith(
      wallet: result.wallet,
      requestQuotas: {...current.requestQuotas, result.feature: result.quota},
    );
    await _deletePendingCommand(pending);
    notifyListeners();
  }

  Future<void> consumeRequest(String feature, {String? idempotencyKey}) async {
    final userId = _userProvider.currentUser?.id;
    if (userId == null || userId.isEmpty) return;
    if (!isFeatureEnabled(feature)) {
      throw Exception('Функция временно недоступна');
    }
    final result = await _api.consumeRequest(
      feature: feature,
      idempotencyKey: idempotencyKey ?? const Uuid().v4(),
    );
    if (_userProvider.currentUser?.id != userId) return;
    _applyRequestQuota(result.quota);
  }

  Future<RequestQuotaCommandResultModel> executeRequestQuotaCommand(
    String feature, {
    required Map<String, dynamic> payload,
    String? idempotencyKey,
  }) async {
    final userId = _userProvider.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw Exception('Пользователь не авторизован');
    }
    if (!isFeatureEnabled(feature)) {
      throw Exception('Функция временно недоступна');
    }
    final result = await _api.executeRequestQuotaCommand(
      feature: feature,
      payload: payload,
      idempotencyKey: idempotencyKey ?? const Uuid().v4(),
    );
    if (_userProvider.currentUser?.id != userId || result.uid != userId) {
      throw Exception('Пользователь изменился во время выполнения запроса');
    }
    _applyRequestQuota(result.quota);
    _userProvider.applyServerUserSnapshot(result.user);
    return result;
  }

  /// Apple callers carry their login generation through every await. Check it
  /// at the assignment itself; never apply the receipt response's wallet first.
  Future<void> refreshAppleEntitlements(
    String uid, {
    required bool Function() isCurrent,
  }) async {
    if (!isCurrent() || _userProvider.currentUser?.id != uid) return;
    final generation = ++_refreshGeneration;
    try {
      final next = await _api.getCurrent();
      if (!isCurrent() ||
          generation != _refreshGeneration ||
          _userProvider.currentUser?.id != uid ||
          next.uid != uid) {
        return;
      }
      _state = next;
      notifyListeners();
    } finally {
      if (generation == _refreshGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshAfterVerify(StoreVerifyResponse response) async {
    final current = _state;
    if (current != null) {
      _state = current.copyWith(
        wallet: current.wallet.copyWith(balance: response.balance),
      );
      notifyListeners();
    }
    await refresh();
  }

  void applyLocalSpend(int price) {
    final current = _state;
    if (current == null || price <= 0) return;
    _state = current.copyWith(
      wallet: current.wallet.copyWith(
        balance: (current.balance - price).clamp(0, current.balance),
      ),
    );
    notifyListeners();
  }

  void _applyRequestQuota(RequestQuotaModel quota) {
    final current = _state;
    if (current == null) {
      unawaited(refresh());
      return;
    }
    _state = current.copyWith(
      requestQuotas: {...current.requestQuotas, quota.feature: quota},
    );
    notifyListeners();
  }

  Future<PendingFeatureExecution?> _pendingCommand({
    required String userId,
    required String featureKey,
    required String payloadKey,
    String? idempotencyKey,
  }) async {
    final store =
        _pendingStore ??
        (di.isRegistered<PendingFeatureExecutionStore>()
            ? di.get<PendingFeatureExecutionStore>()
            : null);
    return store?.findOrCreate(
      userId: userId,
      featureKey: featureKey,
      payloadKey: payloadKey,
      idempotencyKey: idempotencyKey,
    );
  }

  Future<void> _deletePendingCommand(PendingFeatureExecution? pending) async {
    if (pending == null) return;
    final store =
        _pendingStore ??
        (di.isRegistered<PendingFeatureExecutionStore>()
            ? di.get<PendingFeatureExecutionStore>()
            : null);
    await store?.delete(
      userId: pending.userId,
      featureKey: pending.featureKey,
      payloadKey: pending.payloadKey,
    );
  }
}

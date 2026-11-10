import 'dart:async';
import 'package:asteria_app/app/data/models/horoscope/horoscope_day_model.dart';
import 'package:asteria_app/app/data/models/kelt_deck/kelt_deck_model.dart';
import 'package:asteria_app/app/data/models/love_deck/love_deck_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/utils/enums.dart';
import 'package:asteria_app/features/balance/presentation/provider/rewards_provider.dart';
import 'package:asteria_app/features/monetization/data/feature_execution_api.dart';
import 'package:asteria_app/features/monetization/data/pending_feature_execution_store.dart';
import 'package:asteria_app/features/monetization/domain/feature_execution_models.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Провайдер для управления состоянием пользователя
/// Использует ChangeNotifier для реактивных обновлений UI
class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthSessionService? _authSessionService;
  final FeatureExecutionApi? _featureExecutionApi;
  final PendingFeatureExecutionStore? _pendingFeatureExecutionStore;
  final Future<int> Function()? _catalogRevisionLoader;
  StreamSubscription<UserModel?>? _userSubscription;

  final Map<String, UserStatisticsModel> _knownAchievementStatistics = {};
  UserModel? _currentUser;
  UserModel? _lastAuthoritativeUser;
  bool _isLoading = false;
  String? _error;
  int _profileGeneration = 0;
  final Map<DeckType, Set<String>> _openedDeckCards = {
    DeckType.kelt: <String>{},
    DeckType.love: <String>{},
  };

  // ID товаров в магазине
  static const String shopItemSonnikId = 'VY7UBP2lTsNLj96hMqWi';
  static const String shopItemAnakraId = 'Xx565eJSWdSmCoUiY9wE';
  static const String shopItemCompatibilityId = 'rmqNcJvZPBxT3t81rwge';

  UserProvider({
    UserRepository? userRepository,
    AuthSessionService? authSessionService,
    FeatureExecutionApi? featureExecutionApi,
    PendingFeatureExecutionStore? pendingFeatureExecutionStore,
    Future<int> Function()? catalogRevisionLoader,
  }) : _userRepository = userRepository ?? di.get<UserRepository>(),
       _authSessionService = authSessionService,
       _featureExecutionApi = featureExecutionApi,
       _pendingFeatureExecutionStore = pendingFeatureExecutionStore,
       _catalogRevisionLoader = catalogRevisionLoader;

  /// Текущий пользователь
  UserModel? get currentUser => _currentUser;

  /// Флаг загрузки
  bool get isLoading => _isLoading;

  /// Ошибка
  String? get error => _error;

  /// Проверяет, авторизован ли пользователь
  bool get isAuthenticated => _currentUser != null;

  /// Инициализация провайдера
  /// Подписывается на изменения пользователя
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Подписываемся на поток изменений пользователя
      _userSubscription = _userRepository.getMe().listen(
        (user) {
          _profileGeneration += 1;
          _currentUser = _withAchievementStatistics(user);
          _lastAuthoritativeUser = _currentUser;
          _isLoading = false;
          _error = null;
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Обновление текущего пользователя
  Future<void> updateUser(UserModel user) async {
    final previousUser = _currentUser;
    final targetUserId = user.id;
    final generation = _profileGeneration;
    try {
      _isLoading = true;
      _error = null;
      _currentUser = _withAchievementStatistics(user);
      _safeNotifyListeners();

      await _userRepository.updateCurrentUser(user);
      if (_profileGeneration != generation ||
          _currentUser?.id != targetUserId) {
        _currentUser = _withAchievementStatistics(
          _lastAuthoritativeUser ?? _currentUser,
        );
        _isLoading = false;
        _safeNotifyListeners();
        return;
      }
      // Обновление произойдет автоматически через stream
    } catch (e) {
      if (_profileGeneration == generation &&
          _currentUser?.id == targetUserId) {
        _currentUser = _withAchievementStatistics(previousUser);
      }
      _error = e.toString();
      _isLoading = false;
      _safeNotifyListeners();
      rethrow;
    }
  }

  Future<void> updateCurrentLocation(
    CurrentLocationModel location, {
    bool preserveManualLocation = true,
  }) async {
    final currentUser = _currentUser;
    if (currentUser == null) {
      throw Exception('Пользователь не авторизован');
    }

    final existingLocation = currentUser.currentLocation;
    if (preserveManualLocation &&
        existingLocation?.source == CurrentLocationSource.manual &&
        location.source == CurrentLocationSource.auto) {
      return;
    }

    await updateUser(
      currentUser.copyWith(
        currentLocation: location.copyWith(updatedAt: DateTime.now()),
        clearMoonPhase: true,
      ),
    );
  }

  Future<void> clearCurrentLocation() async {
    final currentUser = _currentUser;
    if (currentUser == null) {
      throw Exception('Пользователь не авторизован');
    }

    await updateUser(
      currentUser.copyWith(clearCurrentLocation: true, clearMoonPhase: true),
    );
  }

  /// Applies authoritative server state locally without writing it back through
  /// profile PATCH. Paid fulfillment is already persisted by the backend.
  void applyServerUserSnapshot(UserModel user) {
    _profileGeneration += 1;
    _isLoading = false;
    _error = null;
    _currentUser = _withAchievementStatistics(user);
    _lastAuthoritativeUser = _currentUser;
    _safeNotifyListeners();
  }

  /// Applies only acknowledged counters, without confirming an in-flight profile edit.
  void applyAchievementStatistics(
    String userId,
    UserStatisticsModel statistics,
  ) {
    final user = _currentUser;
    if (user == null || user.id != userId) return;
    _currentUser = _withAchievementStatistics(
      user.copyWith(statistics: statistics),
    );
    _safeNotifyListeners();
  }

  UserModel? _withAchievementStatistics(UserModel? user) {
    if (user == null) return null;
    final previous = _knownAchievementStatistics[user.id];
    final incoming = user.statistics;
    if (previous == null ||
        (incoming.tarotCardsOpened >= previous.tarotCardsOpened &&
            incoming.horoscopeOpened >= previous.horoscopeOpened &&
            incoming.runesOpened >= previous.runesOpened)) {
      _knownAchievementStatistics[user.id] = incoming;
      return user;
    }
    int highest(int a, int b) => a > b ? a : b;
    final merged = UserStatisticsModel(
      tarotCardsOpened: highest(
        incoming.tarotCardsOpened,
        previous.tarotCardsOpened,
      ),
      horoscopeOpened: highest(
        incoming.horoscopeOpened,
        previous.horoscopeOpened,
      ),
      runesOpened: highest(incoming.runesOpened, previous.runesOpened),
    );
    _knownAchievementStatistics[user.id] = merged;
    return user.copyWith(statistics: merged);
  }

  /// Reloads the authoritative user document after server-side fulfillment.
  /// This never writes the local snapshot back to backend.
  Future<UserModel?> refreshCurrentUser() async {
    final userId = _currentUser?.id;
    if (userId == null || userId.isEmpty) return null;
    try {
      final refreshed = await _userRepository.getUserById(userId);
      if (refreshed == null || _currentUser?.id != userId) return null;
      await _userRepository.setCurrentUser(refreshed);
      if (_currentUser?.id != userId) return null;
      _currentUser = _withAchievementStatistics(refreshed);
      _error = null;
      _safeNotifyListeners();
      return refreshed;
    } catch (e) {
      _error = e.toString();
      _safeNotifyListeners();
      return null;
    }
  }

  /// Установка текущего пользователя
  Future<void> setUser(UserModel user) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userRepository.setCurrentUser(user);
      // Обновление произойдет автоматически через stream
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Очистка текущего пользователя (выход)
  Future<void> clearUser() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userRepository.clearCurrentUser();
      await _authSessionService?.signOut();
      // Обновление произойдет автоматически через stream
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Получение пользователя по ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _userRepository.getUserById(userId);
      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void _updateBalance({
    required int amount,
    required BalanceHistoryType type,
    required String description,
  }) {
    if (_currentUser == null) return;

    final newBalance = type == BalanceHistoryType.deposit
        ? _currentUser!.balance + amount
        : _currentUser!.balance - amount;

    final historyEntry = BalanceHistoryModel(
      date: DateTime.now(),
      type: type,
      amount: amount,
      description: description,
    );

    final updatedHistory = [..._currentUser!.balanceHistory, historyEntry];

    _currentUser = _currentUser!.copyWith(
      balance: newBalance,
      balanceHistory: updatedHistory,
    );
  }

  void makePurchase(int price, {String description = 'Покупка'}) {
    final balanceBefore = _currentUser?.balance;
    _updateBalance(
      amount: price,
      type: BalanceHistoryType.withdraw,
      description: description,
    );
    _userRepository.updateCurrentUser(_currentUser!);
    di.get<ProductAnalyticsService>().trackCoinSpendSuccess(
      originSurface: 'user_provider',
      offerType: OfferType.oneOffUnlock,
      coinAmount: price,
      balanceBefore: balanceBefore,
      balanceAfter: _currentUser?.balance,
    );
    notifyListeners();
  }

  /// Пополняет баланс пользователя
  ///
  /// [amount] - количество монет для пополнения
  /// [description] - описание операции
  Future<void> addBalance(
    int amount, {
    String description = 'Пополнение баланса',
  }) async {
    if (_currentUser == null) return;

    _updateBalance(
      amount: amount,
      type: BalanceHistoryType.deposit,
      description: description,
    );
    await updateUser(_currentUser!);
  }

  Future<void> onOpenDayHoroscope(DayHoroscopeOpenEnum type) async {
    if (_currentUser?.horoscopeDay == null) return;
    final userId = _currentUser!.id;

    final (updatedHoroscopeDay, description) = switch (type) {
      DayHoroscopeOpenEnum.keyTheme => (
        _currentUser!.horoscopeDay!.copyWith(isKeyThemeOpened: true),
        'Открытие ключевой темы дня',
      ),
      DayHoroscopeOpenEnum.weaknesses => (
        _currentUser!.horoscopeDay!.copyWith(isWeaknessOpened: true),
        'Открытие слабостей дня',
      ),
    };
    final featureKey = switch (type) {
      DayHoroscopeOpenEnum.keyTheme => 'day_horoscope_key_theme',
      DayHoroscopeOpenEnum.weaknesses => 'day_horoscope_weaknesses',
    };

    final pending = await _pendingFeatureExecution(
      userId: userId,
      featureKey: featureKey,
      payloadKey: type.name,
      result: updatedHoroscopeDay.toJson(),
    );
    final committed =
        await (_featureExecutionApi ?? di.get<FeatureExecutionApi>())
            .createClientResultFeature(
              featureKey: featureKey,
              result: pending.result ?? updatedHoroscopeDay.toJson(),
              expectedCatalogRevision: await _loadCatalogRevision(),
              idempotencyKey: pending.idempotencyKey,
            );
    final committedHoroscopeDay = HoroscopeDayModel.fromJson(committed.result);
    if (_currentUser?.id != userId) {
      throw Exception('Пользователь изменился во время открытия гороскопа');
    }
    applyServerUserSnapshot(
      _currentUser!.copyWith(horoscopeDay: committedHoroscopeDay),
    );
    await _deletePendingFeatureExecution(
      userId: userId,
      featureKey: featureKey,
      payloadKey: type.name,
    );
  }

  int getNewBalance(int price) {
    return _currentUser?.balance != null ? _currentUser!.balance - price : 0;
  }

  int getNeededBalance(int price) {
    return _currentUser?.balance != null ? price + _currentUser!.balance : 0;
  }

  bool isContentViewed(String contentId) {
    return _currentUser?.viewedContentIds.contains(contentId) ?? false;
  }

  /// Добавляет ID контента в список просмотренного
  Future<void> addViewedContent(String contentId) async {
    if (_currentUser == null) {
      return;
    }

    // Проверяем, не был ли уже просмотрен этот контент
    if (isContentViewed(contentId)) {
      return;
    }

    try {
      final updatedViewedContentIds = [
        ..._currentUser!.viewedContentIds,
        contentId,
      ];
      final updatedUser = _currentUser!.copyWith(
        viewedContentIds: updatedViewedContentIds,
      );
      debugPrint('[DEBUG] Добавили айди контента: $contentId');
      await updateUser(updatedUser);
    } catch (e) {
      debugPrint('[ERROR] Ошибка добавления просмотренного контента: $e');
    }
  }

  /// Очистка ошибки
  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> buyDeck(
    DeckType deckType, {
    String? idempotencyKey,
    bool requirePro = false,
  }) async {
    if (_currentUser == null) {
      throw Exception('Пользователь не найден');
    }
    final userId = _currentUser!.id;

    try {
      final spreadType = deckType == DeckType.love ? 'love' : 'celtic';
      final pending = await _pendingFeatureExecution(
        userId: userId,
        featureKey: 'tarot_spread',
        payloadKey: spreadType,
        idempotencyKey: idempotencyKey,
      );
      final result =
          await (_featureExecutionApi ?? di.get<FeatureExecutionApi>())
              .createTarotSpread(
                spreadType: spreadType,
                requirePro: requirePro,
                expectedCatalogRevision: await _loadCatalogRevision(),
                idempotencyKey: pending.idempotencyKey,
              );
      if (_currentUser?.id != userId) {
        throw Exception('Пользователь изменился во время покупки расклада');
      }
      if (result.cardIds.length != deckType.cardCount) {
        throw Exception('Backend returned invalid Tarot spread');
      }
      _openedDeckCards[deckType]!.clear();
      _applyTarotSpreadResult(deckType, result);
      await _deletePendingFeatureExecution(
        userId: userId,
        featureKey: 'tarot_spread',
        payloadKey: spreadType,
      );
      debugPrint(
        '[DEBUG] Сгенерирован расклад ${result.executionId} для ${deckType.key}',
      );
    } catch (e) {
      debugPrint('[ERROR] Ошибка покупки расклада ${deckType.key}: $e');
      throw Exception('Ошибка покупки расклада: $e');
    }
  }

  Future<bool> loadLatestDeck(DeckType deckType) async {
    if (_currentUser == null) {
      throw Exception('Пользователь не найден');
    }
    final userId = _currentUser!.id;
    final spreadType = deckType == DeckType.love ? 'love' : 'celtic';
    try {
      final result =
          await (_featureExecutionApi ?? di.get<FeatureExecutionApi>())
              .getLatestTarotSpread(spreadType: spreadType);
      if (result == null) return false;
      if (_currentUser?.id != userId) {
        throw Exception('Пользователь изменился во время загрузки расклада');
      }
      if (result.cardIds.length != deckType.cardCount) {
        throw Exception('Backend returned invalid Tarot spread');
      }
      _applyTarotSpreadResult(deckType, result);
      return true;
    } catch (e) {
      debugPrint('[ERROR] Ошибка загрузки расклада ${deckType.key}: $e');
      return false;
    }
  }

  void _applyTarotSpreadResult(
    DeckType deckType,
    TarotSpreadResultModel result,
  ) {
    final currentUser = _currentUser;
    if (currentUser == null) return;
    final newDeckCards = <String, bool>{};
    for (final cardId in result.cardIds) {
      newDeckCards[cardId] = false;
    }
    _currentUser = switch (deckType) {
      DeckType.kelt => currentUser.copyWith(
        keltDeck: KeltDeckModel(
          keltDeckCards: newDeckCards,
          executionId: result.executionId,
        ),
      ),
      DeckType.love => currentUser.copyWith(
        loveDeck: LoveDeckModel(
          loveDeckCards: newDeckCards,
          executionId: result.executionId,
        ),
      ),
    };
    _isLoading = false;
    _error = null;
    _safeNotifyListeners();
  }

  Future<PendingFeatureExecution> _pendingFeatureExecution({
    required String userId,
    required String featureKey,
    required String payloadKey,
    String? idempotencyKey,
    Map<String, dynamic>? result,
  }) {
    final store =
        _pendingFeatureExecutionStore ??
        (di.isRegistered<PendingFeatureExecutionStore>()
            ? di.get<PendingFeatureExecutionStore>()
            : PendingFeatureExecutionStore());
    return store.findOrCreate(
      userId: userId,
      featureKey: featureKey,
      payloadKey: payloadKey,
      idempotencyKey: idempotencyKey,
      result: result,
    );
  }

  Future<void> _deletePendingFeatureExecution({
    required String userId,
    required String featureKey,
    required String payloadKey,
  }) async {
    final store =
        _pendingFeatureExecutionStore ??
        (di.isRegistered<PendingFeatureExecutionStore>()
            ? di.get<PendingFeatureExecutionStore>()
            : null);
    await store?.delete(
      userId: userId,
      featureKey: featureKey,
      payloadKey: payloadKey,
    );
  }

  Future<void> buyKeltDeck({String? idempotencyKey, bool requirePro = false}) =>
      buyDeck(
        DeckType.kelt,
        idempotencyKey: idempotencyKey,
        requirePro: requirePro,
      );
  Future<void> buyLoveDeck({String? idempotencyKey, bool requirePro = false}) =>
      buyDeck(
        DeckType.love,
        idempotencyKey: idempotencyKey,
        requirePro: requirePro,
      );

  Future<void> openDeckCard(DeckType deckType, String cardId) async {
    if (_currentUser == null) {
      throw Exception('Пользователь не найден');
    }

    try {
      final currentCards = switch (deckType) {
        DeckType.kelt => _currentUser!.keltDeck?.keltDeckCards,
        DeckType.love => _currentUser!.loveDeck?.loveDeckCards,
      };

      if (currentCards == null) return;

      if (!currentCards.containsKey(cardId)) {
        throw Exception('Карта не найдена в раскладе');
      }
      final openedCards = _openedDeckCards[deckType]!;
      final wasCompleted = openedCards.length == currentCards.length;
      if (!openedCards.add(cardId)) return;

      final facade = di.get<AnalyticsFacade>();
      facade.trackEvent(
        deckType == DeckType.love
            ? AnalyticsEvents.loveDeckCardView
            : AnalyticsEvents.keltDeckCardView,
        params: {
          'feature_name': deckType == DeckType.love ? 'love_deck' : 'kelt_deck',
          'card_id': cardId,
        },
      );

      notifyListeners();
      if (!wasCompleted &&
          currentCards.isNotEmpty &&
          openedCards.length == currentCards.length) {
        final executionId = switch (deckType) {
          DeckType.kelt => _currentUser!.keltDeck?.executionId,
          DeckType.love => _currentUser!.loveDeck?.executionId,
        };
        if (executionId == null || executionId.isEmpty) return;
        unawaited(di.get<RewardsProvider>().recordTarotSpread(executionId));
      }
      debugPrint('[DEBUG] Карта $cardId открыта в ${deckType.key}');
    } catch (e) {
      debugPrint('[ERROR] Ошибка открытия карты: $e');
      throw Exception('Ошибка открытия карты: $e');
    }
  }

  Future<void> openKeltDeckCard(String cardId) =>
      openDeckCard(DeckType.kelt, cardId);
  Future<void> openLoveDeckCard(String cardId) =>
      openDeckCard(DeckType.love, cardId);

  bool isDeckCardOpened(DeckType deckType, String cardId) {
    return _openedDeckCards[deckType]!.contains(cardId);
  }

  void resetDeckOpenState(DeckType deckType) {
    _openedDeckCards[deckType]!.clear();
  }

  bool isAllCardsOpened(String deckKey) {
    final deckType = DeckType.values.firstWhere(
      (d) => d.key == deckKey,
      orElse: () => DeckType.kelt,
    );

    final cards = switch (deckType) {
      DeckType.kelt => _currentUser?.keltDeck?.keltDeckCards,
      DeckType.love => _currentUser?.loveDeck?.loveDeckCards,
    };

    if (cards == null || cards.isEmpty) return false;
    return _openedDeckCards[deckType]!.length == cards.length;
  }

  Future<int> _loadCatalogRevision() async {
    final injected = _catalogRevisionLoader;
    if (injected != null) {
      final revision = await injected();
      if (revision >= 1) return revision;
    } else {
      final monetization = di.get<MonetizationProvider>();
      await monetization.ensureLoaded();
      final revision = monetization.state?.catalogRevision ?? 0;
      if (revision >= 1) return revision;
    }
    throw Exception('Monetization catalog is not available');
  }

  bool showHoroscope(HoroscopeTypeEnum horoscopeType) {
    final dateNow = DateTime.now();
    switch (horoscopeType) {
      case HoroscopeTypeEnum.day:
        return _currentUser?.horoscopeDay != null &&
            _currentUser!.horoscopeDay!.dateUntil.isAfter(dateNow);
      case HoroscopeTypeEnum.week:
        return _currentUser?.horoscopeWeek != null &&
            _currentUser!.horoscopeWeek!.dateUntil.isAfter(dateNow);
      case HoroscopeTypeEnum.month:
        return _currentUser?.horoscopeMonth != null &&
            _currentUser!.horoscopeMonth!.dateUntil.isAfter(dateNow);
      case HoroscopeTypeEnum.year:
        return _currentUser?.horoscopeYear != null &&
            _currentUser!.horoscopeYear!.dateUntil.isAfter(dateNow);
    }
  }

  void _safeNotifyListeners() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}

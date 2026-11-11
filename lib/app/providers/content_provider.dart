import 'package:asteria_app/core/config/app_feature_visibility.dart';
import 'package:asteria_app/features/achievements/data/achievement_recorder.dart';
import 'package:asteria_app/features/achievements/domain/achievement_event.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/app/data/models/article/article_model.dart';
import 'package:asteria_app/app/data/models/energy_of_day/energy_of_day_model.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_month_model.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_week_model.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_year_model.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/personalized_lunar_month_model.dart';
import 'package:asteria_app/app/data/models/moon_phase/moon_phase_model.dart';
import 'package:asteria_app/app/data/models/natal_card/natal_card_model.dart';
import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';
import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/data/models/user/rune_deck_model.dart';
import 'package:asteria_app/app/data/models/user/rune_of_day_item_model.dart';
import 'package:asteria_app/app/data/models/user/tarot_card_of_day_item_model.dart';
import 'package:asteria_app/app/data/models/user/tarot_deck_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/content/content_repository.dart';
import 'package:asteria_app/app/data/repositories/lunar_calendar/personalized_lunar_calendar_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/features/compatibility/domain/repositories/compatibility_repository.dart';
import 'package:asteria_app/features/balance/presentation/provider/rewards_provider.dart';
import 'package:asteria_app/features/monetization/data/feature_execution_api.dart';
import 'package:asteria_app/features/monetization/data/pending_feature_execution_store.dart';
import 'package:asteria_app/features/monetization/domain/feature_execution_models.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/const/keys_const.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/extensions/datetime_extensions.dart';
import 'package:asteria_app/core/localization/app_locale_service.dart';
import 'package:asteria_app/core/location/current_location_resolver.dart';
import 'package:asteria_app/core/services/api/backend_api.dart';
import 'package:asteria_app/core/services/hive/hive_service.dart';
import 'package:asteria_app/core/utils/enums.dart';
import 'package:asteria_app/core/utils/horoscope_parsers/horoscope_parsers_index.dart';
import 'package:asteria_app/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';

class ContentProvider extends ChangeNotifier with WidgetsBindingObserver {
  final DateTime Function() _now;
  final bool _horoscopesEnabled;
  final AchievementRecorder? _achievementRecorder;
  final ContentRepository _contentRepository;
  final PersonalizedLunarCalendarRepository?
  _personalizedLunarCalendarRepository;
  final UserProvider _userProvider;
  final MonetizationProvider? _monetizationProvider;
  final FeatureExecutionApi? _featureExecutionApi;
  final PendingFeatureExecutionStore? _pendingFeatureExecutionStore;
  final BackendApi? _backendApi;
  final AppLocaleService _localeService;
  final CurrentLocationResolver _currentLocationResolver;

  ContentProvider({
    DateTime Function()? now,
    bool horoscopesEnabled = AppFeatureVisibility.horoscopes,
    AchievementRecorder? achievementRecorder,
    ContentRepository? contentRepository,
    PersonalizedLunarCalendarRepository? personalizedLunarCalendarRepository,
    UserProvider? userProvider,
    MonetizationProvider? monetizationProvider,
    FeatureExecutionApi? featureExecutionApi,
    PendingFeatureExecutionStore? pendingFeatureExecutionStore,
    CompatibilityRepository? compatibilityRepository,
    BackendApi? backendApi,
    AppLocaleService? localeService,
    CurrentLocationResolver? currentLocationResolver,
  }) : _now = now ?? DateTime.now,
       _horoscopesEnabled = horoscopesEnabled,
       _achievementRecorder = achievementRecorder,
       _contentRepository = contentRepository ?? di.get<ContentRepository>(),
       _personalizedLunarCalendarRepository =
           personalizedLunarCalendarRepository ??
           (di.isRegistered<PersonalizedLunarCalendarRepository>()
               ? di.get<PersonalizedLunarCalendarRepository>()
               : null),
       _userProvider = userProvider ?? di.get<UserProvider>(),
       _monetizationProvider =
           monetizationProvider ??
           (di.isRegistered<MonetizationProvider>()
               ? di.get<MonetizationProvider>()
               : null),
       _featureExecutionApi = featureExecutionApi,
       _pendingFeatureExecutionStore = pendingFeatureExecutionStore,
       _backendApi =
           backendApi ??
           (di.isRegistered<BackendApi>() ? di.get<BackendApi>() : null),
       _currentLocationResolver =
           currentLocationResolver ?? const CurrentLocationResolver(),
       _localeService =
           localeService ??
           (di.isRegistered<AppLocaleService>()
               ? di.get<AppLocaleService>()
               : AppLocaleService(
                   platformLocales: const <Locale>[Locale('ru')],
                 )) {
    _userProvider.addListener(_onUserChanged);
    _lastLocaleTag = _localeService.languageTag;
    _lastLocationFingerprint = _currentLocationFingerprintOrNull();
    WidgetsBinding.instance.addObserver(this);
    _localeService.addListener(_onLocaleChanged);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(loadContent());
    }
  }

  late String _lastLocaleTag;
  String? _lastLocationFingerprint;

  void _onLocaleChanged() {
    final nextLocaleTag = _localeService.languageTag;
    if (nextLocaleTag == _lastLocaleTag) return;
    _lastLocaleTag = nextLocaleTag;
    _tarotCards = [];
    _runes = [];
    _articles = [];
    _affirmations = [];
    _energyOfDay = [];
    _moonPhaseCache.clear();
    _clearPersonalizedLunarState();
    _cachedTodayRune = null;
    _cachedRuneDateKey = null;
    _cachedTodayTarotCard = null;
    _cachedTarotCardDateKey = null;
    notifyListeners();

    final activeLoad = _contentLoadFuture;
    unawaited(
      Future<void>(() async {
        if (activeLoad != null) await activeLoad;
        await loadContent();
      }),
    );
  }

  void _onUserChanged() {
    final userId = _userProvider.currentUser?.id;
    final nextLocationFingerprint = _currentLocationFingerprintOrNull();
    if (userId != _lastCachedUserId) {
      _lastCachedUserId = userId;
      _cachedTodayRune = null;
      _cachedRuneDateKey = null;
      _cachedTodayTarotCard = null;
      _cachedTarotCardDateKey = null;
      _clearTarotOpenState();
      _clearRuneOpenState();
    }
    if (nextLocationFingerprint != _lastLocationFingerprint) {
      _lastLocationFingerprint = nextLocationFingerprint;
      _clearPersonalizedLunarState();
    }
    notifyListeners();
  }

  List<TarotCardModel> _tarotCards = [];
  List<RuneOfDayModel> _runes = [];
  List<ArticleModel> _articles = [];
  List<AffirmationModel> _affirmations = [];
  List<EnergyOfDayModel> _energyOfDay = [];
  final Map<String, MoonPhaseModel> _moonPhaseCache = {};
  final Map<String, Future<PersonalizedLunarMonthModel>>
  _personalizedLunarInflight = {};
  PersonalizedLunarMonthModel? _activeLunarMonth;
  String? _activeLunarMonthContextKey;
  Future<void>? _contentLoadFuture;
  bool _isLoadingContent = false;

  RuneOfDayModel? _cachedTodayRune;
  String? _cachedRuneDateKey;
  TarotCardModel? _cachedTodayTarotCard;
  String? _cachedTarotCardDateKey;
  String? _lastCachedUserId;
  String? _openedTarotDay;
  String? _openedRuneDay;
  bool _isDailySymbolTarotOpenedInSession = false;
  bool _isDailySymbolRuneOpenedInSession = false;
  final Set<int> _openedTarotDeckPositions = <int>{};
  final Set<int> _openedRuneDeckPositions = <int>{};

  Box<Map> get _box => HiveService.contentBox;

  String _moonPhaseCacheKey(
    DateTime date,
    int hour,
    int minute,
    int timezoneOffsetMinutes,
    double lat,
    double lon,
  ) =>
      '${date.year}-${date.month}-${date.day}-$hour-$minute-$timezoneOffsetMinutes-${lat.toStringAsFixed(4)}-${lon.toStringAsFixed(4)}';

  String _timeZoneOffsetLabel(Duration offset) {
    final sign = offset.isNegative ? '-' : '+';
    final absOffset = offset.abs();
    final hours = absOffset.inHours.toString().padLeft(2, '0');
    final minutes = (absOffset.inMinutes % 60).toString().padLeft(2, '0');
    return '$sign$hours:$minutes';
  }

  String? _currentLocationFingerprintOrNull() {
    final location = _userProvider.currentUser?.currentLocation;
    if (location == null) return null;
    return _locationFingerprint(location);
  }

  String _locationFingerprint(CurrentLocationModel location) {
    return [
      location.latitude.toStringAsFixed(4),
      location.longitude.toStringAsFixed(4),
      location.source.name,
    ].join('|');
  }

  String _personalizedMonthContextKey(
    DateTime month,
    CurrentLocationModel location,
  ) {
    return [
      month.year.toString().padLeft(4, '0'),
      month.month.toString().padLeft(2, '0'),
      _locationFingerprint(location),
      _localeService.languageTag,
    ].join('|');
  }

  void _clearPersonalizedLunarState() {
    _activeLunarMonth = null;
    _activeLunarMonthContextKey = null;
    _personalizedLunarInflight.clear();
  }

  void _logMoonPhaseRequest({
    required String source,
    required DateTime selectedDate,
    required DateTime phoneNow,
    required double lat,
    required double lon,
  }) {
    debugPrint(
      '[MoonPhase] $source: selectedDate=${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}, '
      'sentTime=${phoneNow.hour.toString().padLeft(2, '0')}:${phoneNow.minute.toString().padLeft(2, '0')}, '
      'timezoneOffsetMinutes=${phoneNow.timeZoneOffset.inMinutes}, '
      'phoneNow=${phoneNow.toIso8601String()}, '
      'timezone=${phoneNow.timeZoneName} (${_timeZoneOffsetLabel(phoneNow.timeZoneOffset)}), '
      'locationContext=${lat.toStringAsFixed(1)}:${lon.toStringAsFixed(1)}',
    );
  }

  UserModel _currentUserOrThrow() {
    final user = _userProvider.currentUser;
    if (user == null) {
      throw Exception('Пользователь не авторизован');
    }
    return user;
  }

  List<TarotCardModel> get tarotCards => _tarotCards;
  List<RuneOfDayModel> get runes => _runes;
  List<ArticleModel> get articles => _articles;
  List<AffirmationModel> get affirmations => _affirmations;
  List<EnergyOfDayModel> get energyOfDay => _energyOfDay;
  List<String> get affirmationCategories => _affirmationCategories;
  bool get isLoadingContent => _isLoadingContent;
  PersonalizedLunarMonthModel? get activeLunarMonth => _activeLunarMonth;

  void _clearTarotOpenState() {
    _openedTarotDay = null;
    _isDailySymbolTarotOpenedInSession = false;
    _openedTarotDeckPositions.clear();
  }

  void _clearRuneOpenState() {
    _openedRuneDay = null;
    _isDailySymbolRuneOpenedInSession = false;
    _openedRuneDeckPositions.clear();
  }

  void resetTarotOpenState() {
    _clearTarotOpenState();
  }

  void resetRuneOpenState() {
    _clearRuneOpenState();
  }

  void resetTarotAndRuneOpenState() {
    _clearTarotOpenState();
    _clearRuneOpenState();
  }

  final List<String> _affirmationCategories = const [
    'love',
    'abundance',
    'strength',
    'creativity',
    'lunar',
    'calm',
  ];

  List<AffirmationModel> getAffirmationsByCategory(String category) {
    return _affirmations
        .where((affirmation) => affirmation.effectiveCategoryId == category)
        .toList();
  }

  ArticleModel? getArticleById(String id) {
    try {
      return _articles.firstWhere((article) => article.id == id);
    } catch (e) {
      debugPrint('[ERROR] Статья с id $id не найдена: $e');
      return null;
    }
  }

  Future<void> initialize() async {
    await loadContent();
  }

  Future<PersonalizedLunarMonthModel> loadPersonalizedLunarMonth(
    DateTime month, {
    bool forceRefresh = false,
  }) {
    final user = _currentUserOrThrow();
    final location = _currentLocationResolver.requireLocation(user);
    final normalizedMonth = DateTime(month.year, month.month);
    final contextKey = _personalizedMonthContextKey(normalizedMonth, location);
    final inflightKey = contextKey;

    final existing = _personalizedLunarInflight[inflightKey];
    if (existing != null) return existing;

    final repository =
        _personalizedLunarCalendarRepository ??
        di.get<PersonalizedLunarCalendarRepository>();
    final future = repository
        .loadMonth(month: normalizedMonth, location: location)
        .then((month) {
          final currentLocation = _currentLocationResolver
              .resolve(_userProvider.currentUser)
              .location;
          if (currentLocation != null &&
              _personalizedMonthContextKey(normalizedMonth, currentLocation) ==
                  contextKey) {
            _activeLunarMonth = month;
            _activeLunarMonthContextKey = contextKey;
            notifyListeners();
          }
          return month;
        })
        .whenComplete(() {
          _personalizedLunarInflight.remove(inflightKey);
        });

    _personalizedLunarInflight[inflightKey] = future;
    return future;
  }

  PersonalizedLunarDayModel? getPersonalizedLunarDayByDate(DateTime date) {
    final user = _userProvider.currentUser;
    if (user == null) return null;
    final location = _currentLocationResolver.resolve(user).location;
    if (location == null) return null;

    final contextKey = _personalizedMonthContextKey(
      DateTime(date.year, date.month),
      location,
    );
    if (_activeLunarMonthContextKey != contextKey) return null;

    final normalized = DateTime(date.year, date.month, date.day);
    for (final day in _activeLunarMonth?.days ?? const []) {
      if (DateTime(day.date.year, day.date.month, day.date.day) == normalized) {
        return day;
      }
    }
    return null;
  }

  Future<void> loadContent() {
    return _contentLoadFuture ??= _performContentLoad().whenComplete(() {
      _contentLoadFuture = null;
    });
  }

  Future<void> _performContentLoad() async {
    _isLoadingContent = true;
    notifyListeners();

    try {
      await _contentRepository.refreshContentVersions();
      await Future.wait([
        _loadContentList<TarotCardModel>(
          debugName: 'карт таро',
          load: _contentRepository.getTarotCards,
          apply: (items) => _tarotCards = items,
        ),
        _loadContentList<RuneOfDayModel>(
          debugName: 'рун',
          load: _contentRepository.getRunes,
          apply: (items) => _runes = items,
        ),
        _loadContentList<ArticleModel>(
          debugName: 'статей',
          load: _contentRepository.getArticles,
          apply: (items) => _articles = _horoscopesEnabled
              ? items
              : items
                    .where(
                      (article) => ![
                        article.title,
                        article.category,
                        article.intro,
                        article.text,
                        article.conclusion,
                      ].any(AppFeatureVisibility.containsHoroscope),
                    )
                    .toList(),
        ),
        _loadContentList<AffirmationModel>(
          debugName: 'аффирмаций',
          load: _contentRepository.getAffirmations,
          apply: (items) => _affirmations = items,
        ),
      ]);
      await _loadEnergyOfDay();
    } finally {
      _isLoadingContent = false;
      notifyListeners();
    }
  }

  Future<void> _loadContentList<T>({
    required String debugName,
    required Future<List<T>> Function() load,
    required void Function(List<T>) apply,
  }) async {
    try {
      final items = await load();
      if (items.isEmpty) {
        debugPrint(
          '[WARNING] Загружен пустой список $debugName, текущие данные сохранены',
        );
        return;
      }
      apply(items);
    } catch (e) {
      debugPrint(
        '[ERROR] Ошибка загрузки $debugName, текущие данные сохранены: $e',
      );
    }
  }

  Future<void> _loadEnergyOfDay() async {
    try {
      // Проверяем, нужно ли перезагрузить данные
      final shouldReload = await _contentRepository.shouldReloadEnergyOfDay();

      if (shouldReload) {
        debugPrint('[DEBUG] Загрузка энергии дня из backend');
        _energyOfDay = await _contentRepository.getEnergyOfDay();
      } else {
        debugPrint('[DEBUG] Загрузка энергии дня из кэша');
        _energyOfDay = await _contentRepository.getEnergyOfDayFromCache();

        // Если кэш пуст, загружаем из backend
        if (_energyOfDay.isEmpty) {
          debugPrint('[DEBUG] Кэш пуст, загрузка из backend');
          _energyOfDay = await _contentRepository.getEnergyOfDay();
        }
      }
    } catch (e) {
      debugPrint('[ERROR] Ошибка загрузки энергии дня: $e');
      // Пытаемся загрузить из кэша в случае ошибки
      try {
        _energyOfDay = await _contentRepository.getEnergyOfDayFromCache();
      } catch (cacheError) {
        debugPrint('[ERROR] Ошибка загрузки энергии дня из кэша: $cacheError');
      }
    }
  }

  // Общие функции для работы с элементами дня

  /// Получает сегодняшний элемент из кеша или выбирает новый
  T _getTodayItem<T>({
    required String cacheKey,
    required List<T> items,
    required String itemTypeName,
    required String Function(T) getId,
    required String Function(T) getTitle,
    String? previousItemId,
  }) {
    if (items.isEmpty) {
      throw Exception('Список $itemTypeName пуст');
    }

    final DateTime today = DateTime.now();
    final String todayKey = formatDateKey(today);

    // Получаем сохраненные данные
    final Map<dynamic, dynamic>? cachedData = _box.get(cacheKey);

    if (cachedData != null) {
      final String? savedDate = cachedData['date'] as String?;
      final String? savedItemId = cachedData['${itemTypeName}Id'] as String?;

      // Если дата совпадает с сегодняшним днем - возвращаем сохраненный элемент
      if (savedDate == todayKey && savedItemId != null) {
        try {
          final item = items.firstWhere(
            (element) => getId(element) == savedItemId,
          );
          return item;
        } catch (e) {
          debugPrint(
            '[WARNING] Сохраненный $itemTypeName не найден, выбираем новый: $e',
          );
        }
      }
    }

    // Если дата другая или элемент не найден - выбираем новый случайный элемент
    final String? previousId =
        previousItemId ?? cachedData?['${itemTypeName}Id'] as String?;
    final T newItem = _selectRandomItem<T>(
      items: items,
      excludingId: previousId,
      getId: getId,
    );

    // Сохраняем новый элемент
    _box.put(cacheKey, {
      '${itemTypeName}Id': getId(newItem),
      'date': todayKey,
      'previous${itemTypeName}Id':
          previousId, // Сохраняем предыдущий для следующего дня
    });

    debugPrint(
      '[DEBUG] Выбран новый $itemTypeName дня: ${getTitle(newItem)} (ID: ${getId(newItem)})',
    );
    return newItem;
  }

  /// Выбирает случайный элемент из списка, исключая указанные ID
  T _selectRandomItem<T>({
    required List<T> items,
    String? excludingId,
    List<String>? excludingIds,
    required String Function(T) getId,
  }) {
    List<T> availableItems = items;

    final idsToExclude = <String>{
      if (excludingId != null) excludingId,
      ...?excludingIds,
    };
    if (idsToExclude.isNotEmpty) {
      availableItems = items
          .where((item) => !idsToExclude.contains(getId(item)))
          .toList();
      if (availableItems.isEmpty) {
        availableItems = items;
      }
    }

    final random = Random();
    final randomIndex = random.nextInt(availableItems.length);
    final selectedItem = availableItems[randomIndex];

    // Сохраняем ID выбранного элемента в просмотренный контент
    final selectedItemId = getId(selectedItem);
    _userProvider.addViewedContent(selectedItemId);

    return selectedItem;
  }

  /// Обновляет сегодняшний элемент, выбирая новый, отличный от текущего
  void _refreshItem<T>({
    required String cacheKey,
    required List<T> items,
    required String itemTypeName,
    required String Function(T) getId,
    required String Function(T) getTitle,
  }) {
    if (items.isEmpty) {
      throw Exception('Список $itemTypeName пуст');
    }

    final DateTime today = DateTime.now();
    final String todayKey = formatDateKey(today);

    // Получаем текущий элемент из кеша
    final Map<dynamic, dynamic>? cachedData = _box.get(cacheKey);
    String? currentItemId;
    bool wasOpened = false;

    if (cachedData != null) {
      final String? savedDate = cachedData['date'] as String?;
      if (savedDate == todayKey) {
        currentItemId = cachedData['${itemTypeName}Id'] as String?;
        wasOpened = cachedData['isOpened'] == true;
      }
    }

    // Выбираем новый элемент, исключая текущий
    final T newItem = _selectRandomItem<T>(
      items: items,
      excludingId: currentItemId,
      getId: getId,
    );

    // Сохраняем новый элемент, сохраняя флаг открытия если карта уже была открыта
    _box.put(cacheKey, {
      '${itemTypeName}Id': getId(newItem),
      'date': todayKey,
      'previous${itemTypeName}Id':
          currentItemId, // Сохраняем предыдущий для следующего дня
      'isOpened': wasOpened, // Сохраняем флаг открытия при обновлении
    });

    debugPrint(
      '[DEBUG] Обновлен $itemTypeName дня: ${getTitle(newItem)} (ID: ${getId(newItem)})',
    );
    notifyListeners();
  }

  // Функции для таро карт

  bool isTodayTarotCardOpened() {
    return _openedTarotDay == formatDateKey(_now());
  }

  Future<void> setTodayTarotCardOpened() async {
    if (isTodayTarotCardOpened()) return;
    final currentUser = _userProvider.currentUser;
    final todayKey = formatDateKey(_now());
    final item = currentUser?.tarotCardOfDayItem;
    final cardId = item?.date == todayKey
        ? item?.cardId
        : (_cachedTarotCardDateKey == todayKey
              ? _cachedTodayTarotCard?.id
              : null);

    if (cardId != null && cardId.isNotEmpty) {
      di.get<AnalyticsFacade>().trackEvent(
        AnalyticsEvents.tarotCardView,
        params: {
          EventParams.featureName: 'tarot',
          'card_id': cardId,
          'context': 'card_of_day',
        },
      );
    }

    if (currentUser != null && cardId != null && cardId.isNotEmpty) {
      var updatedUser = currentUser;
      if (!_userProvider.isContentViewed(cardId)) {
        updatedUser = updatedUser.copyWith(
          viewedContentIds: [...updatedUser.viewedContentIds, cardId],
        );
      }
      if (updatedUser != currentUser) {
        _userProvider.updateUser(updatedUser).catchError((e) {
          debugPrint('[ERROR] Ошибка сохранения карты таро дня: $e');
        });
      }
    } else if (cardId != null && cardId.isNotEmpty) {
      _userProvider.addViewedContent(cardId);
    }
    if (cardId == null || cardId.isEmpty) return;
    _openedTarotDay = todayKey;
    notifyListeners();
    if (currentUser != null) {
      await _achievementRecorder?.record(
        AchievementEvent(
          userId: currentUser.id,
          kind: AchievementEventKind.tarotDay,
          reference: todayKey,
        ),
      );
    }
  }

  bool isDailySymbolTarotOpened() {
    return _isDailySymbolTarotOpenedInSession;
  }

  void setDailySymbolTarotOpened() {
    _isDailySymbolTarotOpenedInSession = true;
    notifyListeners();
  }

  static const int _layoutLeftIndex = 0;
  static const int _layoutCenterIndex = 1;
  static const int _layoutRightIndex = 2;

  int _getLayoutPositionIndex(String hiveKey) {
    switch (hiveKey) {
      case KeysConst.tarotDeckCardLeftKey:
        return _layoutLeftIndex;
      case KeysConst.tarotDeckCardCenterKey:
        return _layoutCenterIndex;
      case KeysConst.tarotDeckCardRightKey:
        return _layoutRightIndex;
      default:
        return _layoutLeftIndex;
    }
  }

  TarotDeckModel _getOrCreateTarotDeck() {
    final existing = _userProvider.currentUser?.tarotDeck;
    if (existing == null) {
      return TarotDeckModel(
        cards: const [
          TarotCardInDeckModel(id: '', isOpened: false),
          TarotCardInDeckModel(id: '', isOpened: false),
          TarotCardInDeckModel(id: '', isOpened: false),
        ],
      );
    }
    if (existing.cards.length >= 3) {
      return existing;
    }
    final cards = List<TarotCardInDeckModel>.from(existing.cards);
    while (cards.length < 3) {
      cards.add(const TarotCardInDeckModel(id: '', isOpened: false));
    }
    return existing.copyWith(cards: cards);
  }

  /// Предзаполняет расклад картами при показе (как в Love deck).
  /// Идемпотентен: если все 3 позиции уже имеют id, ничего не делает.
  Future<void> ensureTarotDeckLayoutReady() async {
    if (_tarotCards.isEmpty) return;

    final currentUser = _userProvider.currentUser;
    if (currentUser == null) return;

    final tarotDeck = _getOrCreateTarotDeck();
    final currentCards = List<TarotCardInDeckModel>.from(tarotDeck.cards);

    bool hasEmptySlots = false;
    final excludingIds = <String>[];

    for (int i = 0; i < 3; i++) {
      if (currentCards[i].id.isEmpty) {
        hasEmptySlots = true;
        final card = _selectRandomItem<TarotCardModel>(
          items: _tarotCards,
          excludingIds: excludingIds,
          getId: (c) => c.id,
        );
        currentCards[i] = TarotCardInDeckModel(id: card.id, isOpened: false);
        excludingIds.add(card.id);
      } else {
        excludingIds.add(currentCards[i].id);
      }
    }

    if (!hasEmptySlots) return;

    final updatedTarotDeck = tarotDeck.copyWith(cards: currentCards);
    await _userProvider.updateUser(
      currentUser.copyWith(tarotDeck: updatedTarotDeck),
    );
    notifyListeners();
  }

  /// Выбирает карту для позиции без сохранения. Для анимации "сначала flip, потом save".
  /// [extraExcludingIds] — дополнительные id для исключения (например, карты в процессе анимации).
  TarotCardModel? selectTarotCardForPosition(
    String hiveKey, {
    List<String>? extraExcludingIds,
  }) {
    if (_tarotCards.isEmpty) return null;

    final tarotDeck = _getOrCreateTarotDeck();
    final currentCards = List<TarotCardInDeckModel>.from(tarotDeck.cards);

    final excludingIds = [
      ...currentCards.where((c) => c.id.isNotEmpty).map((c) => c.id),
      ...?extraExcludingIds,
    ];

    return _selectRandomItem<TarotCardModel>(
      items: _tarotCards,
      excludingIds: excludingIds,
      getId: (card) => card.id,
    );
  }

  Future<void> openTarotCardInDeck(String hiveKey, {String? cardId}) async {
    if (_tarotCards.isEmpty) {
      debugPrint('[WARNING] Список карт таро пуст, невозможно выбрать карту');
      return;
    }

    final currentUser = _userProvider.currentUser;
    if (currentUser == null) {
      debugPrint(
        '[WARNING] Пользователь не авторизован, невозможно сохранить расклад',
      );
      return;
    }

    final positionIndex = _getLayoutPositionIndex(hiveKey);
    final tarotDeck = _getOrCreateTarotDeck();
    final currentCards = List<TarotCardInDeckModel>.from(tarotDeck.cards);
    if (_openedTarotDeckPositions.contains(positionIndex)) {
      return;
    }
    final wasSpreadCompleted = _openedTarotDeckPositions.length == 3;

    final TarotCardModel selectedCard;
    if (cardId != null) {
      try {
        selectedCard = _tarotCards.firstWhere((c) => c.id == cardId);
      } catch (_) {
        debugPrint('[WARNING] Карта с id $cardId не найдена');
        return;
      }
    } else {
      final excludingIds = currentCards
          .where((c) => c.id.isNotEmpty)
          .map((c) => c.id)
          .toList();
      selectedCard = _selectRandomItem<TarotCardModel>(
        items: _tarotCards,
        excludingIds: excludingIds,
        getId: (card) => card.id,
      );
    }

    final isFirstOpenedCard = _openedTarotDeckPositions.isEmpty;
    _openedTarotDeckPositions.add(positionIndex);
    notifyListeners();

    final spreadCompleted = _openedTarotDeckPositions.length == 3;
    if (!wasSpreadCompleted && spreadCompleted) {
      unawaited(di.get<RewardsProvider>().recordTarotSpread('main'));
    }

    final facade = di.get<AnalyticsFacade>();
    if (isFirstOpenedCard) {
      facade.trackEvent(
        AnalyticsEvents.tarotSpreadStarted,
        params: const {EventParams.featureName: 'tarot'},
      );
    }
    facade.trackEvent(
      AnalyticsEvents.tarotCardView,
      params: {
        EventParams.featureName: 'tarot',
        'card_id': selectedCard.id,
        'context': 'spread',
        'position_index': positionIndex,
      },
    );

    debugPrint(
      '[DEBUG] Открыта карта в раскладе: ${selectedCard.title} (ID: ${selectedCard.id}) в позиции: $positionIndex',
    );
  }

  bool isTarotCardInDeckOpened(String hiveKey) {
    return _openedTarotDeckPositions.contains(_getLayoutPositionIndex(hiveKey));
  }

  bool areAllTarotDeckCardsOpened() => _openedTarotDeckPositions.length == 3;

  InterpretationModel? getTarotDeckLayoutInterpretation() {
    return _userProvider.currentUser?.tarotDeck?.interpretation;
  }

  TarotCardModel? getTarotCardInDeck(String hiveKey) {
    final tarotDeck = _userProvider.currentUser?.tarotDeck;
    if (tarotDeck == null ||
        tarotDeck.cards.length <= _getLayoutPositionIndex(hiveKey)) {
      return null;
    }
    final cardInDeck = tarotDeck.cards[_getLayoutPositionIndex(hiveKey)];
    if (cardInDeck.id.isEmpty) {
      return null;
    }
    try {
      return _tarotCards.firstWhere((card) => card.id == cardInDeck.id);
    } catch (_) {
      return null;
    }
  }

  /// Получает инсайт по раскладу из 3 карт таро.
  /// Сохраняет InterpretationModel в tarotDeck пользователя.
  Future<void> getTarotDeckLayoutInsight() async {
    final currentUser = _userProvider.currentUser;
    if (currentUser == null) {
      throw Exception('Пользователь не авторизован');
    }

    final tarotDeck = currentUser.tarotDeck;
    if (tarotDeck == null ||
        tarotDeck.cards.length < 3 ||
        !tarotDeck.cards.take(3).every((card) => card.id.isNotEmpty) ||
        !areAllTarotDeckCardsOpened()) {
      throw Exception('Расклад не заполнен');
    }

    final card1 = getTarotCardInDeck(KeysConst.tarotDeckCardLeftKey);
    final card2 = getTarotCardInDeck(KeysConst.tarotDeckCardCenterKey);
    final card3 = getTarotCardInDeck(KeysConst.tarotDeckCardRightKey);

    if (card1 == null || card2 == null || card3 == null) {
      throw Exception('Не все карты расклада открыты');
    }

    final variables = buildTarotDeckLayoutVariables(
      firstCardName: card1.title,
      firstCardMeaning: card1.generalDescription,
      secondCardName: card2.title,
      secondCardMeaning: card2.generalDescription,
      thirdCardName: card3.title,
      thirdCardMeaning: card3.generalDescription,
    );

    final interpretation = await _contentRepository.getTarotDeckLayoutInsight(
      variables,
    );
    final freshUser = _currentUserOrThrow();
    final updatedTarotDeck = (freshUser.tarotDeck ?? tarotDeck).copyWith(
      interpretation: interpretation,
    );
    await _userProvider.updateUser(
      freshUser.copyWith(tarotDeck: updatedTarotDeck),
    );
    notifyListeners();
  }

  /// Сбрасывает расклад и сразу создаёт новый с 3 картами (isOpened: false).
  /// Без промежуточного null — пользователь всегда видит новый расклад.
  /// Возвращает true если сброс выполнен, false если без подписки уже использован лимит 1 раз в день.
  Future<bool> refreshTarotDeckLayout() async {
    final currentUser = _userProvider.currentUser;
    if (currentUser == null) return false;
    if (_tarotCards.isEmpty) return false;

    final hasProSubscription = _monetizationProvider?.effectivePro ?? false;
    final now = DateTime.now();

    if (!hasProSubscription) {
      final lastReset = currentUser.tarotDeckLayoutLastResetDate;
      if (lastReset != null && isSameDay(lastReset, now)) {
        return false;
      }
    }

    final excludingIds = <String>[];
    final newCards = <TarotCardInDeckModel>[];
    for (int i = 0; i < 3; i++) {
      final card = _selectRandomItem<TarotCardModel>(
        items: _tarotCards,
        excludingIds: excludingIds,
        getId: (c) => c.id,
      );
      newCards.add(TarotCardInDeckModel(id: card.id, isOpened: false));
      excludingIds.add(card.id);
    }

    final newTarotDeck = TarotDeckModel(cards: newCards);
    final updatedUser = hasProSubscription
        ? currentUser.copyWith(tarotDeck: newTarotDeck)
        : currentUser.copyWith(
            tarotDeck: newTarotDeck,
            tarotDeckLayoutLastResetDate: now,
          );

    await _userProvider.updateUser(updatedUser);
    _openedTarotDeckPositions.clear();
    notifyListeners();
    return true;
  }

  TarotCardModel getTodayTarotCard() {
    if (_tarotCards.isEmpty) throw Exception('Список карт таро пуст');
    final todayKey = formatDateKey(_now());

    if (_cachedTarotCardDateKey == todayKey && _cachedTodayTarotCard != null) {
      return _cachedTodayTarotCard!;
    }

    final user = _userProvider.currentUser;
    final item = user?.tarotCardOfDayItem;
    if (item != null && item.date == todayKey && item.cardId.isNotEmpty) {
      try {
        final card = _tarotCards.firstWhere((c) => c.id == item.cardId);
        _cachedTodayTarotCard = card;
        _cachedTarotCardDateKey = todayKey;
        return card;
      } catch (_) {
        debugPrint('[WARNING] Карта таро из user не найдена, выбираем новую');
      }
    }

    final hiveData = _box.get(KeysConst.tarotCardOfDayKey);
    if (hiveData != null) {
      final savedDate = hiveData['date'] as String?;
      final savedId = hiveData['cardId'] as String?;
      if (savedDate == todayKey && savedId != null && savedId.isNotEmpty) {
        try {
          final card = _tarotCards.firstWhere((c) => c.id == savedId);
          _cachedTodayTarotCard = card;
          _cachedTarotCardDateKey = todayKey;
          if (user != null) {
            final newItem = TarotCardOfDayItemModel(
              cardId: card.id,
              date: todayKey,
              isOpened: false,
            );
            _userProvider
                .updateUser(user.copyWith(tarotCardOfDayItem: newItem))
                .catchError((e) {
                  debugPrint('[ERROR] Миграция карты таро в user: $e');
                });
          }
          return card;
        } catch (_) {}
      }
    }

    final previousId = item?.cardId ?? hiveData?['cardId'] as String?;
    final newCard = _selectRandomItem<TarotCardModel>(
      items: _tarotCards,
      excludingId: previousId,
      getId: (c) => c.id,
    );
    _cachedTodayTarotCard = newCard;
    _cachedTarotCardDateKey = todayKey;
    if (user != null) {
      final newItem = TarotCardOfDayItemModel(
        cardId: newCard.id,
        date: todayKey,
        isOpened: false,
      );
      _userProvider
          .updateUser(user.copyWith(tarotCardOfDayItem: newItem))
          .catchError((e) {
            debugPrint('[ERROR] Сохранение карты таро дня: $e');
          });
    } else {
      _box.put(KeysConst.tarotCardOfDayKey, {
        'cardId': newCard.id,
        'date': todayKey,
        'previousCardId': previousId,
      });
    }
    debugPrint(
      '[DEBUG] Выбран новая карта таро дня: ${newCard.title} (ID: ${newCard.id})',
    );
    return newCard;
  }

  void refreshTarotCard() {
    if (_tarotCards.isEmpty) throw Exception('Список карт таро пуст');
    final todayKey = formatDateKey(_now());
    final user = _userProvider.currentUser;
    final item = user?.tarotCardOfDayItem;
    final currentId = (item != null && item.date == todayKey)
        ? item.cardId
        : null;
    final newCard = _selectRandomItem<TarotCardModel>(
      items: _tarotCards,
      excludingId: currentId,
      getId: (c) => c.id,
    );
    _cachedTodayTarotCard = newCard;
    _cachedTarotCardDateKey = todayKey;
    if (user != null) {
      final newItem = TarotCardOfDayItemModel(
        cardId: newCard.id,
        date: todayKey,
        isOpened: false,
      );
      _userProvider
          .updateUser(user.copyWith(tarotCardOfDayItem: newItem))
          .catchError((e) {
            debugPrint('[ERROR] Обновление карты таро дня: $e');
          });
    } else {
      _box.put(KeysConst.tarotCardOfDayKey, {
        'cardId': newCard.id,
        'date': todayKey,
      });
    }
    _openedTarotDay = null;
    _isDailySymbolTarotOpenedInSession = false;
    debugPrint('[DEBUG] Обновлена карта таро дня: ${newCard.title}');
    notifyListeners();
  }

  // Функции для рун

  bool isTodayRuneOpened() {
    return _openedRuneDay == formatDateKey(_now());
  }

  Future<void> setTodayRuneOpened() async {
    if (isTodayRuneOpened()) return;
    final currentUser = _userProvider.currentUser;
    final todayKey = formatDateKey(_now());
    final item = currentUser?.runeOfDayItem;
    final runeId = item?.date == todayKey
        ? item?.runeId
        : (_cachedRuneDateKey == todayKey ? _cachedTodayRune?.id : null);

    if (runeId != null && runeId.isNotEmpty) {
      di.get<AnalyticsFacade>().trackEvent(
        AnalyticsEvents.runeView,
        params: {
          EventParams.featureName: 'runes',
          'rune_id': runeId,
          'context': 'rune_of_day',
        },
      );
    }

    if (currentUser != null && runeId != null && runeId.isNotEmpty) {
      var updatedUser = currentUser;
      if (!_userProvider.isContentViewed(runeId)) {
        updatedUser = updatedUser.copyWith(
          viewedContentIds: [...updatedUser.viewedContentIds, runeId],
        );
      }
      if (updatedUser != currentUser) {
        _userProvider.updateUser(updatedUser).catchError((e) {
          debugPrint('[ERROR] Ошибка сохранения руны дня: $e');
        });
      }
    } else if (runeId != null && runeId.isNotEmpty) {
      _userProvider.addViewedContent(runeId);
    }
    if (runeId == null || runeId.isEmpty) return;
    _openedRuneDay = todayKey;
    notifyListeners();
    if (currentUser != null) {
      await _achievementRecorder?.record(
        AchievementEvent(
          userId: currentUser.id,
          kind: AchievementEventKind.runeDay,
          reference: todayKey,
        ),
      );
    }
  }

  bool isDailySymbolRuneOpened() {
    return _isDailySymbolRuneOpenedInSession;
  }

  void setDailySymbolRuneOpened() {
    _isDailySymbolRuneOpenedInSession = true;
    notifyListeners();
  }

  RuneOfDayModel getTodayRune() {
    if (_runes.isEmpty) throw Exception('Список рун пуст');
    final todayKey = formatDateKey(_now());

    if (_cachedRuneDateKey == todayKey && _cachedTodayRune != null) {
      return _cachedTodayRune!;
    }

    final user = _userProvider.currentUser;
    final item = user?.runeOfDayItem;
    if (item != null && item.date == todayKey && item.runeId.isNotEmpty) {
      try {
        final rune = _runes.firstWhere((r) => r.id == item.runeId);
        _cachedTodayRune = rune;
        _cachedRuneDateKey = todayKey;
        return rune;
      } catch (_) {
        debugPrint('[WARNING] Руна из user не найдена, выбираем новую');
      }
    }

    final hiveData = _box.get(KeysConst.runeOfDayKey);
    if (hiveData != null) {
      final savedDate = hiveData['date'] as String?;
      final savedId = hiveData['runeId'] as String?;
      if (savedDate == todayKey && savedId != null && savedId.isNotEmpty) {
        try {
          final rune = _runes.firstWhere((r) => r.id == savedId);
          _cachedTodayRune = rune;
          _cachedRuneDateKey = todayKey;
          if (user != null) {
            final newItem = RuneOfDayItemModel(
              runeId: rune.id,
              date: todayKey,
              isOpened: false,
            );
            _userProvider
                .updateUser(user.copyWith(runeOfDayItem: newItem))
                .catchError((e) {
                  debugPrint('[ERROR] Миграция руны в user: $e');
                });
          }
          return rune;
        } catch (_) {}
      }
    }

    final previousId = item?.runeId ?? hiveData?['runeId'] as String?;
    final newRune = _selectRandomItem<RuneOfDayModel>(
      items: _runes,
      excludingId: previousId,
      getId: (r) => r.id,
    );
    _cachedTodayRune = newRune;
    _cachedRuneDateKey = todayKey;
    if (user != null) {
      final newItem = RuneOfDayItemModel(
        runeId: newRune.id,
        date: todayKey,
        isOpened: false,
      );
      _userProvider
          .updateUser(user.copyWith(runeOfDayItem: newItem))
          .catchError((e) {
            debugPrint('[ERROR] Сохранение руны дня: $e');
          });
    } else {
      _box.put(KeysConst.runeOfDayKey, {
        'runeId': newRune.id,
        'date': todayKey,
        'previousRuneId': previousId,
      });
    }
    debugPrint(
      '[DEBUG] Выбрана новая руна дня: ${newRune.title} (ID: ${newRune.id})',
    );
    return newRune;
  }

  void refreshRune() {
    if (_runes.isEmpty) throw Exception('Список рун пуст');
    final todayKey = formatDateKey(_now());
    final user = _userProvider.currentUser;
    final item = user?.runeOfDayItem;
    final currentId = (item != null && item.date == todayKey)
        ? item.runeId
        : null;
    final newRune = _selectRandomItem<RuneOfDayModel>(
      items: _runes,
      excludingId: currentId,
      getId: (r) => r.id,
    );
    _cachedTodayRune = newRune;
    _cachedRuneDateKey = todayKey;
    if (user != null) {
      final newItem = RuneOfDayItemModel(
        runeId: newRune.id,
        date: todayKey,
        isOpened: false,
      );
      _userProvider
          .updateUser(user.copyWith(runeOfDayItem: newItem))
          .catchError((e) {
            debugPrint('[ERROR] Обновление руны дня: $e');
          });
    } else {
      _box.put(KeysConst.runeOfDayKey, {
        'runeId': newRune.id,
        'date': todayKey,
      });
    }
    _openedRuneDay = null;
    _isDailySymbolRuneOpenedInSession = false;
    debugPrint('[DEBUG] Обновлена руна дня: ${newRune.title}');
    notifyListeners();
  }

  int _getRuneLayoutPositionIndex(String hiveKey) {
    switch (hiveKey) {
      case KeysConst.runeDeckLeftKey:
        return 0;
      case KeysConst.runeDeckCenterKey:
        return 1;
      case KeysConst.runeDeckRightKey:
        return 2;
      default:
        return 0;
    }
  }

  RuneDeckModel _getOrCreateRuneDeck() {
    final existing = _userProvider.currentUser?.runeDeck;
    if (existing == null) {
      return RuneDeckModel(
        cards: const [
          RuneInDeckModel(id: '', isOpened: false),
          RuneInDeckModel(id: '', isOpened: false),
          RuneInDeckModel(id: '', isOpened: false),
        ],
      );
    }
    if (existing.cards.length >= 3) {
      return existing;
    }
    final cards = List<RuneInDeckModel>.from(existing.cards);
    while (cards.length < 3) {
      cards.add(const RuneInDeckModel(id: '', isOpened: false));
    }
    return existing.copyWith(cards: cards);
  }

  Future<void> ensureRuneDeckLayoutReady() async {
    if (_runes.isEmpty) return;

    final currentUser = _userProvider.currentUser;
    if (currentUser == null) return;

    final runeDeck = _getOrCreateRuneDeck();
    final currentCards = List<RuneInDeckModel>.from(runeDeck.cards);

    bool hasEmptySlots = false;
    final excludingIds = <String>[];

    for (int i = 0; i < 3; i++) {
      if (currentCards[i].id.isEmpty) {
        hasEmptySlots = true;
        final rune = _selectRandomItem<RuneOfDayModel>(
          items: _runes,
          excludingIds: excludingIds,
          getId: (r) => r.id,
        );
        currentCards[i] = RuneInDeckModel(id: rune.id, isOpened: false);
        excludingIds.add(rune.id);
      } else {
        excludingIds.add(currentCards[i].id);
      }
    }

    if (!hasEmptySlots) return;

    final updatedRuneDeck = runeDeck.copyWith(cards: currentCards);
    await _userProvider.updateUser(
      currentUser.copyWith(runeDeck: updatedRuneDeck),
    );
    notifyListeners();
  }

  Future<void> openRuneInDeck(String hiveKey) async {
    if (_runes.isEmpty) {
      debugPrint('[WARNING] Список рун пуст, невозможно открыть руну');
      return;
    }

    final currentUser = _userProvider.currentUser;
    if (currentUser == null) {
      debugPrint(
        '[WARNING] Пользователь не авторизован, невозможно сохранить расклад',
      );
      return;
    }

    final positionIndex = _getRuneLayoutPositionIndex(hiveKey);
    final runeDeck = _getOrCreateRuneDeck();
    final currentCards = List<RuneInDeckModel>.from(runeDeck.cards);

    if (currentCards[positionIndex].id.isEmpty) {
      debugPrint('[WARNING] Руна в позиции $positionIndex не выбрана');
      return;
    }
    if (_openedRuneDeckPositions.contains(positionIndex)) {
      return;
    }

    final openedRune = currentCards[positionIndex];
    _openedRuneDeckPositions.add(positionIndex);
    notifyListeners();

    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.runeView,
      params: {
        EventParams.featureName: 'runes',
        'rune_id': openedRune.id,
        'context': 'spread',
        'position_index': positionIndex,
      },
    );

    debugPrint('[DEBUG] Открыта руна в раскладе в позиции: $positionIndex');
  }

  bool isRuneInDeckOpened(String hiveKey) {
    return _openedRuneDeckPositions.contains(
      _getRuneLayoutPositionIndex(hiveKey),
    );
  }

  bool areAllRuneDeckCardsOpened() => _openedRuneDeckPositions.length == 3;

  RuneOfDayModel? getRuneInDeck(String hiveKey) {
    final runeDeck = _userProvider.currentUser?.runeDeck;
    if (runeDeck == null ||
        runeDeck.cards.length <= _getRuneLayoutPositionIndex(hiveKey)) {
      return null;
    }
    final runeInDeck = runeDeck.cards[_getRuneLayoutPositionIndex(hiveKey)];
    if (runeInDeck.id.isEmpty) {
      return null;
    }
    try {
      return _runes.firstWhere((rune) => rune.id == runeInDeck.id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> refreshRuneDeckLayout() async {
    final currentUser = _userProvider.currentUser;
    if (currentUser == null) return false;
    if (_runes.isEmpty) return false;

    final hasProSubscription = _monetizationProvider?.effectivePro ?? false;
    final now = DateTime.now();

    if (!hasProSubscription) {
      final lastReset = currentUser.runeDeckLayoutLastResetDate;
      if (lastReset != null && isSameDay(lastReset, now)) {
        return false;
      }
    }

    final excludingIds = <String>[];
    final newCards = <RuneInDeckModel>[];
    for (int i = 0; i < 3; i++) {
      final rune = _selectRandomItem<RuneOfDayModel>(
        items: _runes,
        excludingIds: excludingIds,
        getId: (r) => r.id,
      );
      newCards.add(RuneInDeckModel(id: rune.id, isOpened: false));
      excludingIds.add(rune.id);
    }

    final newRuneDeck = RuneDeckModel(cards: newCards);
    final updatedUser = hasProSubscription
        ? currentUser.copyWith(runeDeck: newRuneDeck)
        : currentUser.copyWith(
            runeDeck: newRuneDeck,
            runeDeckLayoutLastResetDate: now,
          );

    await _userProvider.updateUser(updatedUser);
    _openedRuneDeckPositions.clear();
    notifyListeners();
    return true;
  }

  Future<void> getRuneDeckLayoutInsight() async {
    final currentUser = _userProvider.currentUser;
    if (currentUser == null) {
      throw Exception('Пользователь не авторизован');
    }

    final runeDeck = currentUser.runeDeck;
    if (runeDeck == null ||
        runeDeck.cards.length < 3 ||
        !runeDeck.cards.take(3).every((rune) => rune.id.isNotEmpty) ||
        !areAllRuneDeckCardsOpened()) {
      throw Exception('Расклад не заполнен');
    }

    final rune1 = getRuneInDeck(KeysConst.runeDeckLeftKey);
    final rune2 = getRuneInDeck(KeysConst.runeDeckCenterKey);
    final rune3 = getRuneInDeck(KeysConst.runeDeckRightKey);

    if (rune1 == null || rune2 == null || rune3 == null) {
      throw Exception('Не все руны расклада открыты');
    }

    final variables = buildRuneDeckLayoutVariables(
      firstRuneName: rune1.title,
      firstRuneMeaning: rune1.pastDeck,
      secondRuneName: rune2.title,
      secondRuneMeaning: rune2.presentDeck,
      thirdRuneName: rune3.title,
      thirdRuneMeaning: rune3.futureDeck,
    );

    final interpretation = await _contentRepository.getRuneDeckLayoutInsight(
      variables,
    );
    final freshUser = _currentUserOrThrow();
    final updatedRuneDeck = (freshUser.runeDeck ?? runeDeck).copyWith(
      interpretation: interpretation,
    );
    await _userProvider.updateUser(
      freshUser.copyWith(runeDeck: updatedRuneDeck),
    );
    notifyListeners();
  }

  // Функции для аффирмаций

  AffirmationModel getTodayAffirmation() {
    return _getTodayItem<AffirmationModel>(
      cacheKey: _localeService.isRussian
          ? KeysConst.affirmationOfDayKey
          : '${KeysConst.affirmationOfDayKey}_${_localeService.contentLanguage}',
      items: _affirmations,
      itemTypeName: 'affirmation',
      getId: (affirmation) => affirmation.id,
      getTitle: (affirmation) => affirmation.text,
    );
  }

  void refreshAffirmation() {
    _refreshItem<AffirmationModel>(
      cacheKey: _localeService.isRussian
          ? KeysConst.affirmationOfDayKey
          : '${KeysConst.affirmationOfDayKey}_${_localeService.contentLanguage}',
      items: _affirmations,
      itemTypeName: 'affirmation',
      getId: (affirmation) => affirmation.id,
      getTitle: (affirmation) => affirmation.text,
    );
  }

  Future<void> buyHoroscope(
    HoroscopeTypeEnum horoscopeType, {
    bool requirePro = false,
  }) async {
    if (!_horoscopesEnabled) throw StateError('Feature is unavailable');
    try {
      final currentUser = _userProvider.currentUser;
      if (currentUser == null) {
        throw Exception('Пользователь не авторизован');
      }
      final userId = currentUser.id;

      final name = currentUser.name ?? '';
      final birthDate = currentUser.personalInfo?.birthDate?.birthDate;
      final birthTime = currentUser.personalInfo?.birthDate?.birthTime;
      final birthDateStr = birthDate?.toIsoDate() ?? '';
      final zodiac =
          birthDate?.getZodiacSignName(
            languageCode: _localeService.contentLanguage,
          ) ??
          '';
      final dateNow = DateTime.now().toIsoDate();
      final dateTime = DateTime.now().toIso8601String();
      final birthTimeStr = birthTime?.toIso8601String() ?? '';
      final planetsHousesData = currentUser.planetsHousesData;
      final solarData = currentUser.solarData;

      late UserModel Function(UserModel user) applyHoroscopeUpdate;
      late DateTime horoscopeValidUntil;
      String? featureKey;
      String? payloadKey;

      switch (horoscopeType) {
        case HoroscopeTypeEnum.day:
          final horoscopeDay = await _contentRepository.getHoroscopeDay(
            name,
            birthDateStr,
            birthTimeStr,
            dateNow,
            dateTime,
            planetsHousesData.data,
            solarData.data,
          );
          horoscopeValidUntil = horoscopeDay.dateUntil;
          applyHoroscopeUpdate = (user) =>
              user.copyWith(horoscopeDay: horoscopeDay);
          break;
        case HoroscopeTypeEnum.week:
          featureKey = 'weekly_horoscope';
          payloadKey = 'week:${_localeService.languageTag}';
          final committed = await _executeGeneratedFeature(
            requirePro: requirePro,
            userId: userId,
            featureKey: featureKey,
            payloadKey: payloadKey,
            payload: {
              'name': name,
              'birthdate': birthDateStr,
              'zodiac': zodiac,
              'date_now': dateNow,
              'locale': _localeService.languageTag,
            },
          );
          final committedWeek = HoroscopeWeekModel.fromJson(committed.result);
          horoscopeValidUntil = committedWeek.dateUntil;
          applyHoroscopeUpdate = (user) =>
              user.copyWith(horoscopeWeek: committedWeek);
          break;
        case HoroscopeTypeEnum.month:
          featureKey = 'monthly_horoscope';
          payloadKey = 'month:${_localeService.languageTag}';
          final committed = await _executeGeneratedFeature(
            requirePro: requirePro,
            userId: userId,
            featureKey: featureKey,
            payloadKey: payloadKey,
            payload: {
              'name': name,
              'birthdate': birthDateStr,
              'zodiac': zodiac,
              'date_now': dateNow,
              'locale': _localeService.languageTag,
            },
          );
          final committedMonth = HoroscopeMonthModel.fromJson(committed.result);
          horoscopeValidUntil = committedMonth.dateUntil;
          applyHoroscopeUpdate = (user) =>
              user.copyWith(horoscopeMonth: committedMonth);
          break;
        case HoroscopeTypeEnum.year:
          featureKey = 'yearly_personal_horoscope';
          payloadKey = 'year:${_localeService.languageTag}';
          final committed = await _executeGeneratedFeature(
            requirePro: requirePro,
            userId: userId,
            featureKey: featureKey,
            payloadKey: payloadKey,
            payload: {
              'name': name,
              'birthdate': birthDateStr,
              'birthtime': birthTimeStr,
              'zodiac': zodiac,
              'date_now': dateNow,
              'data': planetsHousesData.data,
              'locale': _localeService.languageTag,
            },
          );
          final committedYear = HoroscopeYearModel.fromJson(committed.result);
          horoscopeValidUntil = committedYear.dateUntil;
          applyHoroscopeUpdate = (user) =>
              user.copyWith(horoscopeYear: committedYear);
          break;
      }

      if (_userProvider.currentUser?.id != userId) {
        throw StateError('User changed while obtaining horoscope');
      }
      // Persist the event before any ancillary profile PATCH can fail.
      await _achievementRecorder?.record(
        AchievementEvent(
          userId: userId,
          kind: AchievementEventKind.horoscope,
          reference:
              '${horoscopeType.name}:${formatDateKey(horoscopeValidUntil)}',
        ),
      );
      if (_userProvider.currentUser?.id != userId) {
        throw StateError('User changed while obtaining horoscope');
      }
      await _userProvider.updateUser(
        applyHoroscopeUpdate(_currentUserOrThrow()),
      );
      if (featureKey != null && payloadKey != null) {
        await _deletePendingFeatureExecution(
          userId: userId,
          featureKey: featureKey,
          payloadKey: payloadKey,
        );
      }
    } catch (e) {
      debugPrint('[ERROR] Ошибка покупки гороскопа: $e');
      throw Exception('Ошибка покупки гороскопа: $e');
    }
  }

  Future<void> buyNatalCard({bool requirePro = false}) async {
    try {
      final currentUser = _userProvider.currentUser;
      if (currentUser == null) {
        throw Exception('Пользователь не авторизован');
      }
      final userId = currentUser.id;

      final name = currentUser.name ?? '';
      final birthdate = currentUser.personalInfo?.birthDate?.birthDate;
      final birthtime = currentUser.personalInfo?.birthDate?.birthTime;
      final city = currentUser.personalInfo?.birthPlace?.location;
      final planetsHousesData = await _resolveNatalPlanetsHousesData(
        currentUser,
      );
      final birthdateStr = birthdate?.toIsoDate() ?? '';
      final birthtimeStr = birthtime?.getBirthTime() ?? '00:00';
      final cityName = city ?? 'Москва';
      final planetsBirthdate = planetsHousesData.toPromptContext(
        name: name,
        birthdate: birthdateStr,
        birthtime: birthtimeStr,
        city: cityName,
        latitude: currentUser.personalInfo?.birthPlace?.latitude,
        longitude: currentUser.personalInfo?.birthPlace?.longitude,
      );
      final committed = await _executeGeneratedFeature(
        requirePro: requirePro,
        userId: userId,
        featureKey: 'natal_chart',
        payloadKey: 'natal:${_localeService.languageTag}',
        payload: {
          'name': name,
          'birthdate': birthdateStr,
          'birthtime': birthtimeStr,
          'fire': planetsHousesData.elements.fire,
          'earth': planetsHousesData.elements.earth,
          'air': planetsHousesData.elements.air,
          'water': planetsHousesData.elements.water,
          'city': cityName,
          'planets_birthdate': planetsBirthdate,
          'locale': _localeService.languageTag,
        },
      );
      final committedCard = NatalCardModel.fromJson(committed.result);
      final language = _localeService.contentLanguage;
      if (!committedCard.hasLanguage(language)) {
        throw Exception(
          'Сервер вернул натальную карту без интерпретации для языка $language',
        );
      }
      final committedUser = _currentUserOrThrow().copyWith(
        natalCard: committedCard,
      );
      _userProvider.applyServerUserSnapshot(committedUser);
      final refreshedUser = await _userProvider.refreshCurrentUser();
      if (!(refreshedUser?.natalCard?.hasLanguage(language) ?? false)) {
        _userProvider.applyServerUserSnapshot(committedUser);
      }
      await _deletePendingFeatureExecution(
        userId: userId,
        featureKey: 'natal_chart',
        payloadKey: 'natal:${_localeService.languageTag}',
      );
    } catch (e) {
      debugPrint('[ERROR] Ошибка покупки натальной карты: $e');
      throw Exception('Ошибка покупки натальной карты: $e');
    }
  }

  Future<void> translateNatalCardIfNeeded() async {
    try {
      final currentUser = _userProvider.currentUser;
      final natalCard = currentUser?.natalCard;
      if (currentUser == null || natalCard == null) return;
      if (!natalCard.hasAnyInterpretation) return;
      final language = _localeService.contentLanguage;
      if (natalCard.hasLanguage(language)) return;
      final api = _featureApi();
      final translatedUser = await api.translateNatalCard(language: language);
      _userProvider.applyServerUserSnapshot(translatedUser);
    } catch (e) {
      debugPrint('[ERROR] Ошибка перевода натальной карты: $e');
      throw Exception('Ошибка перевода натальной карты: $e');
    }
  }

  Future<PlanetsHousesDataModel> _resolveNatalPlanetsHousesData(
    UserModel user,
  ) async {
    final existing = user.planetsHousesData;
    final hasStructuredNatalContext =
        existing.positions.isNotEmpty &&
        existing.calculation != null &&
        (existing.promptContext?.trim().isNotEmpty ?? false);
    if (hasStructuredNatalContext) {
      return existing;
    }

    final api = _backendApi;
    final birthDate = user.personalInfo?.birthDate?.birthDate;
    final birthTime = user.personalInfo?.birthDate?.birthTime;
    final birthPlace = user.personalInfo?.birthPlace;
    if (api == null || birthDate == null || birthPlace == null) {
      return existing;
    }

    final response = await api.getPlanetsHousesPosition(
      year: birthDate.year,
      month: birthDate.month,
      day: birthDate.day,
      hour: birthTime?.hour ?? 0,
      minute: birthTime?.minute ?? 0,
      latitude: birthPlace.latitude,
      longitude: birthPlace.longitude,
    );
    final refreshed = PlanetsHousesDataModel.fromJson(
      response.data as Map<String, dynamic>,
    );
    await _userProvider.updateUser(user.copyWith(planetsHousesData: refreshed));
    return refreshed;
  }

  Future<void> loadMoonPhase() async {
    try {
      final user = _userProvider.currentUser;
      if (user == null) {
        throw Exception('Пользователь не авторизован');
      }
      final currentLocation = _currentLocationResolver.requireLocation(user);
      final lat = currentLocation.latitude;
      final lon = currentLocation.longitude;
      final dateNow = DateTime.now();
      _logMoonPhaseRequest(
        source: 'loadMoonPhase',
        selectedDate: dateNow,
        phoneNow: dateNow,
        lat: lat,
        lon: lon,
      );
      final moonPhase = await _contentRepository.getMoonPhase(
        dateNow.year,
        dateNow.month,
        dateNow.day,
        dateNow.hour,
        dateNow.minute,
        dateNow.timeZoneOffset.inMinutes,
        lat,
        lon,
      );
      final cacheKey = _moonPhaseCacheKey(
        dateNow,
        dateNow.hour,
        dateNow.minute,
        dateNow.timeZoneOffset.inMinutes,
        lat,
        lon,
      );
      _moonPhaseCache[cacheKey] = moonPhase;
      await _userProvider.updateUser(
        _currentUserOrThrow().copyWith(moonPhase: moonPhase),
      );
    } catch (e) {
      debugPrint('[ERROR] Ошибка получения фазы луны: $e');
      throw Exception('Ошибка получения фазы луны: $e');
    }
  }

  Future<MoonPhaseModel> getMoonPhaseForDate(DateTime date) async {
    final user = _userProvider.currentUser;
    if (user == null) {
      throw Exception('Пользователь не авторизован');
    }
    final currentLocation = _currentLocationResolver.requireLocation(user);
    final lat = currentLocation.latitude;
    final lon = currentLocation.longitude;
    final timeNow = DateTime.now();
    final cacheKey = _moonPhaseCacheKey(
      date,
      timeNow.hour,
      timeNow.minute,
      timeNow.timeZoneOffset.inMinutes,
      lat,
      lon,
    );
    final cached = _moonPhaseCache[cacheKey];
    if (cached != null) return cached;
    _logMoonPhaseRequest(
      source: 'getMoonPhaseForDate',
      selectedDate: date,
      phoneNow: timeNow,
      lat: lat,
      lon: lon,
    );
    final moonPhase = await _contentRepository.getMoonPhase(
      date.year,
      date.month,
      date.day,
      timeNow.hour,
      timeNow.minute,
      timeNow.timeZoneOffset.inMinutes,
      lat,
      lon,
    );
    _moonPhaseCache[cacheKey] = moonPhase;
    return moonPhase;
  }

  Future<SonnikModel> createSonnik(String text) async {
    try {
      final currentUser = _userProvider.currentUser;
      if (currentUser == null) {
        throw Exception('Пользователь не авторизован');
      }
      final userId = currentUser.id;
      final payload = {
        'text': text.trim(),
        'locale': _localeService.languageTag,
        'name':
            currentUser.name ??
            (_localeService.isRussian ? 'Пользователь' : 'User'),
      };
      final payloadKey = _stablePayloadKey('sonnik', payload);
      final pending = await _pendingFeatureExecution(
        userId: userId,
        featureKey: 'request_quota_command',
        payloadKey: payloadKey,
      );
      final command = await _requestQuotaCommand(
        'sonnik',
        payload: payload,
        idempotencyKey: pending.idempotencyKey,
      );
      if (_userProvider.currentUser?.id != userId) {
        throw Exception('Пользователь изменился во время создания сонника');
      }
      await _deletePendingFeatureExecution(
        userId: userId,
        featureKey: 'request_quota_command',
        payloadKey: payloadKey,
      );
      return SonnikModel.fromJson(command.result);
    } catch (e) {
      debugPrint('[ERROR] Ошибка создания сонника: $e');
      throw Exception('Ошибка создания сонника: $e');
    }
  }

  Future<SavedCompatibilityModel> createCompatibility({
    required String firstName,
    required String firstDate,
    required String secondName,
    required String secondDate,
  }) async {
    try {
      final currentUser = _userProvider.currentUser;
      if (currentUser == null) {
        throw Exception('Пользователь не авторизован');
      }
      final userId = currentUser.id;
      final payload = {
        'first_name': firstName,
        'first_date': firstDate,
        'second_name': secondName,
        'second_date': secondDate,
        'locale': _localeService.languageTag,
      };
      final payloadKey = _stablePayloadKey('compatibility', payload);
      final pending = await _pendingFeatureExecution(
        userId: userId,
        featureKey: 'request_quota_command',
        payloadKey: payloadKey,
      );
      final command = await _requestQuotaCommand(
        'compatibility',
        payload: payload,
        idempotencyKey: pending.idempotencyKey,
      );
      if (_userProvider.currentUser?.id != userId) {
        throw Exception(
          'Пользователь изменился во время расчета совместимости',
        );
      }
      await _deletePendingFeatureExecution(
        userId: userId,
        featureKey: 'request_quota_command',
        payloadKey: payloadKey,
      );

      return SavedCompatibilityModel.fromJson(command.result);
    } catch (e) {
      debugPrint('[ERROR] Ошибка расчета совместимости: $e');
      throw Exception('Ошибка расчета совместимости: $e');
    }
  }

  Future<dynamic> _requestQuotaCommand(
    String feature, {
    required Map<String, dynamic> payload,
    required String idempotencyKey,
  }) async {
    final monetizationProvider = _monetizationProvider;
    if (monetizationProvider == null) {
      throw Exception('Монетизация недоступна');
    }
    return monetizationProvider.executeRequestQuotaCommand(
      feature,
      payload: payload,
      idempotencyKey: idempotencyKey,
    );
  }

  String _stablePayloadKey(String feature, Map<String, dynamic> payload) {
    final canonical = jsonEncode({'feature': feature, 'payload': payload});
    return '$feature:${sha256.convert(utf8.encode(canonical))}';
  }

  Future<ClientFeatureResultModel> _executeGeneratedFeature({
    bool requirePro = false,
    required String userId,
    required String featureKey,
    required String payloadKey,
    required Map<String, dynamic> payload,
  }) {
    return _executeGeneratedFeatureAttempt(
      requirePro: requirePro,
      userId: userId,
      featureKey: featureKey,
      payloadKey: payloadKey,
      payload: payload,
      retryAfterStalePending: true,
    );
  }

  Future<ClientFeatureResultModel> _executeGeneratedFeatureAttempt({
    required bool requirePro,
    required String userId,
    required String featureKey,
    required String payloadKey,
    required Map<String, dynamic> payload,
    required bool retryAfterStalePending,
  }) async {
    final pending = await _pendingFeatureExecution(
      userId: userId,
      featureKey: featureKey,
      payloadKey: payloadKey,
    );
    late final ClientFeatureResultModel committed;
    try {
      committed = await _featureApi().createGeneratedFeature(
        requirePro: requirePro,
        featureKey: featureKey,
        payload: payload,
        expectedCatalogRevision: await _loadCatalogRevision(),
        idempotencyKey: pending.idempotencyKey,
      );
    } on FeatureExecutionException catch (error) {
      if (retryAfterStalePending &&
          _shouldRetryGeneratedFeatureWithFreshCommand(error)) {
        await _deletePendingFeatureExecution(
          userId: userId,
          featureKey: featureKey,
          payloadKey: payloadKey,
        );
        return _executeGeneratedFeatureAttempt(
          requirePro: requirePro,
          userId: userId,
          featureKey: featureKey,
          payloadKey: payloadKey,
          payload: payload,
          retryAfterStalePending: false,
        );
      }
      rethrow;
    }
    if (_userProvider.currentUser?.id != userId) {
      throw Exception('Пользователь изменился во время покупки контента');
    }
    return committed;
  }

  bool _shouldRetryGeneratedFeatureWithFreshCommand(
    FeatureExecutionException error,
  ) {
    return error.code == 'idempotency_conflict' ||
        error.code == 'execution_failed' ||
        error.code == 'execution_compensated';
  }

  Future<PendingFeatureExecution> _pendingFeatureExecution({
    required String userId,
    required String featureKey,
    required String payloadKey,
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

  Future<int> _loadCatalogRevision() async {
    final monetizationProvider = _monetizationProvider;
    if (monetizationProvider == null) {
      throw Exception('Монетизация недоступна');
    }
    await monetizationProvider.ensureLoaded();
    final revision = monetizationProvider.state?.catalogRevision ?? 0;
    if (revision < 1) {
      throw Exception('Каталог монетизации недоступен');
    }
    return revision;
  }

  FeatureExecutionApi _featureApi() {
    return _featureExecutionApi ?? di.get<FeatureExecutionApi>();
  }

  /// Получает инсайт для расклада карт таро
  ///
  /// [deckType] - тип колоды ('love_deck' или 'kelt_deck')
  ///
  /// Функция получает данные карт из UserProvider, формирует запрос к OpenAI API
  /// и сохраняет полученный interpretation в соответствующую модель пользователя
  Future<void> getDeckInsight(String deckType) async {
    try {
      final currentUser = _userProvider.currentUser;
      if (currentUser == null) {
        throw Exception('Пользователь не авторизован');
      }

      String interpretation;

      if (deckType == 'love_deck') {
        final loveDeckCards = currentUser.loveDeck?.loveDeckCards;
        if (loveDeckCards == null || loveDeckCards.isEmpty) {
          throw Exception('Карты любовного расклада не найдены');
        }

        final cardData = _buildLoveDeckCardData(loveDeckCards);
        interpretation = await _contentRepository.getLoveDeckInsight(cardData);
        final freshUser = _currentUserOrThrow();
        final loveDeck = freshUser.loveDeck ?? currentUser.loveDeck;

        await _userProvider.updateUser(
          freshUser.copyWith(
            loveDeck: loveDeck?.copyWith(interpretation: interpretation),
          ),
        );
      } else if (deckType == 'kelt_deck') {
        final keltDeckCards = currentUser.keltDeck?.keltDeckCards;
        if (keltDeckCards == null || keltDeckCards.isEmpty) {
          throw Exception('Карты кельтского расклада не найдены');
        }

        final cardData = _buildKeltDeckCardData(keltDeckCards);
        interpretation = await _contentRepository.getKeltDeckInsight(cardData);
        final freshUser = _currentUserOrThrow();
        final keltDeck = freshUser.keltDeck ?? currentUser.keltDeck;

        await _userProvider.updateUser(
          freshUser.copyWith(
            keltDeck: keltDeck?.copyWith(interpretation: interpretation),
          ),
        );
      } else {
        throw Exception('Неизвестный тип колоды: $deckType');
      }

      debugPrint('[DEBUG] Инсайт получен для $deckType');
    } catch (e) {
      debugPrint('[ERROR] Ошибка получения инсайта: $e');
      throw Exception('Ошибка получения инсайта: $e');
    }
  }

  /// Формирует данные карт для любовного расклада (6 карт)
  /// Возвращает `Map<String, String>` с названиями карт и их позициями
  Map<String, String> _buildLoveDeckCardData(Map<String, bool> loveDeckCards) {
    const loveDeckPositions = {
      0: 'Ты в отношениях',
      1: 'Партнёр в отношениях',
      2: 'Что объединяет',
      3: 'Что разделяет',
      4: 'Будущее отношений',
      5: 'Совет карт',
    };

    final cardIds = loveDeckCards.keys.toList();
    final cardNames = <String>[];

    for (int i = 0; i < 6; i++) {
      if (i < cardIds.length) {
        final card = _tarotCards.firstWhere(
          (c) => c.id == cardIds[i],
          orElse: () => _tarotCards.first,
        );
        cardNames.add(card.title);
      } else {
        cardNames.add('');
      }
    }

    return buildLoveDeckVariables(
      cardNameOne: cardNames[0],
      cardPositionOne: loveDeckPositions[0]!,
      cardNameTwo: cardNames[1],
      cardPositionTwo: loveDeckPositions[1]!,
      cardNameThree: cardNames[2],
      cardPositionThree: loveDeckPositions[2]!,
      cardNameFour: cardNames[3],
      cardPositionFour: loveDeckPositions[3]!,
      cardNameFive: cardNames[4],
      cardPositionFive: loveDeckPositions[4]!,
      cardNameSix: cardNames[5],
      cardPositionSix: loveDeckPositions[5]!,
    );
  }

  /// Формирует данные карт для кельтского расклада (10 карт)
  /// Возвращает `Map<String, String>` с названиями карт и их позициями
  Map<String, String> _buildKeltDeckCardData(Map<String, bool> keltDeckCards) {
    const keltDeckPositions = {
      0: 'Ситуация сейчас',
      1: 'Препятствие',
      2: 'Основа',
      3: 'Прошлое',
      4: 'Потенциал',
      5: 'Ближайшее будущее',
      6: 'Ты сам(а)',
      7: 'Окружение',
      8: 'Совет / предостережение',
      9: 'Итог / результат',
    };

    final cardIds = keltDeckCards.keys.toList();
    final cardNames = <String>[];

    for (int i = 0; i < 10; i++) {
      if (i < cardIds.length) {
        final card = _tarotCards.firstWhere(
          (c) => c.id == cardIds[i],
          orElse: () => _tarotCards.first,
        );
        cardNames.add(card.title);
      } else {
        cardNames.add('');
      }
    }

    return buildKeltDeckVariables(
      cardNameOne: cardNames[0],
      cardPositionOne: keltDeckPositions[0]!,
      cardNameTwo: cardNames[1],
      cardPositionTwo: keltDeckPositions[1]!,
      cardNameThree: cardNames[2],
      cardPositionThree: keltDeckPositions[2]!,
      cardNameFour: cardNames[3],
      cardPositionFour: keltDeckPositions[3]!,
      cardNameFive: cardNames[4],
      cardPositionFive: keltDeckPositions[4]!,
      cardNameSix: cardNames[5],
      cardPositionSix: keltDeckPositions[5]!,
      cardNameSeven: cardNames[6],
      cardPositionSeven: keltDeckPositions[6]!,
      cardNameEight: cardNames[7],
      cardPositionEight: keltDeckPositions[7]!,
      cardNameNine: cardNames[8],
      cardPositionNine: keltDeckPositions[8]!,
      cardNameTen: cardNames[9],
      cardPositionTen: keltDeckPositions[9]!,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _userProvider.removeListener(_onUserChanged);
    _localeService.removeListener(_onLocaleChanged);
    super.dispose();
  }

  // Функции для энергии дня

  /// Получает энергию дня для указанной даты
  /// Если для указанной даты нет энергии, возвращает null
  EnergyOfDayModel? getEnergyOfDayByDate(DateTime date) {
    try {
      // Нормализуем дату (убираем время, оставляем только день)
      final normalizedDate = DateTime(date.year, date.month, date.day);

      return _energyOfDay.firstWhere(
        (energy) {
          final energyDate = DateTime(
            energy.date.year,
            energy.date.month,
            energy.date.day,
          );
          return energyDate.isAtSameMomentAs(normalizedDate);
        },
        orElse: () => throw Exception(
          'Энергия дня для даты ${date.toIso8601String()} не найдена',
        ),
      );
    } catch (e) {
      debugPrint(
        '[WARNING] Энергия дня для даты ${date.toIso8601String()} не найдена: $e',
      );
      return null;
    }
  }

  /// Получает энергию дня для сегодня
  EnergyOfDayModel? getTodayEnergyOfDay() {
    return getEnergyOfDayByDate(DateTime.now());
  }

  // for debug
  void resetRuneAndTarotCards() {
    debugPrint('[DEBUG] Очищаем кэш!');
    final currentUser = _userProvider.currentUser;
    if (currentUser != null) {
      _userProvider.applyServerUserSnapshot(
        currentUser.copyWith(
          tarotCardOfDayItem: currentUser.tarotCardOfDayItem?.copyWith(
            isOpened: false,
          ),
          runeOfDayItem: currentUser.runeOfDayItem?.copyWith(isOpened: false),
        ),
      );
    }
    _cachedTodayRune = null;
    _cachedRuneDateKey = null;
    _cachedTodayTarotCard = null;
    _cachedTarotCardDateKey = null;
    _box.delete(KeysConst.tarotCardOfDayKey);
    _box.delete(KeysConst.runeOfDayKey);
    _box.delete(KeysConst.dailySymbolTarotOfDayKey);
    _box.delete(KeysConst.dailySymbolRuneOfDayKey);
    _box.delete('tarot_cards');
    _box.delete('runes');
    _box.delete('affirmations');
    notifyListeners();
  }
}

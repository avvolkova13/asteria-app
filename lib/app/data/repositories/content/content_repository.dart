import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/app/data/models/article/article_model.dart';
import 'package:asteria_app/app/data/models/energy_of_day/energy_of_day_model.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_day_model.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_month_model.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_week_model.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_year_model.dart';
import 'package:asteria_app/app/data/models/moon_phase/moon_phase_model.dart';
import 'package:asteria_app/app/data/models/natal_card/natal_card_model.dart';
import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/data/models/user/tarot_deck_model.dart';
import 'package:asteria_app/core/const/prompts_const.dart';
import 'package:asteria_app/core/services/api/backend_api.dart';
import 'package:asteria_app/core/services/api/open_ai_api.dart';
import 'package:asteria_app/core/services/content/content_version_service.dart';
import 'package:asteria_app/core/services/hive/hive_service.dart';
import 'package:asteria_app/core/routing/navigator_key.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/utils/horoscope_parsers/horoscope_parsers_index.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

abstract class ContentRepository {
  Future<void> refreshContentVersions();
  Future<List<TarotCardModel>> getTarotCards();
  Future<List<TarotCardModel>> getTarotCardsFromCache();
  Future<void> saveTarotCardsToCache(List<TarotCardModel> tarotCards);

  Future<List<RuneOfDayModel>> getRunes();
  Future<List<RuneOfDayModel>> getRunesFromCache();
  Future<void> saveRunesToCache(List<RuneOfDayModel> runes);

  Future<List<ArticleModel>> getArticles();
  Future<List<ArticleModel>> getArticlesFromCache();
  Future<void> saveArticlesToCache(List<ArticleModel> articles);

  Future<List<AffirmationModel>> getAffirmations();
  Future<List<AffirmationModel>> getAffirmationsFromCache();
  Future<void> saveAffirmationsToCache(List<AffirmationModel> affirmations);

  Future<MoonPhaseModel> getMoonPhase(
    int year,
    int month,
    int day,
    int hour,
    int minute,
    int timezoneOffsetMinutes,
    double lat,
    double lon,
  );

  Future<HoroscopeDayModel> getHoroscopeDay(
    String name,
    String birthDate,
    String birthTime,
    String dateNow,
    String dateTime,
    String planetsBirthdate,
    String planetsToday,
  );

  Future<HoroscopeWeekModel> getHoroscopeWeek(
    String name,
    String birthDate,
    String zodiac,
    String dateNow,
  );

  Future<HoroscopeMonthModel> getHoroscopeMonth(
    String name,
    String birthDate,
    String zodiac,
    String dateNow,
  );

  Future<HoroscopeYearModel> getHoroscopeYear(
    String name,
    String birthDate,
    String birthTime,
    String dateNow,
    String zodiac,
    String data,
  );

  Future<NatalCardModel> getNatalCard(
    String name,
    String birthdate,
    String birthtime,
    String fire,
    String earth,
    String air,
    String water,
    String city,
    String planetsBirthdate,
  );

  Future<String> getLoveDeckInsight(Map<String, String> cardData);
  Future<String> getKeltDeckInsight(Map<String, String> cardData);
  Future<InterpretationModel> getTarotDeckLayoutInsight(
    Map<String, String> cardData,
  );
  Future<String> getRuneDeckLayoutInsight(Map<String, String> variables);

  Future<List<EnergyOfDayModel>> getEnergyOfDay();
  Future<List<EnergyOfDayModel>> getEnergyOfDayFromCache();
  Future<void> saveEnergyOfDayToCache(List<EnergyOfDayModel> energyOfDay);
  Future<bool> shouldReloadEnergyOfDay();
}

class ContentRepositoryImpl implements ContentRepository {
  final OpenAiApi _openAiApi;
  final BackendApi _backendApi;
  final Box<Map>? _contentBox;
  final ContentVersionService _contentVersionService;
  final AppLocaleService _localeService;
  final LocalizedContentResolver _localizedContentResolver;

  ContentRepositoryImpl({
    required OpenAiApi openAiApi,
    required BackendApi backendApi,
    Box<Map>? contentBox,
    ContentVersionService? contentVersionService,
    Duration remoteContentTimeout = const Duration(seconds: 30),
    AppLocaleService? localeService,
    LocalizedContentResolver localizedContentResolver =
        const LocalizedContentResolver(),
  }) : _openAiApi = openAiApi,
       _backendApi = backendApi,
       _contentBox = contentBox,
       _localeService =
           localeService ??
           AppLocaleService(platformLocales: const <Locale>[Locale('ru')]),
       _localizedContentResolver = localizedContentResolver,
       _contentVersionService =
           contentVersionService ??
           ContentVersionService(api: backendApi, contentBox: contentBox);

  @override
  Future<void> refreshContentVersions() async {
    await _contentVersionService.refresh(localeTag: _localeService.languageTag);
  }

  void _showApiErrorSnackBar(String message) {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String _localizedKey(String key, [String? localeTag]) {
    final locale = localeTag ?? _localeService.languageTag;
    return locale == 'ru' ? key : '${key}_$locale';
  }

  Box<Map> get _box => _contentBox ?? HiveService.contentBox;

  static const _displayFields = <String, List<String>>{
    'affirmation': ['text'],
    'articles': ['title', 'category', 'intro', 'text', 'conclusion'],
    'energy_of_day': ['focus', 'risk', 'phrase'],
    'rune_of_day': [
      'title',
      'card_of_day_description',
      'general_description',
      'past_deck',
      'present_deck',
      'future_deck',
      'keywords',
      'definitions',
    ],
    'tarot_cards': [
      'title',
      'keywords',
      'card_of_day_description',
      'general_description',
      'short_description',
      'text_in_decks',
      'kelt_deck',
      'kelt_deck_impact',
      'love_deck',
    ],
  };

  static final _cyrillic = RegExp(r'[А-Яа-яЁё]');
  static final _latin = RegExp(r'[A-Za-z]');

  bool _looksRussian(Object? value) {
    if (value is Iterable) return value.any(_looksRussian);
    if (value is! String) return false;
    return _cyrillic.allMatches(value).length > _latin.allMatches(value).length;
  }

  Future<List<Map<String, dynamic>>> _getLocalizedCollection(
    String collection,
    String localeTag,
  ) async {
    final response = await _backendApi.getContentCollection(collection);
    final data = response.data;
    if (data is! List) {
      throw const FormatException('Invalid localized content response');
    }
    final isRussian = localeTag == 'ru';
    final documents = <Map<String, dynamic>>[];
    for (final item in data) {
      final resolved = _localizedContentResolver.resolveDocument(
        Map<String, dynamic>.from(item as Map),
        localeTag,
        allowRussianFallback: isRussian,
      );
      if (!isRussian &&
          _displayFields[collection]!.any(
            (field) => _looksRussian(resolved[field]),
          )) {
        continue;
      }
      documents.add(resolved);
    }
    return documents;
  }

  @override
  Future<List<TarotCardModel>> getTarotCards() async {
    final locale = _localeService.languageTag;
    try {
      if (_box.get(_localizedKey('tarot_cards', locale)) != null &&
          !_contentVersionService.isStale('tarot_cards', localeTag: locale)) {
        return await getTarotCardsFromCache(localeTag: locale);
      }
      final tarotData = await _getLocalizedCollection('tarot_cards', locale);

      debugPrint('[DEBUG] Карты таро c backend: ${tarotData.length}');

      List<TarotCardModel> tarotCards = tarotData
          .map(TarotCardModel.fromJson)
          .toList();
      // TODO: Remove this after testing
      // tarotCards = tarotCards.where((card) => card.sort == 0).toList();

      if (tarotCards.isEmpty) {
        throw Exception('Карты таро не найдены');
      }

      await saveTarotCardsToCache(tarotCards, localeTag: locale);
      await _contentVersionService.markCurrent(
        'tarot_cards',
        localeTag: locale,
      );

      return tarotCards..sort((a, b) => a.sort.compareTo(b.sort));
    } catch (e) {
      debugPrint('Ошибка получения карты таро: $e');
      final cached = await getTarotCardsFromCache(localeTag: locale);
      if (cached.isNotEmpty) return cached;
      throw Exception('Не удалось получить карту таро: $e');
    }
  }

  List<T> _getFromCache<T>({
    required String key,
    required String dataKey,
    required T Function(Map<String, dynamic>) fromJson,
    String debugName = 'данные',
  }) {
    try {
      final cachedData = _box.get(key);
      if (cachedData == null || cachedData[dataKey] == null) return [];

      final items = (cachedData[dataKey] as List<dynamic>).map((e) {
        return fromJson(Map<String, dynamic>.from(e as Map));
      }).toList();

      debugPrint('[DEBUG] $debugName из кеша получены: ${items.length}');
      return items;
    } catch (e) {
      debugPrint('[ERROR] Ошибка получения $debugName из кеша: $e');
      return [];
    }
  }

  Future<void> _saveToCache<T>({
    required String key,
    required String dataKey,
    required List<T> items,
    required Map<String, dynamic> Function(T) toJson,
    String debugName = 'данные',
  }) async {
    try {
      await _box.put(key, {dataKey: items.map(toJson).toList()});
      debugPrint('[DEBUG] $debugName сохранены в кеш: ${items.length}');
    } catch (e) {
      debugPrint('[ERROR] Ошибка сохранения $debugName в кеш: $e');
      rethrow;
    }
  }

  @override
  Future<List<TarotCardModel>> getTarotCardsFromCache({
    String? localeTag,
  }) async {
    final cards = _getFromCache<TarotCardModel>(
      key: _localizedKey('tarot_cards', localeTag),
      dataKey: 'cards',
      fromJson: TarotCardModel.fromJson,
      debugName: 'Карты таро',
    );
    return cards..sort((a, b) => a.sort.compareTo(b.sort));
  }

  @override
  Future<void> saveTarotCardsToCache(
    List<TarotCardModel> tarotCards, {
    String? localeTag,
  }) async {
    await _saveToCache(
      key: _localizedKey('tarot_cards', localeTag),
      dataKey: 'cards',
      items: tarotCards,
      toJson: (card) => card.toJson(),
      debugName: 'Карты таро',
    );
  }

  @override
  Future<List<RuneOfDayModel>> getRunes() async {
    final locale = _localeService.languageTag;
    try {
      if (_box.get(_localizedKey('runes', locale)) != null &&
          !_contentVersionService.isStale('rune_of_day', localeTag: locale)) {
        return await getRunesFromCache(localeTag: locale);
      }
      final runesData = await _getLocalizedCollection('rune_of_day', locale);
      debugPrint('[DEBUG] Руны c backend: ${runesData.length}');
      List<RuneOfDayModel> runes = runesData
          .map(RuneOfDayModel.fromJson)
          .toList();
      if (runes.isEmpty) {
        throw const FormatException('No runes for the selected locale');
      }
      await saveRunesToCache(runes, localeTag: locale);
      await _contentVersionService.markCurrent(
        'rune_of_day',
        localeTag: locale,
      );
      return runes;
    } catch (e) {
      debugPrint('Ошибка получения рун: $e');
      final cached = await getRunesFromCache(localeTag: locale);
      if (cached.isNotEmpty) return cached;
      throw Exception('Не удалось получить руны: $e');
    }
  }

  @override
  Future<List<RuneOfDayModel>> getRunesFromCache({String? localeTag}) async {
    return _getFromCache<RuneOfDayModel>(
      key: _localizedKey('runes', localeTag),
      dataKey: 'runes',
      fromJson: RuneOfDayModel.fromJson,
      debugName: 'Руны',
    );
  }

  @override
  Future<void> saveRunesToCache(
    List<RuneOfDayModel> runes, {
    String? localeTag,
  }) async {
    await _saveToCache(
      key: _localizedKey('runes', localeTag),
      dataKey: 'runes',
      items: runes,
      toJson: (rune) => rune.toJson(),
      debugName: 'Руны',
    );
  }

  @override
  Future<List<ArticleModel>> getArticles() async {
    final locale = _localeService.languageTag;
    try {
      if (_box.get(_localizedKey('articles', locale)) != null &&
          !_contentVersionService.isStale('articles', localeTag: locale)) {
        return await getArticlesFromCache(localeTag: locale);
      }
      final articlesData = await _getLocalizedCollection('articles', locale);
      debugPrint('[DEBUG] Статьи c backend: ${articlesData.length}');

      List<ArticleModel> articles = articlesData
          .map(ArticleModel.fromJson)
          .toList();

      if (articles.isEmpty) {
        throw Exception('Статьи не найдены');
      }

      await saveArticlesToCache(articles, localeTag: locale);
      await _contentVersionService.markCurrent('articles', localeTag: locale);

      return articles;
    } catch (e) {
      debugPrint('Ошибка получения статей: $e');
      final cached = await getArticlesFromCache(localeTag: locale);
      if (cached.isNotEmpty) return cached;
      throw Exception('Не удалось получить статьи: $e');
    }
  }

  @override
  Future<List<ArticleModel>> getArticlesFromCache({String? localeTag}) async {
    return _getFromCache<ArticleModel>(
      key: _localizedKey('articles', localeTag),
      dataKey: 'articles',
      fromJson: ArticleModel.fromJson,
      debugName: 'Статьи',
    );
  }

  @override
  Future<void> saveArticlesToCache(
    List<ArticleModel> articles, {
    String? localeTag,
  }) async {
    await _saveToCache(
      key: _localizedKey('articles', localeTag),
      dataKey: 'articles',
      items: articles,
      toJson: (article) => article.toJson(),
      debugName: 'Статьи',
    );
  }

  @override
  Future<List<AffirmationModel>> getAffirmations() async {
    final locale = _localeService.languageTag;
    try {
      if (_box.get(_localizedKey('affirmations', locale)) != null &&
          !_contentVersionService.isStale('affirmation', localeTag: locale)) {
        return await getAffirmationsFromCache(localeTag: locale);
      }
      final affirmationsData = await _getLocalizedCollection(
        'affirmation',
        locale,
      );
      debugPrint('[DEBUG] Аффирмации c backend: ${affirmationsData.length}');

      List<AffirmationModel> affirmations = affirmationsData
          .map(AffirmationModel.fromJson)
          .toList();

      if (affirmations.isEmpty) {
        throw Exception('Аффирмации не найдены');
      }

      await saveAffirmationsToCache(affirmations, localeTag: locale);
      await _contentVersionService.markCurrent(
        'affirmation',
        localeTag: locale,
      );

      return affirmations..sort((a, b) => a.sort.compareTo(b.sort));
    } catch (e) {
      debugPrint('Ошибка получения аффирмаций: $e');
      final cached = await getAffirmationsFromCache(localeTag: locale);
      if (cached.isNotEmpty) return cached;
      throw Exception('Не удалось получить аффирмации: $e');
    }
  }

  @override
  Future<List<AffirmationModel>> getAffirmationsFromCache({
    String? localeTag,
  }) async {
    final affirmations = _getFromCache<AffirmationModel>(
      key: _localizedKey('affirmations', localeTag),
      dataKey: 'affirmations',
      fromJson: AffirmationModel.fromJson,
      debugName: 'Аффирмации',
    );
    return affirmations..sort((a, b) => a.sort.compareTo(b.sort));
  }

  @override
  Future<void> saveAffirmationsToCache(
    List<AffirmationModel> affirmations, {
    String? localeTag,
  }) async {
    await _saveToCache(
      key: _localizedKey('affirmations', localeTag),
      dataKey: 'affirmations',
      items: affirmations,
      toJson: (affirmation) => affirmation.toJson(),
      debugName: 'Аффирмации',
    );
  }

  @override
  Future<HoroscopeDayModel> getHoroscopeDay(
    String name,
    String birthDate,
    String birthTime,
    String dateNow,
    String dateTime,
    String planetsBirthdate,
    String planetsToday,
  ) async {
    try {
      final jsonMap = await requestDayHoroscopeData(
        openAiApi: _openAiApi,
        language: _localeService.contentLanguage,
        variables: buildHoroscopeVariables(
          name: name,
          birthDate: birthDate,
          dateNow: dateNow,
          birthTime: birthTime,
          dateTime: dateTime,
          planetsBirthdate: planetsBirthdate,
          planetsToday: planetsToday,
        ),
      );
      final sanitizedJson = sanitizeDayHoroscopeJson(jsonMap);
      return HoroscopeDayModel.fromJson(sanitizedJson);
    } catch (e) {
      debugPrint('Ошибка получения дневного гороскопа: $e');
      _showApiErrorSnackBar('Ошибка получения гороскопа: $e');
      throw Exception('Не удалось получить дневного гороскопа: $e');
    }
  }

  @override
  Future<HoroscopeWeekModel> getHoroscopeWeek(
    String name,
    String birthDate,
    String zodiac,
    String dateNow,
  ) async {
    try {
      final jsonMap = await requestHoroscopeData(
        openAiApi: _openAiApi,
        promptId: PromptConst.horoscopeWeekPromptId,
        promptVersion: PromptConst.horoscopeWeekPromptVersion,
        language: _localeService.contentLanguage,
        variables: buildHoroscopeVariables(
          name: name,
          birthDate: birthDate,
          dateNow: dateNow,
          zodiac: zodiac,
        ),
      );
      final sanitizedJson = sanitizeWeekHoroscopeJson(jsonMap);
      return HoroscopeWeekModel.fromJson(sanitizedJson);
    } catch (e) {
      debugPrint('Ошибка получения недельного гороскопа: $e');
      _showApiErrorSnackBar('Ошибка получения гороскопа: $e');
      throw Exception('Не удалось получить недельный гороскоп: $e');
    }
  }

  @override
  Future<HoroscopeMonthModel> getHoroscopeMonth(
    String name,
    String birthDate,
    String zodiac,
    String dateNow,
  ) async {
    try {
      final jsonMap = await requestHoroscopeData(
        openAiApi: _openAiApi,
        promptId: PromptConst.horoscopeMonthPromptId,
        promptVersion: PromptConst.horoscopeMonthPromptVersion,
        language: _localeService.contentLanguage,
        variables: buildHoroscopeVariables(
          name: name,
          birthDate: birthDate,
          dateNow: dateNow,
          zodiac: zodiac,
        ),
      );
      final sanitizedJson = sanitizeMonthHoroscopeJson(jsonMap);
      return HoroscopeMonthModel.fromJson(sanitizedJson);
    } catch (e) {
      debugPrint('Ошибка получения месячного гороскопа: $e');
      _showApiErrorSnackBar('Ошибка получения гороскопа: $e');
      throw Exception('Не удалось получить месячный гороскоп: $e');
    }
  }

  @override
  Future<HoroscopeYearModel> getHoroscopeYear(
    String name,
    String birthDate,
    String birthTime,
    String dateNow,
    String zodiac,
    String data,
  ) async {
    try {
      final jsonMap = await requestHoroscopeData(
        openAiApi: _openAiApi,
        promptId: PromptConst.horoscopeYearPromptId,
        promptVersion: PromptConst.horoscopeYearPromptVersion,
        language: _localeService.contentLanguage,
        variables: buildHoroscopeVariables(
          name: name,
          birthDate: birthDate,
          dateNow: dateNow,
          birthTime: birthTime,
          zodiac: zodiac,
          data: data,
        ),
      );
      final sanitizedJson = sanitizeYearHoroscopeJson(jsonMap);
      return HoroscopeYearModel.fromJson(sanitizedJson);
    } catch (e) {
      debugPrint('Ошибка получения годового гороскопа: $e');
      _showApiErrorSnackBar('Ошибка получения гороскопа: $e');
      throw Exception('Не удалось получить годовой гороскоп: $e');
    }
  }

  @override
  Future<NatalCardModel> getNatalCard(
    String name,
    String birthdate,
    String birthtime,
    String fire,
    String earth,
    String air,
    String water,
    String city,
    String planetsBirthdate,
  ) async {
    try {
      final jsonMap = await requestNatalCardData(
        openAiApi: _openAiApi,
        language: _localeService.contentLanguage,
        variables: buildNatalCardVariables(
          name: name,
          birthdate: birthdate,
          birthtime: birthtime,
          fire: fire,
          earth: earth,
          air: air,
          water: water,
          city: city,
          planetsBirthdate: planetsBirthdate,
        ),
      );
      return NatalCardModel.fromJson(jsonMap);
    } catch (e) {
      debugPrint('Ошибка получения натальной карты: $e');
      _showApiErrorSnackBar('Ошибка получения натальной карты: $e');
      throw Exception('Не удалось получить натальную карту: $e');
    }
  }

  @override
  Future<MoonPhaseModel> getMoonPhase(
    int year,
    int month,
    int day,
    int hour,
    int minute,
    int timezoneOffsetMinutes,
    double lat,
    double lon,
  ) async {
    try {
      final response = await _backendApi.calculateMoonData(
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        timezoneOffsetMinutes: timezoneOffsetMinutes,
        lat: lat,
        lon: lon,
      );
      final responseData = response.data as Map<String, dynamic>;

      if (responseData['success'] == true && responseData['data'] != null) {
        return MoonPhaseModel.fromJson(
          responseData['data'] as Map<String, dynamic>,
        );
      } else {
        throw Exception('Неверный формат ответа от API');
      }
    } catch (e) {
      debugPrint('Ошибка получения фазы луны: $e');
      throw Exception('Не удалось получить фазу луны: $e');
    }
  }

  @override
  Future<String> getLoveDeckInsight(Map<String, String> cardData) async {
    try {
      final jsonMap = await requestHoroscopeData(
        openAiApi: _openAiApi,
        promptId: PromptConst.loveDeckInsightPromptId,
        promptVersion: PromptConst.loveDeckInsightPromptVersion,
        language: _localeService.contentLanguage,
        variables: cardData,
      );
      return jsonMap['interpretation'] as String;
    } catch (e) {
      debugPrint(
        '[ContentRepository] Love deck insight failed: ${e.runtimeType}',
      );
      rethrow;
    }
  }

  @override
  Future<String> getKeltDeckInsight(Map<String, String> cardData) async {
    try {
      final jsonMap = await requestHoroscopeData(
        openAiApi: _openAiApi,
        promptId: PromptConst.keltDeckInsightPromptId,
        promptVersion: PromptConst.keltDeckInsightPromptVersion,
        language: _localeService.contentLanguage,
        variables: cardData,
      );
      return jsonMap['interpretation'] as String;
    } catch (e) {
      debugPrint(
        '[ContentRepository] Celtic deck insight failed: ${e.runtimeType}',
      );
      rethrow;
    }
  }

  @override
  Future<InterpretationModel> getTarotDeckLayoutInsight(
    Map<String, String> cardData,
  ) async {
    try {
      final jsonMap = await requestHoroscopeData(
        openAiApi: _openAiApi,
        promptId: PromptConst.tarotDeckLayoutInsightPromptId,
        promptVersion: PromptConst.tarotDeckLayoutInsightPromptVersion,
        language: _localeService.contentLanguage,
        variables: cardData,
      );
      return InterpretationModel.fromApiResponse(jsonMap);
    } catch (e) {
      debugPrint('Ошибка получения инсайта расклада таро: $e');
      throw Exception('Не удалось получить инсайт расклада таро: $e');
    }
  }

  @override
  Future<String> getRuneDeckLayoutInsight(Map<String, String> variables) async {
    try {
      final jsonMap = await requestHoroscopeData(
        openAiApi: _openAiApi,
        promptId: PromptConst.runeDeckLayoutInsightPromptId,
        promptVersion: PromptConst.runeDeckLayoutInsightPromptVersion,
        language: _localeService.contentLanguage,
        variables: variables,
      );
      return jsonMap['interpretation'] as String;
    } catch (e) {
      debugPrint('Ошибка получения инсайта расклада рун: $e');
      throw Exception('Не удалось получить инсайт расклада рун: $e');
    }
  }

  @override
  Future<List<EnergyOfDayModel>> getEnergyOfDay() async {
    final locale = _localeService.languageTag;
    try {
      final energyData = await _getLocalizedCollection('energy_of_day', locale);
      debugPrint('[DEBUG] Энергии дня c backend: ${energyData.length}');

      List<EnergyOfDayModel> energyOfDay = energyData
          .map(EnergyOfDayModel.fromJson)
          .toList();

      if (energyOfDay.isEmpty) {
        throw Exception('Энергии дня не найдены');
      }

      await saveEnergyOfDayToCache(energyOfDay, localeTag: locale);
      await _contentVersionService.markCurrent(
        'energy_of_day',
        localeTag: locale,
      );

      return energyOfDay..sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      debugPrint('Ошибка получения энергии дня: $e');
      final cached = await getEnergyOfDayFromCache(localeTag: locale);
      if (cached.isNotEmpty) return cached;
      throw Exception('Не удалось получить энергию дня: $e');
    }
  }

  @override
  Future<List<EnergyOfDayModel>> getEnergyOfDayFromCache({
    String? localeTag,
  }) async {
    return _getFromCache<EnergyOfDayModel>(
      key: _localizedKey('energy_of_day', localeTag),
      dataKey: 'energies',
      fromJson: EnergyOfDayModel.fromJson,
      debugName: 'Энергии дня',
    );
  }

  @override
  Future<void> saveEnergyOfDayToCache(
    List<EnergyOfDayModel> energyOfDay, {
    String? localeTag,
  }) async {
    final locale = localeTag ?? _localeService.languageTag;
    try {
      if (energyOfDay.isEmpty) {
        debugPrint('[WARNING] Список энергий дня пуст, нечего сохранять');
        return;
      }

      // Находим самую позднюю дату
      DateTime? latestDate;
      for (final energy in energyOfDay) {
        if (latestDate == null || energy.date.isAfter(latestDate)) {
          latestDate = energy.date;
        }
      }

      // Сохраняем энергии дня
      await _saveToCache(
        key: _localizedKey('energy_of_day', locale),
        dataKey: 'energies',
        items: energyOfDay,
        toJson: (energy) => energy.toJson(),
        debugName: 'Энергии дня',
      );

      // Сохраняем самую позднюю дату
      if (latestDate != null) {
        await _box.put(_localizedKey('energy_of_day_last_date', locale), {
          'date': latestDate.toIso8601String(),
        });
        debugPrint(
          '[DEBUG] Сохранена самая поздняя дата энергии дня: ${latestDate.toIso8601String()}',
        );
      }
    } catch (e) {
      debugPrint('[ERROR] Ошибка сохранения энергии дня в кеш: $e');
      rethrow;
    }
  }

  @override
  Future<bool> shouldReloadEnergyOfDay() async {
    final locale = _localeService.languageTag;
    try {
      if (_contentVersionService.isStale('energy_of_day', localeTag: locale)) {
        return true;
      }
      final cachedData = _box.get(
        _localizedKey('energy_of_day_last_date', locale),
      );
      if (cachedData == null || cachedData['date'] == null) {
        debugPrint(
          '[DEBUG] Дата последней энергии дня не найдена, требуется загрузка',
        );
        return true;
      }

      final lastDateString = cachedData['date'] as String?;
      if (lastDateString == null) {
        debugPrint('[DEBUG] Дата в кэше пуста, требуется загрузка');
        return true;
      }
      final lastDate = DateTime.parse(lastDateString);
      final now = DateTime.now();
      final daysUntilLastDate = lastDate.difference(now).inDays;

      debugPrint(
        '[DEBUG] Дней до последней даты энергии дня: $daysUntilLastDate',
      );

      // Если до последней даты осталось меньше 3 дней - нужно перезагрузить
      if (daysUntilLastDate < 3) {
        debugPrint(
          '[DEBUG] Требуется перезагрузка энергии дня (осталось дней: $daysUntilLastDate)',
        );
        return true;
      }

      return false;
    } catch (e) {
      debugPrint(
        '[ERROR] Ошибка проверки необходимости перезагрузки энергии дня: $e',
      );
      // В случае ошибки лучше перезагрузить
      return true;
    }
  }
}

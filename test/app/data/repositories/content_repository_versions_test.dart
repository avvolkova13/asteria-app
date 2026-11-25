import 'dart:async';

import 'package:asteria_app/app/data/repositories/content/content_repository.dart';
import 'package:asteria_app/core/localization/app_locale_service.dart';
import 'package:asteria_app/core/services/api/backend_api.dart';
import 'package:asteria_app/core/services/api/open_ai_api.dart';
import 'package:asteria_app/core/services/content/content_version_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'stale version downloads, validates and marks new cache current',
    () async {
      final box = _FakeBox({
        'tarot_cards': {
          'cards': [_tarotJson('old', 'Старая карта')],
        },
        'content_collection_versions': {'tarot_cards': 1},
      });
      final api = _FakeFunctionsApi(
        {'tarot_cards': 2},
        contentDocuments: [_tarotJson('new', 'Новая карта')],
      );
      final versions = ContentVersionService(api: api, contentBox: box);
      final repository = _repository(box, api, versions);

      await repository.refreshContentVersions();
      final cards = await repository.getTarotCards();

      expect(api.versionCalls, 1);
      expect(api.contentCalls, 1);
      expect(cards.single.id, 'new');
      expect(
        box.storedValues['content_collection_versions'],
        containsPair('tarot_cards', 2),
      );
    },
  );

  test(
    'offline fallback keeps old cache and does not advance local version',
    () async {
      final box = _FakeBox({
        'tarot_cards': {
          'cards': [_tarotJson('old', 'Старая карта')],
        },
        'content_collection_versions': {'tarot_cards': 1},
      });
      final api = _FakeFunctionsApi({'tarot_cards': 2}, failContent: true);
      final versions = ContentVersionService(api: api, contentBox: box);
      final repository = _repository(box, api, versions);

      await repository.refreshContentVersions();
      final cards = await repository.getTarotCards();

      expect(cards.single.id, 'old');
      expect(
        box.storedValues['content_collection_versions'],
        containsPair('tarot_cards', 1),
      );
    },
  );

  test('version timeout does not block cached content', () async {
    final box = _FakeBox({
      'tarot_cards': {
        'cards': [_tarotJson('cached', 'Кэшированная карта')],
      },
      'content_collection_versions': {'tarot_cards': 1},
    });
    final api = _FakeFunctionsApi(
      const {},
      versionResponse: Completer<Response<dynamic>>().future,
    );
    final versions = ContentVersionService(
      api: api,
      contentBox: box,
      refreshTimeout: const Duration(milliseconds: 1),
    );
    final repository = _repository(box, api, versions);

    await repository.refreshContentVersions();
    final cards = await repository.getTarotCards();

    expect(cards.single.id, 'cached');
    expect(
      box.storedValues['content_collection_versions'],
      containsPair('tarot_cards', 1),
    );
  });

  test(
    'an in-flight Russian response does not populate the English cache',
    () async {
      final locale = AppLocaleService(platformLocales: const [Locale('ru')]);
      addTearDown(locale.dispose);
      final box = _FakeBox({});
      final pending = Completer<List<Map<String, dynamic>>>();
      final api = _FakeFunctionsApi({
        'tarot_cards': 2,
      }, contentResponse: pending.future);
      final versions = ContentVersionService(api: api, contentBox: box);
      final repository = _repository(box, api, versions, localeService: locale);

      await repository.refreshContentVersions();
      final russian = repository.getTarotCards();
      locale.updatePlatformLocales(const [Locale('en', 'US')]);
      pending.complete([_tarotJson('fool', 'Шут')]);

      expect((await russian).single.title, 'Шут');
      expect(await repository.getTarotCardsFromCache(), isEmpty);
      expect(
        box.storedValues['content_collection_versions'],
        containsPair('tarot_cards', 2),
      );
      expect(
        box.storedValues,
        isNot(contains('content_collection_versions_en-US')),
      );
    },
  );

  test(
    'English regional content and versions retain separate cache keys',
    () async {
      final locale = AppLocaleService(
        platformLocales: const [Locale('en', 'US')],
      );
      addTearDown(locale.dispose);
      final box = _FakeBox({});
      final card = _tarotJson('world', 'Мир')
        ..['i18n'] = {
          'title': {'en-US': 'Color', 'en-GB': 'Colour'},
        };
      final api = _FakeFunctionsApi(
        {'tarot_cards': 2},
        contentDocuments: [card],
      );
      final versions = ContentVersionService(api: api, contentBox: box);
      final repository = _repository(box, api, versions, localeService: locale);

      await repository.refreshContentVersions();
      expect((await repository.getTarotCards()).single.title, 'Color');
      locale.updatePlatformLocales(const [Locale('en', 'GB')]);
      await repository.refreshContentVersions();
      expect((await repository.getTarotCards()).single.title, 'Colour');
      locale.updatePlatformLocales(const [Locale('en', 'US')]);

      expect((await repository.getTarotCardsFromCache()).single.title, 'Color');
      expect(api.contentCalls, 2);
      expect(
        box.storedValues.keys,
        containsAll([
          'tarot_cards_en-US',
          'tarot_cards_en-GB',
          'content_collection_versions_en-US',
          'content_collection_versions_en-GB',
        ]),
      );
    },
  );

  test(
    'English catalog keeps English values and skips Russian-only entries',
    () async {
      final locale = AppLocaleService(
        platformLocales: const [Locale('en', 'US')],
      );
      addTearDown(locale.dispose);
      final box = _FakeBox({});
      final card = _tarotJson('fool', 'The Fool')
        ..['i18n'] = {
          'title': {'ru': 'Шут'},
        };
      final api = _FakeFunctionsApi(
        {},
        contentDocuments: [card, _tarotJson('moon', 'Луна')],
      );
      final versions = ContentVersionService(api: api, contentBox: box);
      final repository = _repository(box, api, versions, localeService: locale);

      expect((await repository.getTarotCards()).single.title, 'The Fool');
      expect((await repository.getTarotCardsFromCache()).single.id, 'fool');
    },
  );
}

ContentRepositoryImpl _repository(
  Box<Map> box,
  _FakeFunctionsApi api,
  ContentVersionService versions, {
  AppLocaleService? localeService,
}) {
  return ContentRepositoryImpl(
    openAiApi: OpenAiApi(api),
    backendApi: api,
    contentVersionService: versions,
    localeService: localeService,
    contentBox: box,
  );
}

Map<String, dynamic> _tarotJson(String id, String title) => {
  'id': id,
  'title': title,
  'image_name': 'card.png',
  'sort': 1,
  'keywords': <String>[],
  'card_of_day_description': '',
  'general_description': '',
  'short_description': '',
  'text_in_decks': <String>[],
  'kelt_deck': <String>[],
  'kelt_deck_impact': <String>[],
  'love_deck': <String>[],
};

class _FakeFunctionsApi implements BackendApi {
  _FakeFunctionsApi(
    this.versions, {
    this.versionResponse,
    this.contentDocuments = const [],
    this.contentResponse,
    this.failContent = false,
  });

  final Map<String, int> versions;
  final Future<Response<dynamic>>? versionResponse;
  final List<Map<String, dynamic>> contentDocuments;
  final Future<List<Map<String, dynamic>>>? contentResponse;
  final bool failContent;
  int versionCalls = 0;
  int contentCalls = 0;

  @override
  Future<Response<dynamic>> getContentVersions() async {
    versionCalls++;
    if (versionResponse != null) return versionResponse!;
    return Response<dynamic>(
      data: versions,
      requestOptions: RequestOptions(path: '/api/v1/content/versions'),
    );
  }

  @override
  Future<Response<dynamic>> getContentCollection(String collection) async {
    contentCalls++;
    if (failContent) throw Exception('offline');
    return Response<dynamic>(
      data: contentResponse == null ? contentDocuments : await contentResponse,
      requestOptions: RequestOptions(path: '/api/v1/$collection'),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBox implements Box<Map> {
  _FakeBox(this.storedValues);

  final Map<String, Map> storedValues;

  @override
  Map? get(dynamic key, {Map? defaultValue}) =>
      storedValues[key] ?? defaultValue;

  @override
  Future<void> put(dynamic key, Map value) async {
    storedValues[key as String] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

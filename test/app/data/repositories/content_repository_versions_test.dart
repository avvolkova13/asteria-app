import 'dart:async';

import 'package:asteria_app/app/data/repositories/content/content_repository.dart';
import 'package:asteria_app/core/services/api/backend_api.dart';
import 'package:asteria_app/core/services/api/open_ai_api.dart';
import 'package:asteria_app/core/services/content/content_version_service.dart';
import 'package:dio/dio.dart';
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
}

ContentRepositoryImpl _repository(
  Box<Map> box,
  _FakeFunctionsApi api,
  ContentVersionService versions,
) {
  return ContentRepositoryImpl(
    openAiApi: OpenAiApi(api),
    backendApi: api,
    contentVersionService: versions,
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
    this.failContent = false,
  });

  final Map<String, int> versions;
  final Future<Response<dynamic>>? versionResponse;
  final List<Map<String, dynamic>> contentDocuments;
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
      data: contentDocuments,
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

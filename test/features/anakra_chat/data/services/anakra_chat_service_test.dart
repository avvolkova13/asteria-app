import 'package:asteria_app/core/services/api/backend_api.dart';
import 'package:asteria_app/features/anakra_chat/data/services/anakra_chat_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds temporal grounding and preserves the request contract', () async {
    final api = _FakeBackendApi();
    final service = AnakraChatService(
      api,
      now: () => DateTime.utc(2026, 7, 27, 10, 30),
    );
    final history = <Map<String, dynamic>>[
      {'role': 'user', 'content': 'Расскажи о моей карте'},
      {'role': 'assistant', 'content': 'Я вытянула Звезду'},
    ];

    final result = await service.sendMessage(
      message: 'А ближайший день силы?',
      conversationHistory: history,
      userName: 'Анна',
      zodiac: 'Лев',
    );

    expect(result, 'Ответ Анакры');
    expect(api.path, 'v1/chat/completions');
    expect(api.data?['model'], 'gpt-4o-mini');
    expect(api.data?['temperature'], 0.7);
    expect(api.data?['max_tokens'], 1000);

    final messages = api.data?['messages'] as List<dynamic>;
    final systemMessage = messages.first as Map<String, dynamic>;
    expect(systemMessage['role'], 'system');
    final systemContent = systemMessage['content'] as String;
    expect(systemContent, contains('2026-07-27 10:30 (UTC+00:00)'));
    expect(
      systemContent,
      contains('«сегодня», «завтра», «ближайший», «следующий»'),
    );
    expect(systemContent, contains('не называй уже прошедшую дату'));
    expect(systemContent, contains('всегда указывай год явно'));
    expect(systemContent, contains('Внутренние знания модели'));
    expect(systemContent, contains('не называй дату даже приблизительно'));
    expect(
      systemContent,
      contains('точный расчёт по имеющимся данным недоступен'),
    );
    expect(systemContent, contains('Имя: Анна'));
    expect(systemContent, contains('Знак зодиака: Лев'));
    expect(messages.sublist(1, 3), history);
    expect(messages.last, {
      'role': 'user',
      'content': 'А ближайший день силы?',
    });
  });
}

class _FakeBackendApi implements BackendApi {
  String? path;
  Map<String, dynamic>? data;

  @override
  Future<Response<dynamic>> openaiPost({
    required String path,
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
  }) async {
    this.path = path;
    this.data = data;

    return Response<dynamic>(
      data: {
        'choices': [
          {
            'message': {'content': ' Ответ Анакры '},
          },
        ],
      },
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

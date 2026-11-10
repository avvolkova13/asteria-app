import 'package:asteria_app/app/data/models/prompt_request.dart';
import 'package:asteria_app/core/services/api/backend_api.dart';
import 'package:asteria_app/core/services/api/open_ai_api.dart';
import 'package:asteria_app/core/utils/horoscope_parsers/horoscope_request_helper.dart';
import 'package:asteria_app/core/utils/horoscope_parsers/horoscope_variables_builder.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'OpenAiApi preserves prompt variables and sends language instructions',
    () async {
      final functionsApi = _RecordingFunctionsApi();
      final api = OpenAiApi(functionsApi);

      await api.generateFromReusablePrompt(
        const PromptRequest(
          id: 'prompt-id',
          version: '3',
          variables: <String, dynamic>{'name': 'Anna', 'data': 'Dream'},
          instructions: 'Write every narrative field only in US English.',
        ),
      );

      expect(functionsApi.data, <String, dynamic>{
        'prompt': <String, dynamic>{
          'id': 'prompt-id',
          'version': '3',
          'variables': <String, dynamic>{'name': 'Anna', 'data': 'Dream'},
        },
        'instructions': 'Write every narrative field only in US English.',
      });
    },
  );

  test('AI output language instructions are explicit for EN and RU', () {
    expect(
      buildAiOutputLanguageInstructions('en'),
      contains('only in US English'),
    );
    expect(
      buildAiOutputLanguageInstructions('ru'),
      contains('только на русском языке'),
    );
  });

  test('natal card instructions ground interpretations in calculated data', () {
    final instructions = buildNatalCardInstructions('ru');

    expect(instructions, contains('профессиональный астролог'));
    expect(instructions, contains('расчетные данные'));
    expect(instructions, contains('Не пересчитывай'));
    expect(instructions, contains('Солнце в Козероге в 3 доме'));
    expect(instructions, isNot(contains('медицин')));
    expect(instructions, isNot(contains('юрид')));
  });

  test(
    'natal card uses direct Responses schema with calculated context',
    () async {
      final functionsApi = _RecordingFunctionsApi(
        responseText:
            '{"source_language":"ru","interpretations":{"ru":{"personality":"Личность","intellectual_area":"Ум","love_area":"Любовь","talent_area":"Талант","energy_area":"Энергия","inside_area":"Внутри","final_conclusion":"Итог"}}}',
      );
      final api = OpenAiApi(functionsApi);

      final json = await requestNatalCardData(
        openAiApi: api,
        language: 'ru',
        variables: buildNatalCardVariables(
          name: 'Антон',
          birthdate: '2000-08-19',
          birthtime: '12:45',
          fire: '5',
          earth: '3',
          air: '6',
          water: '2',
          city: 'Калининск',
          planetsBirthdate: 'Солнце - Лев - 10, Луна - Овен - 5',
        ),
      );

      expect(json['interpretations']['ru']['final_conclusion'], 'Итог');
      expect(functionsApi.openaiPostPath, 'v1/responses');
      expect(functionsApi.openaiPostData, isNot(contains('prompt')));
      expect(functionsApi.openaiPostData?['model'], 'gpt-4o-mini');
      expect(
        functionsApi.openaiPostData?['input'],
        contains('Солнце - Лев - 10, Луна - Овен - 5'),
      );
      expect(
        functionsApi.openaiPostData?['instructions'],
        contains('расчетные данные'),
      );
      expect(
        functionsApi.openaiPostData?['text']['format']['type'],
        'json_schema',
      );
      expect(
        functionsApi.openaiPostData?['text']['format']['schema']['required'],
        contains('interpretations'),
      );
    },
  );

  test(
    'day horoscope uses direct Responses schema with calculated context',
    () async {
      final functionsApi = _RecordingFunctionsApi(responseText: _dayJsonText);
      final api = OpenAiApi(functionsApi);

      final json = await requestDayHoroscopeData(
        openAiApi: api,
        language: 'ru',
        variables: buildHoroscopeVariables(
          name: 'Антон',
          birthDate: '2000-01-01',
          birthTime: '12:00',
          dateNow: '2026-09-07',
          dateTime: '2026-09-07T15:19:11+03:00',
          planetsBirthdate: 'Солнце - Козерог - 9, Луна - Скорпион - 7',
          planetsToday: 'Солнце - Дева - 6, Луна - Рыбы - 12',
        ),
      );

      expect(json['spotlight'], 'Сфокусируйся на одном важном разговоре.');
      expect(functionsApi.openaiPostPath, 'v1/responses');
      expect(functionsApi.openaiPostData, isNot(contains('prompt')));
      expect(functionsApi.openaiPostData?['model'], 'gpt-4o-mini');
      expect(
        functionsApi.openaiPostData?['input'],
        contains('Солнце - Козерог - 9, Луна - Скорпион - 7'),
      );
      expect(
        functionsApi.openaiPostData?['input'],
        contains('Солнце - Дева - 6, Луна - Рыбы - 12'),
      );
      expect(
        functionsApi.openaiPostData?['text']['format']['type'],
        'json_schema',
      );
      expect(
        functionsApi.openaiPostData?['text']['format']['schema']['required'],
        contains('spotlight'),
      );
    },
  );

  test('buildNatalCardVariables carries rich calculated natal context', () {
    final variables = buildNatalCardVariables(
      name: 'Диагностика',
      birthdate: '2000-12-23',
      birthtime: '02:00',
      fire: '5',
      earth: '4',
      air: '6',
      water: '2',
      city: 'Шымкент',
      planetsBirthdate: 'Солнце - Козерог - 3',
      calculationContext:
          'Место рождения: Шымкент\nЧасовой пояс места рождения: Asia/Almaty (UTC+6)',
    );

    expect(variables['planets_birthdate'], contains('Солнце - Козерог - 3'));
    expect(variables['planets_birthdate'], contains('Место рождения: Шымкент'));
    expect(
      variables['planets_birthdate'],
      contains('Часовой пояс места рождения: Asia/Almaty (UTC+6)'),
    );
  });

  test('persisted AI content is rejected when its language is stale', () {
    final english = <String, Object>{
      'title': 'Emotions and inner world',
      'items': <String>['Long walks', 'Yoga'],
    };
    final russian = <String, Object>{
      'title': 'Эмоции и внутренний мир',
      'items': <String>['Долгие прогулки', 'Йога'],
    };

    expect(isAiContentLocalized(english, 'en'), isTrue);
    expect(isAiContentLocalized(russian, 'en'), isFalse);
    expect(isAiContentLocalized(russian, 'ru'), isTrue);
    expect(isAiContentLocalized(english, 'ru'), isFalse);
  });

  test('love deck variables match the published prompt contract', () {
    final variables = buildLoveDeckVariables(
      cardNameOne: 'One',
      cardPositionOne: 'Position one',
      cardNameTwo: 'Two',
      cardPositionTwo: 'Position two',
      cardNameThree: 'Three',
      cardPositionThree: 'Position three',
      cardNameFour: 'Four',
      cardPositionFour: 'Position four',
      cardNameFive: 'Five',
      cardPositionFive: 'Position five',
      cardNameSix: 'Six',
      cardPositionSix: 'Position six',
    );

    expect(
      variables.keys,
      unorderedEquals(<String>[
        'card_name_one',
        'card_position_one',
        'card_name_two',
        'card_position_two',
        'card_name_three',
        'card_position_three',
        'card_name_four',
        'card_position_four',
        'card_name_five',
        'card_position_five',
        'card_name_six',
        'card_position_six',
      ]),
    );
  });

  test('rune spread variables match the published prompt contract', () {
    final variables = buildRuneDeckLayoutVariables(
      firstRuneName: 'Fehu',
      firstRuneMeaning: 'Resources',
      secondRuneName: 'Raidho',
      secondRuneMeaning: 'Movement',
      thirdRuneName: 'Gebo',
      thirdRuneMeaning: 'Partnership',
    );

    expect(
      variables.keys,
      unorderedEquals(<String>[
        'first_rune_name',
        'first_rune_meaning',
        'second_rune_name',
        'second_rune_meaning',
        'third_rune_name',
        'third_rune_meaning',
      ]),
    );
  });
}

const _dayJsonText = '''
{
  "focus": "Разговор",
  "risk": "Спешка",
  "personal_area": {
    "key_theme": "Собранность",
    "theme_title": "Личный фокус",
    "description": "Держи темп ровным."
  },
  "personal_weak_points": [
    {"title": "Импульсивность", "description": "Не отвечай слишком резко."}
  ],
  "personal_area_persentage": "72%",
  "love_area": {
    "key_theme": "Честность",
    "theme_title": "Отношения",
    "description": "Говори проще."
  },
  "love_weak_points": [
    {"title": "Недосказанность", "description": "Уточняй ожидания."}
  ],
  "love_area_persentage": "66%",
  "finance_area": {
    "key_theme": "План",
    "theme_title": "Финансы",
    "description": "Проверь обязательства."
  },
  "finance_weak_points": [
    {"title": "Покупки на эмоциях", "description": "Возьми паузу."}
  ],
  "finance_area_persentage": "58%",
  "spotlight": "Сфокусируйся на одном важном разговоре."
}
''';

class _RecordingFunctionsApi implements BackendApi {
  _RecordingFunctionsApi({this.responseText});

  final String? responseText;
  Map<String, dynamic>? data;
  Map<String, dynamic>? openaiPostData;
  String? openaiPostPath;

  @override
  Future<Response<dynamic>> openaiGenerateResponse({
    required Map<String, dynamic> data,
  }) async {
    this.data = data;
    return Response<dynamic>(
      data: const <String, dynamic>{},
      requestOptions: RequestOptions(path: '/openai-generate-response'),
    );
  }

  @override
  Future<Response<dynamic>> openaiPost({
    required String path,
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
  }) async {
    openaiPostPath = path;
    openaiPostData = data;
    return Response<dynamic>(
      statusCode: 200,
      data: <String, dynamic>{
        'id': 'resp_test',
        'object': 'response',
        'created_at': 0,
        'status': 'completed',
        'output': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'msg_test',
            'type': 'message',
            'status': 'completed',
            'role': 'assistant',
            'content': <Map<String, dynamic>>[
              <String, dynamic>{
                'type': 'output_text',
                'text': responseText ?? '{}',
              },
            ],
          },
        ],
      },
      requestOptions: RequestOptions(path: '/openai-post'),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

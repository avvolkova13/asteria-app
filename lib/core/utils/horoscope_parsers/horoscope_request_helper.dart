import 'package:asteria_app/app/data/models/prompt_request.dart';
import 'package:asteria_app/app/data/models/prompt_response.dart';
import 'package:asteria_app/core/services/api/open_ai_api.dart';
import 'package:asteria_app/core/utils/horoscope_parsers/horoscope_api_exception.dart';
import 'package:asteria_app/core/utils/horoscope_parsers/horoscope_json_parser.dart';
import 'package:asteria_app/core/utils/horoscope_parsers/horoscope_variables_builder.dart';
import 'package:flutter/foundation.dart';

String buildAiOutputLanguageInstructions(String language) {
  if (language == 'en') {
    return 'Write every generated natural-language value only in US English. '
        'Translate all titles, labels, recommendations, descriptions, card and '
        'astrology interpretations into English. Keep the required JSON keys '
        'and response structure unchanged. Do not output Cyrillic text unless '
        'it is part of a user-provided proper name.';
  }
  return 'Пиши все сгенерированные текстовые значения только на русском языке. '
      'Сохраняй обязательные JSON-ключи и структуру ответа без изменений.';
}

/// Detects whether persisted AI content matches the currently selected base
/// language. Legacy records do not contain a locale marker, so the client must
/// not render an obviously Russian result inside an English UI (or vice versa).
bool isAiContentLocalized(Object? content, String language) {
  final textValues = <String>[];

  void collect(Object? value) {
    switch (value) {
      case String():
        textValues.add(value);
      case Map():
        for (final nestedValue in value.values) {
          collect(nestedValue);
        }
      case Iterable():
        for (final nestedValue in value) {
          collect(nestedValue);
        }
    }
  }

  collect(content);
  final text = textValues.join(' ');
  final cyrillicCount = RegExp(r'[А-Яа-яЁё]').allMatches(text).length;
  final latinCount = RegExp(r'[A-Za-z]').allMatches(text).length;

  if (cyrillicCount == 0 && latinCount == 0) return true;
  if (language == 'ru') return cyrillicCount > latinCount;
  return cyrillicCount == 0;
}

Future<Map<String, dynamic>> requestHoroscopeData({
  required OpenAiApi openAiApi,
  required String promptId,
  required String promptVersion,
  required Map<String, String> variables,
  required String language,
  String? additionalInstructions,
}) async {
  final instructions = [
    buildAiOutputLanguageInstructions(language),
    if (additionalInstructions != null &&
        additionalInstructions.trim().isNotEmpty)
      additionalInstructions.trim(),
  ].join('\n\n');
  final promptRequest = PromptRequest(
    id: promptId,
    version: promptVersion,
    variables: variables,
    instructions: instructions,
  );
  final response = await openAiApi.generateFromReusablePrompt(promptRequest);

  if (response.statusCode != 200) {
    debugPrint('❌ Ошибка API: ${response.statusCode}');
    throw HoroscopeApiException(
      'Ошибка API: ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }

  debugPrint('✅ Ответ от OpenAI API: ${response.data.toString()}');

  debugPrint('✅ Получен успешный ответ от OpenAI API');
  final responseData = response.data as Map<String, dynamic>;
  final promptResponse = PromptResponse.fromJson(responseData);
  final rawText = promptResponse.responseText;

  if (rawText == null || rawText.isEmpty) {
    throw HoroscopeApiException('Пустой ответ от сервиса гороскопов');
  }

  try {
    return parseHoroscopeJson(rawText);
  } catch (e) {
    throw HoroscopeApiException('Ошибка парсинга JSON гороскопа: $e');
  }
}

Future<Map<String, dynamic>> requestNatalCardData({
  required OpenAiApi openAiApi,
  required Map<String, String> variables,
  required String language,
}) async {
  final input = language == 'en'
      ? '''
User:
Name: ${variables['name'] ?? ''}
Birth date: ${variables['birthdate'] ?? ''}
Birth time: ${variables['birthtime'] ?? ''}
Birth city: ${variables['city'] ?? ''}

Calculated natal context:
${variables['planets_birthdate'] ?? ''}
'''
      : '''
Пользователь:
Имя: ${variables['name'] ?? ''}
Дата рождения: ${variables['birthdate'] ?? ''}
Время рождения: ${variables['birthtime'] ?? ''}
Место рождения: ${variables['city'] ?? ''}

Расчетный контекст натальной карты:
${variables['planets_birthdate'] ?? ''}
''';

  final response = await openAiApi.post(
    'v1/responses',
    data: <String, dynamic>{
      'model': 'gpt-4o-mini',
      'instructions': [
        buildAiOutputLanguageInstructions(language),
        buildNatalCardInstructions(language),
        if (language == 'en')
          'Return only JSON that matches the provided schema.'
        else
          'Верни только JSON, соответствующий переданной схеме.',
      ].join('\n\n'),
      'input': input,
      'text': <String, dynamic>{
        'format': <String, dynamic>{
          'type': 'json_schema',
          'name': 'asteria_natal_card',
          'strict': true,
          'schema': _natalCardJsonSchema(language),
        },
      },
      'store': false,
      'temperature': 0.4,
      'max_output_tokens': 12000,
    },
  );

  if (response.statusCode != 200) {
    throw HoroscopeApiException(
      'Ошибка API: ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }

  final responseData = response.data as Map<String, dynamic>;
  final promptResponse = PromptResponse.fromJson(responseData);
  final rawText = promptResponse.responseText;
  if (rawText == null || rawText.isEmpty) {
    throw HoroscopeApiException('Пустой ответ от сервиса натальной карты');
  }

  try {
    return parseHoroscopeJson(rawText);
  } catch (e) {
    throw HoroscopeApiException('Ошибка парсинга JSON натальной карты: $e');
  }
}

Future<Map<String, dynamic>> requestDayHoroscopeData({
  required OpenAiApi openAiApi,
  required Map<String, String> variables,
  required String language,
}) async {
  final input = language == 'en'
      ? '''
User:
Name: ${variables['name'] ?? ''}
Birth date: ${variables['birthdate'] ?? ''}
Birth time: ${variables['birthtime'] ?? ''}
Current date: ${variables['date_now'] ?? ''}
Current date-time: ${variables['date_time'] ?? ''}

Calculated natal context:
${variables['planets_birthdate'] ?? ''}

Current astrological context:
${variables['planets_today'] ?? ''}
'''
      : '''
Пользователь:
Имя: ${variables['name'] ?? ''}
Дата рождения: ${variables['birthdate'] ?? ''}
Время рождения: ${variables['birthtime'] ?? ''}
Текущая дата: ${variables['date_now'] ?? ''}
Текущие дата и время: ${variables['date_time'] ?? ''}

Расчетный натальный контекст:
${variables['planets_birthdate'] ?? ''}

Текущий астрологический контекст:
${variables['planets_today'] ?? ''}
''';

  final response = await openAiApi.post(
    'v1/responses',
    data: <String, dynamic>{
      'model': 'gpt-4o-mini',
      'instructions': [
        buildAiOutputLanguageInstructions(language),
        buildDayHoroscopeInstructions(language),
        if (language == 'en')
          'Return only JSON that matches the provided schema.'
        else
          'Верни только JSON, соответствующий переданной схеме.',
      ].join('\n\n'),
      'input': input,
      'text': <String, dynamic>{
        'format': <String, dynamic>{
          'type': 'json_schema',
          'name': 'asteria_day_horoscope',
          'strict': true,
          'schema': _dayHoroscopeJsonSchema(),
        },
      },
      'store': false,
      'temperature': 0.4,
      'max_output_tokens': 12000,
    },
  );

  if (response.statusCode != 200) {
    throw HoroscopeApiException(
      'Ошибка API: ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }

  final responseData = response.data as Map<String, dynamic>;
  final promptResponse = PromptResponse.fromJson(responseData);
  final rawText = promptResponse.responseText;
  if (rawText == null || rawText.isEmpty) {
    throw HoroscopeApiException('Пустой ответ от сервиса гороскопов');
  }

  try {
    return parseHoroscopeJson(rawText);
  } catch (e) {
    throw HoroscopeApiException('Ошибка парсинга JSON гороскопа: $e');
  }
}

String buildDayHoroscopeInstructions(String language) {
  if (language == 'en') {
    return 'You are a professional astrologer. Create a concise personal daily '
        'horoscope grounded only in the provided natal and current astrological '
        'contexts. Do not recalculate planetary positions. Avoid medical, legal, '
        'financial, or deterministic predictions. Keep each field practical, '
        'specific, and suitable for a mobile app card.';
  }
  return 'Ты профессиональный астролог. Составь краткий персональный дневной '
      'гороскоп только на основе переданного натального и текущего '
      'астрологического контекста. Не пересчитывай положения планет. Не давай '
      'медицинских, юридических, финансовых или фаталистичных прогнозов. '
      'Каждое поле должно быть практичным, конкретным и подходить для карточки '
      'в мобильном приложении.';
}

Map<String, dynamic> _dayHoroscopeJsonSchema() {
  final area = <String, dynamic>{
    'type': 'object',
    'additionalProperties': false,
    'properties': <String, dynamic>{
      'key_theme': <String, dynamic>{'type': 'string'},
      'theme_title': <String, dynamic>{'type': 'string'},
      'description': <String, dynamic>{'type': 'string'},
    },
    'required': <String>['key_theme', 'theme_title', 'description'],
  };

  final weakPoint = <String, dynamic>{
    'type': 'object',
    'additionalProperties': false,
    'properties': <String, dynamic>{
      'title': <String, dynamic>{'type': 'string'},
      'description': <String, dynamic>{'type': 'string'},
    },
    'required': <String>['title', 'description'],
  };

  final properties = <String, dynamic>{
    'focus': <String, dynamic>{'type': 'string'},
    'risk': <String, dynamic>{'type': 'string'},
    'personal_area': area,
    'personal_weak_points': <String, dynamic>{
      'type': 'array',
      'minItems': 1,
      'maxItems': 3,
      'items': weakPoint,
    },
    'personal_area_persentage': <String, dynamic>{'type': 'string'},
    'love_area': area,
    'love_weak_points': <String, dynamic>{
      'type': 'array',
      'minItems': 1,
      'maxItems': 3,
      'items': weakPoint,
    },
    'love_area_persentage': <String, dynamic>{'type': 'string'},
    'finance_area': area,
    'finance_weak_points': <String, dynamic>{
      'type': 'array',
      'minItems': 1,
      'maxItems': 3,
      'items': weakPoint,
    },
    'finance_area_persentage': <String, dynamic>{'type': 'string'},
    'spotlight': <String, dynamic>{'type': 'string'},
  };

  return <String, dynamic>{
    'type': 'object',
    'additionalProperties': false,
    'properties': properties,
    'required': properties.keys.toList(),
  };
}

Map<String, dynamic> _natalCardJsonSchema(String language) {
  final baseLanguage = language == 'en' ? 'en' : 'ru';
  final interpretationProperties = <String, dynamic>{
    'personality': <String, dynamic>{'type': 'string'},
    'intellectual_area': <String, dynamic>{'type': 'string'},
    'love_area': <String, dynamic>{'type': 'string'},
    'talent_area': <String, dynamic>{'type': 'string'},
    'energy_area': <String, dynamic>{'type': 'string'},
    'inside_area': <String, dynamic>{'type': 'string'},
    'final_conclusion': <String, dynamic>{'type': 'string'},
    'elements_interpretation': <String, dynamic>{'type': 'string'},
  };
  const planetKeys = <String>[
    'sun',
    'moon',
    'mercury',
    'venus',
    'mars',
    'jupiter',
    'saturn',
    'uranus',
    'neptune',
    'pluto',
    'chiron',
    'lilith',
    'selena',
    'north_node',
    'south_node',
    'pars_fortunae',
    'vertex',
  ];
  const houseKeys = <String>['strong_house', 'weak_house', 'accent_house'];
  interpretationProperties['planet_interpretations'] = <String, dynamic>{
    'type': 'object',
    'additionalProperties': false,
    'properties': <String, dynamic>{
      for (final key in planetKeys) key: <String, dynamic>{'type': 'string'},
    },
    'required': planetKeys,
  };
  interpretationProperties['house_interpretations'] = <String, dynamic>{
    'type': 'object',
    'additionalProperties': false,
    'properties': <String, dynamic>{
      for (final key in houseKeys) key: <String, dynamic>{'type': 'string'},
    },
    'required': houseKeys,
  };
  final interpretation = <String, dynamic>{
    'type': 'object',
    'additionalProperties': false,
    'properties': interpretationProperties,
    'required': interpretationProperties.keys.toList(),
  };
  final properties = <String, dynamic>{
    'source_language': <String, dynamic>{
      'type': 'string',
      'enum': <String>[baseLanguage],
    },
    'interpretations': <String, dynamic>{
      'type': 'object',
      'additionalProperties': false,
      'properties': <String, dynamic>{baseLanguage: interpretation},
      'required': <String>[baseLanguage],
    },
  };

  return <String, dynamic>{
    'type': 'object',
    'additionalProperties': false,
    'properties': properties,
    'required': properties.keys.toList(),
  };
}

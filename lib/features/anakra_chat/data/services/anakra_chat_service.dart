import 'package:asteria_app/core/services/api/backend_api.dart';
import 'package:asteria_app/core/localization/app_locale_service.dart';
import 'package:asteria_app/core/utils/ai_temporal_context.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AnakraChatService {
  final BackendApi _backendApi;
  final DateTime Function() _now;
  final AppLocaleService? _localeService;

  AnakraChatService(
    this._backendApi, {
    DateTime Function()? now,
    AppLocaleService? localeService,
  }) : _now = now ?? DateTime.now,
       _localeService = localeService;

  Future<String> sendMessage({
    required String message,
    required List<Map<String, dynamic>> conversationHistory,
    String? userName,
    String? zodiac,
  }) async {
    // Для тестов: отправь "ошибка" или "error" чтобы симулировать ошибку API
    if (kDebugMode &&
        (message.toLowerCase() == 'ошибка' ||
            message.toLowerCase() == 'error')) {
      throw Exception('Simulated API error');
    }

    try {
      final language = _localeService?.contentLanguage ?? 'ru';
      final isEnglish = language == 'en';
      final userInfo = <String>[];
      if (userName != null && userName.isNotEmpty) {
        userInfo.add('${isEnglish ? 'Name' : 'Имя'}: $userName');
      }
      if (zodiac != null && zodiac.isNotEmpty) {
        userInfo.add('${isEnglish ? 'Zodiac sign' : 'Знак зодиака'}: $zodiac');
      }

      final userInfoText = userInfo.isNotEmpty
          ? '\n\n${isEnglish ? 'User information' : 'Информация о пользователе'}:\n${userInfo.join('\n')}'
          : '';
      final temporalGrounding = buildAiTemporalGrounding(
        _now(),
        language: language,
      );

      final systemContent = isEnglish
          ? '''You are Anakra, a wise keeper of star signs and celestial paths. You help people reflect on their destiny through astrology, tarot, runes, and other mystical practices. Reply in English. Be wise, enigmatic, and kind. Use emoji sparingly.

$temporalGrounding

You have access to the previous messages in this conversation. Use them when answering questions about earlier interactions, such as tarot cards drawn previously.$userInfoText'''
          : '''Ты Анакра — мудрая хранительница звёздных знаков и небесного пути. Ты помогаешь людям понять их судьбу через астрологию, таро, руны и другие мистические практики. Отвечай на русском языке, будь мудрой, загадочной и доброй. Используй эмодзи умеренно.

$temporalGrounding

У тебя есть доступ к истории предыдущих сообщений в этом разговоре. Используй её для ответа на вопросы о прошлых взаимодействиях, например, о картах таро, которые ты вытягивала ранее.$userInfoText''';

      final messages = <Map<String, dynamic>>[
        {'role': 'system', 'content': systemContent},
        ...conversationHistory,
        {'role': 'user', 'content': message},
      ];

      final response = await _backendApi.openaiPost(
        path: 'v1/chat/completions',
        data: {
          'model': 'gpt-4o-mini',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1000,
        },
      );

      final content =
          response.data['choices'][0]['message']['content'] as String;
      return content.trim();
    } on DioException catch (e) {
      debugPrint('OpenAI API Error: ${e.message}');
      if (e.response != null) {
        debugPrint('Response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      rethrow;
    }
  }
}

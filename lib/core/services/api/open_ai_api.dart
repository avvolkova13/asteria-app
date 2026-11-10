import 'package:asteria_app/app/data/models/prompt_request.dart';
import 'package:asteria_app/core/services/api/backend_api.dart';
import 'package:dio/dio.dart';

class OpenAiApi {
  final BackendApi _backendApi;

  OpenAiApi(this._backendApi);

  /// Выполняет POST запрос
  ///
  /// [path] - путь запроса
  /// [data] - данные запроса
  /// [queryParameters] - параметры запроса
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final dataMap = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{};
    return await _backendApi.openaiPost(
      path: path,
      data: dataMap,
      queryParameters: queryParameters,
    );
  }

  /// Выполняет запрос к OpenAI API для генерации ответа через backend proxy
  ///
  /// [promptRequest] - запрос с промптом для генерации ответа
  Future<Response> generateFromReusablePrompt(
    PromptRequest promptRequest,
  ) async {
    return _backendApi.openaiGenerateResponse(data: promptRequest.toJson());
  }
}

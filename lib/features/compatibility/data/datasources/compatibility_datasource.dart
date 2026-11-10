import 'package:asteria_app/app/data/models/prompt_response.dart';
import 'package:asteria_app/core/services/api/backend_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class CompatibilityDataSource {
  /// Рассчитать совместимость по датам рождения
  Future<CompatibilityData> calculateCompatibility({
    required String herName,
    required String hisName,
    required String herBirthdate,
    required String hisBirthdate,
  });
}

class CompatibilityDataSourceImpl implements CompatibilityDataSource {
  final BackendApi _api;

  CompatibilityDataSourceImpl({required BackendApi api}) : _api = api;

  @override
  Future<CompatibilityData> calculateCompatibility({
    required String herName,
    required String hisName,
    required String herBirthdate,
    required String hisBirthdate,
  }) async {
    try {
      final response = await _api.calculateCompatibility(
        herName: herName,
        hisName: hisName,
        herBirthdate: herBirthdate,
        hisBirthdate: hisBirthdate,
      );

      if (response.statusCode == 200) {
        return CompatibilityData.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      } else {
        debugPrint('❌ Ошибка API: ${response.statusCode}');
        throw Exception('Ошибка API: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Ошибка сети при расчете совместимости: ${e.message}');
    } catch (e) {
      throw Exception('Не удалось рассчитать совместимость: $e');
    }
  }
}

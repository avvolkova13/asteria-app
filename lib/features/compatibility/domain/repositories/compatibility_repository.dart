import 'package:asteria_app/app/data/models/prompt_response.dart';
import 'package:asteria_app/features/compatibility/data/datasources/compatibility_datasource.dart';

abstract class CompatibilityRepository {
  /// Рассчитать совместимость по датам рождения
  Future<CompatibilityData> calculateCompatibility({
    required String herName,
    required String hisName,
    required String herBirthdate,
    required String hisBirthdate,
  });
}

class CompatibilityRepositoryImpl implements CompatibilityRepository {
  final CompatibilityDataSource _dataSource;

  CompatibilityRepositoryImpl({required CompatibilityDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<CompatibilityData> calculateCompatibility({
    required String herName,
    required String hisName,
    required String herBirthdate,
    required String hisBirthdate,
  }) async {
    try {
      return await _dataSource.calculateCompatibility(
        herName: herName,
        hisName: hisName,
        herBirthdate: herBirthdate,
        hisBirthdate: hisBirthdate,
      );
    } catch (e) {
      throw Exception('Ошибка при расчете совместимости: $e');
    }
  }
}

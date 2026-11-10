import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/services/api/backend_api.dart';
import 'package:asteria_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:flutter/foundation.dart';

abstract class AuthRepository {
  Future<UserModel> createUser(UserModel user);
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;
  final BackendApi _backendApi;

  AuthRepositoryImpl(this._dataSource, this._backendApi);

  @override
  Future<UserModel> createUser(UserModel user) async {
    try {
      final birthTime = user.personalInfo?.birthDate?.birthTime;
      final solarData = await _backendApi.getSolarData(
        birthYear: user.personalInfo?.birthDate?.birthDate.year ?? 0,
        birthMonth: user.personalInfo?.birthDate?.birthDate.month ?? 0,
        birthDay: user.personalInfo?.birthDate?.birthDate.day ?? 0,
        latitude: user.personalInfo?.birthPlace?.latitude ?? 0,
        longitude: user.personalInfo?.birthPlace?.longitude ?? 0,
      );
      final planetsHousesData = await _backendApi.getPlanetsHousesPosition(
        year: user.personalInfo?.birthDate?.birthDate.year ?? 0,
        month: user.personalInfo?.birthDate?.birthDate.month ?? 0,
        day: user.personalInfo?.birthDate?.birthDate.day ?? 0,
        hour: birthTime?.hour ?? 0,
        minute: birthTime?.minute ?? 0,
        latitude: user.personalInfo?.birthPlace?.latitude ?? 0,
        longitude: user.personalInfo?.birthPlace?.longitude ?? 0,
      );

      final solarDataModel = SolarDataModel.fromJson(solarData.data);
      final planetsHousesDataModel = PlanetsHousesDataModel.fromJson(
        planetsHousesData.data,
      );

      return await _dataSource.createUser(
        user.copyWith(
          clearPhoneNumber: true,
          authMethod: AuthMethod.email,
          solarData: solarDataModel,
          planetsHousesData: planetsHousesDataModel,
        ),
      );
    } catch (e) {
      debugPrint('Error: $e');
      throw Exception('Ошибка при создании пользователя: $e');
    }
  }
}

import 'package:asteria_app/app/data/models/lunar_calendar/lunar_month_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/services/api/backend_api.dart';

abstract interface class PersonalizedLunarCalendarRepository {
  Future<LunarMonthModel> loadMonth({
    required DateTime month,
    required CurrentLocationModel location,
  });
}

class PersonalizedLunarCalendarRepositoryImpl
    implements PersonalizedLunarCalendarRepository {
  PersonalizedLunarCalendarRepositoryImpl({required BackendApi api})
    : _api = api;

  final BackendApi _api;

  @override
  Future<LunarMonthModel> loadMonth({
    required DateTime month,
    required CurrentLocationModel location,
  }) async {
    final response = await _api.getPersonalizedLunarMonth(
      year: month.year,
      month: month.month,
      latitude: location.latitude,
      longitude: location.longitude,
    );
    return LunarMonthModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}

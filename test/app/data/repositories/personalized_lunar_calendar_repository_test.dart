import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/lunar_calendar/personalized_lunar_calendar_repository.dart';
import 'package:asteria_app/core/services/api/backend_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('repository parses current backend month contract', () async {
    final api = _FakeBackendApi(response: _monthJson());
    final repository = PersonalizedLunarCalendarRepositoryImpl(api: api);

    final month = await repository.loadMonth(
      month: DateTime(2026, 8),
      location: _saratov,
    );

    expect(api.personalizedCalls, 1);
    expect(month.year, 2026);
    expect(month.days.single.lunarContext.lunarDayNumber, 2);
  });

  test(
    'repository does not read generic fallback on backend failure',
    () async {
      final error = DioException(requestOptions: RequestOptions(path: 'month'));
      final api = _FakeBackendApi(error: error);
      final repository = PersonalizedLunarCalendarRepositoryImpl(api: api);

      await expectLater(
        repository.loadMonth(month: DateTime(2026, 8), location: _saratov),
        throwsA(same(error)),
      );

      expect(api.personalizedCalls, 1);
    },
  );
}

const _saratov = CurrentLocationModel(
  location: 'Саратов',
  latitude: 51.5336,
  longitude: 46.0343,
  source: CurrentLocationSource.manual,
);

class _FakeBackendApi implements BackendApi {
  _FakeBackendApi({this.response, this.error});

  final Map<String, dynamic>? response;
  final Object? error;
  int personalizedCalls = 0;

  @override
  Future<Response<dynamic>> getPersonalizedLunarMonth({
    required int year,
    required int month,
    required double latitude,
    required double longitude,
  }) async {
    personalizedCalls += 1;
    final error = this.error;
    if (error != null) throw error;
    return Response<dynamic>(
      data: response,
      requestOptions: RequestOptions(path: 'month'),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, dynamic> _monthJson() {
  return {
    'year': 2026,
    'month': 8,
    'timezone': 'Europe/Saratov',
    'anchor_local_time': '12:00',
    'days': [
      {
        'date': '2026-08-13',
        'lunar_context': {
          'lunar_day_number': 2,
          'moon_age_days': 0.64,
          'moon_age_day_index': 0,
          'moon_phase_code': 'waxing_crescent',
          'moon_phase_name': 'Растущий серп',
          'moon_sign_code': 'cancer',
          'moon_sign_name': 'Рак',
          'phase_event': null,
        },
        'daily_background': {
          'tone': 'growth',
          'title': 'Начало',
          'summary': 'Можно начинать спокойно.',
        },
        'spheres': {
          'gardening': {'status': 'neutral', 'tasks': <String, dynamic>{}},
        },
      },
    ],
  };
}

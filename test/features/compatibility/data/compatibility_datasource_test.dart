import 'package:asteria_app/core/services/api/backend_api.dart';
import 'package:asteria_app/features/compatibility/data/datasources/compatibility_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the backend-owned compatibility contract', () async {
    final api = _FakeFunctionsApi();
    final dataSource = CompatibilityDataSourceImpl(api: api);

    final result = await dataSource.calculateCompatibility(
      herName: 'Alice',
      hisName: 'Bob',
      herBirthdate: '1990-01-02',
      hisBirthdate: '1991-03-04',
    );

    expect(api.arguments, <String>['Alice', 'Bob', '1990-01-02', '1991-03-04']);
    expect(result.phrase, 'A strong connection');
    expect(result.percentage, '82%');
    expect(result.generalCompatibility, contains('shared values'));
  });
}

class _FakeFunctionsApi implements BackendApi {
  List<String>? arguments;

  @override
  Future<Response<dynamic>> calculateCompatibility({
    required String herName,
    required String hisName,
    required String herBirthdate,
    required String hisBirthdate,
  }) async {
    arguments = <String>[herName, hisName, herBirthdate, hisBirthdate];
    return Response<dynamic>(
      data: <String, dynamic>{
        'phrase': 'A strong connection',
        'introduction': 'You bring out the best in each other.',
        'percentage': '82%',
        'general_compatibility': 'Your shared values create stability.',
        'love_compatibility': 'Affection comes naturally.',
        'love_compatibility_persentage': '86%',
        'family_compatibility': 'You can build supportive routines.',
        'family_compatibility_persentage': '80%',
        'conflicts': 'Different pacing may create brief tension.',
        'conflicts_persentage': '24%',
      },
      statusCode: 200,
      requestOptions: RequestOptions(path: '/api/v1/compatibility/calculate'),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

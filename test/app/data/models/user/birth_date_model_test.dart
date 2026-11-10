import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BirthDateModel.fromJson', () {
    test('parses existing ISO birth_time values with 24-hour time', () {
      final model = BirthDateModel.fromJson({
        'birth_date': '1995-05-13T00:00:00.000',
        'birth_time': '-0001-11-30T13:05:00.000',
      });

      expect(model.birthTime, isNotNull);
      expect(model.birthTime!.hour, 13);
      expect(model.birthTime!.minute, 5);
    });
  });
}

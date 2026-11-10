import 'package:asteria_app/core/utils/ai_temporal_context.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatAiTemporalContext', () {
    test('formats positive UTC offset', () {
      final result = formatAiTemporalContext(
        DateTime(2026, 7, 27, 10, 5),
        utcOffset: const Duration(hours: 5),
      );

      expect(result, '2026-07-27 10:05 (UTC+05:00)');
    });

    test('formats negative UTC offset', () {
      final result = formatAiTemporalContext(
        DateTime(2026, 1, 2, 3, 4),
        utcOffset: const Duration(hours: -3),
      );

      expect(result, '2026-01-02 03:04 (UTC-03:00)');
    });

    test('formats fractional UTC offset', () {
      final result = formatAiTemporalContext(
        DateTime(2026, 7, 27, 10, 5),
        utcOffset: const Duration(hours: 5, minutes: 30),
      );

      expect(result, '2026-07-27 10:05 (UTC+05:30)');
    });
  });

  test('buildAiTemporalGrounding defines date and accuracy rules', () {
    final result = buildAiTemporalGrounding(DateTime.utc(2026, 7, 27, 10, 30));

    expect(
      result,
      allOf(
        contains('2026-07-27 10:30 (UTC+00:00)'),
        contains('достоверным источником истины'),
        contains('не называй уже прошедшую дату'),
        contains('всегда указывай год явно'),
        contains('Внутренние знания модели'),
        contains('не называй дату даже приблизительно'),
        contains('точный расчёт по имеющимся данным недоступен'),
      ),
    );
  });
}

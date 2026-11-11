import 'package:asteria_app/features/home/presentation/models/lunar_almanac.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the UTC transition belongs to its civil date on the device', () {
    // The Dec 9 event falls on Dec 8 in America/Los_Angeles.
    final event = DateTime.utc(2026, 12, 9, 0, 52).toLocal();
    final before = DateTime(event.year, event.month, event.day - 1);
    final after = DateTime(event.year, event.month, event.day + 1);
    final previous = LunarAlmanacDay.on(before)!;
    expect(previous.phase, AlmanacPhase.waningCrescent);
    expect(previous.nextPhase, AlmanacPhase.newMoon);
    expect(previous.nextEvent, event);
    expect(LunarAlmanacDay.on(event)!.phase, AlmanacPhase.newMoon);
    expect(LunarAlmanacDay.on(after)!.phase, AlmanacPhase.waxingCrescent);
    expect(
      LunarAlmanacDay.on(event)!.nextEvent.toUtc(),
      DateTime.utc(2026, 12, 17, 5, 43),
    );
  });

  test('both ends of the supported range have a following phase', () {
    for (final day in [DateTime(2000, 1, 1), DateTime(2050, 12, 31)]) {
      expect(LunarAlmanacDay.on(day)!.nextEvent.isAfter(day), isTrue);
    }
    expect(LunarAlmanacDay.on(DateTime(2051)), isNull);
  });
}

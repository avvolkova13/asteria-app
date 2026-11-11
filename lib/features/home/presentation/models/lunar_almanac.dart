import 'package:asteria_app/core/extensions/build_context_extensions.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'lunar_quarter_minutes.dart';

enum AlmanacPhase {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent;

  String label(BuildContext c) => switch (this) {
    newMoon => c.l10n.moonPhaseNewMoon,
    waxingCrescent => c.l10n.moonPhaseWaxingCrescent,
    firstQuarter => c.l10n.moonPhaseFirstQuarter,
    waxingGibbous => c.l10n.moonPhaseWaxingGibbous,
    fullMoon => c.l10n.moonPhaseFullMoon,
    waningGibbous => c.l10n.moonPhaseWaningGibbous,
    lastQuarter => c.l10n.moonPhaseLastQuarter,
    waningCrescent => c.l10n.moonPhaseWaningCrescent,
  };
}

class LunarAlmanacDay {
  const LunarAlmanacDay(this.phase, this.nextPhase, this.nextEvent);

  final AlmanacPhase phase;
  final AlmanacPhase nextPhase;
  final DateTime nextEvent;

  // Calendar dates are civil dates. Convert both local midnights to instants
  // separately so a daylight-saving change cannot move an event to another day.
  static LunarAlmanacDay? on(DateTime day) {
    if (day.year < 2000 || day.year > 2050) return null;
    final midnight = DateTime(day.year, day.month, day.day);
    final tomorrow = DateTime(day.year, day.month, day.day + 1);
    final endMinute =
        tomorrow.millisecondsSinceEpoch ~/ Duration.millisecondsPerMinute;
    var low = 0;
    var high = lunarQuarterMinutes.length;
    while (low < high) {
      final mid = (low + high) ~/ 2;
      if (lunarQuarterMinutes[mid] < endMinute) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    final previous = low - 1;
    if (previous < 0 || low >= lunarQuarterMinutes.length) return null;
    final isEventDay =
        lunarQuarterMinutes[previous] >=
        midnight.millisecondsSinceEpoch ~/ Duration.millisecondsPerMinute;
    final phase = (previous % 4) * 2 + (isEventDay ? 0 : 1);
    return LunarAlmanacDay(
      AlmanacPhase.values[phase],
      AlmanacPhase.values[(low % 4) * 2],
      DateTime.fromMillisecondsSinceEpoch(
        lunarQuarterMinutes[low] * Duration.millisecondsPerMinute,
      ),
    );
  }

  String describeNextEvent(BuildContext context) {
    final date = DateFormat.MMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(nextEvent);
    return context.l10n.moonNextPhaseDate(nextPhase.label(context), date);
  }
}

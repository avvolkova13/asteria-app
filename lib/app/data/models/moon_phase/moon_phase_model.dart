import 'package:asteria_app/core/extensions/string_extensions.dart';
import 'package:asteria_app/core/utils/utils.dart';

class MoonPhaseModel {
  final String date;
  final int lunarDay;
  final String moonSign;
  final String moonPhase;
  final String moonPhaseRu;
  final String moonriseLocal;
  final MoonPhaseEventModel? phaseEvent;

  const MoonPhaseModel({
    required this.date,
    required this.lunarDay,
    required this.moonSign,
    required this.moonPhase,
    required this.moonPhaseRu,
    required this.moonriseLocal,
    this.phaseEvent,
  });

  factory MoonPhaseModel.fromJson(Map<String, dynamic> json) {
    final rawPhaseEvent = json['phase_event'];
    return MoonPhaseModel(
      date: json['date'] as String,
      lunarDay: json['lunar_day'] as int,
      moonSign: json['moon_sign'] as String,
      moonPhase: json['moon_phase'] as String,
      moonPhaseRu: json['moon_phase_ru'] as String,
      moonriseLocal: json['moonrise_local'] as String? ?? '',
      phaseEvent: rawPhaseEvent == null
          ? null
          : MoonPhaseEventModel.fromJson(
              Map<String, dynamic>.from(rawPhaseEvent as Map),
            ),
    );
  }

  bool isToday() {
    final DateTime dateTime = date.fromRussianShortDate();
    return isSameDay(dateTime, DateTime.now());
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'lunar_day': lunarDay,
      'moon_sign': moonSign,
      'moon_phase': moonPhase,
      'moon_phase_ru': moonPhaseRu,
      'moonrise_local': moonriseLocal,
      'phase_event': phaseEvent?.toJson(),
    };
  }

  bool get hasPrimaryPhase => phaseEvent != null;

  MoonPhaseModel copyWith({
    String? date,
    int? lunarDay,
    String? moonSign,
    String? moonPhase,
    String? moonPhaseRu,
    String? moonriseLocal,
    MoonPhaseEventModel? phaseEvent,
  }) {
    return MoonPhaseModel(
      date: date ?? this.date,
      lunarDay: lunarDay ?? this.lunarDay,
      moonSign: moonSign ?? this.moonSign,
      moonPhase: moonPhase ?? this.moonPhase,
      moonPhaseRu: moonPhaseRu ?? this.moonPhaseRu,
      moonriseLocal: moonriseLocal ?? this.moonriseLocal,
      phaseEvent: phaseEvent ?? this.phaseEvent,
    );
  }
}

class MoonPhaseEventModel {
  final String phase;
  final String phaseRu;
  final String exactUtc;
  final String exactLocal;
  final String localDate;

  const MoonPhaseEventModel({
    required this.phase,
    required this.phaseRu,
    required this.exactUtc,
    required this.exactLocal,
    required this.localDate,
  });

  factory MoonPhaseEventModel.fromJson(Map<String, dynamic> json) {
    return MoonPhaseEventModel(
      phase: json['phase'] as String,
      phaseRu: json['phase_ru'] as String,
      exactUtc: json['exact_utc'] as String,
      exactLocal: json['exact_local'] as String,
      localDate: json['local_date'] as String,
    );
  }

  String get localTimeLabel {
    final timeStart = exactLocal.indexOf('T');
    if (timeStart >= 0 && exactLocal.length >= timeStart + 6) {
      return exactLocal.substring(timeStart + 1, timeStart + 6);
    }

    final parsed = DateTime.tryParse(exactLocal);
    if (parsed == null) return '';

    return '${parsed.hour.toString().padLeft(2, '0')}:'
        '${parsed.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'phase': phase,
      'phase_ru': phaseRu,
      'exact_utc': exactUtc,
      'exact_local': exactLocal,
      'local_date': localDate,
    };
  }
}

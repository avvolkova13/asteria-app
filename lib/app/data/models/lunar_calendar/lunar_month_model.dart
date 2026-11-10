import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';

class LunarPhaseEventModel {
  final String phase;
  final String phaseName;
  final String exactUtc;
  final String exactLocal;

  const LunarPhaseEventModel({
    required this.phase,
    required this.phaseName,
    required this.exactUtc,
    required this.exactLocal,
  });

  factory LunarPhaseEventModel.fromJson(Map<String, dynamic> json) {
    return LunarPhaseEventModel(
      phase: _requiredString(json, 'phase'),
      phaseName: _requiredString(json, 'phase_name'),
      exactUtc: _requiredString(json, 'exact_utc'),
      exactLocal: _requiredString(json, 'exact_local'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phase': phase,
      'phase_name': phaseName,
      'exact_utc': exactUtc,
      'exact_local': exactLocal,
    };
  }
}

class LunarDayContextModel {
  final int lunarDayNumber;
  final double moonAgeDays;
  final int moonAgeDayIndex;
  final String moonPhaseCode;
  final String moonPhaseName;
  final String moonSignCode;
  final String moonSignName;
  final LunarPhaseEventModel? phaseEvent;

  const LunarDayContextModel({
    required this.lunarDayNumber,
    required this.moonAgeDays,
    required this.moonAgeDayIndex,
    required this.moonPhaseCode,
    required this.moonPhaseName,
    required this.moonSignCode,
    required this.moonSignName,
    required this.phaseEvent,
  });

  int get lunarDay => lunarDayNumber;
  String get moonPhase => moonPhaseCode;
  String get moonPhaseRu => moonPhaseName;
  String get moonSign => moonSignName;

  factory LunarDayContextModel.fromJson(Map<String, dynamic> json) {
    return LunarDayContextModel(
      lunarDayNumber: _requiredIntInRange(json, 'lunar_day_number', 1, 30),
      moonAgeDays: _requiredNum(json, 'moon_age_days').toDouble(),
      moonAgeDayIndex: _requiredIntInRange(json, 'moon_age_day_index', 0, 29),
      moonPhaseCode: _requiredString(json, 'moon_phase_code'),
      moonPhaseName: _requiredString(json, 'moon_phase_name'),
      moonSignCode: _requiredString(json, 'moon_sign_code'),
      moonSignName: _requiredString(json, 'moon_sign_name'),
      phaseEvent: json['phase_event'] == null
          ? null
          : LunarPhaseEventModel.fromJson(
              Map<String, dynamic>.from(json['phase_event'] as Map),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lunar_day_number': lunarDayNumber,
      'moon_age_days': moonAgeDays,
      'moon_age_day_index': moonAgeDayIndex,
      'moon_phase_code': moonPhaseCode,
      'moon_phase_name': moonPhaseName,
      'moon_sign_code': moonSignCode,
      'moon_sign_name': moonSignName,
      'phase_event': phaseEvent?.toJson(),
    };
  }
}

class LunarDayModel {
  final DateTime date;
  final LunarDayContextModel lunarContext;
  final DailyBackgroundModel dailyBackground;
  final Map<String, SphereRecommendationModel> spheres;

  const LunarDayModel({
    required this.date,
    required this.lunarContext,
    required this.dailyBackground,
    required this.spheres,
  });

  factory LunarDayModel.fromJson(Map<String, dynamic> json) {
    final rawSpheres = Map<String, dynamic>.from(json['spheres'] as Map);
    return LunarDayModel(
      date: DateTime.parse(_requiredString(json, 'date')),
      lunarContext: LunarDayContextModel.fromJson(
        Map<String, dynamic>.from(json['lunar_context'] as Map),
      ),
      dailyBackground: DailyBackgroundModel.fromJson(
        Map<String, dynamic>.from(json['daily_background'] as Map),
      ),
      spheres: rawSpheres.map(
        (key, value) => MapEntry(
          key,
          SphereRecommendationModel.fromJson(
            Map<String, dynamic>.from(value as Map),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': _dateOnly(date),
      'lunar_context': lunarContext.toJson(),
      'daily_background': dailyBackground.toJson(),
      'spheres': spheres.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

class LunarMonthModel {
  final int year;
  final int month;
  final String timezone;
  final String anchorLocalTime;
  final List<LunarDayModel> days;

  const LunarMonthModel({
    required this.year,
    required this.month,
    required this.timezone,
    required this.anchorLocalTime,
    required this.days,
  });

  factory LunarMonthModel.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'];
    if (rawDays is! List) {
      throw FormatException('Invalid days: $rawDays');
    }
    return LunarMonthModel(
      year: _requiredIntInRange(json, 'year', 1, 9999),
      month: _requiredIntInRange(json, 'month', 1, 12),
      timezone: _requiredString(json, 'timezone'),
      anchorLocalTime: _requiredString(json, 'anchor_local_time'),
      days: rawDays
          .map(
            (value) =>
                LunarDayModel.fromJson(Map<String, dynamic>.from(value as Map)),
          )
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'timezone': timezone,
      'anchor_local_time': anchorLocalTime,
      'days': days.map((day) => day.toJson()).toList(),
    };
  }
}

typedef PersonalizedLunarContextModel = LunarDayContextModel;
typedef PersonalizedLunarDayModel = LunarDayModel;
typedef PersonalizedLunarMonthModel = LunarMonthModel;

int _requiredIntInRange(
  Map<String, dynamic> json,
  String key,
  int min,
  int max,
) {
  final value = json[key];
  if (value is! int || value < min || value > max) {
    throw FormatException('Invalid $key: $value');
  }
  return value;
}

num _requiredNum(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! num) {
    throw FormatException('Invalid $key: $value');
  }
  return value;
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw FormatException('Invalid $key: $value');
  }
  return value;
}

String _dateOnly(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

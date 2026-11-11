import 'package:asteria_app/app/data/models/lunar_calendar/lunar_month_model.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';
import 'package:hive/hive.dart';

DateTime calendarDay(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);
String calendarDateKey(DateTime date) =>
    calendarDay(date).toIso8601String().substring(0, 10);

enum CalendarActivity {
  haircut('beauty', ['haircut']),
  transplant('gardening', [
    'transplanting_pricking',
    'transplanting_and_pricking',
  ]),
  coloring('beauty', ['hair_coloring']),
  planting('gardening', ['sowing_planting', 'sowing_and_planting']),
  watering('gardening', ['watering_fertilizing', 'watering_and_fertilizing']);

  const CalendarActivity(this.sphere, this.keys);
  final String sphere;
  final List<String> keys;

  TaskRecommendationModel? recommendation(LunarDayModel? day) {
    final tasks = day?.spheres[sphere]?.tasks;
    if (tasks == null) return null;
    for (final key in keys) {
      final candidate = tasks[key];
      if (candidate != null && candidate.description.trim().isNotEmpty) {
        return candidate;
      }
    }
    return null;
  }
}

class CalendarPlan {
  const CalendarPlan({
    required this.id,
    required this.owner,
    required this.day,
    required this.activity,
    required this.title,
    required this.recommendation,
  });

  final String id;
  final String owner;
  final DateTime day;
  final CalendarActivity activity;
  final String title;
  final TaskRecommendationModel? recommendation;

  Map<String, Object> toJson() => {
    'id': id,
    'owner': owner,
    'day': calendarDateKey(day),
    'activity': activity.name,
    'title': title,
    if (recommendation case final rec?) 'recommendation': rec.toJson(),
  };

  factory CalendarPlan.fromJson(Map data) => CalendarPlan(
    id: data['id'] as String,
    owner: data['owner'] as String,
    day: calendarDay(DateTime.parse(data['day'] as String)),
    activity: CalendarActivity.values.byName(data['activity'] as String),
    title: data['title'] as String,
    recommendation: data['recommendation'] == null
        ? null
        : TaskRecommendationModel.fromJson(
            Map<String, dynamic>.from(data['recommendation'] as Map),
          ),
  );
}

class CalendarPlans {
  static Future<Box<Map>> open() => Hive.openBox<Map>('calendar_plans_v1');

  static Future<void> save(CalendarPlan plan) async {
    final box = await open();
    await box.put('${plan.owner}/${plan.id}', plan.toJson());
  }

  static List<CalendarPlan> read(Box<Map> box, String owner) {
    return box.values
        .where((row) => row['owner'] == owner)
        .map(CalendarPlan.fromJson)
        .toList()
      ..sort((a, b) => a.day.compareTo(b.day));
  }
}

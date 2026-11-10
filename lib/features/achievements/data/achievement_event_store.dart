import 'package:asteria_app/features/achievements/domain/achievement_event.dart';
import 'package:hive/hive.dart';

class AchievementEventStore {
  Future<Box<Map>>? _box;
  Future<Box<Map>> get _openedBox =>
      _box ??= Hive.openBox<Map>('pending_achievement_events');

  Future<void> save(AchievementEvent event) async =>
      (await _openedBox).put(event.key, event.toJson());
  Future<void> delete(AchievementEvent event) async =>
      (await _openedBox).delete(event.key);

  Future<List<AchievementEvent>> eventsFor(String userId) async {
    final box = await _openedBox;
    return box.values
        .map(
          (value) =>
              AchievementEvent.fromJson(Map<String, dynamic>.from(value)),
        )
        .where((event) => event.userId == userId)
        .toList();
  }
}

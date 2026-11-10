import 'package:asteria_app/features/balance/domain/reward_models.dart';
import 'package:hive/hive.dart';

class RewardEventStore {
  static const _boxName = 'pending_reward_events';
  Box<Map>? _box;

  Future<void> init() async {
    _box ??= await Hive.openBox<Map>(_boxName);
  }

  Future<void> save(PendingRewardEvent event) async {
    await init();
    await _box!.put(event.eventId, event.toJson());
  }

  Future<void> delete(String eventId) async {
    await init();
    await _box!.delete(eventId);
  }

  Future<List<PendingRewardEvent>> eventsFor(String userId) async {
    await init();
    final events = <PendingRewardEvent>[];
    for (final value in _box!.values) {
      try {
        final event = PendingRewardEvent.fromJson(
          Map<String, dynamic>.from(value),
        );
        if (event.userId == userId) events.add(event);
      } catch (_) {
        // Ignore malformed legacy entries; valid events remain retryable.
      }
    }
    events.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return events;
  }
}

import 'dart:convert';

import 'package:asteria_app/core/services/hive/hive_service.dart';
import 'package:hive/hive.dart';

import 'guidance_situation.dart';

/// Keeps a revealed insight stable even when the shared Home card is refreshed.
class DailyGuidanceStore {
  DailyGuidanceStore(this.owner, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final String owner;
  final DateTime Function() _now;
  Box<Map> get _box => Hive.box<Map>(HiveBoxNames.appSettings);
  String get _key => 'daily-guidance/${base64Url.encode(utf8.encode(owner))}';
  String get day => _now().toIso8601String().substring(0, 10);

  ({GuidanceSituation situation, String cardId})? read() {
    if (owner.isEmpty) return null;
    final data = _box.get(_key);
    if (data == null || data['day'] != day) return null;
    for (final situation in GuidanceSituation.values) {
      if (data['situation'] == situation.name && data['cardId'] is String) {
        return (situation: situation, cardId: data['cardId'] as String);
      }
    }
    return null;
  }

  Future<void> save(
    GuidanceSituation situation,
    String cardId,
    String drawnDay,
  ) async {
    if (owner.isEmpty || day != drawnDay) throw StateError('Insight expired');
    final existing = read();
    if (existing != null) {
      if (existing.situation != situation || existing.cardId != cardId) {
        throw StateError('An insight has already been opened');
      }
      return;
    }
    await _box.put(_key, {
      'day': drawnDay,
      'situation': situation.name,
      'cardId': cardId,
    });
  }
}

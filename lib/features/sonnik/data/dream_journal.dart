import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class DreamEntry {
  const DreamEntry({
    required this.id,
    required this.text,
    required this.recordedAt,
    this.interpretations = const [],
    this.historyOnly = false,
    this.currentInterpretation,
  });

  final String id;
  final String text;
  final DateTime recordedAt;
  final List<SonnikModel> interpretations;
  final bool historyOnly;
  final SonnikModel? currentInterpretation;
}

class DreamJournal {
  DreamJournal(String owner) : _prefix = '${Uri.encodeComponent(owner)}/';

  static const _boxName = 'dream_journal_v1';
  final String _prefix;

  Future<Box<Map>> _open() => Hive.openBox<Map>(_boxName);

  Iterable<String> _keys(Box<Map> box) =>
      box.keys.whereType<String>().where((key) => key.startsWith(_prefix));

  static Iterable<Map> _storedReadings(Map? record) sync* {
    if (record?['interpretations'] case final List readings) {
      yield* readings.whereType<Map>();
    }
  }

  static String _textKey(String text) =>
      sha256.convert(utf8.encode(text)).toString();

  static DreamEntry _entry({
    required String id,
    required String text,
    required DateTime date,
    required Iterable<Map> stored,
    Map<String, SonnikModel>? history,
  }) {
    final readings = <SonnikModel>[];
    final textKey = _textKey(text);
    SonnikModel? current;
    for (final item in stored) {
      final reading =
          history?.remove(item['id']) ??
          SonnikModel.fromJson(Map<String, dynamic>.from(item));
      readings.add(reading);
      if (item['sourceKey'] == textKey &&
          (current == null ||
              reading.dateGenerated.isAfter(current.dateGenerated))) {
        current = reading;
      }
    }
    readings.sort((a, b) => b.dateGenerated.compareTo(a.dateGenerated));
    return DreamEntry(
      id: id,
      text: text,
      recordedAt: date,
      interpretations: readings,
      currentInterpretation: current,
    );
  }

  Future<List<DreamEntry>> read({
    Iterable<SonnikModel> history = const [],
  }) async {
    final box = await _open();
    final unlinked = {for (final item in history) item.id: item};
    final entries = <DreamEntry>[];

    for (final key in _keys(box)) {
      final record = box.get(key);
      if (record?['removedReadings'] case final List ids) {
        for (final id in ids) {
          unlinked.remove(id);
        }
      }
      if (record case {'text': final String text, 'at': final int at}) {
        entries.add(
          _entry(
            id: key.substring(_prefix.length),
            text: text,
            date: DateTime.fromMillisecondsSinceEpoch(at),
            stored: _storedReadings(record),
            history: unlinked,
          ),
        );
      }
    }
    for (final reading in unlinked.values) {
      entries.add(
        DreamEntry(
          id: 'reading/${reading.id}',
          text: reading.title,
          recordedAt: reading.dateGenerated.toLocal(),
          interpretations: [reading],
          historyOnly: true,
        ),
      );
    }
    return entries..sort((a, b) {
      final byDate = b.recordedAt.compareTo(a.recordedAt);
      return byDate == 0 ? a.id.compareTo(b.id) : byDate;
    });
  }

  Future<DreamEntry> save(
    String text, {
    DreamEntry? entry,
    SonnikModel? interpretation,
  }) async {
    final value = text.trim();
    if (value.isEmpty) throw ArgumentError('Dream text cannot be empty');
    final box = await _open();
    final id = entry?.id ?? const Uuid().v4();
    final key = '$_prefix$id';
    final existing = box.get(key);
    final stored = {
      for (final item in _storedReadings(existing)) item['id'] as String: item,
      if (interpretation != null)
        interpretation.id: {
          ...interpretation.toJson(),
          'sourceKey': _textKey(value),
        },
    }.values.toList();
    final date = entry?.recordedAt ?? DateTime.now();
    final result = _entry(id: id, text: value, date: date, stored: stored);
    await box.put(key, {
      'text': value,
      'at': date.millisecondsSinceEpoch,
      if (stored.isNotEmpty) 'interpretations': stored,
    });
    return result;
  }

  Future<void> delete(String id) async {
    final box = await _open();
    final key = '$_prefix$id';
    final record = box.get(key);
    if (record?['removedReadings'] != null) return;
    final ids = {
      for (final item in _storedReadings(record)) item['id'] as String,
      if (id.startsWith('reading/')) id.substring('reading/'.length),
    };
    if (ids.isEmpty) {
      await box.delete(key);
    } else {
      // Account history remains on the server. Only identifiers are needed
      // locally to prevent a deleted dream from reappearing after refresh.
      await box.put(key, {'removedReadings': ids.toList()});
    }
  }

  Future<void> clear() async {
    final box = await _open();
    await box.deleteAll(_keys(box).toList());
  }
}

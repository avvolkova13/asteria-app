import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class DreamEntry {
  const DreamEntry({
    required this.id,
    required this.text,
    required this.recordedAt,
  });

  final String id;
  final String text;
  final DateTime recordedAt;
}

class DreamJournal {
  DreamJournal(String owner) : _prefix = '${Uri.encodeComponent(owner)}/';

  static const _boxName = 'dream_journal_v1';
  final String _prefix;

  Future<Box<Map>> _open() => Hive.openBox<Map>(_boxName);

  Iterable<String> _keys(Box<Map> box) =>
      box.keys.whereType<String>().where((key) => key.startsWith(_prefix));

  Future<List<DreamEntry>> read() async {
    final box = await _open();
    final entries = [
      for (final key in _keys(box))
        if (box.get(key) case {'text': final String text, 'at': final int at})
          DreamEntry(
            id: key.substring(_prefix.length),
            text: text,
            recordedAt: DateTime.fromMillisecondsSinceEpoch(at),
          ),
    ];
    return entries..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  Future<DreamEntry> save(String text, {DreamEntry? entry}) async {
    final value = text.trim();
    if (value.isEmpty) throw ArgumentError('Dream text cannot be empty');
    final result = DreamEntry(
      id: entry?.id ?? const Uuid().v4(),
      text: value,
      recordedAt: entry?.recordedAt ?? DateTime.now(),
    );
    final box = await _open();
    await box.put('$_prefix${result.id}', {
      'text': result.text,
      'at': result.recordedAt.millisecondsSinceEpoch,
    });
    return result;
  }

  Future<void> delete(String id) async {
    final box = await _open();
    await box.delete('$_prefix$id');
  }

  Future<void> clear() async {
    final box = await _open();
    await box.deleteAll(_keys(box).toList());
  }
}

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class PracticeNote {
  const PracticeNote({
    required this.id,
    required this.text,
    required this.recordedAt,
  });

  final String id;
  final String text;
  final DateTime recordedAt;
}

class PracticeNotesStore {
  const PracticeNotesStore();

  Future<Box<Map>> _open() => Hive.openBox<Map>('practice_notes_v1');

  String _ownerPrefix(String ownerId) {
    if (ownerId.isEmpty) throw ArgumentError('A note requires an account');
    return '${Uri.encodeComponent(ownerId)}/';
  }

  String _practicePrefix(String ownerId, String practiceId) {
    if (practiceId.isEmpty) throw ArgumentError('A note requires a practice');
    return '${_ownerPrefix(ownerId)}${Uri.encodeComponent(practiceId)}/';
  }

  Iterable<String> _scopedKeys(Box<Map> box, String prefix) =>
      box.keys.whereType<String>().where((key) => key.startsWith(prefix));

  Future<List<PracticeNote>> read(String ownerId, String practiceId) async {
    final prefix = _practicePrefix(ownerId, practiceId);
    final box = await _open();
    final notes = [
      for (final key in _scopedKeys(box, prefix))
        if (box.get(key) case {'text': final String text, 'at': final int at})
          PracticeNote(
            id: key.substring(prefix.length),
            text: text,
            recordedAt: DateTime.fromMillisecondsSinceEpoch(at),
          ),
    ];
    return notes..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  Future<PracticeNote> save({
    required String ownerId,
    required String practiceId,
    required String text,
    String? noteId,
  }) async {
    final value = text.trim();
    if (value.isEmpty) throw ArgumentError('Note text cannot be empty');
    final id = noteId ?? const Uuid().v4();
    final key = _practicePrefix(ownerId, practiceId) + Uri.encodeComponent(id);
    final box = await _open();
    final int at;
    if (noteId == null) {
      at = DateTime.now().millisecondsSinceEpoch;
    } else if (box.get(key) case {'at': final int recordedAt}) {
      at = recordedAt;
    } else {
      throw StateError('The note no longer exists');
    }
    await box.put(key, {'text': value, 'at': at});
    return PracticeNote(
      id: id,
      text: value,
      recordedAt: DateTime.fromMillisecondsSinceEpoch(at),
    );
  }

  Future<void> delete(String ownerId, String practiceId, String noteId) async {
    final key =
        _practicePrefix(ownerId, practiceId) + Uri.encodeComponent(noteId);
    final box = await _open();
    await box.delete(key);
  }

  Future<void> clearForOwner(String ownerId) async {
    final prefix = _ownerPrefix(ownerId);
    final box = await _open();
    await box.deleteAll(_scopedKeys(box, prefix).toList());
  }
}

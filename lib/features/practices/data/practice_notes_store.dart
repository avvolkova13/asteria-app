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

typedef JournalNote = ({String practiceId, PracticeNote note});

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

  Future<List<JournalNote>> readJournal(String ownerId) async {
    final prefix = _ownerPrefix(ownerId);
    final box = await _open();
    final notes = <JournalNote>[];
    for (final key in _scopedKeys(box, prefix)) {
      final parts = key.substring(prefix.length).split('/');
      if (parts.length != 2 || parts.any((part) => part.isEmpty)) continue;
      if (box.get(key) case {'text': final String text, 'at': final int at}) {
        try {
          notes.add((
            practiceId: Uri.decodeComponent(parts.first),
            note: PracticeNote(
              id: Uri.decodeComponent(parts.last),
              text: text,
              recordedAt: DateTime.fromMillisecondsSinceEpoch(at),
            ),
          ));
        } on ArgumentError {
          continue;
        }
      }
    }
    return notes
      ..sort((a, b) => b.note.recordedAt.compareTo(a.note.recordedAt));
  }

  Stream<int> watchCount(String ownerId, String practiceId) async* {
    final prefix = _practicePrefix(ownerId, practiceId);
    final box = await _open();
    int count() => _scopedKeys(box, prefix).where((key) {
      final value = box.get(key);
      return value?['text'] is String && value?['at'] is int;
    }).length;
    yield* Stream<int>.multi((controller) {
      final subscription = box
          .watch()
          .where(
            (event) =>
                event.key is String && (event.key as String).startsWith(prefix),
          )
          .listen((_) => controller.add(count()), onError: controller.addError);
      controller.add(count());
      controller.onCancel = subscription.cancel;
    });
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

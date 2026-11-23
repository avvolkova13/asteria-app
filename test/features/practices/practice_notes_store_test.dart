import 'dart:io';

import 'package:asteria_app/features/practices/data/practice_notes_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  const store = PracticeNotesStore();
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'asteria-practice-notes-',
    );
    Hive.init(directory.path);
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test(
    'notes persist after reopen and resolve by both owner and practice',
    () async {
      await store.save(ownerId: 'a/b', practiceId: 'morning', text: 'First');
      await store.save(ownerId: 'a/b', practiceId: 'body', text: 'Body');
      await store.save(ownerId: 'a', practiceId: 'b/morning', text: 'Other');
      final first = (await store.read('a/b', 'morning')).single;

      await Hive.close();
      Hive.init(directory.path);

      final recovered = (await store.read('a/b', 'morning')).single;
      expect(recovered.id, first.id);
      expect(recovered.recordedAt, first.recordedAt);
      expect(recovered.text, 'First');
      expect((await store.read('a/b', 'body')).single.text, 'Body');
      expect((await store.read('a', 'b/morning')).single.text, 'Other');
      expect(await store.read('new', 'morning'), isEmpty);
    },
  );

  test(
    'editing retains the date and rejects stale or cross-account IDs',
    () async {
      final first = await store.save(
        ownerId: 'owner',
        practiceId: 'morning',
        text: 'Initial',
      );
      final edited = await store.save(
        ownerId: 'owner',
        practiceId: 'morning',
        text: '  Updated  ',
        noteId: first.id,
      );
      expect(edited.id, first.id);
      expect(edited.recordedAt, first.recordedAt);
      expect((await store.read('owner', 'morning')).single.text, 'Updated');
      await expectLater(
        store.save(
          ownerId: 'other',
          practiceId: 'morning',
          text: 'Unexpected',
          noteId: first.id,
        ),
        throwsStateError,
      );
      await store.delete('other', 'morning', first.id);
      expect(await store.read('owner', 'morning'), hasLength(1));
      await store.delete('owner', 'morning', first.id);
      await expectLater(
        store.save(
          ownerId: 'owner',
          practiceId: 'morning',
          text: 'Unexpected',
          noteId: first.id,
        ),
        throwsStateError,
      );
    },
  );

  test(
    'clearing an account deletes only that account across practices',
    () async {
      await store.save(ownerId: 'a', practiceId: 'morning', text: 'One');
      await store.save(ownerId: 'a', practiceId: 'body', text: 'Two');
      await store.save(ownerId: 'a/a', practiceId: 'morning', text: 'Keep');

      await store.clearForOwner('a');
      await Hive.close();
      Hive.init(directory.path);

      expect(await store.read('a', 'morning'), isEmpty);
      expect(await store.read('a', 'body'), isEmpty);
      expect((await store.read('a/a', 'morning')).single.text, 'Keep');
    },
  );
}

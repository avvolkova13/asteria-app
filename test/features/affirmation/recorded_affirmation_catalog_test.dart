import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/features/affirmation/recorded_affirmations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('both bundled catalogs offer all 68 cards with matching identities', () {
    const categories = [
      'love',
      'abundance',
      'strength',
      'creativity',
      'lunar',
      'calm',
    ];
    final russian = [
      for (final category in categories)
        ...mergeRecordedAffirmations(category, []),
    ];
    final english = [
      for (final category in categories)
        ...mergeEnglishRecordedAffirmations(category, []),
    ];
    expect(russian, hasLength(68));
    expect(
      russian.map((card) => card.id),
      unorderedEquals(english.map((card) => card.id)),
    );
    for (final card in russian) {
      expect(
        lookupRecordedAffirmation(card.id, catalogText: card.text),
        isNotNull,
      );
      expect(
        mergeRecordedAffirmations(card.categoryId, [
          card,
        ]).where((item) => item.id == card.id),
        hasLength(1),
      );
    }
  });

  test('recordings extend the original categories without replacing cards', () {
    const categories = [
      'love',
      'abundance',
      'strength',
      'creativity',
      'lunar',
      'calm',
    ];
    final catalogCards = <AffirmationModel>[
      for (final category in categories)
        for (var index = 0; index < 2; index++)
          AffirmationModel(
            id: '$category-$index',
            categoryId: category,
            category: category,
            text: 'Existing affirmation $index',
            sort: index,
          ),
    ];
    final editorialIds = <String>{};

    for (final category in categories) {
      final original = catalogCards
          .where((card) => card.effectiveCategoryId == category)
          .toList();
      final merged = mergeRecordedAffirmations(category, original);
      expect(merged.take(original.length), orderedEquals(original));
      for (final card in merged.skip(original.length)) {
        expect(card.effectiveCategoryId, category);
        expect(editorialIds.add(card.id), isTrue);
        expect(lookupRecordedAffirmation(card.id)?.title, card.text);
      }
    }

    expect(editorialIds, {
      for (final recording in longAffirmationRecordings.values)
        recording.catalogId ?? recording.libraryId,
    });
  });

  test(
    'original recordings resolve on existing cards and follow source text',
    () {
      for (final entry in catalogAffirmationRecordings.entries) {
        final recording = longAffirmationRecordings[entry.key] ?? entry.value;
        final card = AffirmationModel(
          id: entry.key,
          categoryId: recording.categoryId,
          category: recording.categoryId,
          text: recording.title,
          sort: 1,
        );
        final category = mergeRecordedAffirmations(card.categoryId, [card]);
        expect(category.where((item) => item.id == card.id), [card]);
        expect(
          lookupRecordedAffirmation(card.id, catalogText: card.text),
          same(recording),
        );
        expect(
          lookupRecordedAffirmation(
            card.id,
            catalogText: 'A revised source text',
          ),
          isNull,
        );
        expect(recording.notesId, 'affirmation:${card.id}');
        if (longAffirmationRecordings.containsKey(entry.key)) {
          expect(
            recording.duration,
            greaterThanOrEqualTo(const Duration(minutes: 3)),
          );
          expect(recording.transcript, hasLength(greaterThan(1)));
        } else {
          expect(recording.transcript.single.$2, card.text);
        }
      }
    },
  );

  test(
    'revised Russian text keeps the original card identity and metadata',
    () {
      const original = AffirmationModel(
        id: '5UgabJFV5M2TiptnhZMm',
        categoryId: 'love',
        category: 'Любовь',
        text: 'Previous Russian text',
        sort: 1,
      );
      final updated = mergeRecordedAffirmations('love', [original]).first;
      expect(
        updated.text,
        longAffirmationRecordings[original.id]?.title ??
            'Когда обо мне заботятся, я могу просто принять это. '
                'Иногда достаточно сказать «спасибо».',
      );
      expect(updated.toJson(), original.copyWith(text: updated.text).toJson());
      expect(catalogAffirmationCopy, hasLength(60));
    },
  );

  test('approved long affirmations preserve editorial titles and note IDs', () {
    final recording = lookupRecordedAffirmation('asteria-recording:time')!;
    expect(recording.title, 'У меня есть время');
    expect(recording.notesId, 'affirmation:time');
    expect(recording.duration, const Duration(minutes: 3, seconds: 30));
    expect(recording.transcript, hasLength(greaterThan(1)));
  });

  test('a recording on a catalog card preserves its saved notes identity', () {
    const recording = RecordedAffirmation(
      slug: 'love-fixture',
      title: 'Existing affirmation',
      categoryId: 'love',
      duration: Duration(seconds: 20),
      transcript: [(5, 'Existing affirmation')],
      catalogId: 'existing-card',
    );
    expect(recording.notesId, 'affirmation:existing-card');
  });
}

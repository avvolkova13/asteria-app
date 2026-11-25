import 'package:asteria_app/features/affirmation/recorded_affirmations.dart';
import 'package:asteria_app/features/affirmation/widgets/affirmation_card_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('each recorded affirmation has a distinct bundled cover', () async {
    final assets = <String>{};
    for (final recording in longAffirmationRecordings.values) {
      final id = recording.catalogId ?? recording.libraryId;
      final cover = AffirmationCardWidget.artworkFor(
        recording.categoryId,
        0,
        affirmationId: id,
      );
      expect(assets.add(cover), isTrue, reason: recording.title);
      expect(
        AffirmationCardWidget.artworkFor(
          recording.categoryId,
          1,
          affirmationId: id,
        ),
        cover,
        reason: recording.title,
      );
      expect((await rootBundle.load(cover)).lengthInBytes, greaterThan(0));
    }
    expect(assets, hasLength(longAffirmationRecordings.length));
  });
}

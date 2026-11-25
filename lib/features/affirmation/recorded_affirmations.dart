import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';

part 'recorded_affirmation_content.dart';
part 'catalog_affirmation_recordings.dart';
part 'long_affirmation_recordings.dart';
part 'english_affirmation_recordings.dart';

class RecordedAffirmation {
  const RecordedAffirmation({
    required this.slug,
    required this.title,
    required this.categoryId,
    required this.duration,
    required this.transcript,
    this.catalogId,
    this.audioAsset,
  });

  final String slug, title, categoryId;
  final String? catalogId, audioAsset;
  final Duration duration;
  final List<(double, String)> transcript;

  String get libraryId => 'asteria-recording:$slug';
  String get notesId => 'affirmation:${catalogId ?? slug}';
  String get asset => audioAsset ?? 'assets/audio/affirmation-$slug.mp3';

  String get metadata => durationLabel(ru: true);

  String durationLabel({required bool ru}) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final sec = ru ? 'сек' : 'sec';
    if (minutes == 0) return '$seconds $sec';
    final min = ru ? 'мин' : 'min';
    return seconds == 0 ? '$minutes $min' : '$minutes $min $seconds $sec';
  }

  AffirmationModel asCard(int order) => AffirmationModel(
    id: libraryId,
    categoryId: categoryId,
    category: categoryId,
    text: title,
    sort: order,
  );
}

RecordedAffirmation? lookupRecordedAffirmation(
  String id, {
  String? catalogText,
  bool ru = true,
}) {
  if (!ru) {
    return englishAffirmationRecordings[id.replaceFirst(
      RegExp(r'^asteria-recording:'),
      '',
    )];
  }
  final catalogRecording =
      longAffirmationRecordings[id] ?? catalogAffirmationRecordings[id];
  if (catalogRecording != null) {
    return catalogText == null ||
            catalogRecording.title.trim() == catalogText.trim()
        ? catalogRecording
        : null;
  }

  for (final recording in recordedAffirmations) {
    if (recording.libraryId == id) {
      return longAffirmationRecordings[recording.slug] ?? recording;
    }
  }
  return null;
}

AffirmationModel revisedRussianAffirmation(AffirmationModel card) {
  final text =
      longAffirmationRecordings[card.id]?.title ??
      catalogAffirmationCopy[card.id];
  return text == null || text == card.text ? card : card.copyWith(text: text);
}

/// Keep server order and fill gaps from the corresponding bundled catalog.
List<AffirmationModel> mergeRecordedAffirmations(
  String categoryId,
  List<AffirmationModel> catalog,
) => _completeCatalog(categoryId, catalog, ru: true);

List<AffirmationModel> mergeEnglishRecordedAffirmations(
  String categoryId,
  List<AffirmationModel> catalog,
) => _completeCatalog(categoryId, catalog, ru: false);

List<AffirmationModel> _completeCatalog(
  String categoryId,
  List<AffirmationModel> catalog, {
  required bool ru,
}) {
  final existing = {for (final card in catalog) card.id};
  final recordings = ru
      ? longAffirmationRecordings.values
      : englishAffirmationRecordings.values;
  return [
    for (final card in catalog)
      if (ru)
        revisedRussianAffirmation(card)
      else if (lookupRecordedAffirmation(card.id, ru: false)
          case final recording?)
        card.copyWith(text: recording.title)
      else
        card,
    for (final (index, recording) in recordings.indexed)
      if (recording.categoryId == categoryId &&
          !existing.contains(recording.catalogId ?? recording.libraryId))
        recording
            .asCard(catalog.length + index)
            .copyWith(id: recording.catalogId),
  ];
}

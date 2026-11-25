import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/affirmation/player/affirmation_player_screen.dart';
import 'package:asteria_app/features/affirmation/player/player_artwork.dart';
import 'package:asteria_app/features/affirmation/recorded_affirmations.dart';
import 'package:asteria_app/features/affirmation/widgets/affirmation_card_widget.dart';
import 'package:asteria_app/features/practices/presentation/practice_notes_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A specific affirmation and its matching catalog artwork.
class AffirmationSelection {
  const AffirmationSelection({required this.affirmation, this.imageIndex = 0});
  final AffirmationModel affirmation;
  final int imageIndex;
}

class SelectedAffirmationPlayer extends StatelessWidget {
  const SelectedAffirmationPlayer({super.key, required this.selection});
  final AffirmationSelection selection;

  @override
  Widget build(BuildContext context) {
    final affirmation = selection.affirmation;
    final id = 'affirmation:${affirmation.id}';
    final categoryId = affirmation.effectiveCategoryId;
    final l = context.l10n;
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    final hasNotes =
        context.watch<UserProvider?>()?.currentUser?.id.isNotEmpty == true;
    final category = switch (categoryId) {
      'love' => l.affirmationCategoryLove,
      'abundance' => l.affirmationCategoryAbundance,
      'strength' => l.affirmationCategoryStrength,
      'creativity' => l.affirmationCategoryCreativity,
      'lunar' => l.affirmationCategoryLunar,
      'calm' => l.affirmationCategoryCalm,
      _ => affirmation.category,
    };

    final scene = switch (categoryId) {
      'abundance' => PracticeScene.dawn,
      'strength' => PracticeScene.ribbon,
      'creativity' => PracticeScene.bloom,
      'lunar' => PracticeScene.moon,
      _ => PracticeScene.dusk,
    };
    final recording = lookupRecordedAffirmation(
      affirmation.id,
      catalogText: affirmation.text,
      ru: ru,
    );
    final cover = AffirmationCardWidget.artworkFor(
      categoryId,
      selection.imageIndex,
      affirmationId: affirmation.id,
    );
    if (recording != null) {
      return RecordedAffirmationPlayer(
        recording: recording,
        portraitAsset: cover,
        displayTitle:
            ru &&
                recording.catalogId != null &&
                !longAffirmationRecordings.containsKey(affirmation.id)
            ? category
            : null,
        scene: recording.catalogId == null ? null : scene,
      );
    }

    return AffirmationPlayerScreen(
      showBack: true,
      onOpenNotes: hasNotes
          ? () => openPracticeNotes(
              context,
              practiceId: id,
              practiceTitle: affirmation.text,
            )
          : null,
      session: PracticePlayerSession(
        id: id,
        title: category,
        category: l.affirmationsTitle,
        metadata: ru ? '30\u00a0сек' : '30 sec',
        duration: const Duration(seconds: 30),
        transcript: [(0, affirmation.text)],
        previewLabel: ru ? 'Пока без озвучки' : 'Voice recording coming soon',
        scene: scene,
        portraitAsset: cover,
      ),
    );
  }
}

class DefaultAffirmationPlayer extends StatelessWidget {
  const DefaultAffirmationPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    final recording = lookupRecordedAffirmation(
      'asteria-recording:time',
      ru: ru,
    );
    if (recording == null) {
      return const AffirmationPlayerScreen();
    }
    return RecordedAffirmationPlayer(recording: recording, showBack: false);
  }
}

class RecordedAffirmationPlayer extends StatelessWidget {
  const RecordedAffirmationPlayer({
    super.key,
    required this.recording,
    this.portraitAsset,
    this.displayTitle,
    this.scene,
    this.showBack = true,
    this.autoPlay = false,
    this.showClassicActions,
    this.onCompleted,
  });

  final RecordedAffirmation recording;
  final String? portraitAsset;
  final String? displayTitle;
  final PracticeScene? scene;
  final bool showBack, autoPlay;
  final bool? showClassicActions;
  final VoidCallback? onCompleted;

  @override
  Widget build(BuildContext context) {
    final hasNotes =
        context.watch<UserProvider?>()?.currentUser?.id.isNotEmpty == true;
    final useLotus = recording.slug == 'time';
    final ru = Localizations.localeOf(context).languageCode == 'ru';

    return AffirmationPlayerScreen(
      key: ValueKey(recording.asset),
      showBack: showBack,
      showClassicActions: showClassicActions ?? (useLotus && !showBack),
      autoPlay: autoPlay,
      onCompleted: onCompleted,
      onOpenNotes: hasNotes
          ? () => openPracticeNotes(
              context,
              practiceId: recording.notesId,
              practiceTitle: recording.title,
            )
          : null,
      session: PracticePlayerSession(
        id: recording.notesId,
        title: displayTitle ?? recording.title,
        category: context.l10n.affirmationsTitle,
        metadata: recording.durationLabel(ru: ru),
        duration: recording.duration,
        audioAsset: recording.asset,
        transcript: recording.transcript,
        previewLabel: ru ? 'Озвучка недоступна' : 'Recording unavailable',
        scene: scene ?? (useLotus ? PracticeScene.lotus : PracticeScene.dusk),
        portraitAsset: useLotus ? null : portraitAsset,
      ),
    );
  }
}

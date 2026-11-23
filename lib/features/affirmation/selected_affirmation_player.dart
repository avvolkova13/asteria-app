import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/affirmation/player/affirmation_player_screen.dart';
import 'package:asteria_app/features/affirmation/player/player_artwork.dart';
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
        scene: switch (categoryId) {
          'abundance' => PracticeScene.dawn,
          'strength' => PracticeScene.ribbon,
          'creativity' => PracticeScene.bloom,
          'lunar' => PracticeScene.moon,
          _ => PracticeScene.dusk,
        },
        portraitAsset: AffirmationCardWidget.artworkFor(
          categoryId,
          selection.imageIndex,
        ),
      ),
    );
  }
}

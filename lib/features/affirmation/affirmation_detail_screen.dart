import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_bar_geometry.dart';
import 'package:asteria_app/features/affirmation/widgets/affirmation_card_widget.dart';
import 'package:flutter/material.dart';

/// Text affirmations have no recording in the content model. Keep the selected
/// card separate from the bundled "I have time" audio practice.
class AffirmationSelection {
  const AffirmationSelection({required this.affirmation, this.imageIndex = 0});
  final AffirmationModel affirmation;
  final int imageIndex;
}

class AffirmationDetailScreen extends StatelessWidget {
  const AffirmationDetailScreen({super.key, required this.selection});
  final AffirmationSelection selection;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final category = switch (selection.affirmation.effectiveCategoryId) {
      'love' => l.affirmationCategoryLove,
      'abundance' => l.affirmationCategoryAbundance,
      'strength' => l.affirmationCategoryStrength,
      'creativity' => l.affirmationCategoryCreativity,
      'lunar' => l.affirmationCategoryLunar,
      'calm' => l.affirmationCategoryCalm,
      _ => selection.affirmation.category,
    };
    return Scaffold(
      backgroundColor: AppColorsDark.homeCanvas,
      body: SafeArea(
        child: Column(
          children: [
            AsteriaTopBarFrame(
              child: Row(
                children: [
                  LotusButtons.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: l.commonBack,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const LotusArrowBubble(back: true),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        l.affirmationsTitle,
                        style: AppTypography.navTitle.copyWith(
                          color: AppColors.textInverse,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            category,
                            style: AppTypography.h2.copyWith(
                              color: AppColors.textInverse,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SelectionArea(
                          child: AffirmationCardWidget(
                            affirmation: selection.affirmation,
                            imageIndex: selection.imageIndex,
                            showOpenIndicator: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

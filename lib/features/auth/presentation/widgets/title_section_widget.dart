import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class TitleSectionWidget extends StatelessWidget {
  const TitleSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.authCosmicEssence,
          style: AppTypography.navLargeTitle.copyWith(
            color: AppColors.textInverse,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          context.l10n.authMoonRhythms,
          style: AppTypography.text1.copyWith(color: const Color(0xFFB5AAB8)),
        ),
        const SizedBox(height: 15),
        Text(
          context.l10n.authBirthDetailsPrompt,
          style: AppTypography.h2.copyWith(color: AppColors.textInverse),
        ),
      ]),
    );
  }
}

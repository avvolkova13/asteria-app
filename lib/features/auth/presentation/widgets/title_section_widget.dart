import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class TitleSectionWidget extends StatelessWidget {
  const TitleSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.authCosmicEssence,
          style: context.textTheme.inversePlayfairBold32.copyWith(
            fontSize: 34,
            height: 1.2,
            letterSpacing: 0.374,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          context.l10n.authMoonRhythms,
          style: context.textTheme.inverseUrbanistRegular16.copyWith(
            color: const Color(0xFFB5AAB8),
            height: 1.2,
            letterSpacing: -0.408,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          context.l10n.authBirthDetailsPrompt,
          style: context.textTheme.inversePlayfairSemiBold24.copyWith(
            height: 1,
          ),
        ),
      ],
    );
  }
}

import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:flutter/material.dart';

/// A quiet visual reflection; no playback controller or audio session.
class IntroMoodArtwork extends StatelessWidget {
  const IntroMoodArtwork({super.key});

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(AsteriaCardRadii.card));
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: CardLensDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColorsDark.modal,
                AppColorsDark.modal.withValues(alpha: .65),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Image.asset(
              'assets/images/affirmation/lavender-clay-lotus.webp',
              key: const ValueKey('intro-mood-flower'),
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    );
  }
}

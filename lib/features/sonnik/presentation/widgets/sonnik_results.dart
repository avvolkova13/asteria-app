import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:flutter/material.dart';

class SonnikResults extends StatelessWidget {
  final SonnikModel sonnik;
  final VoidCallback onDecodeAgainPressed;

  const SonnikResults({
    required this.sonnik,
    required this.onDecodeAgainPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AsteriaEntrance.sections([
        Text(
          sonnik.title,
          style: context.textTheme.inversePlayfairSemiBold24,
        ),
        const SizedBox(height: 16),
        Text(
          sonnik.interpretation,
          style: context.textTheme.inverseUrbanistRegular16.copyWith(
            color: SonnikPalette.white.withValues(alpha: 0.84),
            height: 1.42,
          ),
        ),
        const SizedBox(height: 28),
        SonnikGradientButton(
          text: context.l10n.dreamDecodeAgain,
          onPressed: onDecodeAgainPressed,
        ),
        const SizedBox(height: 18),
        LotusButtons.text(
          onPressed: () {
            CreateSonnikHistoryRoute.pushReplacement(context);
          },
          style: TextButton.styleFrom(
            foregroundColor: SonnikPalette.white,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            context.l10n.viewHistory,
            style: context.textTheme.inverseUrbanistSemiBold17.copyWith(
              decoration: TextDecoration.underline,
              decorationColor: SonnikPalette.white,
            ),
          ),
        ),
        const SizedBox(height: 60),
      ]),
    );
  }
}

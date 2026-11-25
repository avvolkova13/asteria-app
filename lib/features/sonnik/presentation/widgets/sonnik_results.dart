import 'package:asteria_app/core/ui_kit/widgets/saved_result_language_notice.dart';
import 'package:asteria_app/core/ui_kit/widgets/responsive_heading.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';
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
    final tablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AsteriaEntrance.sections([
            if (savedResultLanguageNotice(context, sonnik.locale)
                case final notice?)
              notice,
            ResponsiveHeading(
              sonnik.title,
              style: context.textTheme.inversePlayfairSemiBold24.copyWith(
                fontSize: tablet ? 32 : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              sonnik.interpretation,
              style: context.textTheme.inverseUrbanistRegular16.copyWith(
                fontSize: tablet ? 19 : null,
                color: SonnikPalette.white.withValues(alpha: 0.84),
                height: 1.42,
              ),
            ),
            const SizedBox(height: 28),
            SonnikGradientButton(
              text: context.l10n.dreamDecodeAgain,
              onPressed: onDecodeAgainPressed,
            ),
          ]),
        ),
      ),
    );
  }
}

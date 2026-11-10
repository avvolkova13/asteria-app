import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class CompatibilityLoading extends StatelessWidget {
  const CompatibilityLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoadingBlock(
          loadingTexts: [
            context.l10n.astrologyLoadingChart,
            context.l10n.astrologyLoadingStars,
            context.l10n.astrologyLoadingSymbols,
            context.l10n.astrologyLoadingPersonal,
          ],
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

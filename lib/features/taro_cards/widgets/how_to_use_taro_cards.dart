import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class HowToUseTaroCards extends StatelessWidget {
  const HowToUseTaroCards({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final height = (media.size.height - media.padding.top - 12).clamp(
      0.0,
      540.0,
    );
    return ModalGlassSurface(
      height: height,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              height: 4,
              width: 64,
              decoration: BoxDecoration(
                color: ModalGlassTokens.grabber,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: AsteriaEntrance.sections([
                    Text(
                      context.l10n.deckHowToUse,
                      style: AppTypography.h2.copyWith(
                        color: ModalGlassTokens.text,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.tarotHowToSteps,
                      style: AppTypography.text1.copyWith(
                        color: ModalGlassTokens.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: LotusRasterIcon(
                            'assets/icons/magic_wand.png',
                            height: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.l10n.tarotHowToReminder,
                            style: AppTypography.text1.copyWith(
                              color: ModalGlassTokens.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

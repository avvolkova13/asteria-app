import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class _HowToUseRunesColors {
  static const surface = Color(0xFF140725);
  static const grabber = Color(0xFF332544);
  static const text = Color(0xFFEEEAFD);
}

class HowToUseRunes extends StatelessWidget {
  const HowToUseRunes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxHeight = screenHeight * 0.9;
    final minHeight = maxHeight < 560.0 ? maxHeight : 560.0;
    final modalHeight = (screenHeight * 0.72)
        .clamp(minHeight, maxHeight)
        .toDouble();

    return SizedBox(
      height: modalHeight,
      child: ModalGlassSurface(
        color: _HowToUseRunesColors.surface,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: AsteriaEntrance.sections([
                const SizedBox(height: 16),
                Container(
                  height: 4,
                  width: 64,
                  decoration: BoxDecoration(
                    color: _HowToUseRunesColors.grabber,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.runesHowToUse,
                  style: context.textTheme.playfairSemiBold24.copyWith(
                    color: AppColors.white,
                    height: 1,
                    letterSpacing: 0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: AsteriaEntrance.sections([
                        Text(
                          context.l10n.runesHowToIntroduction,
                          style: context.textTheme.urbanistRegular16.copyWith(
                            color: _HowToUseRunesColors.text,
                            height: 1.2,
                            letterSpacing: -0.408,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 8),
                        ClipRect(
                          child: Align(
                            alignment: Alignment.center,
                            heightFactor: 0.75,
                            child: Image.asset(
                              'assets/images/home/runes_bag.webp',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.runesHowToSteps,
                          style: context.textTheme.urbanistRegular16.copyWith(
                            color: _HowToUseRunesColors.text,
                            height: 1.2,
                            letterSpacing: -0.408,
                          ),
                          textAlign: TextAlign.left,
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
                                context.l10n.runesHowToReminder,
                                style: context.textTheme.urbanistRegular16
                                    .copyWith(
                                      color: _HowToUseRunesColors.text,
                                      height: 1.2,
                                      letterSpacing: -0.408,
                                    ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ]),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

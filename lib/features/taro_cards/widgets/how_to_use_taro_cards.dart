import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class HowToUseTaroCards extends StatelessWidget {
  const HowToUseTaroCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 540,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: AsteriaEntrance.sections([
              const SizedBox(height: 16),
              // Drag indicator
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 64,
                decoration: BoxDecoration(
                  color: AppColors.uiDisabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Заголовок
              Text(
                context.l10n.deckHowToUse,
                style: context.textTheme.playfairSemiBold24,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Контент
              Expanded(
                child: Text(
                  context.l10n.tarotHowToSteps,
                  style: context.textTheme.urbanistRegular16,
                  textAlign: TextAlign.left,
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
                      style: context.textTheme.urbanistRegular16,
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
    );
  }
}

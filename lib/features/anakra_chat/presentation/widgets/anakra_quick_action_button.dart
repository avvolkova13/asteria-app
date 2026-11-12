import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:flutter/material.dart';

class AnakraQuickActionButton extends StatelessWidget {
  const AnakraQuickActionButton({
    super.key,
    required this.text,
    required this.onPressed,
  });
  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final radius = BorderRadius.circular(AsteriaCardRadii.tile);
    return Semantics(
      button: true,
      enabled: enabled,
      child: DecoratedBox(
        decoration: CardLensDecoration.button(
          borderRadius: radius,
          color: AppColorsDark.modal,
          enabled: enabled,
        ),
        child: Material(
          color: Colors.transparent,
          child: LotusInkTap(
            onTap: onPressed,
            borderRadius: radius,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: AppTypography.text1SemiBold.copyWith(
                    color: enabled
                        ? AppColorsDark.linkGold
                        : AppColors.uiDisabledText,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:flutter/material.dart';

class TarotSphereChip extends StatelessWidget {
  const TarotSphereChip({
    super.key,
    required this.title,
    required this.iconName,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String iconName;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = selected ? AppColors.textPrimary : AppColorsDark.linkGold;
    return Semantics(
      button: true,
      selected: selected,
      child: LotusTap(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: CardLensDecoration.button(
            color: selected ? AppColorsDark.linkGold : AppColorsDark.modal,
            borderRadius: BorderRadius.circular(AsteriaCardRadii.compact),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClayAssetIcon(
                'assets/icons/sphere_icon/$iconName.svg',
                width: 20,
                height: 20,
                tint: ink,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: AppTypography.text1SemiBold.copyWith(color: ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

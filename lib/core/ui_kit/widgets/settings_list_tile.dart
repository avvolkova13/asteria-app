import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool? isExit;
  final String icon;
  const SettingsListTile({
    super.key,
    required this.title,
    required this.onTap,
    this.isExit = false,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: LotusTap(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        decoration: CardLensDecoration.button(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 34,
              child: LotusIconSurface(
                child: Center(
                  child: ClayAssetIcon(
                    isExit == true
                        ? 'assets/icons/exit_icon.svg'
                        : 'assets/icons/$icon.svg',
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: context.textTheme.urbanistRegular17.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            if (isExit != true &&
                MediaQuery.textScalerOf(context).scale(17) <= 22) ...[
              const SizedBox(width: 12),
              const LotusArrowBubble(),
            ],
          ],
        ),
      ),
    ),
  );
}

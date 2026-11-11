import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:flutter/material.dart';

class RepeatButtonWidget extends StatelessWidget {
  const RepeatButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 6.0),
      child: LotusIconSurface(
        diameter: 32,
        child: ClayAssetIcon(
          'assets/icons/repeat_icon.svg',
          width: 24,
          height: 24,
        ),
      ),
    );
  }
}

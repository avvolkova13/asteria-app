import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:flutter/material.dart';

class RepeatButtonWidget extends StatelessWidget {
  const RepeatButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: LotusArrowBubble.hitExtent,
      child: Center(child: LotusRefreshBubble()),
    );
  }
}

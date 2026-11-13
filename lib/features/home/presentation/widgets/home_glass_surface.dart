import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';

import 'package:flutter/material.dart';

/// The tinted surfaces on the Asteria home canvas share one beveled rim.
class HomeGlassSurface extends StatelessWidget {
  const HomeGlassSurface({
    super.key,
    this.animateEntrance = true,
    this.radius = AsteriaCardRadii.card,
    this.tint = const Color(0x339A7DB8),
    required this.child,
  });

  final bool animateEntrance;
  final double radius;
  final Color tint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AsteriaEntrance(
      animateInitially: animateEntrance,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: DecoratedBox(
          decoration: CardLensDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: tint,
          ),
          child: child,
        ),
      ),
    );
  }
}

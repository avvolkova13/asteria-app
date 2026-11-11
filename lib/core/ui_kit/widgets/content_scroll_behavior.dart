import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Keep a vertical page parked above its bottom controls, while allowing
/// native pull-to-refresh at the top and native overscroll in horizontal lists.
class ContentScrollBehavior extends MaterialScrollBehavior {
  const ContentScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    final platformPhysics = super.getScrollPhysics(context);
    if (getPlatform(context) != TargetPlatform.iOS) return platformPhysics;
    return _ContentEndPhysics(parent: platformPhysics);
  }
}

class _ContentEndPhysics extends ScrollPhysics {
  const _ContentEndPhysics({super.parent});

  @override
  _ContentEndPhysics applyTo(ScrollPhysics? ancestor) =>
      _ContentEndPhysics(parent: buildParent(ancestor));

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (position.axisDirection == AxisDirection.down &&
        value > position.maxScrollExtent &&
        value > position.pixels) {
      return value - math.max(position.pixels, position.maxScrollExtent);
    }
    return super.applyBoundaryConditions(position, value);
  }
}

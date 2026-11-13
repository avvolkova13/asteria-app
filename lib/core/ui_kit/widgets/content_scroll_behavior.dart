import 'dart:math' as math;

import 'package:asteria_app/core/ui_kit/app_colors/app_colors.dart';
import 'package:flutter/material.dart';

/// Keep a vertical page parked above its bottom controls, while allowing
/// native pull-to-refresh at the top and native overscroll in horizontal lists.
class ContentScrollBehavior extends MaterialScrollBehavior {
  const ContentScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    final platform = getPlatform(context);
    if (axisDirectionToAxis(details.direction) != Axis.vertical ||
        (platform != TargetPlatform.iOS &&
            platform != TargetPlatform.android)) {
      return super.buildScrollbar(context, child, details);
    }
    final darkSurface =
        ThemeData.estimateBrightnessForColor(
          Theme.of(context).colorScheme.surface,
        ) ==
        Brightness.dark;
    final tint = darkSurface ? AppColors.cardTinted : AppColors.uiPressed;
    return RawScrollbar(
      controller: details.controller,
      thumbColor: tint.withValues(
        alpha: MediaQuery.highContrastOf(context) ? 0.9 : 0.65,
      ),
      thickness: 3,
      radius: const Radius.circular(3),
      crossAxisMargin: 2,
      mainAxisMargin: 5,
      interactive: false,
      fadeDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 180),
      timeToFade: const Duration(milliseconds: 480),
      child: child,
    );
  }

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

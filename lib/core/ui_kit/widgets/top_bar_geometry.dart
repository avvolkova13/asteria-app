import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shared toolbar geometry. SafeArea belongs to the screen or sliver, once.
abstract final class AsteriaTopBarMetrics {
  static const double toolbarHeight = 52;
  static const double horizontalInset = 16;

  static double heightOf(BuildContext context) => math.max(
    toolbarHeight,
    MediaQuery.textScalerOf(context).scale(17) * 1.2 + 8,
  );
}

class AsteriaTopBarFrame extends StatelessWidget {
  const AsteriaTopBarFrame({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AsteriaTopBarMetrics.horizontalInset,
    ),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      minHeight: AsteriaTopBarMetrics.heightOf(context),
    ),
    child: Center(
      heightFactor: 1,
      child: Padding(padding: padding, child: child),
    ),
  );
}

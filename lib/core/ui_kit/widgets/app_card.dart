import 'package:flutter/material.dart';
import '../../extensions/build_context_extensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool hasGradient;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
    this.onTap,
    this.hasGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      margin: margin ?? EdgeInsets.all(context.spacing.small),
      decoration: BoxDecoration(
        color: hasGradient
            ? null
            : (backgroundColor ?? context.colors.cardBackground),
        gradient: hasGradient
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [context.colors.primary, context.colors.accent],
              )
            : null,
        borderRadius: borderRadius ?? context.corners.medium,
        boxShadow: [
          BoxShadow(
            color: context.colors.overlay,
            blurRadius: elevation ?? 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(context.spacing.medium),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? context.corners.medium,
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}

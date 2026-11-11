import 'package:asteria_app/core/ui_kit/app_colors/app_colors.dart';
import 'package:flutter/material.dart';

import 'card_lens_decoration.dart';

/// Shared field shell. Editing, validation and hit targets belong to the child.
class InputBubbleSurface extends StatefulWidget {
  const InputBubbleSurface({
    super.key,
    required this.child,
    this.enabled = true,
    this.hasError = false,
    this.focused = false,
    this.surfaceBrightness,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
  });

  final Widget child;
  final bool enabled;
  final bool hasError;
  final bool focused;
  final Brightness? surfaceBrightness;
  final BorderRadiusGeometry borderRadius;

  @override
  State<InputBubbleSurface> createState() => _InputBubbleSurfaceState();
}

class _InputBubbleSurfaceState extends State<InputBubbleSurface> {
  bool _childFocused = false;

  void _onFocusChanged(bool focused) {
    if (_childFocused != focused) setState(() => _childFocused = focused);
  }

  @override
  Widget build(BuildContext context) {
    final dark =
        (widget.surfaceBrightness ?? Theme.of(context).brightness) ==
        Brightness.dark;
    final focused = widget.enabled && (widget.focused || _childFocused);
    final opacity = widget.enabled ? 1.0 : .42;
    final edge = widget.hasError
        ? AppColors.error
        : focused
        ? (dark ? AppColors.cardTinted : AppColors.primary)
        : (dark ? AppColors.white : AppColors.primary);
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: _onFocusChanged,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: focused ? 1.0 : 0.0),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: widget.child,
        builder: (context, focus, child) => DecoratedBox(
          decoration: CardLensDecoration(
            borderRadius: widget.borderRadius,
            intensity: opacity * (.40 + focus * .16),
            border: Border.all(
              color: edge.withValues(
                alpha: opacity * (widget.hasError ? .85 : .17 + focus * .43),
              ),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? [
                      AppColors.cardTinted.withValues(alpha: opacity * .19),
                      AppColors.primary.withValues(alpha: opacity * .12),
                      AppColors.cardTinted.withValues(alpha: opacity * .12),
                    ]
                  : [
                      AppColors.white.withValues(alpha: opacity * .85),
                      AppColors.cardTinted.withValues(alpha: opacity * .46),
                      AppColors.white.withValues(alpha: opacity * .66),
                    ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

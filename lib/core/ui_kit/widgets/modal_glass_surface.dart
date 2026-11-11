import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../app_colors/app_colors.dart';
import '../app_typography.dart';
import '../card_radii.dart';
import 'card_lens_decoration.dart';

/// Shared palette for app-owned transient surfaces, independent of legacy pages.
abstract final class ModalGlassTokens {
  static const surface = AppColorsDark.modal;
  static const text = AppColors.textInverse;
  static const muted = Color(0xCCFFFFFF);
  static const grabber = AppColorsDark.divider;
  static const barrier = Color(0xCC0F0A1A);
  static const headingGradient = LinearGradient(
    colors: [AppColors.textInverse, AppColors.background],
  );
}

/// A bounded, stationary lens over the actual route below the modal.
class ModalGlassSurface extends StatelessWidget {
  const ModalGlassSurface({
    super.key,
    this.color = ModalGlassTokens.surface,
    required this.child,
    this.height,
    this.sheet = true,
  });

  final Color color;
  final Widget child;
  final double? height;
  final bool sheet;

  @override
  Widget build(BuildContext context) {
    final radius = sheet
        ? const BorderRadius.vertical(
            top: Radius.circular(AsteriaCardRadii.card),
            bottom: Radius.circular(AsteriaCardRadii.compact),
          )
        : const BorderRadius.all(Radius.circular(AsteriaCardRadii.card));
    final opaque = MediaQuery.highContrastOf(context);
    final panel = DecoratedBox(
      decoration: CardLensDecoration(
        borderRadius: radius,
        color: color.withValues(alpha: opaque ? 1 : .87),
        intensity: opaque ? .32 : .72,
      ),
      child: child,
    );
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: radius,
        child: opaque
            ? panel
            : BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: panel,
              ),
      ),
    );
  }
}

/// Keeps content and actions apart when they fit, and scrolls when text grows.
/// Supply ordinary content groups, without vertical Expanded or Spacer children.
class ModalGlassScrollBody extends StatelessWidget {
  const ModalGlassScrollBody({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      ),
    ),
  );
}

/// Uses Dialog's native keyboard insets, focus traversal and dialog semantics.
class ModalGlassAlert extends StatelessWidget {
  const ModalGlassAlert({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.color,
    this.titlePadding = const EdgeInsets.fromLTRB(24, 24, 24, 0),
    this.contentPadding = const EdgeInsets.fromLTRB(24, 16, 24, 16),
    this.actionsPadding = const EdgeInsets.fromLTRB(16, 0, 16, 12),
  });

  final Widget title;
  final Widget content;
  final List<Widget> actions;
  final Color? color;
  final EdgeInsets titlePadding;
  final EdgeInsets contentPadding;
  final EdgeInsets actionsPadding;

  @override
  Widget build(BuildContext context) {
    final surface = color ?? ModalGlassTokens.surface;
    final ink = ThemeData.estimateBrightnessForColor(surface) == Brightness.dark
        ? AppColors.textInverse
        : AppColors.textPrimary;
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
      child: ModalGlassSurface(
        color: surface,
        sheet: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: titlePadding,
                child: Semantics(
                  namesRoute: true,
                  header: true,
                  child: DefaultTextStyle(
                    style: AppTypography.h2.copyWith(color: ink),
                    child: title,
                  ),
                ),
              ),
              Padding(
                padding: contentPadding,
                child: DefaultTextStyle(
                  style: AppTypography.text1.copyWith(color: ink),
                  child: content,
                ),
              ),
              Padding(
                padding: actionsPadding,
                child: OverflowBar(
                  alignment: MainAxisAlignment.end,
                  overflowAlignment: OverflowBarAlignment.end,
                  children: actions,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Material transient messages paint the same optical perimeter as modal cards.
class ModalLensBorder extends RoundedRectangleBorder {
  const ModalLensBorder()
    : super(
        borderRadius: const BorderRadius.all(
          Radius.circular(AsteriaCardRadii.tile),
        ),
      );

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    CardLensDecoration.paintFinish(
      canvas,
      borderRadius.resolve(textDirection).toRRect(rect),
      intensity: .58,
    );
  }
}

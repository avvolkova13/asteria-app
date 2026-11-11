import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';

import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_glyph_motion.dart';

import 'package:asteria_app/core/ui_kit/widgets/lotus_sprite.dart';

enum ClayGlyph {
  play,
  pause,
  share,
  bookmark,
  saved,
  repeat,
  close,
  chevron,
  spark,
}

class PlayerClayGlyph extends StatelessWidget {
  const PlayerClayGlyph(this.glyph, this.size, {super.key, this.frame = 0});
  final ClayGlyph glyph;
  final double size;
  final int frame;

  @override
  Widget build(BuildContext context) {
    if (glyph == ClayGlyph.share) {
      return ClayIcon(Icons.ios_share, size: size, color: Colors.white);
    }
    return LotusSprite(LotusPose.values[glyph.index], size: size, frame: frame);
  }
}

class PlayerPebble extends StatefulWidget {
  const PlayerPebble({
    super.key,
    required this.glyph,
    required this.label,
    required this.onTap,
    this.value,
    this.primary = false,
    this.compact = false,
  });
  final ClayGlyph glyph;
  final String label;
  final VoidCallback onTap;
  final bool? value;
  final bool primary;
  final bool compact;

  @override
  State<PlayerPebble> createState() => _PlayerPebbleState();
}

class _PlayerPebbleState extends State<PlayerPebble>
    with SingleTickerProviderStateMixin {
  late final _animation = AnimationController(
    vsync: this,
    duration: LotusMotionScope.duration,
  );
  bool _pressed = false;
  bool _focused = false;

  void _activate() {
    LotusFeedback.selection();
    if (!MediaQuery.disableAnimationsOf(context)) _animation.forward(from: 0);
    widget.onTap();
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glyph = widget.glyph;
    final header = glyph == ClayGlyph.close || glyph == ClayGlyph.repeat;
    final width = widget.primary
        ? (widget.compact ? 56.0 : 84.0)
        : header
        ? 47.0
        : 49.0;
    final height = widget.primary
        ? (widget.compact ? 56.0 : 75.0)
        : header
        ? 44.0
        : 45.0;
    final glyphSize = widget.primary
        ? (widget.compact ? 28.0 : 46.0)
        : glyph == ClayGlyph.close
        ? 19.5
        : header
        ? 24.0
        : 26.0;
    final inset = header || widget.primary ? 0.0 : 2.0;
    final w = width - 2 * inset;
    final h = height - 2 * inset;
    final contour = switch (glyph) {
      ClayGlyph.repeat => LotusPebbleContour.repeat,
      ClayGlyph.bookmark || ClayGlyph.saved => LotusPebbleContour.bookmark,
      ClayGlyph.play || ClayGlyph.pause => LotusPebbleContour.play,
      _ => LotusPebbleContour.action,
    };
    final shape = contour.resolve(w, h);
    return Semantics(
      container: true,
      label: widget.label,
      toggled: widget.value,
      enabled: true,
      button: widget.value == null,
      onTap: _activate,
      excludeSemantics: true,
      child: FocusableActionDetector(
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _activate,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          child: SizedBox(
            width: width,
            height: height,
            child: AnimatedScale(
              scale: _pressed && !MediaQuery.disableAnimationsOf(context)
                  ? LotusMotionScope.pressedScale
                  : 1,
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : LotusMotionScope.pressDuration,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.all(inset),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: shape,
                          boxShadow: const [
                            BoxShadow(
                              offset: Offset(0, 3),
                              blurRadius: 7,
                              spreadRadius: -3,
                              color: Color(0x453e2948),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: shape,
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: CustomPaint(
                              painter: LotusSurfacePainter(
                                shape,
                                _pressed || widget.value == true,
                                _focused,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (_, _) {
                      final glyphArt = PlayerClayGlyph(
                        glyph,
                        glyphSize,
                        frame: _animation.isAnimating
                            ? (_animation.value * 15).floor()
                            : 0,
                      );
                      final icon = glyph == ClayGlyph.share
                          ? LotusMotionScope(pulse: _animation, child: glyphArt)
                          : glyphArt;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, 1),
                            child: ImageFiltered(
                              imageFilter: ui.ImageFilter.blur(
                                sigmaX: .6,
                                sigmaY: .7,
                              ),
                              child: ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Color(0x7a795a80),
                                  BlendMode.srcIn,
                                ),
                                child: icon,
                              ),
                            ),
                          ),
                          icon,
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

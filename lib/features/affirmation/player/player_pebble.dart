import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';

import 'player_artwork.dart';

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
    return SizedBox.square(
      dimension: size,
      child: ClipRect(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -size * frame,
              top: -size * glyph.index,
              width: size * 16,
              height: size * 9,
              child: Image.asset(
                '$playerArtDirectory/iconity-clay.webp',
                fit: BoxFit.fill,
                excludeFromSemantics: true,
              ),
            ),
          ],
        ),
      ),
    );
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
    duration: const Duration(milliseconds: 400),
  );
  bool _pressed = false;
  bool _focused = false;

  void _activate() {
    HapticFeedback.selectionClick();
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
        ? 46.0
        : glyph == ClayGlyph.close
        ? 19.5
        : header
        ? 24.0
        : 26.0;
    final inset = header || widget.primary ? 0.0 : 2.0;
    final w = width - 2 * inset;
    final h = height - 2 * inset;
    final radii = switch (glyph) {
      ClayGlyph.repeat => [.54, .46, .50, .50, .55, .55, .45, .45],
      ClayGlyph.bookmark ||
      ClayGlyph.saved => [.54, .46, .51, .49, .54, .58, .42, .46],
      ClayGlyph.play ||
      ClayGlyph.pause => [.52, .48, .46, .54, .60, .57, .43, .40],
      _ => [.49, .51, .45, .55, .56, .54, .46, .44],
    };
    final shape = BorderRadius.only(
      topLeft: Radius.elliptical(w * radii[0], h * radii[4]),
      topRight: Radius.elliptical(w * radii[1], h * radii[5]),
      bottomRight: Radius.elliptical(w * radii[2], h * radii[6]),
      bottomLeft: Radius.elliptical(w * radii[3], h * radii[7]),
    );
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
                  ? .96
                  : 1,
              duration: const Duration(milliseconds: 90),
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
                              painter: _PebbleSurface(
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
                      final icon = PlayerClayGlyph(
                        glyph,
                        glyphSize,
                        frame: _animation.isAnimating
                            ? (_animation.value * 15).floor()
                            : 0,
                      );
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

class _PebbleSurface extends CustomPainter {
  const _PebbleSurface(this.radius, this.active, this.focused);
  final BorderRadius radius;
  final bool active;
  final bool focused;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shape = radius.toRRect(rect);
    void fill(Gradient gradient) =>
        canvas.drawRRect(shape, Paint()..shader = gradient.createShader(rect));
    fill(
      const LinearGradient(
        begin: Alignment(-.5, -1),
        end: Alignment(.5, 1),
        colors: [Color(0x25fbdeef), Color(0x0cfae3ec), Color(0x26c4b4dd)],
      ),
    );
    fill(
      const RadialGradient(
        center: Alignment(-.5, -.84),
        radius: .73,
        colors: [Color(0x34fff5f5), Color(0x00fff5f5)],
      ),
    );
    fill(
      const RadialGradient(
        center: Alignment(.66, .8),
        radius: .76,
        colors: [Color(0x34cbbde7), Color(0x00cbbde7)],
      ),
    );
    if (active) {
      fill(
        const RadialGradient(
          center: Alignment(-.18, -.12),
          radius: .72,
          colors: [Color(0x66fff5ee), Color(0x20f4d8ec), Color(0x00f4d8ec)],
          stops: [0, .6, 1],
        ),
      );
    }
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.1);
    canvas.drawRRect(
      shape.shift(const Offset(0, .75)),
      stroke
        ..color = const Color(0x5efff8f5)
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x9afff8f5), Color(0x30f9e0f1), Color(0x335e4766)],
        ).createShader(rect),
    );
    // A narrow directional rim follows the upper edge of the clay surface.
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .85
      ..shader = const LinearGradient(
        begin: Alignment(-.55, -1),
        end: Alignment(.4, 1),
        colors: [
          Color(0xa8fff8f5),
          Color(0x48f9e0f1),
          Color(0x115e4766),
          Color(0x355e4766),
        ],
        stops: [0, .32, .72, 1],
      ).createShader(rect);
    canvas.drawRRect(shape.deflate(.45), rim);
    if (focused) {
      canvas.drawRRect(
        shape.deflate(1),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xfff3cbab),
      );
    }
  }

  @override
  bool shouldRepaint(_PebbleSurface old) =>
      radius != old.radius || active != old.active || focused != old.focused;
}

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:asteria_app/core/ui_kit/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  ui.Image? _atlas;
  bool _holdsLaunchFrame = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    // Hand off from the matching native image only when Flutter can paint it.
    if (!WidgetsBinding.instance.firstFrameRasterized) {
      WidgetsBinding.instance.deferFirstFrame();
      _holdsLaunchFrame = true;
    }
    _loadMark();
  }

  Future<void> _loadMark() async {
    try {
      final data = await rootBundle.load(
        'assets/images/auth/asteria_mark_layers.png',
      );
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      late final ui.Image image;
      try {
        image = (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() => _atlas = image);
      if (!MediaQuery.disableAnimationsOf(context)) _motion.forward();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      _releaseLaunchFrame();
    }
  }

  void _releaseLaunchFrame() {
    if (_holdsLaunchFrame) {
      _holdsLaunchFrame = false;
      WidgetsBinding.instance.allowFirstFrame();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) _motion.value = 1;
  }

  @override
  void dispose() {
    _releaseLaunchFrame();
    _motion.dispose();
    _atlas?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final atlas = _atlas;
    return ColoredBox(
      color: AppColorsDark.homeCanvas,
      child: Center(
        child: Semantics(
          label: 'Asteria',
          image: true,
          child: SizedBox.square(
            dimension: 104,
            child: atlas != null
                ? CustomPaint(painter: _MarkPainter(atlas, _motion))
                : _failed
                ? Image.asset(
                    'assets/images/auth/asteria_mark.png',
                    excludeFromSemantics: true,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

/// The first square is the intact mark; the others are registered crops of
/// its clay letter, pearl profile, and three stars in the same coordinate space.
class _MarkPainter extends CustomPainter {
  _MarkPainter(this.atlas, this.motion) : super(repaint: motion);

  final ui.Image atlas;
  final Animation<double> motion;

  double _pulse(double start, double end) {
    final t = ((motion.value - start) / (end - start)).clamp(0.0, 1.0);
    return math.pow(math.sin(math.pi * t), 2).toDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final side = atlas.width.toDouble();
    final dst = Offset.zero & size;
    final ink = Paint()..filterQuality = FilterQuality.medium;
    void layer(int index) {
      canvas.drawImageRect(
        atlas,
        Rect.fromLTWH(0, index * side, side, side),
        dst,
        ink,
      );
    }

    if (motion.value == 0 || motion.value == 1) {
      layer(0);
      return;
    }
    final lift = _pulse(0, .94);
    final center = dst.center;
    canvas.save();
    canvas.translate(center.dx, center.dy - 1.6 * lift);
    canvas.scale(1 + .045 * lift);
    canvas.translate(-center.dx, -center.dy);
    layer(1);
    canvas.save();
    final face = _pulse(.08, .84);
    canvas.translate(center.dx, size.height * .89);
    canvas.scale(1 + .022 * face);
    canvas.translate(-center.dx, -size.height * .89);
    layer(2);
    canvas.restore();
    const stars = [(0.160, 0.821), (0.198, 0.771), (0.181, 0.744)];
    for (var i = 0; i < stars.length; i++) {
      final pulse = _pulse(.14 + .12 * i, .72 + .12 * i);
      final x = size.width * stars[i].$1;
      final y = size.height * stars[i].$2;
      canvas.save();
      canvas.translate(x, y - .85 * pulse);
      canvas.scale(1 + .32 * pulse);
      canvas.translate(-x, -y);
      layer(3 + i);
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) =>
      oldDelegate.atlas != atlas || oldDelegate.motion != motion;
}

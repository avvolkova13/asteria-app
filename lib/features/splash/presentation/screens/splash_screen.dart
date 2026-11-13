import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'brand_contours.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock;
  ui.FragmentShader? _silk;
  ui.Image? _base;
  ui.Image? _logo;
  bool _started = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _clock =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 3850),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) _finish();
        });
    _loadSilk();
    _loadArtwork();
  }

  Future<ui.Image> _decode(String asset) async {
    final data = await rootBundle.load('assets/images/auth/$asset');
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    try {
      return (await codec.getNextFrame()).image;
    } finally {
      codec.dispose();
    }
  }

  Future<void> _loadArtwork() async {
    final images = await Future.wait(
      [_decode('splash_clay_base.png'), _decode('asteria_mark.png')],
      cleanUp: (image) => image.dispose(),
    ).catchError((Object error) => <ui.Image>[]);
    if (!mounted) {
      for (final image in images) {
        image.dispose();
      }
      return;
    }
    if (images.isEmpty) {
      _finish();
      return;
    }
    setState(() {
      _base = images.first;
      _logo = images.last;
    });
  }

  Future<void> _loadSilk() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'assets/shaders/splash_fluid.frag',
      );
      if (mounted) setState(() => _silk = program.fragmentShader());
    } catch (_) {
      // The vector mark and the launch handoff work without shader support.
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_finished) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _started = true;
      _clock.stop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _finish();
      });
    } else if (!_started) {
      _started = true;
      _clock.forward();
    }
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    widget.onFinished();
  }

  @override
  void dispose() {
    _clock.dispose();
    _silk?.dispose();
    _base?.dispose();
    _logo?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'Asteria',
    child: RepaintBoundary(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _LaunchPainter(
            _clock,
            _silk,
            _base,
            _logo,
            MediaQuery.disableAnimationsOf(context),
          ),
        ),
      ),
    ),
  );
}

class _LaunchPainter extends CustomPainter {
  _LaunchPainter(this.clock, this.silk, this.base, this.logo, this.still)
    : super(repaint: clock);
  final Animation<double> clock;
  final ui.FragmentShader? silk;
  final ui.Image? base;
  final ui.Image? logo;
  final bool still;
  static final _shapes = [_profile, _starOne, _starTwo, _starThree];
  static final _metrics = [
    for (final shape in _shapes) shape.computeMetrics().first,
  ];
  static const _ivory = Color(0xffffe9d2);
  static double _ramp(double v) {
    final x = v.clamp(0.0, 1.0);
    return x * x * (3 - 2 * x);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = still ? 3.85 : clock.value * 3.85;
    final rect = Offset.zero & size;
    final shader = silk;
    if (shader != null) {
      shader
        ..setFloat(0, size.width)
        ..setFloat(1, size.height)
        ..setFloat(2, t);
      canvas.drawRect(rect, Paint()..shader = shader);
    } else {
      canvas.drawRect(rect, Paint()..color = const Color(0xff100d1c));
    }
    final baseImage = base, markImage = logo;
    final opacity = _ramp((t - .35) / .85);
    if (opacity <= 0 || baseImage == null || markImage == null) return;
    final side = math.min(size.width * .49, size.height * .32);
    canvas.save();
    canvas.translate((size.width - side) / 2, size.height * .4 - side / 2);
    canvas.scale(side / 416);
    const destination = Rect.fromLTWH(0, 0, 416, 416);
    final original = Rect.fromLTWH(
      0,
      0,
      markImage.width.toDouble(),
      markImage.height.toDouble(),
    );
    final ink = Paint()..filterQuality = FilterQuality.medium;
    if (t < 3.18) {
      // Align the opaque bounds of the generated base with the original relief.
      canvas.drawImageRect(
        baseImage,
        Rect.fromLTWH(
          baseImage.width * 30 / 1254,
          baseImage.height * 93 / 1254,
          baseImage.width * 1174 / 1254,
          baseImage.height * 1038 / 1254,
        ),
        const Rect.fromLTWH(
          10 * 416 / 312,
          23 * 416 / 312,
          292 * 416 / 312,
          265 * 416 / 312,
        ),
        ink..color = Colors.white.withValues(alpha: opacity),
      );
      for (var i = 0; i < _shapes.length; i++) {
        final start = i == 0 ? .84 : 1.97 + (i - 1) * .215;
        final elapsed = t - start;
        if (elapsed <= 0) continue;
        final duration = i == 0 ? 1.22 : .34;
        final progress = _ramp(elapsed / duration);
        final fill = _ramp((elapsed - duration * .64) / (i == 0 ? 1.04 : .38));
        final path = _shapes[i], metric = _metrics[i];
        canvas.drawPath(
          metric.extractPath(0, metric.length * progress),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = i == 0 ? 1.6 : 1
            ..color = _ivory.withValues(alpha: .9 * (1 - fill)),
        );
        if (fill <= 0) continue;
        final bounds = path.getBounds().inflate(11);
        canvas.saveLayer(bounds, Paint());
        final texture = ui.ImageShader(
          markImage,
          TileMode.clamp,
          TileMode.clamp,
          (Matrix4.diagonal3Values(
            416 / markImage.width,
            416 / markImage.height,
            1,
          )).storage,
          filterQuality: FilterQuality.medium,
        );
        final relief = Paint()..shader = texture;
        canvas.drawPath(path, relief);
        canvas.drawPath(
          path,
          relief
            ..style = PaintingStyle.stroke
            ..strokeWidth = 21
            ..strokeJoin = StrokeJoin.round,
        );
        if (fill < 1) {
          final edge = bounds.top - 12 + (bounds.height + 30) * fill;
          canvas.drawRect(
            bounds,
            Paint()
              ..blendMode = BlendMode.dstIn
              ..shader = ui.Gradient.linear(
                Offset(0, edge - 18),
                Offset(0, edge + 12),
                [Colors.white, Colors.transparent],
              ),
          );
        }
        canvas.restore();
        texture.dispose();
      }
    }
    if (t > 2.75) {
      canvas.drawImageRect(
        markImage,
        original,
        destination,
        ink..color = Colors.white.withValues(alpha: _ramp((t - 2.75) / .43)),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LaunchPainter old) =>
      old.clock != clock ||
      old.silk != silk ||
      old.base != base ||
      old.logo != logo ||
      old.still != still;
}

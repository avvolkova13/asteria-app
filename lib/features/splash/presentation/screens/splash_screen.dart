import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

part 'brand_contours.dart';
part 'brand_wordmark.dart';

const _artworkDuration = Duration(milliseconds: 3850);
const _finalHold = Duration(seconds: 2);

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onFinished,
    this.destinationReady = true,
  });

  final VoidCallback onFinished;
  final bool destinationReady;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _silkTime = ValueNotifier(Duration.zero);
  final _artworkTime = ValueNotifier(Duration.zero);
  ui.FragmentShader? _silk;
  ui.Image? _base;
  ui.Image? _logo;
  ui.Image? _relief;
  Timer? _startupDeadline;
  bool _firstFrameDeferred = false;
  bool _started = false;
  bool _finished = false;
  bool _nativeArtwork = false;
  static const _artworkChannel = MethodChannel('asteria/launch-artwork');

  @override
  void initState() {
    super.initState();
    var previous = Duration.zero;
    _ticker = createTicker((elapsed) {
      final step = elapsed - previous;
      previous = elapsed;
      // A late frame must not skip a visible section of the silk's drift.
      if (defaultTargetPlatform != TargetPlatform.iOS) {
        _silkTime.value += step > const Duration(milliseconds: 48)
            ? const Duration(milliseconds: 48)
            : step;
      }
      if (!_nativeArtwork) {
        _artworkTime.value = elapsed < _artworkDuration
            ? elapsed
            : _artworkDuration;
      }
      if (!_finished && elapsed >= _artworkDuration + _finalHold) _finish();
    });
    final binding = WidgetsBinding.instance;
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        !binding.firstFrameRasterized) {
      binding.deferFirstFrame();
      _firstFrameDeferred = true;
    }
    Future.wait([_loadSilk(), _loadArtwork()]).whenComplete(() {
      _releaseFirstFrame();
      if (mounted && widget.destinationReady) _startPlayback();
    });
    _startupDeadline = Timer(const Duration(milliseconds: 1400), () {
      _releaseFirstFrame();
      _startPlayback();
    });
  }

  void _releaseFirstFrame() {
    if (!_firstFrameDeferred) return;
    _firstFrameDeferred = false;
    WidgetsBinding.instance.allowFirstFrame();
  }

  void _startPlayback() {
    if (!mounted || _started || _finished || _firstFrameDeferred) return;
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_finished && !MediaQuery.disableAnimationsOf(context)) {
        unawaited(_startArtworkClock());
      }
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  Future<void> _startArtworkClock() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      var playing = false;
      try {
        playing = await _artworkChannel.invokeMethod<bool>('start') ?? false;
      } on MissingPluginException {
        // An embedder without the native renderer uses the vector painter.
      } on PlatformException {
        // The vector renderer also works if the media asset is unavailable.
      }
      if (!mounted || _finished || MediaQuery.disableAnimationsOf(context)) {
        if (playing) await _artworkChannel.invokeMethod<void>('stop');
        return;
      }
      if (playing) setState(() => _nativeArtwork = true);
    }
    _ticker.start();
  }

  @override
  void didUpdateWidget(SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.destinationReady && !oldWidget.destinationReady) {
      _startPlayback();
    }
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
    ui.Image? relief;
    try {
      relief = await _LaunchPainter.bakeRelief(images.last);
    } catch (_) {
      // Use vector drawing when the renderer cannot rasterize offscreen.
    }
    if (!mounted) {
      relief?.dispose();
      for (final image in images) {
        image.dispose();
      }
      return;
    }
    setState(() {
      _base = images.first;
      _logo = images.last;
      _relief = relief;
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
    if (MediaQuery.disableAnimationsOf(context)) {
      _started = true;
      _releaseFirstFrame();
      _ticker.stop();
      if (_finished) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _finish();
      });
    } else if (widget.destinationReady) {
      _startPlayback();
    }
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    widget.onFinished();
  }

  @override
  void dispose() {
    if (_nativeArtwork) unawaited(_artworkChannel.invokeMethod<void>('stop'));
    _startupDeadline?.cancel();
    _releaseFirstFrame();
    _ticker.dispose();
    _silkTime.dispose();
    _artworkTime.dispose();
    _silk?.dispose();
    _base?.dispose();
    _logo?.dispose();
    _relief?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      image: true,
      label: 'Asteria',
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!still && defaultTargetPlatform == TargetPlatform.iOS)
            const ExcludeSemantics(
              child: IgnorePointer(
                child: UiKitView(viewType: 'asteria/launch-silk'),
              ),
            )
          else
            RepaintBoundary(
              child: CustomPaint(
                painter: _SilkPainter(_silkTime, _silk, still),
              ),
            ),
          if (!_nativeArtwork || still)
            RepaintBoundary(
              child: CustomPaint(
                painter: _LaunchPainter(
                  _artworkTime,
                  _base,
                  _logo,
                  _relief,
                  still,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SilkPainter extends CustomPainter {
  _SilkPainter(this.clock, this.silk, this.still) : super(repaint: clock);
  final ValueNotifier<Duration> clock;
  final ui.FragmentShader? silk;
  final bool still;

  @override
  void paint(Canvas canvas, Size size) {
    final time = still ? _artworkDuration : clock.value;
    final shader = silk;
    final paint = Paint()..color = const Color(0xff100d1c);
    if (shader != null) {
      shader
        ..setFloat(0, size.width)
        ..setFloat(1, size.height)
        ..setFloat(2, time.inMicroseconds / Duration.microsecondsPerSecond);
      paint.shader = shader;
    }
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_SilkPainter old) =>
      old.clock != clock || old.silk != silk || old.still != still;
}

class _LaunchPainter extends CustomPainter {
  _LaunchPainter(this.clock, this.base, this.logo, this.reliefAtlas, this.still)
    : super(repaint: clock);
  final ValueNotifier<Duration> clock;
  final ui.Image? base;
  final ui.Image? logo;
  final ui.Image? reliefAtlas;
  final bool still;
  static final _shapes = [_profile, _starOne, _starTwo, _starThree];
  static final _metrics = [
    for (final shape in _shapes) shape.computeMetrics().first,
  ];
  static const _ivory = Color(0xffffe9d2);
  static final _letterContours = [
    for (final stroke in _penStrokes) stroke.computeMetrics().toList(),
  ];
  static final _letterLengths = [
    for (final contours in _letterContours)
      contours.fold(0.0, (sum, contour) => sum + contour.length),
  ];
  // The side wall and the soft bevel follow each individual ink stroke.
  static final _letterSides = ui.Gradient.linear(
    Offset.zero,
    const Offset(0, _wordmarkHeight),
    const [Color(0xffac9076), Color(0xff72564c)],
  );
  static final _outsideLetters = [
    for (final glyph in _wordmarkGlyphs)
      Path.combine(
        PathOperation.difference,
        Path()..addRect(glyph.getBounds().inflate(20)),
        glyph,
      ),
  ];

  static double _ramp(double v) {
    final x = v.clamp(0.0, 1.0);
    return x * x * (3 - 2 * x);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final elapsed = still ? _artworkDuration : clock.value;
    final t = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
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
    final finish = _ramp((t - 2.48) / .85);
    final blending = finish > 0 && finish < 1;
    // Mix premultiplied pixels in isolation so translucent rims do not double up.
    if (blending) canvas.saveLayer(destination, Paint());
    if (finish < 1) {
      if (blending) {
        canvas.saveLayer(
          destination,
          Paint()..color = Colors.white.withValues(alpha: 1 - finish),
        );
      }
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
        if (fill < 1) canvas.saveLayer(bounds, Paint());
        if (reliefAtlas case final atlas?) {
          canvas.drawImageRect(
            atlas,
            _tiles[i],
            bounds,
            ink..color = Colors.white,
          );
        } else {
          _paintProfileRelief(canvas, path, markImage);
        }
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
        if (fill < 1) canvas.restore();
      }
      if (blending) canvas.restore();
    }
    if (finish > 0) {
      canvas.drawImageRect(
        markImage,
        original,
        destination,
        ink
          ..color = Colors.white.withValues(alpha: finish)
          ..blendMode = blending ? BlendMode.plus : BlendMode.srcOver,
      );
    }
    if (blending) canvas.restore();
    canvas.restore();
    _paintWordmark(canvas, size, side, t);
  }

  void _paintWordmark(Canvas canvas, Size size, double side, double t) {
    const durations = [.88, .38, .32, .33, .38, .26, .38];
    final writingTime = (t - .75) * 1.12;
    var start = 0.0;
    final width = side * 1.15;
    canvas.save();
    canvas.translate((size.width - width) / 2, size.height * .4 + side * .55);
    canvas.scale(width / _wordmarkWidth);
    for (var i = 0; i < _wordmarkGlyphs.length; i++) {
      final elapsed = writingTime - start;
      if (elapsed <= 0) break;
      final duration = durations[i];
      start += duration;
      final glyph = _wordmarkGlyphs[i];
      final progress = _ramp(elapsed / duration);
      final fill = _ramp((elapsed - .075) / duration);
      final bounds = glyph.getBounds().inflate(4);
      if (fill < 1) {
        canvas.saveLayer(bounds, Paint());
        canvas.drawPath(
          glyph,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = _ivory,
        );
        _maskWrittenPart(canvas, i, bounds, progress);
        canvas.restore();
      }
      if (fill <= 0) continue;
      if (fill < 1) canvas.saveLayer(bounds, Paint());
      if (reliefAtlas case final atlas?) {
        canvas.drawImageRect(
          atlas,
          _tiles[_shapes.length + i],
          bounds,
          Paint()..filterQuality = FilterQuality.medium,
        );
      } else {
        _paintClayLetter(canvas, i, logo!);
      }
      if (fill < 1) {
        _maskWrittenPart(canvas, i, bounds, fill);
        canvas.restore();
      }
    }
    canvas.restore();
  }

  static final _bounds = [
    for (final shape in _shapes) shape.getBounds().inflate(11),
    for (final letter in _wordmarkGlyphs) letter.getBounds().inflate(4),
  ];
  static const _atlasScale = 2.0;
  static final _tiles = _packTiles();

  static List<Rect> _packTiles() {
    var x = 1.0;
    final tiles = <Rect>[];
    for (final bounds in _bounds) {
      final tile = Rect.fromLTWH(
        x,
        1,
        bounds.width * _atlasScale,
        bounds.height * _atlasScale,
      );
      tiles.add(tile);
      x = tile.right.ceilToDouble() + 2;
    }
    return tiles;
  }

  // Rasterize the static clay surfaces together, before playback. Only the
  // moving pen and reveal masks need to be drawn for each frame.
  static Future<ui.Image> bakeRelief(ui.Image mark) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    for (var i = 0; i < _tiles.length; i++) {
      final tile = _tiles[i];
      final bounds = _bounds[i];
      canvas.save();
      canvas.clipRect(tile);
      canvas.translate(tile.left, tile.top);
      canvas.scale(_atlasScale);
      canvas.translate(-bounds.left, -bounds.top);
      if (i < _shapes.length) {
        _paintProfileRelief(canvas, _shapes[i], mark);
      } else {
        _paintClayLetter(canvas, i - _shapes.length, mark);
      }
      canvas.restore();
    }
    final picture = recorder.endRecording();
    try {
      return await picture.toImage(
        _tiles.last.right.ceil() + 1,
        _tiles.map((tile) => tile.bottom.ceil()).reduce(math.max) + 1,
      );
    } finally {
      picture.dispose();
    }
  }

  static void _paintProfileRelief(
    Canvas canvas,
    Path path,
    ui.Image markImage,
  ) {
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
    texture.dispose();
  }

  static void _paintClayLetter(Canvas canvas, int index, ui.Image mark) {
    final glyph = _wordmarkGlyphs[index];
    canvas.save();
    canvas.translate(.6, 1.8);
    canvas.drawPath(glyph, Paint()..shader = _letterSides);
    canvas.restore();

    canvas.save();
    canvas.clipPath(glyph);
    // Sample the original matte clay directly from the interior of the cheek.
    final unitX = mark.width / 312;
    final unitY = mark.height / 312;
    canvas.drawImageRect(
      mark,
      Rect.fromLTWH(146 * unitX, 108 * unitY, 52 * unitX, 67 * unitY),
      glyph.getBounds().inflate(1),
      Paint()..filterQuality = FilterQuality.medium,
    );

    // Light enters from the upper left, as on the profile. Both soft edges
    // turn around the counters and the curves of the handwritten strokes.
    final outside = _outsideLetters[index];
    canvas.save();
    canvas.translate(-2.6, -3.8);
    canvas.drawPath(
      outside,
      Paint()
        ..color = const Color(0xc380604e)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2),
    );
    canvas.restore();
    canvas.translate(1.8, 2.4);
    canvas.drawPath(
      outside,
      Paint()
        ..color = const Color(0xe6fff0d9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.55),
    );
    canvas.restore();
  }

  void _maskWrittenPart(
    Canvas canvas,
    int index,
    Rect bounds,
    double progress,
  ) {
    if (progress >= 1) return;
    var remaining = _letterLengths[index] * progress;
    final written = Path();
    for (final contour in _letterContours[index]) {
      if (remaining <= 0) break;
      written.addPath(
        contour.extractPath(0, math.min(remaining, contour.length)),
        Offset.zero,
      );
      remaining -= contour.length;
    }
    canvas.saveLayer(bounds, Paint()..blendMode = BlendMode.dstIn);
    canvas.drawPath(
      written,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 31
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LaunchPainter old) =>
      old.clock != clock ||
      old.base != base ||
      old.logo != logo ||
      old.reliefAtlas != reliefAtlas ||
      old.still != still;
}

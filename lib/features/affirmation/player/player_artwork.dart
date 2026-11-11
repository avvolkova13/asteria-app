import 'package:asteria_app/features/scenarios/scenario_sky.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

const playerArtDirectory = 'assets/images/affirmation';

class PlayerArtwork extends StatefulWidget {
  const PlayerArtwork({
    super.key,
    required this.position,
    required this.duration,
    required this.playing,
  });

  final Duration position;
  final Duration duration;
  final bool playing;

  @override
  State<PlayerArtwork> createState() => _PlayerArtworkState();
}

class _PlayerArtworkState extends State<PlayerArtwork>
    with SingleTickerProviderStateMixin {
  static const _lotus = AssetImage(
    '$playerArtDirectory/lavender-clay-lotus.webp',
  );
  late final Ticker _ticker = createTicker(_tick);
  final _time = ValueNotifier(0.0);
  final _extrapolation = Stopwatch();
  ImageStream? _stream;
  late final _imageListener = ImageStreamListener(_receiveImage);
  ImageInfo? _image;
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'assets/shaders/affirmation_lotus.frag',
      );
      if (mounted) setState(() => _shader = program.fragmentShader());
    } catch (_) {
      // The reference also provides a static image for unsupported renderers.
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stream = _lotus.resolve(createLocalImageConfiguration(context));
    if (_stream?.key != stream.key) {
      _stream?.removeListener(_imageListener);
      _stream = stream..addListener(_imageListener);
    }
    _syncClock();
  }

  void _receiveImage(ImageInfo info, bool synchronousCall) {
    _image?.dispose();
    setState(() => _image = info);
  }

  @override
  void didUpdateWidget(PlayerArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.position != oldWidget.position ||
        widget.playing != oldWidget.playing ||
        widget.duration != oldWidget.duration) {
      _syncClock();
    }
  }

  void _syncClock() {
    _extrapolation
      ..stop()
      ..reset();
    final reduced = MediaQuery.disableAnimationsOf(context);
    _time.value = reduced ? 0 : widget.position.inMilliseconds / 1000;
    if (widget.playing && !reduced && TickerMode.valuesOf(context).enabled) {
      _extrapolation.start();
      if (!_ticker.isActive) _ticker.start();
    } else {
      _ticker.stop();
    }
  }

  void _tick(Duration _) {
    _time.value = math.min(
      widget.duration.inMilliseconds / 1000,
      (widget.position.inMilliseconds + _extrapolation.elapsedMilliseconds) /
          1000,
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    _extrapolation.stop();
    _stream?.removeListener(_imageListener);
    _image?.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = math.max(1.0, widget.duration.inMilliseconds / 1000);
    return ExcludeSemantics(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, bounds) {
            final width = bounds.maxWidth;
            final height = bounds.maxHeight;
            final lotusWidth = math.min(width * .96, height * .5 * 1000 / 667);
            return Stack(
              fit: StackFit.expand,
              children: [
                if (ScenarioSkyScope.of(context)) const ScenarioSky() else Image.asset(
                  '$playerArtDirectory/zephyr-sky.webp',
                  fit: BoxFit.cover,
                ),
                ClipRect(
                  child: ValueListenableBuilder<double>(
                    valueListenable: _time,
                    child: OverflowBox(
                      minWidth: width * 2,
                      maxWidth: width * 2,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          for (int i = 0; i < 2; i++)
                            Image.asset(
                              '$playerArtDirectory/light_wave.png',
                              width: width,
                              height: height,
                              fit: BoxFit.fill,
                            ),
                        ],
                      ),
                    ),
                    builder: (_, time, child) => Transform.translate(
                      offset: Offset(
                        -width *
                            ((time * (duration / 20.45).round() / duration) %
                                1),
                        0,
                      ),
                      child: child,
                    ),
                  ),
                ),
                Positioned(
                  bottom: height * .29,
                  left: width * .34,
                  width: width * .32,
                  height: height * .015,
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                    child: const DecoratedBox(
                      decoration: ShapeDecoration(
                        shape: StadiumBorder(),
                        color: Color(0x26694777),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: lotusWidth,
                    height: lotusWidth * 667 / 1000,
                    child: _shader != null && _image != null
                        ? RepaintBoundary(
                            child: CustomPaint(
                              painter: _LotusPainter(
                                _time,
                                duration,
                                _image!.image,
                                _shader!,
                              ),
                            ),
                          )
                        : FractionallySizedBox(
                            widthFactor: .92,
                            heightFactor: .92,
                            child: Image(image: _lotus, fit: BoxFit.contain),
                          ),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x822b184c),
                        Color(0x002b184c),
                        Color(0x004f3455),
                        Color(0x264f3455),
                        Color(0xa8322338),
                      ],
                      stops: [0, .29, .57, .72, 1],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LotusPainter extends CustomPainter {
  _LotusPainter(this.time, this.duration, this.image, this.shader)
    : super(repaint: time);
  final ValueNotifier<double> time;
  final double duration;
  final ui.Image image;
  final ui.FragmentShader shader;

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(
        2,
        time.value * 2 * math.pi * (duration / 10.22).round() / duration,
      )
      ..setImageSampler(0, image);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_LotusPainter oldDelegate) =>
      oldDelegate.time != time ||
      oldDelegate.image != image ||
      oldDelegate.shader != shader ||
      oldDelegate.duration != duration;
}

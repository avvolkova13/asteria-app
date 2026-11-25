import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:asteria_app/features/scenarios/scenario_sky.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'affirmation_motion_artwork.dart';
import 'body_motion_artwork.dart';
import 'compass_motion.dart';
import 'cover_motion_artwork.dart';
import 'door_motion.dart';
import 'plate_motion.dart';
import 'player_subject_motion.dart';

const playerArtDirectory = 'assets/images/affirmation';

enum PracticeScene {
  lotus(10.22),
  dawn(9, 'assets/images/home/hand_with_star.webp'),
  dusk(10, 'assets/images/affirmation/category_calm_2.webp'),
  moon(12, 'assets/images/moon_phase_days/day_04.webp'),
  bloom(8, 'assets/images/scenarios/lotus.webp'),
  ribbon(9.5);

  const PracticeScene(this.period, [this.asset]);

  final double period;
  final String? asset;
}

class PlayerArtwork extends StatefulWidget {
  const PlayerArtwork({
    super.key,
    required this.position,
    required this.duration,
    required this.playing,
    this.scene = PracticeScene.lotus,
    this.subjectAsset,
    this.portraitAsset,
    this.previewMotion = false,
    this.looping = false,
    this.showBackground = true,
    this.showSubject = true,
  });

  final Duration position;
  final Duration duration;
  final bool playing;
  final bool previewMotion;
  final bool looping;
  final bool showBackground, showSubject;
  final PracticeScene scene;
  final String? subjectAsset, portraitAsset;

  @override
  State<PlayerArtwork> createState() => _PlayerArtworkState();
}

class _PlayerArtworkState extends State<PlayerArtwork>
    with SingleTickerProviderStateMixin {
  PlayerSubjectMotion? get _motion => PlayerSubjectMotion.forAsset(
    widget.portraitAsset ?? widget.subjectAsset ?? widget.scene.asset,
  );
  bool get _hasLunarAmbientMotion => switch (_motion) {
    PlayerSubjectMotion.moonClouds ||
    PlayerSubjectMotion.fullMoon ||
    PlayerSubjectMotion.orb => true,
    _ => false,
  };

  late final Ticker _ticker = createTicker(_tick);
  final _time = ValueNotifier(0.0);
  double _previewOffset = 0;
  final _extrapolation = Stopwatch();
  ImageStream? _stream;
  late final _imageListener = ImageStreamListener(_receiveImage);
  ImageInfo? _image;
  ui.FragmentShader? _atmosphere;

  @override
  void initState() {
    super.initState();
    if (widget.scene != PracticeScene.lotus && widget.showBackground) {
      _loadAtmosphere();
    }
  }

  Future<void> _loadAtmosphere() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'assets/shaders/practice_atmosphere.frag',
      );
      if (mounted && _atmosphere == null) {
        setState(() => _atmosphere = program.fragmentShader());
      }
    } catch (_) {
      // The canvas atmosphere is also used by renderers without runtime effects.
    }
  }

  void _resolveLotus() {
    if (widget.scene != PracticeScene.lotus || !widget.showSubject) return;
    final stream = const AssetImage(
      '$playerArtDirectory/lavender-clay-lotus.webp',
    ).resolve(createLocalImageConfiguration(context));
    if (_stream?.key == stream.key) return;
    _stream?.removeListener(_imageListener);
    _stream = stream..addListener(_imageListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveLotus();
    _syncClock();
  }

  void _receiveImage(ImageInfo info, bool synchronousCall) {
    _image?.dispose();
    setState(() => _image = info);
  }

  @override
  void didUpdateWidget(PlayerArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene != widget.scene ||
        oldWidget.showSubject != widget.showSubject ||
        oldWidget.showBackground != widget.showBackground) {
      _resolveLotus();
      if (widget.showBackground &&
          widget.scene != PracticeScene.lotus &&
          _atmosphere == null) {
        _loadAtmosphere();
      }
    }
    if (!_hasLunarAmbientMotion &&
        oldWidget.previewMotion &&
        !widget.previewMotion) {
      _previewOffset = _time.value - oldWidget.position.inMilliseconds / 1000;
    }
    // Lunar ambience has its own continuous clock; audio updates and seeking
    // must not freeze or rewind the sky, cloud drift or the slow lunar light.
    if (oldWidget.portraitAsset != widget.portraitAsset ||
        oldWidget.subjectAsset != widget.subjectAsset ||
        (!_hasLunarAmbientMotion &&
            (widget.position != oldWidget.position ||
                widget.playing != oldWidget.playing ||
                widget.previewMotion != oldWidget.previewMotion ||
                widget.duration != oldWidget.duration))) {
      _syncClock();
    }
  }

  void _syncClock() {
    _extrapolation
      ..stop()
      ..reset();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced) {
      _time.value = 0;
    } else if (!widget.previewMotion && !_hasLunarAmbientMotion) {
      _time.value = widget.position.inMilliseconds / 1000 + _previewOffset;
    }
    _anchor = _time.value;
    if ((widget.playing || widget.previewMotion || _hasLunarAmbientMotion) &&
        !reduced &&
        TickerMode.valuesOf(context).enabled) {
      _extrapolation.start();
      if (!_ticker.isActive) _ticker.start();
    } else {
      _ticker.stop();
    }
  }

  double _anchor = 0;
  void _tick(Duration _) {
    _time.value = _anchor + _extrapolation.elapsedMicroseconds / 1000000;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    _extrapolation.stop();
    _stream?.removeListener(_imageListener);
    _image?.dispose();
    _atmosphere?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = math.max(1.0, widget.duration.inMilliseconds / 1000);
    final scene = widget.scene;
    return ExcludeSemantics(
      child: IgnorePointer(
        child: scene == PracticeScene.lotus
            ? _buildLotus(duration)
            : _PracticeSceneArtwork(
                scene: scene,
                subjectAsset:
                    widget.portraitAsset ?? widget.subjectAsset ?? scene.asset,
                isPortrait: widget.portraitAsset != null,
                time: _time,
                duration: duration,
                motion: _motion,
                showSubject: widget.showSubject,
                atmosphere: _atmosphere,
                showBackground: widget.showBackground,
              ),
      ),
    );
  }

  Widget _buildLotus(double duration) => LayoutBuilder(
    builder: (context, bounds) {
      final width = bounds.maxWidth;
      final height = bounds.maxHeight;
      final heightFactor = widget.showBackground ? .5 : .68;
      final lotusWidth = math.min(
        width * .96,
        height * heightFactor * 1000 / 667,
      );
      return Stack(
        fit: StackFit.expand,
        children: [
          if (widget.showBackground) ...[
            if (ScenarioSkyScope.of(context))
              const ScenarioSky()
            else
              Image.asset(
                '$playerArtDirectory/zephyr-sky.webp',
                fit: BoxFit.cover,
              ),
            ClipRect(child: CustomPaint(painter: _SkyLight(_time, duration))),
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
          ],
          if (widget.showSubject)
            Center(
              child: SizedBox(
                width: lotusWidth,
                height: lotusWidth * 667 / 1000,
                child: _image != null
                    ? RepaintBoundary(
                        child: CustomPaint(
                          painter: _LotusPainter(
                            _time,
                            duration,
                            _image!.image,
                          ),
                        ),
                      )
                    : FractionallySizedBox(
                        widthFactor: .92,
                        heightFactor: .92,
                        child: Image.asset(
                          '$playerArtDirectory/lavender-clay-lotus.webp',
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
            ),
          if (widget.showBackground)
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
  );
}

class _PracticeSceneArtwork extends StatelessWidget {
  const _PracticeSceneArtwork({
    required this.scene,
    required this.subjectAsset,
    required this.isPortrait,
    required this.time,
    required this.duration,
    required this.motion,
    required this.showSubject,
    required this.atmosphere,
    required this.showBackground,
  });

  final PracticeScene scene;
  final String? subjectAsset;
  final bool isPortrait;
  final ValueListenable<double> time;
  final double duration;
  final PlayerSubjectMotion? motion;
  final bool showSubject;
  final ui.FragmentShader? atmosphere;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final art = subjectAsset ?? scene.asset;
    final sceneCycles = math.max(1, (duration / scene.period).round());
    final subjectCycles = switch (motion) {
      PlayerSubjectMotion.mountain ||
      PlayerSubjectMotion.sunInHand ||
      PlayerSubjectMotion.moonClouds ||
      PlayerSubjectMotion.fullMoon ||
      PlayerSubjectMotion.lunarRibbons => math.max(1, (duration / 30).round()),
      PlayerSubjectMotion.shaking => math.max(1, (duration / 10).round()),
      _ => sceneCycles,
    };
    final skyCycles = switch ((motion, scene)) {
      (PlayerSubjectMotion.shaking, _) => math.max(1, (duration / 40).round()),
      (_, PracticeScene.moon) => math.max(1, (duration / 30).round()),
      _ => math.max(1, (sceneCycles / 2).round()),
    };
    // The full scene clips to the player on compact and wide layouts.
    return LayoutBuilder(
      builder: (context, bounds) {
        final heightFactor = showBackground ? .66 : .88;
        final size = math.min(bounds.maxWidth, bounds.maxHeight * heightFactor);
        return ClipRect(
          child: ValueListenableBuilder<double>(
            valueListenable: time,
            builder: (_, seconds, _) {
              final phase = 2 * math.pi * subjectCycles * seconds / duration;
              final backgroundPhase =
                  2 * math.pi * skyCycles * seconds / duration;
              return Stack(
                fit: StackFit.expand,
                children: [
                  if (showBackground && scene == PracticeScene.moon)
                    Transform.translate(
                      offset: Offset(
                        -bounds.maxWidth * .045 * math.sin(backgroundPhase),
                        bounds.maxHeight *
                            .012 *
                            math.sin(backgroundPhase - .5),
                      ),
                      child: Transform.scale(
                        scale: 1.23 + .012 * math.sin(backgroundPhase - .4),
                        child: Image.asset(
                          'assets/images/sonnik/sonnik_clouds.webp',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),
                  if (showBackground)
                    CustomPaint(
                      painter: atmosphere == null
                          ? _SceneAtmosphere(scene, backgroundPhase)
                          : _LayeredAtmosphere(
                              scene,
                              backgroundPhase,
                              atmosphere!,
                            ),
                    ),
                  if (showSubject)
                    Center(
                      child: SizedBox.square(
                        dimension: size * (isPortrait ? .77 : .73),
                        child: switch (motion) {
                          final subject? when subject.isAffirmation =>
                            AffirmationMotionArtwork(
                              motion: subject,
                              phase: phase,
                            ),
                          final subject? => BodyMotionArtwork(
                            motion: subject,
                            phase: phase,
                          ),
                          null
                              when art != null &&
                                  art.startsWith(
                                    '$playerArtDirectory/cover-',
                                  ) =>
                            _CoverForeground(
                              cover: art,
                              phase: phase,
                              seconds: seconds,
                            ),
                          null when art != null => Image.asset(
                            art,
                            fit: BoxFit.contain,
                          ),
                          _ => const SizedBox.shrink(),
                        },
                      ),
                    ),
                  if (showBackground)
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xa3100b1c),
                            Color(0x00100b1c),
                            Color(0x00100b1c),
                            Color(0xd0100b1c),
                          ],
                          stops: [0, .28, .60, 1],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _LayeredAtmosphere extends CustomPainter {
  const _LayeredAtmosphere(this.scene, this.phase, this.shader);

  final PracticeScene scene;
  final double phase;
  final ui.FragmentShader shader;

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, phase)
      ..setFloat(3, (scene.index - 1).toDouble());
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_LayeredAtmosphere oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.scene != scene ||
      oldDelegate.shader != shader;
}

class _CoverForeground extends StatelessWidget {
  const _CoverForeground({
    required this.cover,
    required this.phase,
    required this.seconds,
  });

  final String cover;
  final double phase, seconds;

  @override
  Widget build(BuildContext context) {
    final filename = cover.split('/').last;
    final subject = '$playerArtDirectory/motion/subjects/$filename';
    if (filename == 'cover-2RIYK845VuQLc9nY5BRI.webp') {
      return WeightedRibbonArtwork(asset: subject, seconds: seconds);
    }
    if (filename == 'cover-itqgt8x2gCPskF3Dv19h.webp') {
      return AbacusArtwork(asset: subject, seconds: seconds);
    }
    if (filename == 'cover-KvjWWJfzOtGBXzi0VCzv.webp') {
      return FigLeavesArtwork(asset: subject, seconds: seconds);
    }
    if (filename == 'cover-i5x8b2lu1nOvj0VPF8zi.webp') {
      return LinkedStonesArtwork(asset: subject, seconds: seconds);
    }
    if (filename == 'cover-be-kinder.webp') {
      return RoseReflectionArtwork(asset: subject, seconds: seconds);
    }
    if (filename == 'cover-d09HZSKvdtMrmJ9TrsbZ.webp') {
      return _BellArtwork(asset: subject, seconds: seconds);
    }
    if (filename == 'cover-5UgabJFV5M2TiptnhZMm.webp') {
      return DoorMotionArtwork(asset: subject, seconds: seconds);
    }
    if (filename == 'cover-EG8DuZL1V6idVvW0jp4B.webp') {
      return _CraneGiftArtwork(asset: subject, seconds: seconds);
    }
    if (filename == 'cover-9Mvd1yeBUDmiLPRdJ1mv.webp') {
      return _RotatingRibbonArtwork(asset: subject, seconds: seconds);
    }
    if (filename == 'cover-aivVFq7TD00qsfLg4VzX.webp') {
      return PlateMotionArtwork(asset: subject, seconds: seconds);
    }
    if (filename == 'cover-choose-yourself.webp') {
      return CompassMotionArtwork(asset: subject, seconds: seconds);
    }
    if (filename == 'cover-km6gqT17HfO35Q4t0WQo.webp') {
      return CustomPaint(painter: _LunarRipple(phase));
    }
    final id = filename.substring(
      'cover-'.length,
      filename.length - '.webp'.length,
    );
    final scene = coverMotions[id];
    return scene == null
        ? Image.asset(subject, fit: BoxFit.contain)
        : CoverMotionArtwork(asset: subject, scene: scene, seconds: seconds);
  }
}

// Swing into the paper silhouette so its originally occluded edge stays hidden.
class _BellArtwork extends StatelessWidget {
  const _BellArtwork({required this.asset, required this.seconds});

  final String asset;
  final double seconds;

  @override
  Widget build(BuildContext context) {
    final phase = seconds * 2 * math.pi / 4.8;
    Widget plate() => Image.asset(asset, excludeFromSemantics: true);
    return FittedBox(
      child: SizedBox.square(
        dimension: 350,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipPath(clipper: const _BellClip(inverse: true), child: plate()),
            Transform.rotate(
              alignment: const Alignment(125 / 175 - 1, 95 / 175 - 1),
              angle: -.085 * (1 - math.cos(phase)),
              child: ClipPath(clipper: const _BellClip(), child: plate()),
            ),
          ],
        ),
      ),
    );
  }
}

class _BellClip extends CustomClipper<Path> {
  const _BellClip({this.inverse = false});
  final bool inverse;

  @override
  Path getClip(Size size) {
    final bell = Path()
      ..moveTo(32, 67)
      ..lineTo(166, 67)
      ..lineTo(167, 195)
      ..cubicTo(169, 224, 179, 254, 196, 275)
      ..lineTo(200, 280)
      ..lineTo(201, 298)
      ..lineTo(32, 298)
      ..close();
    if (inverse)
      return Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        bell,
      );
    return bell;
  }

  @override
  bool shouldReclip(_BellClip old) =>
      inverse != old.inverse;
}

class _CraneGiftArtwork extends StatelessWidget {
  const _CraneGiftArtwork({required this.asset, required this.seconds});

  final String asset;
  final double seconds;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(asset, fit: BoxFit.contain);
    const hinge = Alignment(2 * 283 / 350 - 1, 2 * 124 / 350 - 1);
    final angle = .065 * math.sin(2 * math.pi * seconds / 16);

    return Stack(
      fit: StackFit.expand,
      children: [
        Transform.rotate(
          alignment: hinge,
          angle: angle,
          child: ClipPath(
            clipper: const _CraneGiftClipper(gift: true),
            child: image,
          ),
        ),
        ClipPath(clipper: const _CraneGiftClipper(gift: false), child: image),
      ],
    );
  }
}

class _CraneGiftClipper extends CustomClipper<Path> {
  const _CraneGiftClipper({required this.gift});

  final bool gift;

  @override
  Path getClip(Size size) {
    // The cut splits the rope where it leaves the beak. Both layers keep
    // their source registration as the gift rotates around that same point.
    final suspended =
        (Path()
              ..moveTo(274, 124)
              ..lineTo(291, 124)
              ..lineTo(299, 149)
              ..lineTo(336, 152)
              ..lineTo(336, 248)
              ..lineTo(236, 248)
              ..lineTo(236, 164)
              ..lineTo(272, 161)
              ..close())
            .transform(
              Matrix4.diagonal3Values(
                size.width / 350,
                size.height / 350,
                1,
              ).storage,
            );
    return gift
        ? suspended
        : Path.combine(
            PathOperation.difference,
            Path()..addRect(Offset.zero & size),
            suspended,
          );
  }

  @override
  bool shouldReclip(_CraneGiftClipper oldClipper) => oldClipper.gift != gift;
}

class _RotatingRibbonArtwork extends StatelessWidget {
  const _RotatingRibbonArtwork({required this.asset, required this.seconds});

  final String asset;
  final double seconds;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(asset, fit: BoxFit.contain);
    const center = Alignment(2 * 177 / 350 - 1, 2 * 180 / 350 - 1);
    final angle = 2 * math.pi * (seconds % 36) / 36;

    return Stack(
      fit: StackFit.expand,
      children: [
        FractionalTranslation(
          translation: const Offset(0, -46 / 350),
          child: ClipPath(
            clipper: const _RibbonStoneClipper(stone: true),
            child: image,
          ),
        ),
        Transform.rotate(
          alignment: center,
          angle: angle,
          child: ClipPath(
            clipper: const _RibbonStoneClipper(stone: false),
            child: image,
          ),
        ),
      ],
    );
  }
}

class _RibbonStoneClipper extends CustomClipper<Path> {
  const _RibbonStoneClipper({required this.stone});

  final bool stone;

  @override
  Path getClip(Size size) {
    final pebble =
        (Path()
              ..moveTo(141, 258)
              ..cubicTo(136, 253, 138, 239, 153, 232)
              ..cubicTo(174, 221, 207, 225, 215, 241)
              ..cubicTo(225, 262, 205, 273, 181, 271)
              ..cubicTo(166, 272, 153, 265, 141, 258)
              ..close())
            .transform(
              Matrix4.diagonal3Values(
                size.width / 350,
                size.height / 350,
                1,
              ).storage,
            );
    return stone
        ? pebble
        : Path.combine(
            PathOperation.difference,
            Path()..addRect(Offset.zero & size),
            pebble,
          );
  }

  @override
  bool shouldReclip(_RibbonStoneClipper oldClipper) =>
      oldClipper.stone != stone;
}

class _LunarRipple extends CustomPainter {
  const _LunarRipple(this.phase);

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .5, size.height * .53);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var ring = 0; ring < 5; ring++) {
      final travel = (phase / (2 * math.pi) + ring / 5 + .12) % 1;
      final radius = size.width * (.035 + .43 * travel);
      final opacity = math.pow(math.sin(math.pi * travel), 1.4).toDouble();
      final oval = Rect.fromCenter(
        center: center.translate(0, radius * .095),
        width: radius * 2,
        height: radius * .52,
      );
      paint
        ..color = const Color(0xFFDAABE8).withValues(alpha: .22 * opacity)
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
      canvas.drawOval(oval, paint);
      paint
        ..color = const Color(0xFFECC4F3).withValues(alpha: .52 * opacity)
        ..strokeWidth = 1.05
        ..maskFilter = null;
      canvas.drawOval(oval, paint);
      paint
        ..color = const Color(0xFFFFDBF5).withValues(alpha: .38 * opacity)
        ..strokeWidth = 1.8;
      canvas.drawArc(oval, .54, 2.03, false, paint);
    }
  }

  @override
  bool shouldRepaint(_LunarRipple oldDelegate) => phase != oldDelegate.phase;
}

class _SceneAtmosphere extends CustomPainter {
  _SceneAtmosphere(this.scene, this.phase);

  final PracticeScene scene;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final sway = math.sin(phase);
    final lift = (1 - math.cos(phase)) * .5;
    switch (scene) {
      case PracticeScene.dawn:
        _backdrop(canvas, size, const [
          Color(0xff332248),
          Color(0xffcd8b91),
          Color(0xff3b2450),
        ]);
        _glow(
          canvas,
          size,
          Offset(.37 + .14 * sway, .46 - .045 * lift),
          const Color(0xffffb56e),
          .85,
          .65 + .19 * lift,
        );
        _hill(canvas, size, .61, .065 * sway, const [
          Color(0xffce8ba6),
          Color(0xff5c416c),
        ]);
        _hill(canvas, size, .72, -.047 * sway, const [
          Color(0xff8564a0),
          Color(0xff3c274e),
        ]);
        _hill(canvas, size, .82, .02 * sway, const [
          Color(0xff604574),
          Color(0xff231836),
        ]);
      case PracticeScene.dusk:
        _backdrop(canvas, size, const [
          Color(0xff23172f),
          Color(0xff523454),
          Color(0xff21172d),
        ]);
        _glow(
          canvas,
          size,
          Offset(.46 + .23 * sway, .54 - .08 * lift),
          const Color(0xffff9eab),
          .39,
          .27 + .28 * lift,
        );
      case PracticeScene.moon:
        _glow(
          canvas,
          size,
          Offset(.61 - .15 * sway, .45),
          const Color(0xffac85ef),
          .57,
          .30 + .16 * lift,
        );
      case PracticeScene.bloom:
        _backdrop(canvas, size, const [
          Color(0xff1b293e),
          Color(0xff456666),
          Color(0xff1b2a3d),
        ]);
        _glow(
          canvas,
          size,
          Offset(.51 + .14 * sway, .52),
          const Color(0xff93bcb2),
          .73,
          .34 + .19 * lift,
        );
        _ripples(canvas, size);
      case PracticeScene.ribbon:
        _backdrop(canvas, size, const [
          Color(0xff271c3b),
          Color(0xff64314f),
          Color(0xff251c3d),
        ]);
        _glow(
          canvas,
          size,
          Offset(.64 - .21 * sway, .48 - .06 * lift),
          const Color(0xffd889a7),
          .72,
          .34 + .22 * lift,
        );
        _ribbons(canvas, size);
      case PracticeScene.lotus:
        break;
    }
  }

  void _backdrop(Canvas canvas, Size size, List<Color> colors) {
    final bounds = Offset.zero & size;
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: const [0, .52, 1],
        ).createShader(bounds),
    );
  }

  void _glow(
    Canvas canvas,
    Size size,
    Offset anchor,
    Color color,
    double radius,
    double alpha,
  ) {
    final center = Offset(size.width * anchor.dx, size.height * anchor.dy);
    final bounds = Rect.fromCircle(center: center, radius: size.width * radius);
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0),
          ],
        ).createShader(bounds),
    );
  }

  void _hill(
    Canvas canvas,
    Size size,
    double level,
    double drift,
    List<Color> colors,
  ) {
    final w = size.width;
    final y = size.height * level;
    final d = size.height * drift;
    final shape = Path()
      ..moveTo(0, y + d)
      ..cubicTo(
        w * .26,
        y - size.height * .10,
        w * .58,
        y + size.height * .10,
        w,
        y - size.height * .025 + d,
      )
      ..lineTo(w, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      shape,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, y - size.height * .05),
          Offset(0, size.height),
          colors,
        ),
    );
  }

  void _ripples(Canvas canvas, Size size) {
    final center = Offset(size.width * .50, size.height * .63);
    for (var index = 0; index < 4; index++) {
      final progress = (phase / (2 * math.pi) + index / 4) % 1;
      final extent = size.width * (.17 + .71 * progress);
      final opacity = math.sin(progress * math.pi) * .48;
      canvas.drawOval(
        Rect.fromCenter(center: center, width: extent, height: extent * .25),
        Paint()
          ..color = const Color(0xffc5ded1).withValues(alpha: opacity)
          ..strokeWidth = 1.8 - .75 * progress
          ..style = PaintingStyle.stroke,
      );
    }
  }

  void _ribbons(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    for (var index = 0; index < 3; index++) {
      final drift = h * (.058 - .010 * index) * math.sin(phase - index * .9);
      final y = h * (.67 + index * .056);
      final shape = Path()
        ..moveTo(-.10 * w, y + drift * .45)
        ..cubicTo(
          w * .29,
          y - h * .22 + drift,
          w * .60,
          y + h * .05 - drift,
          w * 1.10,
          y - h * .30,
        )
        ..cubicTo(
          w * .63,
          y + h * .13 - drift,
          w * .27,
          y - h * .10 + drift,
          -.10 * w,
          y + h * .07,
        )
        ..close();
      final shaderBounds = Rect.fromLTWH(0, y - h * .31, w, h * .44);
      canvas.drawPath(
        shape,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              const Color(0xffe9c4f4).withValues(alpha: .42 - index * .065),
              const Color(0xffd28cab).withValues(alpha: .47 - index * .07),
              const Color(0xff885582).withValues(alpha: .23),
            ],
          ).createShader(shaderBounds),
      );
    }
  }

  @override
  bool shouldRepaint(_SceneAtmosphere oldDelegate) =>
      oldDelegate.scene != scene || oldDelegate.phase != phase;
}

/// A wide band of diffuse light drifts behind the stationary flower root.
class _SkyLight extends CustomPainter {
  _SkyLight(this.time, this.duration) : super(repaint: time);
  final ValueListenable<double> time;
  final double duration;

  @override
  void paint(Canvas canvas, Size size) {
    final phase =
        2 *
        math.pi *
        time.value *
        math.max(1, (duration / 20.45).round()) /
        duration;
    final y = size.height * (.46 + .025 * math.sin(phase));
    final wave = Path()
      ..moveTo(-size.width * .1, y)
      ..cubicTo(
        size.width * .29,
        y - size.height * .06,
        size.width * .64,
        y + size.height * (.10 + .04 * math.cos(phase)),
        size.width * 1.1,
        y - size.height * .06,
      );
    final width = size.shortestSide * .035;
    canvas.drawPath(
      wave,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, width)
        ..color = const Color(0x66f6ceee),
    );
  }

  @override
  bool shouldRepaint(_SkyLight other) =>
      other.time != time || other.duration != duration;
}

/// Two rear petals open at their roots. The complete flower sits in front
/// of the joints, so its cup and stamens keep their original silhouette.
class _LotusPainter extends CustomPainter {
  _LotusPainter(this.time, this.duration, this.image) : super(repaint: time);
  final ValueNotifier<double> time;
  final double duration;
  final ui.Image image;

  // Contours run through transparent space outside the flower and follow the
  // overlap with the front row inside it. A few pixels of extra root underlap
  // stay behind the front cup throughout the arc.
  static final _left = Path()
    ..moveTo(28, 74)
    ..lineTo(99, 73)
    ..cubicTo(115, 97, 120, 121, 137, 141)
    ..cubicTo(147, 161, 156, 178, 172, 200)
    ..cubicTo(145, 195, 128, 186, 111, 176)
    ..lineTo(25, 169)
    ..close();
  static final _right = Path()
    ..moveTo(449, 66)
    ..lineTo(385, 66)
    ..cubicTo(372, 95, 363, 119, 352, 139)
    ..cubicTo(342, 157, 337, 173, 322, 192)
    ..cubicTo(353, 185, 369, 178, 392, 170)
    ..lineTo(460, 163)
    ..close();
  static final _leftPlate = Path.combine(
    PathOperation.union,
    _left,
    Path()..addOval(const Rect.fromLTRB(116, 149, 182, 211)),
  );
  static final _rightPlate = Path.combine(
    PathOperation.union,
    _right,
    Path()..addOval(const Rect.fromLTRB(308, 151, 384, 202)),
  );
  static final _front = Path.combine(
    PathOperation.difference,
    Path()..addRect(const Rect.fromLTWH(0, 0, 480, 320)),
    Path.combine(PathOperation.union, _left, _right),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final rect = const Rect.fromLTWH(0, 0, 480, 320);
    final source =
        Offset.zero & Size(image.width.toDouble(), image.height.toDouble());
    final scale = math.min(size.width / 480, size.height / 320) * .90;
    final phase =
        time.value *
        2 *
        math.pi *
        math.max(1, (duration / 10.22).round()) /
        duration;
    final paint = Paint()..filterQuality = FilterQuality.medium;
    canvas.save();
    canvas.translate(
      (size.width - 480 * scale) / 2,
      (size.height - 320 * scale) / 2,
    );
    canvas.scale(scale);
    for (final left in [true, false]) {
      final contour = left ? _leftPlate : _rightPlate;
      final pivot = left ? const Offset(166, 192) : const Offset(328, 184);
      final close = (1 - math.cos(phase + (left ? .16 : -.16))) / 2;
      canvas.save();
      canvas.translate(pivot.dx, pivot.dy);
      canvas.rotate((left ? .17 : -.17) * close);
      canvas.translate(-pivot.dx, -pivot.dy);
      canvas.clipPath(contour);
      canvas.drawImageRect(image, source, rect, paint);
      canvas.restore();
    }
    canvas.clipPath(_front);
    canvas.drawImageRect(image, source, rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LotusPainter other) =>
      other.time != time || other.image != image || other.duration != duration;
}

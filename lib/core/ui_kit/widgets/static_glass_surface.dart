import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef GlassBackdropPainter =
    void Function(Canvas canvas, Size size, ui.Image image);

/// One composited backdrop per viewport, shared by all refractive surfaces.
class StaticGlassBackdrop extends StatefulWidget {
  const StaticGlassBackdrop({
    super.key,
    required this.asset,
    required this.paintBackdrop,
    required this.child,
  });
  final String asset;
  final GlassBackdropPainter paintBackdrop;
  final Widget child;

  @override
  State<StaticGlassBackdrop> createState() => _StaticGlassBackdropState();
}

class _StaticGlassBackdropState extends State<StaticGlassBackdrop> {
  ui.Image? _image;
  Size? _size;
  int _generation = 0;

  Future<void> _compose(Size size) async {
    final generation = ++_generation;
    final data = await rootBundle.load(widget.asset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final source = (await codec.getNextFrame()).image;
    codec.dispose();
    if (!mounted || generation != _generation) {
      source.dispose();
      return;
    }
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(2);
    widget.paintBackdrop(canvas, size, source);
    final picture = recorder.endRecording();
    final result = await picture.toImage(
      (size.width * 2).ceil(),
      (size.height * 2).ceil(),
    );
    picture.dispose();
    source.dispose();
    if (!mounted || generation != _generation) {
      result.dispose();
      return;
    }
    final previous = _image;
    setState(() => _image = result);
    WidgetsBinding.instance.addPostFrameCallback((_) => previous?.dispose());
  }

  @override
  void didUpdateWidget(covariant StaticGlassBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset ||
        oldWidget.paintBackdrop != widget.paintBackdrop) {
      _size = null;
    }
  }

  @override
  void dispose() {
    _generation++;
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = constraints.biggest;
      if (size != _size && !size.isEmpty && size.isFinite) {
        _size = size;
        _compose(size).catchError(
          (Object error) => debugPrint('Glass backdrop unavailable: $error'),
        );
      }
      return _BackdropScope(
        image: _image,
        size: size,
        origin: () {
          final box = context.findRenderObject();
          return box is RenderBox
              ? box.localToGlobal(Offset.zero)
              : Offset.zero;
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_image != null) RawImage(image: _image, fit: BoxFit.fill),
            widget.child,
          ],
        ),
      );
    },
  );
}

class _BackdropScope extends InheritedWidget {
  const _BackdropScope({
    required this.image,
    required this.size,
    required this.origin,
    required super.child,
  });
  final ui.Image? image;
  final Size size;
  final Offset Function() origin;

  @override
  bool updateShouldNotify(_BackdropScope oldWidget) =>
      image != oldWidget.image || size != oldWidget.size;
}

class StaticGlassSurface extends StatefulWidget {
  const StaticGlassSurface({
    super.key,
    required this.child,
    this.pathBuilder,
    this.backgroundAsset,
    this.radius = 24,
    this.tint = const Color(0x33000000),
    this.light = 0.6,
    this.shadow = false,
  });
  final Widget child;
  final String? backgroundAsset;
  final Path Function(Size, double)? pathBuilder;
  final double radius;
  final Color tint;
  final double light;
  final bool shadow;

  @override
  State<StaticGlassSurface> createState() => _StaticGlassSurfaceState();
}

class _GlassResources {
  _GlassResources(this.program, this.image);
  final ui.FragmentProgram program;
  final ui.Image image;
  static final _pending = <String, Future<_GlassResources>>{};
  static Future<_GlassResources> load(String asset) =>
      _pending.putIfAbsent(asset, () => _load(asset));
  static Future<_GlassResources> _load(String asset) async {
    final program = await ui.FragmentProgram.fromAsset(
      'assets/shaders/anakra_glass.frag',
    );
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    try {
      return _GlassResources(program, (await codec.getNextFrame()).image);
    } finally {
      codec.dispose();
    }
  }
}

class _StaticGlassSurfaceState extends State<StaticGlassSurface> {
  ui.FragmentShader? _shader;
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _GlassResources.load(
          widget.backgroundAsset ??
              'assets/images/home/profile_background.webp',
        )
        .then((resources) {
          if (!mounted) return;
          setState(() {
            _shader = resources.program.fragmentShader();
            _image = resources.image;
          });
        })
        .catchError((Object error) {
          // Software renderers retain a legible translucent fallback.
          debugPrint('Static glass unavailable: $error');
        });
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backdrop = context
        .dependOnInheritedWidgetOfExactType<_BackdropScope>();
    return CustomPaint(
      painter: _GlassPainter(
        shader: _shader,
        image: backdrop == null ? _image : backdrop.image,
        screen: backdrop?.size ?? MediaQuery.sizeOf(context),
        origin: () {
          final box = context.findRenderObject();
          final point = box is RenderBox
              ? box.localToGlobal(Offset.zero)
              : Offset.zero;
          return point - (backdrop?.origin() ?? Offset.zero);
        },
        pathBuilder: widget.pathBuilder,
        radius: widget.radius,
        tint: widget.tint,
        light: widget.light,
        shadow: widget.shadow,
      ),
      child: widget.child,
    );
  }
}

class _GlassPainter extends CustomPainter {
  _GlassPainter({
    required this.shader,
    required this.image,
    required this.screen,
    required this.origin,
    required this.pathBuilder,
    required this.radius,
    required this.tint,
    required this.light,
    required this.shadow,
  });
  final ui.FragmentShader? shader;
  final ui.Image? image;
  final Size screen;
  final Offset Function() origin;
  final Path Function(Size, double)? pathBuilder;
  final double radius;
  final Color tint;
  final double light;
  final bool shadow;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final path =
        pathBuilder?.call(size, radius) ??
        (Path()..addRRect(
          RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
        ));
    if (shadow) {
      canvas.drawPath(
        path.shift(const Offset(0, 8)),
        Paint()
          ..color = const Color(0x14000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      );
    }
    final program = shader;
    final background = image;
    if (program != null && background != null) {
      final offset = origin();
      final values = [
        size.width,
        size.height,
        screen.width,
        screen.height,
        offset.dx,
        offset.dy,
        tint.r,
        tint.g,
        tint.b,
        tint.a,
        radius,
        light,
        background.width.toDouble(),
        background.height.toDouble(),
      ];
      for (var i = 0; i < values.length; i++) {
        program.setFloat(i, values[i]);
      }
      program.setImageSampler(0, background);
      canvas.drawPath(path, Paint()..shader = program);
    } else {
      canvas.drawPath(path, Paint()..color = tint);
    }
    if (pathBuilder == null) {
      CardLensDecoration.paintFinish(
        canvas,
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
      return;
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.65
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: light * 0.6),
            Colors.white.withValues(alpha: 0.02),
            Colors.white.withValues(alpha: light * 0.3),
          ],
          stops: const [0, 0.55, 1],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _GlassPainter oldDelegate) => true;
}

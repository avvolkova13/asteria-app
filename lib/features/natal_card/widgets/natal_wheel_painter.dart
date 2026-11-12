part of 'natal_wheel.dart';

class _WheelPainter extends CustomPainter {
  _WheelPainter(
    this.layout,
    this.data,
    this.knownTime,
    this.selected,
    this.previous,
    this.connected,
    this.entrance,
    this.highlight,
  ) : super(repaint: Listenable.merge([entrance, highlight]));

  final _WheelLayout layout;
  final PlanetsHousesDataModel data;
  final bool knownTime;
  final String? selected;
  final String? previous;
  final Animation<double> highlight;
  final Set<String> connected;
  final Animation<double> entrance;

  static const _enamel = RadialGradient(
    center: Alignment(-.46, -.62),
    radius: 1.24,
    colors: [
      Color(0xff47324b),
      Color(0xff2d2036),
      Color(0xff1c1528),
      Color(0xff100e1b),
    ],
    stops: [0, .45, .85, 1],
  );
  static const _pearl = RadialGradient(
    center: Alignment(-.4, -.6),
    radius: .94,
    colors: [
      Color(0xfffff7e6),
      Color(0xfff7d7b9),
      Color(0xffc88e88),
      Color(0xff895e72),
      Color(0xffd9afa6),
    ],
    stops: [0, .24, .62, .9, 1],
  );
  final _pen = Paint()..strokeCap = StrokeCap.round;

  void _line(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color,
    double width,
  ) {
    _pen
      ..color = color
      ..strokeWidth = width;
    canvas.drawLine(start, end, _pen);
  }

  void _type(
    Canvas canvas,
    String text,
    Offset where,
    double size,
    Color color,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontFamily: 'Lora', fontSize: size, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      where - Offset(painter.width / 2, painter.height / 2),
    );
    painter.dispose();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final time = entrance.value;
    if (time <= 0) return;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(size.width / _diameter);
    const disk = Rect.fromLTWH(-220, -220, 440, 440);
    final appear = const Interval(
      0,
      .26,
      curve: Curves.easeOut,
    ).transform(time);
    if (appear < 1) {
      canvas.saveLayer(
        disk.inflate(1),
        Paint()..color = Colors.white.withValues(alpha: appear),
      );
    }
    canvas.drawCircle(
      Offset.zero,
      220,
      Paint()..shader = _enamel.createShader(disk),
    );
    for (var deg = 0; deg < 360; deg += 2) {
      final major = deg % 30 == 0;
      final end = major
          ? 201.0
          : deg % 10 == 0
          ? 206.0
          : 211.0;
      _line(
        canvas,
        _point(deg.toDouble(), 216),
        _point(deg.toDouble(), end),
        major ? const Color(0xfffae0b6) : const Color(0xffa58e9d),
        major ? 1.8 : .9,
      );
    }
    for (final radius in [198.0, 118.0]) {
      canvas.drawCircle(
        Offset.zero,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0x55b698ac)
          ..strokeWidth = 1,
      );
    }
    if (knownTime) {
      _houses(canvas);
      _axes(canvas);
    }
    _threads(canvas, time);
    _anchors(canvas, time);
    if (appear < 1) canvas.restore();
    canvas.restore();
  }

  void _houses(Canvas canvas) {
    final cusps = data.houseCusps;
    if (cusps.length != 12) return;
    for (var i = 0; i < cusps.length; i++) {
      final house = cusps[i], start = house.longitude;
      final next = cusps[(i + 1) % cusps.length].longitude;
      final span = (next - start + 360) % 360;
      _line(
        canvas,
        _point(start, 120),
        _point(start, 197),
        const Color(0x707b6383),
        1.5,
      );
      _type(
        canvas,
        '${house.house}',
        _point(start + span / 2, 188),
        14,
        const Color(0xffe0ccd4),
      );
    }
  }

  void _axes(Canvas canvas) {
    for (final pos in data.positions) {
      final name = switch (pos.code) {
        'ascendant' => 'ASC',
        'midheaven' => 'MC',
        _ => null,
      };
      if (name == null || !_valid(pos.longitude)) continue;
      final center = _point(pos.longitude, 202);
      _line(
        canvas,
        _point(pos.longitude, 217),
        _point(pos.longitude, 194),
        const Color(0xfff3d4ad),
        2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center,
            width: name == 'ASC' ? 31 : 25,
            height: 14,
          ),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xff35283d),
      );
      _type(canvas, name, center, 11, const Color(0xffffe6ba));
    }
  }

  void _threads(Canvas canvas, double time) {
    final aspects = layout.aspects;
    for (var i = 0; i < aspects.length; i++) {
      final aspect = aspects[i];
      final start = .18 + .17 * i / math.max(1, aspects.length - 1);
      final progress = Interval(
        start,
        start + .62,
        curve: Curves.easeOutCubic,
      ).transform(time);
      if (progress <= 0) continue;
      final from = _point(aspect.first.longitude, 118);
      final target = _point(aspect.second.longitude, 118);
      final end = Offset.lerp(from, target, progress)!;
      final before = previous == null || aspect.connects(previous!) ? 1.0 : .16;
      final after = selected == null || aspect.connects(selected!) ? 1.0 : .16;
      final alpha =
          before + (after - before) * Curves.easeOut.transform(highlight.value);
      _line(
        canvas,
        from + const Offset(.5, 1.55),
        end + const Offset(.5, 1.55),
        const Color(0xff100916).withValues(alpha: .85 * alpha),
        4.6,
      );
      _line(canvas, from, end, aspect.color.withValues(alpha: alpha), 3);
      _line(
        canvas,
        from - const Offset(.32, .65),
        end - const Offset(.32, .65),
        const Color(0xfffff4ee).withValues(alpha: .67 * alpha),
        .85,
      );
    }
  }

  void _anchors(Canvas canvas, double time) {
    final fade = const Interval(
      .07,
      .36,
      curve: Curves.easeOut,
    ).transform(time);
    if (fade == 0) return;
    for (final planet in layout.planets) {
      final pin = _point(planet.longitude, 118);
      final bend = _point(planet.longitude, 128);
      final label = layout.labels[planet.code]!;
      final alpha = fade * (connected.contains(planet.code) ? 1 : .32);
      final lead = const Color(0xffbda3be).withValues(alpha: alpha);
      _line(canvas, pin, bend, lead, 1.28);
      _line(canvas, bend, label, lead, 1.28);
      final rect = Rect.fromCircle(center: pin, radius: 4.8);
      canvas.drawCircle(
        pin + const Offset(.5, 1),
        5,
        Paint()..color = const Color(0xff1b101a).withValues(alpha: alpha),
      );
      canvas.drawCircle(
        pin,
        4.8,
        Paint()
          ..color = Colors.white.withValues(alpha: alpha)
          ..shader = _pearl.createShader(rect),
      );
    }
  }

  @override
  bool shouldRepaint(_WheelPainter old) =>
      old.layout != layout ||
      old.data != data ||
      old.knownTime != knownTime ||
      old.selected != selected ||
      old.previous != previous ||
      old.entrance != entrance ||
      old.highlight != highlight;
}

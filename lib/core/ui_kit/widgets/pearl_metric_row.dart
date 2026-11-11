import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/pearl_progress_ring_painter.dart';
import 'package:flutter/material.dart';

class PearlMetric {
  const PearlMetric(this.label, this.reading, this.fraction, {this.paintKey});

  factory PearlMetric.percentage(
    String label,
    String reading, {
    Key? paintKey,
  }) {
    final number = double.tryParse(
      reading.replaceAll('%', '').replaceAll(',', '.').trim(),
    );
    return PearlMetric(label, reading, (number ?? 0) / 100, paintKey: paintKey);
  }

  final String label;
  final String reading;
  final double fraction;
  final Key? paintKey;
}

class PearlMetricRow extends StatelessWidget {
  const PearlMetricRow({
    super.key,
    required this.metrics,
    this.visible = true,
    this.lightSurface = false,
  });

  final List<PearlMetric> metrics;
  final bool visible;
  final bool lightSurface;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final size = scaler.scale(17).clamp(17.0, 40.0) + 54;
    final captionStyle = lightSurface
        ? context.textTheme.urbanistSemiBold14
        : context.textTheme.inverseUrbanistSemiBold14;
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            scaler.scale(14) > 20 ||
            constraints.maxWidth < metrics.length * (size + 5);
        final gauges = [
          for (final metric in metrics)
            _Gauge(
              metric: metric,
              size: size,
              stacked: stacked,
              visible: visible,
              captionStyle: captionStyle,
            ),
        ];
        if (stacked) return Column(spacing: 8, children: gauges);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [for (final gauge in gauges) Expanded(child: gauge)],
        );
      },
    );
  }
}

class _Gauge extends StatelessWidget {
  const _Gauge({
    required this.metric,
    required this.size,
    required this.stacked,
    required this.visible,
    required this.captionStyle,
  });

  final PearlMetric metric;
  final double size;
  final bool stacked;
  final bool visible;
  final TextStyle captionStyle;

  @override
  Widget build(BuildContext context) {
    final target = metric.fraction.isFinite
        ? metric.fraction.clamp(0.0, 1.0)
        : 0.0;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final reading = Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            metric.reading,
            style: context.textTheme.inversePlayfairMedium20,
          ),
        ),
      ),
    );
    Widget draw(double progress, Widget? child) => CustomPaint(
      key: metric.paintKey,
      painter: PearlProgressRingPainter(progress),
      child: child,
    );
    final ring = SizedBox.square(
      dimension: size,
      child: reduced || !visible
          ? draw(reduced ? target : 0, reading)
          : TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 720),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0, end: target),
              child: reading,
              builder: (context, fraction, child) => draw(fraction, child),
            ),
    );
    final caption = Text(
      metric.label,
      style: captionStyle,
      textAlign: stacked ? TextAlign.start : TextAlign.center,
    );
    return Semantics(
      label: metric.label,
      value: metric.reading,
      excludeSemantics: true,
      child: stacked
          ? Row(
              spacing: 12,
              children: [
                ring,
                Expanded(child: caption),
              ],
            )
          : Column(spacing: 6, children: [ring, caption]),
    );
  }
}

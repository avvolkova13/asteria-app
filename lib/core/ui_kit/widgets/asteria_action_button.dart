import 'package:flutter/material.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_activity_indicator.dart';

/// The two approved CTA surfaces: calendar purple and dream interpretation gold.
class AsteriaActionButton extends StatelessWidget {
  const AsteriaActionButton({
    super.key,
    this.text,
    this.child,
    required this.onPressed,
    this.isLoading = false,
    this.gold = false,
    this.width,
    this.height = 50,
  });
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool gold;
  final double? width;
  final double height;
  static final purpleGradient = _calendarGradient();
  static LinearGradient _calendarGradient() {
    final base = CardLensDecoration.buttonFill(const Color(0xFF6E4BFF));
    const stops = [0.0, .20, .48, .55, .78, 1.0];
    Color sample(double t) {
      final i = base.stops!.indexWhere((stop) => stop >= t);
      if (i <= 0) return base.colors.first;
      return Color.lerp(
        base.colors[i - 1],
        base.colors[i],
        (t - base.stops![i - 1]) / (base.stops![i] - base.stops![i - 1]),
      )!;
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: stops,
      colors: [
        for (final t in stops)
          Color.alphaBlend(
            Colors.white.withValues(alpha: .25 * (1 - t / .55).clamp(0, 1)),
            sample(t),
          ),
      ],
    );
  }

  static const goldGradient = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
    stops: [0, .50032, 1],
  );
  static CardLensDecoration decoration({
    bool gold = false,
    bool enabled = true,
  }) => CardLensDecoration.button(
    enabled: enabled,
    borderRadius: BorderRadius.circular(16),
    gradient: gold ? goldGradient : purpleGradient,
  );
  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final foreground = gold ? const Color(0xFF21152F) : Colors.white;
    return LotusFeedback(
      onActivate: enabled ? onPressed : null,
      builder: (activate) => Semantics(
        button: true,
        enabled: enabled,
        child: Opacity(
          opacity: enabled ? 1 : .48,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: SizedBox(
              width: width,
              child: DecoratedBox(
                decoration: CardLensDecoration.button(
                  enabled: enabled,
                  borderRadius: BorderRadius.circular(16),
                  gradient: gold ? goldGradient : purpleGradient,
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: activate,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          DefaultTextStyle.merge(
                            style: TextStyle(
                              fontFamily: 'Onest',
                              fontSize: 16,
                              height: 1.2,
                              fontWeight: FontWeight.w600,
                              color: foreground,
                            ),
                            child: IconTheme(
                              data: IconThemeData(color: foreground, size: 20),
                              child: isLoading
                                  ? AsteriaActivityIndicator(
                                      size: 20,
                                      color: foreground,
                                    )
                                  : child ??
                                        Text(
                                          text ?? '',
                                          textAlign: TextAlign.center,
                                        ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

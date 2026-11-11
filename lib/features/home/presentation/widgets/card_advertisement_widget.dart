import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

enum CardAdvertisementVariant {
  legacy,
  natalCardBanner,
  balanceSubscriptionBanner,
}

class CardAdvertisementWidget extends StatelessWidget {
  static const _natalCardBannerBackground = Color(0xFF2A2038);
  static const _balanceSubscriptionBackground = Color(0xFF332D3B);

  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;
  final double? horizontalMargin;
  final CardAdvertisementVariant variant;

  const CardAdvertisementWidget({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
    this.horizontalMargin,
    this.variant = CardAdvertisementVariant.legacy,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case CardAdvertisementVariant.legacy:
        return _buildLegacy(context);
      case CardAdvertisementVariant.natalCardBanner:
        return _buildNatalCardBanner(context);
      case CardAdvertisementVariant.balanceSubscriptionBanner:
        return _buildBalanceSubscriptionBanner(context);
    }
  }

  Widget _buildLegacy(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin ?? 16),
      padding: const EdgeInsets.all(16),
      decoration: CardLensDecoration(
        borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
        image: const DecorationImage(
          image: AssetImage('assets/images/home/birth_map_bg.webp'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.textTheme.inversePlayfairSemiBold24),
          const SizedBox(height: 16),
          Text(description, style: context.textTheme.inverseUrbanistRegular16),
          const SizedBox(height: 16),
          CustomButton(
            height: 50,
            type: CustomButtonType.primary,
            text: buttonText,
            isFullWidth: true,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildNatalCardBanner(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth - 2 * (horizontalMargin ?? 16);
        final wheelSize = (cardWidth * .34).clamp(0.0, 138.0).toDouble();
        final roomyCopy =
            cardWidth < 330 || MediaQuery.textScalerOf(context).scale(16) > 20;
        final heading = Text(
          title,
          style: context.textTheme.inversePlayfairSemiBold24.copyWith(
            height: 1.1,
          ),
        );
        final body = Text(
          description,
          style: context.textTheme.inverseUrbanistRegular16,
        );

        return Container(
          key: const ValueKey('natal-card-banner'),
          margin: EdgeInsets.symmetric(horizontal: horizontalMargin ?? 16),
          padding: const EdgeInsets.all(16),
          decoration: CardLensDecoration(
            color: _natalCardBannerBackground,
            borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        heading,
                        if (!roomyCopy) ...[const SizedBox(height: 8), body],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox.square(
                    dimension: wheelSize,
                    child: const _NatalCardWheel(),
                  ),
                ],
              ),
              if (roomyCopy) ...[const SizedBox(height: 8), body],
              const SizedBox(height: 16),
              _NatalCardButton(text: buttonText, onPressed: onPressed),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceSubscriptionBanner(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final clampedTextScale = textScale > 1.35 ? 1.35 : textScale;

    return LayoutBuilder(
      builder: (context, constraints) {
        final outerWidth = constraints.maxWidth;
        final horizontalMargin = this.horizontalMargin ?? 16;
        final cardWidth = outerWidth - (horizontalMargin * 2);
        final baseHeight = cardWidth / 1.598;
        final scaledHeight =
            baseHeight + ((clampedTextScale - 1).clamp(0, 1) * 320);
        final textWidth = cardWidth * 0.61;
        final artWidth = cardWidth * 0.34;

        const borderRadius = AsteriaCardRadii.card;

        return Container(
          width: double.infinity,
          height: scaledHeight.toDouble(),
          margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
          clipBehavior: Clip.antiAlias,
          decoration: CardLensDecoration(
            color: _balanceSubscriptionBackground,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                top: 14,
                right: 12,
                width: artWidth,
                height: baseHeight * 0.76,
                child: Image.asset(
                  'assets/images/home/balance_subscription_art.webp',
                  cacheWidth: 500,
                  fit: BoxFit.contain,
                  alignment: Alignment.topRight,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: textWidth,
                      child: Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.inversePlayfairSemiBold24
                            .copyWith(height: 1),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: textWidth,
                      child: Text(
                        description,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.inverseUrbanistRegular16
                            .copyWith(height: 1.1),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: _BalanceSubscriptionButton(
                        text: buttonText,
                        onPressed: onPressed,
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _BalanceSubscriptionBorderPainter(
                      radius: borderRadius,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NatalCardWheel extends StatelessWidget {
  const _NatalCardWheel();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/home/natal_card_banner_wheel.webp',
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}

class _NatalCardButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _NatalCardButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: double.infinity,
      height: 44,
      child: Material(
        color: Colors.transparent,
        child: LotusInkTap(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: CardLensDecoration.button(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF6E4BFF)),
            ),
            child: Center(
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    colors: [Color(0xFF6E4BFF), Color(0xFF5A3FD1)],
                  ).createShader(Offset.zero & bounds.size);
                },
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: context.textTheme.inverseUrbanistRegular17.copyWith(
                    color: AppColors.textInverse,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: text,
      excludeSemantics: true,
      child: button,
    );
  }
}

class _BalanceSubscriptionBorderPainter extends CustomPainter {
  static const _borderColor = Color(0xFF9A7DB8);
  static const _highlightColor = Color(0xFFE6D8F4);
  static const _glowColor = Color(0x809A7DB8);

  final double radius;

  const _BalanceSubscriptionBorderPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final strokeInset = 0.65;
    final left = strokeInset;
    final top = strokeInset;
    final right = size.width - strokeInset;
    final bottom = size.height - strokeInset;
    final effectiveRadius = radius - strokeInset;
    final pathRect = rect.deflate(strokeInset);

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _borderColor.withValues(alpha: 0.26);

    canvas.drawRRect(
      RRect.fromRectAndRadius(pathRect, Radius.circular(effectiveRadius)),
      basePaint,
    );

    _drawGlowLine(
      canvas,
      Offset(left + effectiveRadius * 0.72, top),
      Offset(size.width * 0.78, top),
      fadeToEnd: true,
    );
    _drawGlowLine(
      canvas,
      Offset(left, top + effectiveRadius * 0.72),
      Offset(left, size.height * 0.78),
      fadeToEnd: true,
    );
    _drawGlowArc(
      canvas,
      Rect.fromLTWH(left, top, effectiveRadius * 2, effectiveRadius * 2),
      math.pi,
      math.pi / 2,
    );

    _drawGlowLine(
      canvas,
      Offset(size.width * 0.22, bottom),
      Offset(right - effectiveRadius * 0.72, bottom),
      fadeToEnd: false,
    );
    _drawGlowLine(
      canvas,
      Offset(right, size.height * 0.22),
      Offset(right, bottom - effectiveRadius * 0.72),
      fadeToEnd: false,
    );
    _drawGlowArc(
      canvas,
      Rect.fromLTWH(
        right - effectiveRadius * 2,
        bottom - effectiveRadius * 2,
        effectiveRadius * 2,
        effectiveRadius * 2,
      ),
      0,
      math.pi / 2,
    );
  }

  void _drawGlowLine(
    Canvas canvas,
    Offset start,
    Offset end, {
    required bool fadeToEnd,
  }) {
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2.4)
      ..shader = ui.Gradient.linear(
        start,
        end,
        fadeToEnd
            ? [_glowColor, _glowColor.withValues(alpha: 0)]
            : [_glowColor.withValues(alpha: 0), _glowColor],
      );
    canvas.drawLine(start, end, glowPaint);

    final sharpPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.linear(
        start,
        end,
        fadeToEnd
            ? [
                _highlightColor.withValues(alpha: 0.92),
                _borderColor.withValues(alpha: 0.06),
              ]
            : [
                _borderColor.withValues(alpha: 0.06),
                _highlightColor.withValues(alpha: 0.92),
              ],
      );
    canvas.drawLine(start, end, sharpPaint);
  }

  void _drawGlowArc(
    Canvas canvas,
    Rect arcRect,
    double startAngle,
    double sweepAngle,
  ) {
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2.2)
      ..color = _glowColor.withValues(alpha: 0.72);
    canvas.drawArc(arcRect, startAngle, sweepAngle, false, glowPaint);

    final sharpPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = _highlightColor.withValues(alpha: 0.88);
    canvas.drawArc(arcRect, startAngle, sweepAngle, false, sharpPaint);
  }

  @override
  bool shouldRepaint(_BalanceSubscriptionBorderPainter oldDelegate) {
    return oldDelegate.radius != radius;
  }
}

class _BalanceSubscriptionButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const _BalanceSubscriptionButton({
    required this.text,
    required this.onPressed,
  });

  @override
  State<_BalanceSubscriptionButton> createState() =>
      _BalanceSubscriptionButtonState();
}

class _BalanceSubscriptionButtonState extends State<_BalanceSubscriptionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerPosition;
  Timer? _shimmerTimer;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _shimmerPosition = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOutCubic,
    );
    _scheduleNextShimmer();
  }

  void _scheduleNextShimmer() {
    _shimmerTimer?.cancel();
    _shimmerTimer = Timer(const Duration(milliseconds: 4600), () async {
      if (!mounted) {
        return;
      }
      if (!MediaQuery.disableAnimationsOf(context)) {
        try {
          await _shimmerController.forward(from: 0).orCancel;
        } on TickerCanceled {
          return;
        }
      }
      if (mounted) {
        _scheduleNextShimmer();
      }
    });
  }

  @override
  void dispose() {
    _shimmerTimer?.cancel();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final button = SizedBox(
      height: 42,
      child: Material(
        color: Colors.transparent,
        child: LotusInkTap(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(21),
          child: Ink(
            decoration: CardLensDecoration.button(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF7BC6A),
                  Color(0xFFF5AC51),
                  Color(0xFFEFA04A),
                ],
                stops: [0, 0.56, 1],
              ),
              borderRadius: BorderRadius.circular(21),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(21),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!disableAnimations)
                    Positioned.fill(
                      key: const ValueKey('balance-subscription-cta-shimmer'),
                      child: AnimatedBuilder(
                        animation: _shimmerPosition,
                        builder: (context, child) {
                          final value = _shimmerPosition.value;
                          return FractionalTranslation(
                            translation: Offset(-1.2 + (value * 2.4), 0),
                            child: child,
                          );
                        },
                        child: const _BalanceSubscriptionButtonShimmer(),
                      ),
                    ),
                  Center(
                    child: Text(
                      widget.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.urbanistRegular16.copyWith(
                        color: const Color(0xFF2A1533),
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: widget.text,
      excludeSemantics: true,
      child: button,
    );
  }
}

class _BalanceSubscriptionButtonShimmer extends StatelessWidget {
  const _BalanceSubscriptionButtonShimmer();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.13),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0.36, 0.5, 0.64],
          transform: const GradientRotation(-0.25),
        ),
      ),
      child: Align(
        alignment: Alignment.center,
        child: FractionallySizedBox(
          widthFactor: 0.36,
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.09),
                  Colors.white.withValues(alpha: 0),
                ],
                stops: const [0, 0.5, 1],
                transform: const GradientRotation(-0.25),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

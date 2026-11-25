import 'package:asteria_app/core/ui_kit/widgets/responsive_heading.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';

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
  static const _balanceSubscriptionBackground = AppColorsDark.modal;

  final Widget? natalChartPreview;
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
    this.natalChartPreview,
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
        final wheelSize = (cardWidth * .44).clamp(0.0, 174.0).toDouble();
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
              if (roomyCopy || natalChartPreview == null) ...[
                heading,
                if (natalChartPreview != null) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: SizedBox.square(
                      dimension: wheelSize,
                      child: natalChartPreview,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                body,
              ] else
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [heading, const SizedBox(height: 8), body],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox.square(
                      dimension: wheelSize,
                      child: natalChartPreview,
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              _NatalCardButton(text: buttonText, onPressed: onPressed),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceSubscriptionBanner(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final margin = horizontalMargin ?? 16;
        final cardWidth = constraints.maxWidth - margin * 2;
        final artWidth = (cardWidth * .29).clamp(64.0, 120.0);
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final minimumHeight =
            (cardWidth / 1.598).clamp(0.0, 240.0) +
            (scale - 1).clamp(0.0, .35) * 320;
        final roomyCopy = cardWidth < 310 || scale > 1.25;
        final body = Text(
          description,
          style: context.textTheme.inverseUrbanistRegular16.copyWith(
            height: 1.2,
          ),
        );
        const borderRadius = AsteriaCardRadii.card;
        return Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: minimumHeight),
          margin: EdgeInsets.symmetric(horizontal: margin),
          clipBehavior: Clip.antiAlias,
          decoration: CardLensDecoration(
            color: _balanceSubscriptionBackground,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: roomyCopy ? 12 : 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (roomyCopy)
                      ResponsiveHeading(
                        title,
                        style: context.textTheme.inversePlayfairSemiBold24
                            .copyWith(height: 1),
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: context
                                      .textTheme
                                      .inversePlayfairSemiBold24
                                      .copyWith(height: 1),
                                ),
                                if (!roomyCopy) ...[
                                  const SizedBox(height: 6),
                                  body,
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Image.asset(
                            'assets/images/home/balance_subscription_art.webp',
                            width: artWidth,
                            height: roomyCopy ? artWidth * .92 : artWidth * 1.1,
                            fit: BoxFit.contain,
                            cacheWidth: 500,
                            excludeFromSemantics: true,
                          ),
                        ],
                      ),
                    if (roomyCopy) ...[
                      const SizedBox(height: 6),
                      body,
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Image.asset(
                          'assets/images/home/balance_subscription_art.webp',
                          width: artWidth,
                          height: artWidth * .92,
                          fit: BoxFit.contain,
                          cacheWidth: 500,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ],
                    SizedBox(height: roomyCopy ? 10 : 12),
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

class _NatalCardButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _NatalCardButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AsteriaActionButton(
      text: text,
      onPressed: onPressed,
      gold: true,
      width: double.infinity,
      height: 44,
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

class _BalanceSubscriptionButton extends StatelessWidget {
  const _BalanceSubscriptionButton({
    required this.text,
    required this.onPressed,
  });
  final String text;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => AsteriaActionButton(
    text: text,
    onPressed: onPressed,
    gold: true,
    width: double.infinity,
  );
}

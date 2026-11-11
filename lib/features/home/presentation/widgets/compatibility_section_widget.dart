import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'dart:math' as math;
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';

import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/extensions/datetime_extensions.dart';
import 'package:asteria_app/core/extensions/string_extensions.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class CompatibilitySectionWidget extends StatelessWidget {
  final VoidCallback onPressed;
  const CompatibilitySectionWidget({Key? key, required this.onPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = di.get<UserProvider>();
    return ListenableBuilder(
      listenable: userProvider,
      builder: (context, _) {
        final compatibilityHistory =
            userProvider.currentUser?.compatibilityHistory;
        final bool hasCompatibility =
            compatibilityHistory != null && compatibilityHistory.isNotEmpty;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: hasCompatibility
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.l10n.compatibilityTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.playfairSemiBold24
                                .copyWith(height: 1),
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: context.l10n.openCompatibilityLabel,
                          child: LotusTap(
                            behavior: HitTestBehavior.opaque,
                            onTap: onPressed,
                            child: ClayAssetIcon(
                              'assets/icons/repeat_icon.svg',
                              width: 24,
                              height: 24,
                              tint: Color(0xFFE6994D),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _CompatibilityHistoryWidget(
                      firstBirthdate: compatibilityHistory.first.firstBirthdate,
                      secondBirthdate:
                          compatibilityHistory.first.secondBirthdate,
                      firstZodiacSign: compatibilityHistory.first.firstBirthdate
                          .getZodiacSignName(
                            languageCode: Localizations.localeOf(
                              context,
                            ).languageCode,
                          ),
                      secondZodiacSign: compatibilityHistory
                          .first
                          .secondBirthdate
                          .getZodiacSignName(
                            languageCode: Localizations.localeOf(
                              context,
                            ).languageCode,
                          ),
                      compatibilityPercentage: compatibilityHistory
                          .first
                          .compatibilityData
                          .percentage
                          .getPercentage,
                      compatibilityDescription: compatibilityHistory
                          .first
                          .compatibilityData
                          .introduction,
                      phrase:
                          compatibilityHistory.first.compatibilityData.phrase,
                      onPressed: onPressed,
                    ),
                  ],
                )
              : Column(
                  children: [
                    // Title
                    Text(
                      context.l10n.compatibilityAboutPair,
                      style: context.textTheme.playfairSemiBold24,
                    ),
                    const SizedBox(height: 12),
                    // Description
                    Text(
                      context.l10n.compatibilityAboutPairDescription,
                      textAlign: TextAlign.center,
                      style: context.textTheme.urbanistRegular16,
                    ),
                    const SizedBox(height: 8),
                    // Compatibility visualization
                    Image.asset('assets/images/home/compatibility.webp'),
                    const SizedBox(height: 16),
                    // Button
                    CustomButton(
                      text: context.l10n.compatibilityCheck,
                      onPressed: onPressed,
                      isFullWidth: true,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _CompatibilityHistoryWidget extends StatelessWidget {
  final DateTime firstBirthdate;
  final DateTime secondBirthdate;
  final String firstZodiacSign;
  final String secondZodiacSign;
  final int compatibilityPercentage;
  final String compatibilityDescription;
  final String phrase;
  final VoidCallback onPressed;

  const _CompatibilityHistoryWidget({
    Key? key,
    required this.firstBirthdate,
    required this.secondBirthdate,
    required this.firstZodiacSign,
    required this.secondZodiacSign,
    required this.compatibilityPercentage,
    required this.compatibilityDescription,
    required this.phrase,
    required this.onPressed,
  }) : super(key: key);

  static const double _cardHeight = 315;
  static const double _horizontalPadding = 16;
  static const double _zodiacColumnWidth = 110;
  static const LinearGradient _accentGradient = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
  );

  @override
  Widget build(BuildContext context) {
    final dateStyle = context.textTheme.inverseUrbanistRegular16.copyWith(
      height: 1.2,
      letterSpacing: -0.408,
    );
    final nameStyle = context.textTheme.playfairMedium20.copyWith(height: 1.1);
    final percentageStyle = context.textTheme.playfairSemiBold24.copyWith(
      height: 1,
    );
    final bodyStyle = context.textTheme.inverseUrbanistRegular16.copyWith(
      height: 1.2,
      letterSpacing: -0.408,
    );
    final linkStyle = context.textTheme.urbanistSemiBold16.copyWith(
      height: 1.2,
      letterSpacing: -0.408,
    );

    return Semantics(
      button: true,
      label: context.l10n.compatibilityDetailsLabel,
      child: LotusTap(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox(
          height: _cardHeight,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
            child: DecoratedBox(
              decoration: const BoxDecoration(color: Color(0xFF171026)),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = constraints.maxWidth;
                  final rightColumnLeft =
                      cardWidth - _horizontalPadding - _zodiacColumnWidth;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/home/compatibility_background.webp',
                          fit: BoxFit.cover,
                          alignment: const Alignment(0, 0.08),
                          opacity: const AlwaysStoppedAnimation(0.5),
                        ),
                      ),
                      Positioned(
                        left: _horizontalPadding,
                        top: 24,
                        width: _zodiacColumnWidth,
                        child: _ZodiacPersonColumn(
                          name: firstZodiacSign,
                          birthdate: firstBirthdate.toLocalizedShortDate(
                            Localizations.localeOf(context),
                          ),
                          assetName: firstBirthdate.getZodiacSignAsset(),
                          angle: -20,
                          nameStyle: nameStyle,
                          dateStyle: dateStyle,
                          gradient: _accentGradient,
                        ),
                      ),
                      Positioned(
                        left: rightColumnLeft,
                        top: 24,
                        width: _zodiacColumnWidth,
                        child: _ZodiacPersonColumn(
                          name: secondZodiacSign,
                          birthdate: secondBirthdate.toLocalizedShortDate(
                            Localizations.localeOf(context),
                          ),
                          assetName: secondBirthdate.getZodiacSignAsset(),
                          angle: 20,
                          nameStyle: nameStyle,
                          dateStyle: dateStyle,
                          gradient: _accentGradient,
                        ),
                      ),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _CompatibilityLinePainter(),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 116,
                        child: Center(
                          child: _GradientText(
                            '$compatibilityPercentage%',
                            gradient: _accentGradient,
                            style: percentageStyle,
                          ),
                        ),
                      ),
                      Positioned(
                        left: _horizontalPadding,
                        right: _horizontalPadding,
                        top: 198,
                        height: 60,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: cardWidth - _horizontalPadding * 2,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _GradientText(
                                  phrase,
                                  gradient: _accentGradient,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: bodyStyle,
                                ),
                                Text(
                                  compatibilityDescription,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: bodyStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: _horizontalPadding,
                        right: _horizontalPadding,
                        bottom: 24,
                        child: Center(
                          child: _GradientText(
                            context.l10n.compatibilityReadMore,
                            gradient: _accentGradient,
                            style: linkStyle,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ZodiacPersonColumn extends StatelessWidget {
  const _ZodiacPersonColumn({
    required this.name,
    required this.birthdate,
    required this.assetName,
    required this.angle,
    required this.nameStyle,
    required this.dateStyle,
    required this.gradient,
  });

  final String name;
  final String birthdate;
  final String assetName;
  final double angle;
  final TextStyle nameStyle;
  final TextStyle dateStyle;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GradientText(
          name,
          gradient: gradient,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: nameStyle,
        ),
        const SizedBox(height: 3),
        Text(
          birthdate,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: dateStyle,
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 110,
          width: 110,
          child: Center(
            child: Transform.rotate(
              angle: angle * math.pi / 180,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.white.withValues(alpha: 0.15),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/zodiacs/compatibility_round/$assetName.webp',
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText(
    this.text, {
    required this.gradient,
    required this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final Gradient gradient;
  final TextStyle style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        style: style.copyWith(color: AppColors.white),
      ),
    );
  }
}

class _CompatibilityLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.74)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.25;

    final topPath = Path()
      ..moveTo(size.width * 0.56, 101)
      ..cubicTo(
        size.width * 0.58,
        88,
        size.width * 0.62,
        98,
        size.width * 0.61,
        112,
      )
      ..cubicTo(
        size.width * 0.64,
        103,
        size.width * 0.68,
        110,
        size.width * 0.66,
        121,
      )
      ..cubicTo(
        size.width * 0.69,
        116,
        size.width * 0.71,
        120,
        size.width * 0.71,
        128,
      );

    final bottomPath = Path()
      ..moveTo(size.width * 0.39, 171)
      ..cubicTo(
        size.width * 0.42,
        151,
        size.width * 0.48,
        148,
        size.width * 0.52,
        154,
      )
      ..cubicTo(
        size.width * 0.47,
        153,
        size.width * 0.44,
        159,
        size.width * 0.43,
        169,
      );

    final leftSpark = Path()
      ..moveTo(size.width * 0.34, 162)
      ..cubicTo(
        size.width * 0.33,
        149,
        size.width * 0.37,
        148,
        size.width * 0.37,
        160,
      )
      ..cubicTo(
        size.width * 0.35,
        154,
        size.width * 0.32,
        156,
        size.width * 0.33,
        166,
      );

    canvas.drawPath(topPath, paint);
    canvas.drawPath(bottomPath, paint);
    canvas.drawPath(leftSpark, paint);
  }

  @override
  bool shouldRepaint(covariant _CompatibilityLinePainter oldDelegate) {
    return false;
  }
}

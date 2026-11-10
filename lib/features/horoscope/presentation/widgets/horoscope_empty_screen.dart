import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/utils/enums.dart';
import 'package:flutter/material.dart';

class HoroscopeEmptyScreen extends StatelessWidget {
  final VoidCallback onBuyPressed;

  const HoroscopeEmptyScreen({required this.onBuyPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _HoroscopePaywall.maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.yearHoroscopePriceTitle(
                HoroscopeTypeEnum.year.price,
              ),
              textAlign: TextAlign.center,
              style: context.textTheme.inversePlayfairSemiBold24.copyWith(
                height: 1,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              context.l10n.yearHoroscopeIntro,
              textAlign: TextAlign.left,
              style: context.textTheme.inverseUrbanistRegular16.copyWith(
                height: 1.2,
                letterSpacing: -0.408,
              ),
            ),
            const SizedBox(height: 16),
            const _InsideCard(),
            const SizedBox(height: 18),
            Text(
              context.l10n.yearHoroscopeChapters,
              style: context.textTheme.inversePlayfairSemiBold24.copyWith(
                height: 1,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 16),
            const _ChapterIncludesList(),
            const SizedBox(height: 18),
            _BuyButton(onPressed: onBuyPressed),
            const SizedBox(height: 8),
            Text(
              context.l10n.natalInstantAccess,
              style: context.textTheme.inverseUrbanistRegular12.copyWith(
                color: AppColors.white.withValues(alpha: 0.82),
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoroscopePaywall {
  static const maxWidth = 358.0;
  static const glass = Color(0x339A7DB8);
  static const glassBorder = Color(0x33FFFFFF);
  static const orangeStart = Color(0xFFE6994D);
  static const orangeMid = Color(0xFFF3B76A);
  static const purpleStart = Color(0xFF6E4BFF);
  static const purpleEnd = Color(0xFF5A3FD1);

  static const orangeGradient = LinearGradient(
    colors: [orangeStart, orangeMid, orangeStart],
    stops: [0, 0.5, 1],
  );

  static const purpleGradient = LinearGradient(
    colors: [purpleStart, purpleEnd],
  );
}

class _InsideCard extends StatelessWidget {
  const _InsideCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 258),
      padding: const EdgeInsets.fromLTRB(16, 15, 12, 14),
      decoration: BoxDecoration(
        color: _HoroscopePaywall.glass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _HoroscopePaywall.glassBorder, width: 0.7),
      ),
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 330;
              final wandWidth = isCompact ? 82.0 : 105.0;
              final wandHeight = isCompact ? 123.0 : 157.0;
              final wandRight = isCompact ? 22.0 : 32.0;
              final wandTop = isCompact ? 86.0 : 66.0;
              final minFeatureWidth = isCompact ? 168.0 : 184.0;
              final maxFeatureWidth = isCompact ? 180.0 : 192.0;
              final featureWidth = constraints.maxWidth.clamp(
                minFeatureWidth,
                maxFeatureWidth,
              );

              return SizedBox(
                width: constraints.maxWidth,
                child: Stack(
                  children: [
                    Positioned(
                      right: wandRight,
                      top: wandTop,
                      child: IgnorePointer(
                        child: _PaywallWandImage(
                          width: wandWidth,
                          height: wandHeight,
                          horizontalCrop: isCompact ? 0.16 : 0.42,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.natalInsideTitle,
                          style: context.textTheme.inversePlayfairSemiBold24
                              .copyWith(height: 1, letterSpacing: 0),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: featureWidth,
                          child: Column(
                            children: [
                              _InsideFeatureItem(
                                title: '${context.l10n.horoscopeEssence} ',
                                description: context
                                    .l10n
                                    .horoscopeEssenceDescription,
                              ),
                              SizedBox(height: 8),
                              _InsideFeatureItem(
                                title: '${context.l10n.horoscopeLifeAreas} ',
                                description: context
                                    .l10n
                                    .horoscopeLifeAreasDescription,
                              ),
                              SizedBox(height: 8),
                              _InsideFeatureItem(
                                title: '${context.l10n.horoscopeEvolution} ',
                                description: context
                                    .l10n
                                    .horoscopeEvolutionDescription,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InsideFeatureItem extends StatelessWidget {
  final String title;
  final String description;

  const _InsideFeatureItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: const _PaywallSpriteIcon.crescent(),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: _GradientText(
                    title,
                    gradient: _HoroscopePaywall.orangeGradient,
                    style: context.textTheme.inverseUrbanistSemiBold16.copyWith(
                      height: 1.2,
                      letterSpacing: -0.408,
                    ),
                  ),
                ),
                TextSpan(
                  text: description,
                  style: context.textTheme.inverseUrbanistRegular16.copyWith(
                    height: 1.2,
                    letterSpacing: -0.408,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChapterIncludesList extends StatelessWidget {
  const _ChapterIncludesList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ChapterItem(text: context.l10n.horoscopeGeneral, isStrong: true),
        const SizedBox(height: 8),
        _ChapterItem(text: context.l10n.horoscopeWeakPoints, isStrong: true),
        const SizedBox(height: 8),
        _ChapterItem(text: context.l10n.horoscopePersonalAdvice, isStrong: true),
        const SizedBox(height: 8),
        _ChapterItem(
          text: context.l10n.horoscopeLifetimeDescription,
        ),
      ],
    );
  }
}

class _ChapterItem extends StatelessWidget {
  final String text;
  final bool isStrong;

  const _ChapterItem({
    required this.text,
    this.isStrong = false,
  });

  @override
  Widget build(BuildContext context) {
    final regularStyle = context.textTheme.inverseUrbanistRegular16.copyWith(
      height: 1.2,
      letterSpacing: -0.408,
    );
    final strongStyle = context.textTheme.inverseUrbanistSemiBold16.copyWith(
      height: 1.2,
      letterSpacing: -0.408,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: const _PaywallSpriteIcon.star(),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(text, style: isStrong ? strongStyle : regularStyle),
        ),
      ],
    );
  }
}

class _PaywallWandImage extends StatelessWidget {
  final double width;
  final double height;
  final double horizontalCrop;

  const _PaywallWandImage({
    required this.width,
    required this.height,
    required this.horizontalCrop,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidth = width * 3.2463;
    final imageHeight = height * 2.1642;

    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: imageWidth,
          maxWidth: imageWidth,
          minHeight: imageHeight,
          maxHeight: imageHeight,
          child: Transform.translate(
            offset: Offset(-width * horizontalCrop, -height * 0.0419),
            child: Image.asset(
              'assets/images/horoscope/year_paywall_wand.webp',
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}

enum _PaywallSpriteCrop { crescent, star }

class _PaywallSpriteIcon extends StatelessWidget {
  final _PaywallSpriteCrop crop;

  const _PaywallSpriteIcon.crescent() : crop = _PaywallSpriteCrop.crescent;

  const _PaywallSpriteIcon.star() : crop = _PaywallSpriteCrop.star;

  @override
  Widget build(BuildContext context) {
    const size = 19.0;
    final imageWidth = switch (crop) {
      _PaywallSpriteCrop.crescent => size * 2.744,
      _PaywallSpriteCrop.star => size * 2.7991,
    };
    final imageHeight = switch (crop) {
      _PaywallSpriteCrop.crescent => size * 2.6968,
      _PaywallSpriteCrop.star => size * 2.732,
    };
    final offset = switch (crop) {
      _PaywallSpriteCrop.crescent => Offset(-size * 1.5164, -size * 1.4452),
      _PaywallSpriteCrop.star => Offset(-size * 0.2433, -size * 1.4597),
    };

    return SizedBox(
      width: size,
      height: size,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: imageWidth,
          maxWidth: imageWidth,
          minHeight: imageHeight,
          maxHeight: imageHeight,
          child: Transform.translate(
            offset: offset,
            child: Image.asset(
              'assets/images/horoscope/year_paywall_moon.webp',
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}

class _BuyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BuyButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: _HoroscopePaywall.purpleGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.1),
          width: 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: _HoroscopePaywall.purpleStart.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.white.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SizedBox(
        height: 50,
        child: Semantics(
          button: true,
          label: context.l10n.buyYearHoroscopeLabel(
            HoroscopeTypeEnum.year.price,
          ),
          child: LotusButtons.text(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              context.l10n.commonBuy,
              textAlign: TextAlign.center,
              style: context.textTheme.button.copyWith(
                color: AppColors.white,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientText extends StatelessWidget {
  final String text;
  final Gradient gradient;
  final TextStyle style;

  const _GradientText(this.text, {required this.gradient, required this.style});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}

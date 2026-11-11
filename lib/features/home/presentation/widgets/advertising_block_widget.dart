import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class AdvertisingBlockWidget extends StatelessWidget {
  static const _backgroundAsset = 'assets/images/home/advertising_card_bg.webp';
  static const _liveyaAsset = 'assets/images/home/advertising_card_liveya.webp';
  // Figma dark Surface/card for the dream banner (node 4379:8613).
  static const _cardBackground = Color(0xFF151028);
  static const _descriptionColor = Color(0xFFB5AAB8);
  static const _orangeGradient = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
    stops: [0, 0.50032, 1],
  );

  const AdvertisingBlockWidget({super.key, this.horizontalMargin = 16});

  final double horizontalMargin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          final availableContentWidth = cardWidth > 32
              ? cardWidth - 32
              : cardWidth;
          final subtitleWidth = _widthWithin(availableContentWidth, 190);
          final descriptionWidth = _widthWithin(availableContentWidth, 161);
          final buttonWidth = _widthWithin(availableContentWidth, 161);
          final imageScale = (cardWidth / 358).clamp(0.8, 1).toDouble();
          final imageWidth = 144 * imageScale;
          final imageHeight = 212 * imageScale;
          final imageRight = 8 * imageScale;

          return ClipRRect(
            borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: CardLensDecoration(
                borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
              ),
              child: SizedBox(
                height: 243,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    const Positioned.fill(
                      child: ColoredBox(color: _cardBackground),
                    ),
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.25,
                        child: Image.asset(_backgroundAsset, fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: imageRight,
                      width: imageWidth,
                      height: imageHeight,
                      child: Image.asset(
                        _liveyaAsset,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          context.l10n.adDreamTitle,
                          maxLines: 1,
                          style: context.textTheme.inversePlayfairSemiBold24
                              .copyWith(
                                fontFamily: 'Lora',
                                height: 1,
                                letterSpacing: 0,
                              ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 56,
                      left: 16,
                      width: subtitleWidth,
                      child: _AdvertisingSubtitle(
                        textStyle: context.textTheme.inverseUrbanistSemiBold16
                            .copyWith(
                              fontFamily: 'Onest',
                              height: 1.2,
                              letterSpacing: -0.408,
                            ),
                      ),
                    ),
                    Positioned(
                      top: 110,
                      left: 16,
                      width: descriptionWidth,
                      child: Text(
                        context.l10n.adDreamDescription,
                        style: context.textTheme.tertiaryUrbanistRegular16
                            .copyWith(
                              fontFamily: 'Onest',
                              height: 1.2,
                              letterSpacing: -0.408,
                              color: _descriptionColor,
                            ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      width: buttonWidth,
                      child: _AdvertisingCtaButton(
                        onTap: () {
                          CreateSonnikInitialRoute.push(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  double _widthWithin(double availableWidth, double preferredWidth) {
    if (availableWidth < preferredWidth) {
      return availableWidth;
    }

    return preferredWidth;
  }
}

class _AdvertisingSubtitle extends StatelessWidget {
  final TextStyle textStyle;

  const _AdvertisingSubtitle({required this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback:
                  AdvertisingBlockWidget._orangeGradient.createShader,
              child: Text(context.l10n.adLiviaName, style: textStyle),
            ),
            Text(' —', style: textStyle),
          ],
        ),
        Text(context.l10n.adLiviaSubtitle, maxLines: 1, style: textStyle),
      ],
    );
  }
}

class _AdvertisingCtaButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AdvertisingCtaButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LotusFeedback(
      onActivate: onTap,
      builder: (activate) => Semantics(
        button: true,
        enabled: true,
        label: context.l10n.adDecode,
        onTap: activate,
        child: SizedBox(
          height: 44,
          child: DecoratedBox(
            decoration: CardLensDecoration.button(
              borderRadius: BorderRadius.circular(16),
              gradient: AdvertisingBlockWidget._orangeGradient,
              boxShadow: const [
                BoxShadow(color: Color(0x0D6E4BFF), blurRadius: 30),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: activate,
                child: Center(
                  child: ExcludeSemantics(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        context.l10n.adDecode,
                        maxLines: 1,
                        style: context.textTheme.inverseUrbanistRegular17
                            .copyWith(
                              fontFamily: 'Onest',
                              color: AppColors.textPrimary,
                              height: 1.2,
                              letterSpacing: -0.408,
                            ),
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

import 'dart:math' as math;

import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AffirmationOfTheDayWidget extends StatelessWidget {
  static const double _cardHeight = 264;
  static const Color _cardBackgroundColor = Color(0xFF1B1433);
  static const double _flowerWidth = 126;
  static const double _flowerVisibleHeight = 143;
  static const double _flowerImageWidth = 154.61;
  static const double _flowerImageHeight = 231;
  static const double _flowerImageLeft = -13.33;
  static const double _flowerImageTop = -16;
  static const double _flowerTop = 133;
  static const double _maxTextScaleFactor = 1.2;
  static const LinearGradient _accentGradient = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
    stops: [0, 0.50032, 1],
  );

  const AffirmationOfTheDayWidget({Key? key, required this.text})
    : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(maxScaleFactor: _maxTextScaleFactor);

    return Semantics(
      button: true,
      label: context.l10n.affirmationOfDay,
      child: GestureDetector(
        onTap: () => AffirmationRoute.push(context),
        child: Container(
          height: _cardHeight,
          clipBehavior: Clip.hardEdge,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _cardBackgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    left: (constraints.maxWidth - _flowerWidth) / 2,
                    top: _flowerTop,
                    width: _flowerWidth,
                    height: _flowerVisibleHeight,
                    child: ClipRect(
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          Positioned(
                            left: _flowerImageLeft,
                            top: _flowerImageTop,
                            width: _flowerImageWidth,
                            height: _flowerImageHeight,
                            child: Image.asset(
                              'assets/images/home/affirmation_flower_figma.webp',
                              fit: BoxFit.fill,
                              cacheWidth: 464,
                              cacheHeight: 693,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: textScaler),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(child: _Description(text: text)),
                          const _AffirmationLink(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class AffirmationUnavailableWidget extends StatelessWidget {
  const AffirmationUnavailableWidget({
    super.key,
    required this.isLoading,
    required this.onRetry,
  });

  final bool isLoading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: isLoading
          ? context.l10n.affirmationLoadingLabel
          : context.l10n.affirmationUnavailableLabel,
      child: Container(
        width: double.infinity,
        height: AffirmationOfTheDayWidget._cardHeight,
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AffirmationOfTheDayWidget._cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -24,
              bottom: -72,
              width: 154.61,
              height: 231,
              child: Opacity(
                opacity: 0.35,
                child: Image.asset(
                  'assets/images/home/affirmation_flower_figma.webp',
                  fit: BoxFit.fill,
                  cacheWidth: 464,
                  cacheHeight: 693,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GradientText(
                  context.l10n.affirmationOfDay,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isLoading
                      ? context.l10n.affirmationLoading
                      : context.l10n.affirmationLoadError,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.inverseUrbanistRegular16.copyWith(
                    height: 1.2,
                  ),
                ),
                const Spacer(),
                if (isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.warning,
                    ),
                  )
                else
                  Semantics(
                    button: true,
                    label: context.l10n.affirmationRetryLabel,
                    child: TextButton(
                      onPressed: onRetry,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(96, 44),
                        alignment: Alignment.centerLeft,
                      ),
                      child: _GradientText(
                        context.l10n.commonRetry,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GradientText(
          context.l10n.affirmationOfDay,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 1.1,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: Text(
            text,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.inverseUrbanistRegular16.copyWith(
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _AffirmationLink extends StatelessWidget {
  const _AffirmationLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: _GradientText(
            context.l10n.allAffirmations,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Transform.rotate(
          angle: -math.pi / 4,
          child: SvgPicture.asset(
            'assets/icons/affirmation_arrow_figma.svg',
            width: 24,
            height: 24,
          ),
        ),
      ],
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText(
    this.text, {
    required this.style,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle style;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return AffirmationOfTheDayWidget._accentGradient.createShader(
          Offset.zero & bounds.size,
        );
      },
      child: Text(
        text,
        maxLines: maxLines,
        overflow: overflow,
        style: style.copyWith(color: AppColors.textInverse),
      ),
    );
  }
}

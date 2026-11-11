import 'package:asteria_app/core/config/app_feature_visibility.dart';
import 'dart:math' as math;

import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'onboarding_visual_styles.dart';

/// A static sample of the personal forecast, without a user or birth chart.
class OnboardingPersonalVisual extends StatelessWidget {
  const OnboardingPersonalVisual({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: 390,
      height: 426,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            left: 16,
            top: 0,
            width: 358,
            height: 174,
            child: _CompatibilityPreview(),
          ),
          Positioned(
            left: 16,
            top: 190,
            width: 190,
            height: 119,
            child: _CosmicPanel(
              child: Padding(
                padding: const EdgeInsets.all(8.49),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.onboardPreviewMagicTitle,
                      style: OnboardingVisualStyles.title(
                        12.74,
                        weight: FontWeight.w600,
                      ).copyWith(height: 1),
                    ),
                    const SizedBox(height: 8.49),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          width: 116,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: 116,
                              child: Text(
                                l10n.onboardPreviewMagicDescription,
                                style: OnboardingVisualStyles.body(
                                  8.49,
                                  spacing: -0.22,
                                ).copyWith(height: 1.2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 136,
            top: 174,
            width: 78,
            height: 192,
            child: Image.asset(
              'assets/images/home/natal_magic_image.webp',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              excludeFromSemantics: true,
            ),
          ),
          if (AppFeatureVisibility.horoscopes)
            Positioned(
              left: 224,
              top: 190,
              width: 150,
              height: 44,
              child: _StatePreview(
                label: l10n.horoscopeWellbeing,
                description: l10n.onboardPreviewPersonalState,
              ),
            ),
          const Positioned(
            left: 209,
            top: 323.3,
            width: 144,
            height: 102,
            child: _NatalPreview(),
          ),
          Positioned(
            left: 278.71,
            top: 297,
            width: 95.29,
            height: 95.75,
            child: Image.asset(
              'assets/images/home/natal_card_banner_wheel.webp',
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompatibilityPreview extends StatelessWidget {
  const _CompatibilityPreview();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 326,
        height: 159,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 0,
              width: 110,
              child: _ZodiacPreview(
                name: l10n.onboardPreviewTaurus,
                dates: l10n.onboardPreviewTaurusDates,
                asset: 'telec',
                angle: -20,
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              width: 110,
              child: _ZodiacPreview(
                name: l10n.onboardPreviewGemini,
                dates: l10n.onboardPreviewGeminiDates,
                asset: 'bliznecy',
                angle: 20,
              ),
            ),
            Positioned(
              left: 159.5,
              top: 59,
              width: 55,
              height: 30,
              child: SvgPicture.asset(
                'assets/icons/compatibility_vector_51.svg',
                fit: BoxFit.fill,
                excludeFromSemantics: true,
              ),
            ),
            Positioned(
              left: 102.5,
              top: 111,
              width: 62.35,
              height: 49.1,
              child: Transform.rotate(
                angle: 157 * math.pi / 180,
                child: Transform.scale(
                  scaleY: -1,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/compatibility_vector_52.svg',
                      width: 55,
                      height: 30,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 110,
              right: 110,
              top: 92,
              child: OnboardingGoldText(
                l10n.onboardPreviewCompatibilityScore,
                style: OnboardingVisualStyles.title(
                  24,
                  weight: FontWeight.w600,
                ).copyWith(height: 1),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZodiacPreview extends StatelessWidget {
  final String name;
  final String dates;
  final String asset;
  final double angle;

  const _ZodiacPreview({
    required this.name,
    required this.dates,
    required this.asset,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OnboardingGoldText(
          name,
          style: OnboardingVisualStyles.title(20).copyWith(height: 1),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            dates,
            style: OnboardingVisualStyles.body(16).copyWith(height: 1.2),
          ),
        ),
        const SizedBox(height: 4),
        Transform.rotate(
          angle: angle * math.pi / 180,
          child: Image.asset(
            'assets/images/zodiacs/compatibility_round/$asset.webp',
            width: 110,
            height: 110,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
      ],
    );
  }
}

class _CosmicPanel extends StatelessWidget {
  final Widget child;

  const _CosmicPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: OnboardingVisualStyles.surface,
        borderRadius: BorderRadius.circular(8),
        image: const DecorationImage(
          image: AssetImage('assets/images/home/natal_magic_card.webp'),
          fit: BoxFit.cover,
          opacity: 0.25,
        ),
      ),
      child: child,
    );
  }
}

class _StatePreview extends StatelessWidget {
  final String label;
  final String description;

  const _StatePreview({required this.label, required this.description});

  @override
  Widget build(BuildContext context) {
    return OnboardingMiniCard(
      color: const Color(0xFF110628),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            width: 69.55,
            height: 11.3,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF875FE6), Color(0xFF5B3FD2)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomRight: Radius.circular(6.7),
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: OnboardingVisualStyles.body(
                    6.7,
                    weight: FontWeight.w600,
                    spacing: -0.14,
                  ).copyWith(height: 1),
                ),
              ),
            ),
          ),
          Positioned(
            left: 6.7,
            right: 6.7,
            top: 16,
            bottom: 4,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 136.6,
                child: Text(
                  description,
                  style: OnboardingVisualStyles.title(
                    8.38,
                  ).copyWith(height: 1.1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NatalPreview extends StatelessWidget {
  const _NatalPreview();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _CosmicPanel(
      child: Padding(
        padding: const EdgeInsets.all(6.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 58,
              child: Text(
                l10n.natalChartTitle,
                style: OnboardingVisualStyles.title(8).copyWith(height: 1.1),
              ),
            ),
            const SizedBox(height: 3.2),
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 66,
                    child: Text(
                      l10n.personalDefaultDescription,
                      style: OnboardingVisualStyles.body(
                        6.4,
                        spacing: -0.16,
                      ).copyWith(height: 1.2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3.2),
            Container(
              height: 17.7,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.4),
                border: Border.all(color: const Color(0xFF5B3FD2), width: 0.5),
              ),
              child: Text(
                l10n.personalOpenChart,
                style: OnboardingVisualStyles.body(
                  6.4,
                  color: const Color(0xFF9274E6),
                  spacing: -0.16,
                ).copyWith(height: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

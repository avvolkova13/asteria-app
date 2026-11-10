import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:asteria_app/core/ui_kit/app_typography.dart';
import '../../data/models/onboarding_page_model.dart';
import '../../localization/onboarding_localization_contract.dart';
import 'visuals/onboarding_daily_visual.dart';
import 'visuals/onboarding_personal_visual.dart';
import 'visuals/onboarding_tarot_visual.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPageModel page;
  final OnboardingLocalizationContract localization;

  const OnboardingPageWidget({
    super.key,
    required this.page,
    required this.localization,
  });

  static final _titleStyle = AppTypography.navLargeTitle.copyWith(
    color: Colors.white,
  );
  static final _descriptionStyle = AppTypography.text1.copyWith(
    color: Colors.white,
  );
  static const _heroAsset =
      'assets/images/onboarding/figma/onboarding_hero_1.webp';

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.paddingOf(context);
    final scaler = MediaQuery.textScalerOf(context);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF0D0719),
        image: DecorationImage(
          image: AssetImage('assets/images/onboarding/figma/onboarding_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final copyHeight =
              _textHeight(context, page.title, _titleStyle, width - 32) +
              16 +
              _textHeight(
                context,
                page.description,
                _descriptionStyle,
                width - 32,
              );
          final viewportHeight = math.max(
            0.0,
            constraints.maxHeight - safe.top - 40 - safe.bottom - 90,
          );
          final isHero = page.visualKind == OnboardingVisualKind.hero;
          final useHeroBackdrop =
              isHero &&
              scaler.scale(1) <= 1.3 &&
              copyHeight < viewportHeight * .6;
          final scale = math.min(
            width / 390,
            math.max(.65, (viewportHeight - copyHeight - 16) / 426),
          );
          final visualHeight = 426 * scale;
          final copy = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isHero)
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: page.title.split('\n').first,
                          style: const TextStyle(color: Color(0xFFF2A447)),
                        ),
                        TextSpan(
                          text:
                              '\n${page.title.split('\n').skip(1).join('\n')}',
                        ),
                      ],
                    ),
                    style: _titleStyle,
                  )
                else
                  Text(page.title, style: _titleStyle),
                const SizedBox(height: 16),
                Text(page.description, style: _descriptionStyle),
              ],
            ),
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              if (useHeroBackdrop)
                Positioned(
                  right: width < 360 ? -64 : -88,
                  bottom: constraints.maxHeight < 760 ? -20 : -28,
                  child: Image.asset(
                    _heroAsset,
                    height:
                        constraints.maxHeight *
                        (constraints.maxHeight < 760 ? .74 : .80),
                    fit: BoxFit.fitHeight,
                    filterQuality: FilterQuality.high,
                    excludeFromSemantics: true,
                  ),
                ),
              Positioned(
                top: safe.top + 40,
                left: 0,
                right: 0,
                bottom: safe.bottom + 90,
                child: SingleChildScrollView(
                  key: ValueKey('onboarding-content-${page.pageIndex}'),
                  child: Column(
                    children: [
                      copy,
                      if (!useHeroBackdrop) ...[
                        const SizedBox(height: 16),
                        Semantics(
                          label: page.description.replaceAll('\n', ' '),
                          image: true,
                          child: ExcludeSemantics(
                            child: IgnorePointer(
                              child: MediaQuery.withNoTextScaling(
                                child: SizedBox(
                                  key: ValueKey(
                                    'onboarding-visual-${page.pageIndex}',
                                  ),
                                  width: width,
                                  height: visualHeight,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    alignment: Alignment.topCenter,
                                    child: SizedBox(
                                      width: 390,
                                      height: 426,
                                      child: switch (page.visualKind) {
                                        OnboardingVisualKind.hero =>
                                          Image.asset(
                                            _heroAsset,
                                            fit: BoxFit.contain,
                                            excludeFromSemantics: true,
                                          ),
                                        OnboardingVisualKind.daily =>
                                          const OnboardingDailyVisual(),
                                        OnboardingVisualKind.tarot =>
                                          const OnboardingTarotVisual(),
                                        OnboardingVisualKind.personal =>
                                          const OnboardingPersonalVisual(),
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _textHeight(
    BuildContext context,
    String text,
    TextStyle style,
    double width,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.localeOf(context),
    )..layout(maxWidth: width);
    final height = painter.height;
    painter.dispose();
    return height;
  }
}

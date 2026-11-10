import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'onboarding_visual_styles.dart';

/// Static localized examples, rendered as text/shapes rather than a screenshot.
class OnboardingDailyVisual extends StatelessWidget {
  const OnboardingDailyVisual({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: 390,
      height: 426,
      child: Stack(
        children: [
          const Positioned(
            left: 13,
            top: 0,
            width: 365,
            height: 155,
            child: _PreviewCalendar(),
          ),
          Positioned(
            left: 87,
            top: 155,
            width: 217,
            height: 160,
            child: OnboardingMiniCard(
              color: const Color(0xFF1B1433),
              radius: 10,
              padding: const EdgeInsets.all(9.7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OnboardingGoldText(
                    l10n.affirmationOfDay,
                    style: OnboardingVisualStyles.title(12.12),
                  ),
                  const SizedBox(height: 4.85),
                  Text(
                    l10n.onboardingPreviewAffirmation,
                    style: OnboardingVisualStyles.body(9.7, spacing: -.25),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 226,
            width: 122,
            height: 165,
            child: _EnergyCard(
              title: l10n.energyRisks,
              phrase: l10n.onboardingPreviewRiskPhrase,
              description: l10n.onboardingPreviewRiskDescription,
              asset: 'energy_risks',
              percentage: '50%',
              progress: .5,
              accent: const Color(0xFFD99BAC),
            ),
          ),
          Positioned(
            left: 252,
            top: 253,
            width: 122,
            height: 165,
            child: _EnergyCard(
              title: l10n.energyFocus,
              phrase: l10n.onboardingPreviewFocusPhrase,
              description: l10n.onboardingPreviewFocusDescription,
              asset: 'energy_focus',
              percentage: '80%',
              progress: .8,
              accent: OnboardingVisualStyles.gold,
            ),
          ),
          Positioned(
            left: 147,
            top: 227,
            width: 96,
            height: 164,
            child: Image.asset(
              'assets/images/home/affirmation_flower_figma.webp',
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCalendar extends StatelessWidget {
  const _PreviewCalendar();

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    const statuses = [
      'neutral',
      'favorable',
      'favorable',
      'unfavorable',
      'favorable',
      'neutral',
      'unfavorable',
    ];
    return Row(
      children: List.generate(7, (index) {
        final selected = index == 3;
        // Fixed example dates, shared by both locales; never a live prediction.
        final date = DateTime(2026, 4, 19 + index);
        final color = selected ? const Color(0xFF140C15) : Colors.white;
        final moonDay = (12 + index).toString().padLeft(2, '0');
        return SizedBox(
          width: selected ? 78 : (index < 3 ? 48 : 143 / 3),
          height: selected ? 155 : 91,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: selected ? OnboardingVisualStyles.goldGradient : null,
              borderRadius: BorderRadius.circular(40),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color(0x40000000),
                        offset: Offset(0, 4),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: selected ? 9 : 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LotusRasterIcon(
                    'assets/icons/day_status_${statuses[index]}_star.png',
                    width: selected ? 22 : 14,
                    height: selected ? 22 : 14,
                    excludeFromSemantics: true,
                  ),
                  Text(
                    DateFormat.E(locale).format(date).toUpperCase(),
                    style: OnboardingVisualStyles.body(
                      selected ? 16 : 10,
                      color: color.withValues(alpha: selected ? .8 : .6),
                      spacing: 0,
                    ),
                  ),
                  Text(
                    DateFormat.MMMd(locale).format(date).replaceAll('.', ''),
                    style: OnboardingVisualStyles.body(
                      selected ? 17 : 9,
                      color: color,
                      weight: selected ? FontWeight.w600 : FontWeight.w400,
                      spacing: -.3,
                    ),
                  ),
                  Image.asset(
                    'assets/images/moon_phase_days/day_$moonDay.webp',
                    width: selected ? 62 : 36,
                    height: selected ? 62 : 36,
                    excludeFromSemantics: true,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _EnergyCard extends StatelessWidget {
  final String title, phrase, description, asset, percentage;
  final double progress;
  final Color accent;
  const _EnergyCard({
    required this.title,
    required this.phrase,
    required this.description,
    required this.asset,
    required this.percentage,
    required this.progress,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => OnboardingMiniCard(
    glow: true,
    padding: const EdgeInsets.all(5.6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 72,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 7,
                width: 44,
                height: 48,
                child: Image.asset(
                  'assets/images/home/$asset.webp',
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
              SizedBox(
                width: 64,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OnboardingGoldText(
                      title,
                      style: OnboardingVisualStyles.title(13.94),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      phrase,
                      style: OnboardingVisualStyles.body(
                        9.06,
                        weight: FontWeight.w600,
                        spacing: -.056,
                        color: const Color(0xFFEEEAFD),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      percentage,
                      style: OnboardingVisualStyles.body(
                        11.15,
                        weight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: SizedBox(
            height: 2.8,
            child: ColoredBox(
              color: accent.withValues(alpha: .15),
              child: Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  heightFactor: 1,
                  child: ColoredBox(color: accent),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5.6),
        Expanded(
          child: Text(
            description,
            style: OnboardingVisualStyles.body(
              9.3,
              spacing: -.056,
              color: const Color(0xFFEEEAFD),
            ),
          ),
        ),
      ],
    ),
  );
}

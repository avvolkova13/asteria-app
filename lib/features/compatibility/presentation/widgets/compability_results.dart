import 'package:asteria_app/core/ui_kit/widgets/pearl_metric_row.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/data/models/prompt_response.dart';
import 'package:asteria_app/core/extensions/datetime_extensions.dart';
import 'package:asteria_app/core/extensions/string_extensions.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/compatibility/presentation/widgets/compatibility_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CompabilityResults extends StatelessWidget {
  final CompatibilityData compatibilityData;
  final String hisBirthdate;
  final String herBirthdate;
  final VoidCallback onHistoryPressed;
  const CompabilityResults({
    Key? key,
    required this.compatibilityData,
    required this.hisBirthdate,
    required this.herBirthdate,
    required this.onHistoryPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstDate = hisBirthdate.toDateTimeFromShortDate();
    final secondDate = herBirthdate.toDateTimeFromShortDate();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: AsteriaEntrance.sections([
        _ZodiacCompatibilityHero(
          firstDate: firstDate,
          secondDate: secondDate,
          percentage: compatibilityData.percentage.getPercentage,
        ),
        const SizedBox(height: 4),
        Text(
          compatibilityData.phrase,
          style: context.textTheme.playfairMedium16.copyWith(
            color: const Color(0xFFFFB45E),
            height: 1.2,
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 4),
        Text(
          compatibilityData.introduction,
          style: context.textTheme.inverseUrbanistRegular14.copyWith(
            height: 1.18,
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 20),
        _MetricsRow(
          love:
              compatibilityData.loveCompatibilityPercentage.getPercentageDouble,
          conflicts: compatibilityData.conflictsPercentage.getPercentageDouble,
          family: compatibilityData
              .familyCompatibilityPercentage
              .getPercentageDouble,
        ),
        const SizedBox(height: 24),
        Text(
          compatibilityData.generalCompatibility,
          style: context.textTheme.inverseUrbanistRegular14.copyWith(
            height: 1.16,
          ),
        ),
        const SizedBox(height: 28),
        CompatibilityGradientButton(
          text: context.l10n.compatibilityNewPair,
          onPressed: () {
            CreateCompatibilityInitialRoute.pushReplacement(context);
          },
        ),
        const SizedBox(height: 14),
        LotusButtons.text(
          onPressed: onHistoryPressed,
          child: Text(
            context.l10n.viewHistory,
            style: context.textTheme.inverseUrbanistSemiBold14.copyWith(
              color: AppColorsDark.linkGold,
            ),
          ),
        ),
      ]),
    );
  }
}

class _ZodiacCompatibilityHero extends StatelessWidget {
  final DateTime firstDate;
  final DateTime secondDate;
  final int percentage;

  const _ZodiacCompatibilityHero({
    required this.firstDate,
    required this.secondDate,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    Widget caption(DateTime date) => Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              date.getZodiacSignName(languageCode: locale.languageCode),
              style: context.textTheme.playfairMedium18.copyWith(
                color: const Color(0xFFFFB45E),
                height: 1.15,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              date.toLocalizedShortDate(locale),
              style: context.textTheme.inverseUrbanistRegular14,
            ),
          ),
        ],
      ),
    );
    Widget portrait(DateTime date) => Expanded(
      child: Center(
        child: ClipOval(
          child: Image.asset(
            'assets/images/zodiacs/compatibility_round/${date.getZodiacSignAsset()}.webp',
            width: 84,
            height: 84,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
    return Column(
      children: [
        Row(
          children: [
            caption(firstDate),
            const SizedBox(width: 12),
            caption(secondDate),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                portrait(firstDate),
                const SizedBox(width: 12),
                portrait(secondDate),
              ],
            ),
            Column(
              children: [
                SvgPicture.asset(
                  'assets/icons/compatibility_heart_right.svg',
                  width: 26,
                  excludeFromSemantics: true,
                ),
                Text(
                  '$percentage%',
                  style: context.textTheme.playfairSemiBold20.copyWith(
                    color: const Color(0xFFFFB45E),
                    height: 1.15,
                  ),
                ),
                SvgPicture.asset(
                  'assets/icons/compatibility_heart_left.svg',
                  width: 26,
                  excludeFromSemantics: true,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricsRow extends StatelessWidget {
  final double love;
  final double conflicts;
  final double family;

  const _MetricsRow({
    required this.love,
    required this.conflicts,
    required this.family,
  });

  @override
  Widget build(BuildContext context) {
    return PearlMetricRow(
      metrics: [
        for (final (value, label) in [
          (love, context.l10n.compatibilityLove),
          (conflicts, context.l10n.compatibilityConflicts),
          (family, context.l10n.compatibilityFamily),
        ])
          PearlMetric(label, '${value.toStringAsFixed(0)}%', value / 100),
      ],
    );
  }
}

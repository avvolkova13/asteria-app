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

double? _percentage(String text) {
  final value = double.tryParse(
    text.replaceAll('%', '').replaceAll(',', '.').trim(),
  );
  return value != null && value >= 0 && value <= 100 ? value : null;
}

class CompabilityResults extends StatelessWidget {
  final CompatibilityData compatibilityData;
  final String hisBirthdate;
  final String herBirthdate;
  final VoidCallback onHistoryPressed;
  final VoidCallback? onNewPairPressed;
  final bool highlightConflicts;
  const CompabilityResults({
    super.key,
    required this.compatibilityData,
    required this.hisBirthdate,
    required this.herBirthdate,
    required this.onHistoryPressed,
    this.onNewPairPressed,
    this.highlightConflicts = false,
  });

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
          percentage: _percentage(compatibilityData.percentage)?.round(),
        ),
        if (highlightConflicts &&
            compatibilityData.conflicts.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            Localizations.localeOf(context).languageCode == 'ru'
                ? 'Почему мы спорим?'
                : 'Why do we disagree?',
            style: context.textTheme.inversePlayfairSemiBold20,
          ),
          const SizedBox(height: 8),
          Text(
            compatibilityData.conflicts.trim(),
            style: context.textTheme.inverseUrbanistRegular16,
          ),
          const SizedBox(height: 16),
        ],
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
        PearlMetricRow(
          metrics: [
            for (final (label, reading) in [
              (
                context.l10n.compatibilityLove,
                compatibilityData.loveCompatibilityPercentage,
              ),
              (
                context.l10n.compatibilityConflicts,
                compatibilityData.conflictsPercentage,
              ),
              (
                context.l10n.compatibilityFamily,
                compatibilityData.familyCompatibilityPercentage,
              ),
            ])
              if (_percentage(reading) case final value?)
                PearlMetric(label, '${value.toStringAsFixed(0)}%', value / 100),
          ],
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
          onPressed:
              onNewPairPressed ??
              () => CreateCompatibilityInitialRoute.pushReplacement(context),
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
  final int? percentage;

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
    final scoreStyle = context.textTheme.playfairSemiBold20.copyWith(
      color: const Color(0xFFFFB45E),
      height: 1.15,
    );
    final score = percentage == null ? null : '$percentage%';
    final scoreWidth = TextPainter(
      text: TextSpan(text: score, style: scoreStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final desiredCenterWidth = (scoreWidth.width + 16).clamp(
      52.0,
      double.infinity,
    );
    scoreWidth.dispose();

    return LayoutBuilder(
      builder: (context, constraints) {
        final centerWidth = desiredCenterWidth.clamp(
          0.0,
          constraints.maxWidth * .42,
        );
        return Column(
          children: [
            Row(
              children: [
                caption(firstDate),
                SizedBox(width: centerWidth),
                caption(secondDate),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                portrait(firstDate),
                SizedBox(
                  width: centerWidth,
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/compatibility_heart_right.svg',
                        width: 26,
                        excludeFromSemantics: true,
                      ),
                      if (score != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(score, style: scoreStyle),
                          ),
                        ),
                      SvgPicture.asset(
                        'assets/icons/compatibility_heart_left.svg',
                        width: 26,
                        excludeFromSemantics: true,
                      ),
                    ],
                  ),
                ),
                portrait(secondDate),
              ],
            ),
          ],
        );
      },
    );
  }
}

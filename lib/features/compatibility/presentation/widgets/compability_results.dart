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
      children: [
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
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          compatibilityData.introduction,
          style: context.textTheme.inverseUrbanistRegular14.copyWith(
            height: 1.18,
          ),
          textAlign: TextAlign.center,
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
        TextButton(
          onPressed: onHistoryPressed,
          child: Text(
            context.l10n.viewHistory,
            style: context.textTheme.tertiaryUrbanistSemiBold14.copyWith(
              decoration: TextDecoration.underline,
              decorationColor: AppColors.textTertiary,
            ),
          ),
        ),
      ],
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
    return SizedBox(
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: 4, top: 0, child: _ZodiacPerson(date: firstDate)),
          Positioned(right: 4, top: 0, child: _ZodiacPerson(date: secondDate)),
          Positioned(
            left: 92,
            top: 78,
            child: SvgPicture.asset(
              'assets/icons/compatibility_heart_left.svg',
              width: 56,
              height: 31,
            ),
          ),
          Positioned(
            right: 92,
            top: 52,
            child: SvgPicture.asset(
              'assets/icons/compatibility_heart_right.svg',
              width: 58,
              height: 28,
            ),
          ),
          Positioned(
            top: 78,
            child: Text(
              '$percentage%',
              style: context.textTheme.playfairSemiBold20.copyWith(
                color: const Color(0xFFFFB45E),
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZodiacPerson extends StatelessWidget {
  final DateTime date;

  const _ZodiacPerson({required this.date});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return SizedBox(
      width: 106,
      child: Column(
        children: [
          Text(
            date.getZodiacSignName(languageCode: locale.languageCode),
            style: context.textTheme.playfairMedium18.copyWith(
              color: const Color(0xFFFFB45E),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date.toLocalizedShortDate(locale),
            style: context.textTheme.inverseUrbanistRegular14,
          ),
          const SizedBox(height: 8),
          ClipOval(
            child: Image.asset(
              'assets/images/zodiacs/compatibility_round/${date.getZodiacSignAsset()}.webp',
              width: 84,
              height: 84,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _MetricGauge(value: love, label: context.l10n.compatibilityLove),
        _MetricGauge(
          value: conflicts,
          label: context.l10n.compatibilityConflicts,
        ),
        _MetricGauge(value: family, label: context.l10n.compatibilityFamily),
      ],
    );
  }
}

class _MetricGauge extends StatelessWidget {
  final double value;
  final String label;

  const _MetricGauge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final progress = (value / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: 88,
      child: Column(
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 8,
                    color: const Color(0xFF4F3A84),
                    backgroundColor: AppColors.white.withValues(alpha: 0.1),
                  ),
                ),
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    color: const Color(0xFFFFD0A1),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                Text(
                  '${value.toStringAsFixed(0)}%',
                  style: context.textTheme.inverseUrbanistRegular16,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: context.textTheme.inverseUrbanistSemiBold14,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

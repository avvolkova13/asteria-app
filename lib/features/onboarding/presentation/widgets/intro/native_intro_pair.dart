// Example compatibility hero using the application's zodiac artwork.
import 'package:asteria_app/core/extensions/datetime_extensions.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IntroPairHero extends StatelessWidget {
  final DateTime firstDate;
  final DateTime secondDate;
  final int percentage;

  const IntroPairHero({
    super.key,

    required this.firstDate,
    required this.secondDate,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    Widget person(DateTime date) => Column(
      children: [
        Text(
          date.getZodiacSignName(languageCode: locale.languageCode),
          textAlign: TextAlign.center,
          style: AppTypography.h3.copyWith(color: AppColorsDark.linkGold),
        ),
        const SizedBox(height: 4),
        Text(
          date.toLocalizedShortDate(locale),
          textAlign: TextAlign.center,
          style: AppTypography.text1,
        ),
        const SizedBox(height: 12),
        Image.asset(
          'assets/images/zodiacs/compatibility_round/${date.getZodiacSignAsset()}.webp',
          width: 84,
          height: 84,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
      ],
    );
    final metric = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/icons/compatibility_heart_right.svg',
          width: 26,
          excludeFromSemantics: true,
        ),
        Text(
          '$percentage%',
          style: AppTypography.h3.copyWith(color: AppColorsDark.linkGold),
        ),
        SvgPicture.asset(
          'assets/icons/compatibility_heart_left.svg',
          width: 26,
          excludeFromSemantics: true,
        ),
      ],
    );
    final largeText = MediaQuery.textScalerOf(context).scale(16) > 21;
    if (largeText) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: person(firstDate)),
              const SizedBox(width: 16),
              Expanded(child: person(secondDate)),
            ],
          ),
          const SizedBox(height: 16),
          metric,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: person(firstDate)),
        Padding(padding: const EdgeInsets.fromLTRB(8, 40, 8, 0), child: metric),
        Expanded(child: person(secondDate)),
      ],
    );
  }
}

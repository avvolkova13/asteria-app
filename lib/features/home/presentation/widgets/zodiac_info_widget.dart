import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/extensions/datetime_extensions.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/app/data/entities/zodiac_info_entity.dart';
import 'package:flutter/material.dart';

/// Карточки с информацией о знаке зодиака
class ZodiacInfoWidget extends StatelessWidget {
  final ZodiacInfoEntity zodiacInfo;
  const ZodiacInfoWidget({Key? key, required this.zodiacInfo})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Верхние карточки - созвездие и знак зодиака
        Row(
          children: [
            Expanded(child: _buildConstellationCard()),
            const SizedBox(width: 8),
            Expanded(
              child: _buildZodiacSignCard(zodiacInfo.birthDate, context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Нижние карточки - атрибуты
        Row(
          children: [
            Expanded(
              child: _buildAttributeCard(
                context.l10n.personalElement,
                zodiacInfo.elementString,
                context,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildAttributeCard(
                context.l10n.personalPlanet,
                zodiacInfo.planetString,
                context,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildAttributeCard(
                context.l10n.personalCharacter,
                zodiacInfo.characterString,
                context,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConstellationCard() {
    return Image.asset(
      'assets/images/zodiacs/constellation/${zodiacInfo.zodiacAsset}.webp',
      height: 67,
    );
  }

  Widget _buildZodiacSignCard(DateTime birthDate, BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: CardLensDecoration(
        color: AppColors.cardTinted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            birthDate.getZodiacSignName(languageCode: locale.languageCode),
            style: context.textTheme.inversePlayfairSemiBold24.copyWith(
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            birthDate.toLocalizedDate(locale),
            style: context.textTheme.urbanistRegular16,
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeCard(String title, String value, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
      decoration: CardLensDecoration(
        color: AppColors.cardTinted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: context.textTheme.playfairMedium16),
          const SizedBox(height: 4),
          Text(value, style: context.textTheme.urbanistRegular14),
        ],
      ),
    );
  }
}

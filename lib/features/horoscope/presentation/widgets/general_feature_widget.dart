import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_year_model.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/horoscope/presentation/horoscope_core_position_assets.dart';
import 'package:flutter/material.dart';

class GeneralFeatureWidget extends StatelessWidget {
  final HoroscopeYearModel horoscopeYear;
  const GeneralFeatureWidget({super.key, required this.horoscopeYear});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: AsteriaEntrance.sections([
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            context.l10n.horoscopeGeneral,
            style: context.textTheme.playfairSemiBold24,
          ),
        ),
        const SizedBox(height: 16),
        _GeneralFeatureItem(
          imagePath: horoscopeCorePositionAssetFor(
            horoscopeYear.coreDescription.sunInSign.planetInSign,
          ),
          title: horoscopeYear.coreDescription.sunInSign.planetInSign,
          description: horoscopeYear.coreDescription.sunInSign.description,
        ),
        _GeneralFeatureItem(
          imagePath: horoscopeCorePositionAssetFor(
            horoscopeYear.coreDescription.moonInSign.planetInSign,
          ),
          title: horoscopeYear.coreDescription.moonInSign.planetInSign,
          description: horoscopeYear.coreDescription.moonInSign.description,
        ),
        _GeneralFeatureItem(
          imagePath: horoscopeCorePositionAssetFor(
            horoscopeYear.coreDescription.ascendantInSign.planetInSign,
          ),
          title: horoscopeYear.coreDescription.ascendantInSign.planetInSign,
          description:
              horoscopeYear.coreDescription.ascendantInSign.description,
        ),
      ]),
    );
  }
}

class _GeneralFeatureItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  const _GeneralFeatureItem({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: CardLensDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.cardTinted,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(imagePath, width: 107, height: 107),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textTheme.playfairMedium20),
                const SizedBox(height: 8),
                Text(description, style: context.textTheme.urbanistRegular14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

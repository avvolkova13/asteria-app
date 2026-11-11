import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/app/data/models/natal_card/natal_card_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/localization/localized_display_names.dart';
import 'package:flutter/material.dart';

class NatalMapWidget extends StatelessWidget {
  final String predictionText;
  final VoidCallback onPressed;
  final NatalCardModel? natalCard;
  final PlanetsHousesDataModel? planetsHousesData;

  const NatalMapWidget({
    super.key,
    required this.predictionText,
    required this.onPressed,
    this.natalCard,
    this.planetsHousesData,
  });

  @override
  Widget build(BuildContext context) {
    final planets = _calculatedPlanets(context);
    final hasNatalCard = natalCard != null;
    final hasPositions = planets.isNotEmpty;

    return Column(
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.natalChartTitle,
          style: context.textTheme.playfairSemiBold32,
        ),
        const SizedBox(height: 16),
        Image.asset(
          'assets/images/home/natal__card_wheel.webp',
          width: 392,
          height: 321,
        ),
        const SizedBox(height: 16),
        if (hasNatalCard && hasPositions) ...[
          Text(
            context.l10n.natalMainPositions,
            style: context.textTheme.playfairSemiBold24,
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: planets
                  .map(
                    (planet) => _NatalMapPositionItem(
                      title: context.l10n.planetName(planet.code),
                      description: planet.description,
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          predictionText,
          style: context.textTheme.urbanistRegular16,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        CustomButton(
          type: CustomButtonType.primary,
          height: 50,
          isFullWidth: true,
          text: hasNatalCard
              ? context.l10n.personalOpenChart
              : context.l10n.natalGetInterpretation,
          onPressed: onPressed,
        ),
      ]),
    );
  }

  List<NatalCardPlanetDisplayModel> _calculatedPlanets(BuildContext context) {
    final positions = planetsHousesData?.positions ?? const [];
    return [
      for (final position in positions)
        NatalCardPlanetDisplayModel(
          code: position.code,
          description: _placementDescription(context, position),
        ),
    ];
  }

  String _placementDescription(
    BuildContext context,
    PlanetHousePositionModel position,
  ) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final sign = position.signCode.isEmpty
        ? position.sign
        : context.l10n.zodiacSignName(position.signCode);
    return isRu
        ? '$sign, ${position.house} дом'
        : '$sign, house ${position.house}';
  }
}

class _NatalMapPositionItem extends StatelessWidget {
  final String title;
  final String description;

  const _NatalMapPositionItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: 207,
      decoration: CardLensDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/home/month_widget_bg.webp'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.white,
            ),
            child: Text(title, style: context.textTheme.playfairMedium20),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              description,
              style: context.textTheme.inverseUrbanistRegular16,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

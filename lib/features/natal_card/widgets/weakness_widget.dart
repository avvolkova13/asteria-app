import 'package:asteria_app/app/data/models/natal_card/natal_card_model.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/localization/localized_display_names.dart';
import 'package:flutter/material.dart';

class WeaknessWidget extends StatelessWidget {
  final List<NatalCardPlanetDisplayModel> planets;

  const WeaknessWidget({Key? key, required this.planets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSingle = planets.length == 1;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: planets
              .map(
                (planet) => _WeaknessItem(
                  title: context.l10n.planetName(planet.code),
                  description: planet.description,
                  isFullWidth: isSingle,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _WeaknessItem extends StatelessWidget {
  final String title;
  final String description;
  final bool isFullWidth;

  const _WeaknessItem({
    Key? key,
    required this.title,
    required this.description,
    this.isFullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = isFullWidth ? MediaQuery.of(context).size.width - 32 : 207.0;
    return Container(
      margin: EdgeInsets.only(right: isFullWidth ? 0 : 16),
      width: width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/home/month_widget_bg.webp'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                description,
                style: context.textTheme.inverseUrbanistRegular16,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

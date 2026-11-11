import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_shared_model.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class ActualTransits extends StatelessWidget {
  final List<HoroscopeTransitModel> transits;
  const ActualTransits({Key? key, required this.transits}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (transits.length == 1) {
      return _ActualTransitItem(
        title: transits.first.planet,
        description: transits.first.description,
        isFullWidth: true,
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var transit in transits)
              _ActualTransitItem(
                title: transit.planet,
                description: transit.description,
                isFullWidth: false,
              ),
          ],
        ),
      ),
    );
  }
}

class _ActualTransitItem extends StatelessWidget {
  final String title;
  final String description;
  final bool isFullWidth;

  const _ActualTransitItem({
    Key? key,
    required this.title,
    required this.description,
    this.isFullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: isFullWidth ? 0 : 16),
      width: isFullWidth ? double.infinity : 207,
      decoration: CardLensDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/home/month_widget_bg.webp'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: isFullWidth ? MainAxisSize.min : MainAxisSize.max,
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
          if (isFullWidth)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                description,
                style: context.textTheme.inverseUrbanistRegular16,
              ),
            )
          else
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

import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class PeriodsWidgetBlock extends StatelessWidget {
  final String text1;
  final String text2;
  final String text3;
  final String text4;
  final String text5;
  final String text6;
  final String title;

  const PeriodsWidgetBlock({
    super.key,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.text4,
    required this.text5,
    required this.text6,
    required this.title,
  });

  static const double _cardWidth = 217;
  static const double _cardSpacing = 12;
  static const double _horizontalPadding = 16;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _CardData(
        title: text1,
        description: text2,
        backgroundImage: 'assets/background/gradient_bg_1.webp',
      ),
      _CardData(
        title: text3,
        description: text4,
        backgroundImage: 'assets/background/gradient_bg_3.webp',
      ),
      _CardData(
        title: text5,
        description: text6,
        backgroundImage: 'assets/background/gradient_bg_2.webp',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AsteriaEntrance.sections([
        Text(title, style: context.textTheme.playfairSemiBold24),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(right: _horizontalPadding),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: _cardWidth,
                  child: _PeriodCard(
                    title: cards[0].title,
                    description: cards[0].description,
                    backgroundImage: cards[0].backgroundImage,
                  ),
                ),
                const SizedBox(width: _cardSpacing),
                SizedBox(
                  width: _cardWidth,
                  child: _PeriodCard(
                    title: cards[1].title,
                    description: cards[1].description,
                    backgroundImage: cards[1].backgroundImage,
                  ),
                ),
                const SizedBox(width: _cardSpacing),
                SizedBox(
                  width: _cardWidth,
                  child: _PeriodCard(
                    title: cards[2].title,
                    description: cards[2].description,
                    backgroundImage: cards[2].backgroundImage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _CardData {
  final String title;
  final String description;
  final String backgroundImage;

  _CardData({
    required this.title,
    required this.description,
    required this.backgroundImage,
  });
}

class _PeriodCard extends StatelessWidget {
  final String title;
  final String description;
  final String backgroundImage;

  const _PeriodCard({
    required this.title,
    required this.description,
    required this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: CardLensDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTypography.h4.copyWith(color: AppColors.textInverse),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: context.textTheme.inverseUrbanistRegular16,
              maxLines: null,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

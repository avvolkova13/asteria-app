import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/const/purchase_products_const.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class SpecialDecks extends StatelessWidget {
  final VoidCallback onBuyLoveDeckPressed;
  final VoidCallback onBuyKeltDeckPressed;
  const SpecialDecks({
    Key? key,
    required this.onBuyLoveDeckPressed,
    required this.onBuyKeltDeckPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.specialReadingsTitle,
          style: context.textTheme.playfairSemiBold24.copyWith(
            color: AppColors.white,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        _SpecialDeckItem(
          title: context.l10n.loveDeckTitle,
          description: context.l10n.loveReadingDescription,
          image: 'love_deck_figma',
          onPressed: onBuyLoveDeckPressed,
          price: PurchaseProductsConst.loveDeck.price,
        ),
        const SizedBox(height: 16),
        _SpecialDeckItem(
          title: context.l10n.keltDeckTitle,
          description: context.l10n.celticCrossDescription,
          image: 'kelt_deck_figma',
          onPressed: onBuyKeltDeckPressed,
          price: PurchaseProductsConst.keltDeck.price,
        ),
      ]),
    );
  }
}

class _SpecialDeckItem extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final int price;
  final VoidCallback onPressed;
  const _SpecialDeckItem({
    Key? key,
    required this.title,
    required this.description,
    required this.image,
    required this.onPressed,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.buySpecialReadingLabel(title, price.toString()),
      onTap: onPressed,
      excludeSemantics: true,
      child: LotusTap(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: CardLensDecoration(
            color: AppColorsDark.modal,
            borderRadius: BorderRadius.circular(AsteriaCardRadii.tile),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/images/horoscope/$image.webp',
                width: 76,
                height: 88,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.h3.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: AppTypography.text1.copyWith(
                        color: AppColors.uiDisabled,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          context.l10n.buyForPrice(price.toString()),
                          style: AppTypography.text1SemiBold.copyWith(
                            color: AppColorsDark.linkGold,
                          ),
                        ),
                        LotusRasterIcon(
                          'assets/icons/star_coin_icon.png',
                          height: 16,
                          width: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/const/purchase_products_const.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class _SpecialDecksColors {
  static const cardBackground = Color(0xFF151028);
  static const imageBackground = Color(0xFF21183D);
  static const text = Color(0xFFFFFFFF);
  static const gold = Color(0xFFF3B76A);
  static const goldGradient = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
  );
}

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
      children: [
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
      ],
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
      child: ExcludeSemantics(
        child: LotusTap(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: SizedBox(
            height: 142,
            child: Row(
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _SpecialDecksColors.cardBackground,
                      borderRadius: BorderRadius.circular(AsteriaCardRadii.tile),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          _SpecialDeckPreview(title: title, image: image),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SpecialDeckDetails(
                              description: description,
                              price: price,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecialDeckPreview extends StatelessWidget {
  const _SpecialDeckPreview({required this.title, required this.image});

  final String title;
  final String image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 126,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _SpecialDecksColors.imageBackground,
          borderRadius: BorderRadius.circular(AsteriaCardRadii.compact),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              ClipRect(
                child: Image.asset(
                  'assets/images/horoscope/$image.webp',
                  width: 80,
                  height: 75,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.textTheme.urbanistRegular16.copyWith(
                      color: _SpecialDecksColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 0.9,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecialDeckDetails extends StatelessWidget {
  const _SpecialDeckDetails({required this.description, required this.price});

  final String description;
  final int price;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              description,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.urbanistRegular16.copyWith(
                color: _SpecialDecksColors.text,
                height: 1.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: _GoldGradientText(
                text: context.l10n.buyForPrice(price.toString()),
                style: AppTypography.text1SemiBold.copyWith(color: _SpecialDecksColors.gold),
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: LotusRasterIcon(
                'assets/icons/star_coin_icon.png',
                height: 14,
                width: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GoldGradientText extends StatelessWidget {
  const _GoldGradientText({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) =>
          _SpecialDecksColors.goldGradient.createShader(bounds),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style.copyWith(color: AppColors.white),
      ),
    );
  }
}

import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/core/localization/tarot_card_asset_resolver.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class _TarotLayoutCardModalColors {
  static const surface = ModalGlassTokens.surface;
  static const grabber = ModalGlassTokens.grabber;
  static const text = ModalGlassTokens.text;
  static const goldGradient = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
  );
}

class TarotLayoutCardDescriptionModal extends StatelessWidget {
  final TarotCardModel card;
  final int positionInDeck;

  const TarotLayoutCardDescriptionModal({
    Key? key,
    required this.card,
    required this.positionInDeck,
  }) : super(key: key);

  String _getTextByPositionInDeck() {
    switch (positionInDeck) {
      case 0:
        return card.textInDecks.length > 0
            ? card.textInDecks[0]
            : card.generalDescription;
      case 1:
        return card.textInDecks.length > 1
            ? card.textInDecks[1]
            : card.generalDescription;
      case 2:
        return card.textInDecks.length > 2
            ? card.textInDecks[2]
            : card.generalDescription;
      default:
        return card.textInDecks.isNotEmpty
            ? card.textInDecks[0]
            : card.generalDescription;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final targetHeight = mediaSize.height - 306;
    final minHeight = mediaSize.height < 640 ? mediaSize.height * 0.72 : 420.0;
    final maxHeight = mediaSize.height * 0.9;
    final sheetHeight = targetHeight.clamp(minHeight, maxHeight).toDouble();

    return SizedBox(
      height: sheetHeight,
      child: ModalGlassSurface(
        color: _TarotLayoutCardModalColors.surface,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  height: 4,
                  width: 64,
                  decoration: BoxDecoration(
                    color: _TarotLayoutCardModalColors.grabber,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AsteriaEntrance.sections([
                      _GradientText(
                        text: card.title,
                        gradient: _TarotLayoutCardModalColors.goldGradient,
                        style: context.textTheme.playfairSemiBold24.copyWith(
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Image.asset(
                          TarotCardAssetResolver.resolve(
                            imageName: card.imageName,
                            languageCode: Localizations.localeOf(
                              context,
                            ).languageCode,
                          ),
                          width: 183,
                          height: 274,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getTextByPositionInDeck(),
                        style: context.textTheme.urbanistRegular16.copyWith(
                          color: _TarotLayoutCardModalColors.text,
                          height: 1.2,
                          letterSpacing: -0.408,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 32),
                    ]),
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

class _GradientText extends StatelessWidget {
  const _GradientText({
    required this.text,
    required this.gradient,
    required this.style,
  });

  final String text;
  final Gradient gradient;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(text, style: style.copyWith(color: AppColors.white)),
    );
  }
}

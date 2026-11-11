import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/core/localization/tarot_card_asset_resolver.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class _LoveDeckCardModalColors {
  static const surface = Color(0xFF130622);
  static const grabber = Color(0xFF332544);
  static const text = Color(0xFFEEEAFD);
  static const goldGradient = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
  );
}

class LoveDeckCardDescriptionModal extends StatelessWidget {
  final TarotCardModel card;
  final int cardNumber;

  const LoveDeckCardDescriptionModal({
    required this.card,
    required this.cardNumber,
  });

  String get _cardText => card.loveDeck.length > cardNumber - 1
      ? card.loveDeck[cardNumber - 1]
      : card.generalDescription;

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final maxSheetHeight = mediaSize.height * 0.86;
    final sheetHeight = maxSheetHeight > 538 ? 538.0 : maxSheetHeight;

    return SizedBox(
      height: sheetHeight,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: _LoveDeckCardModalColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
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
                    color: _LoveDeckCardModalColors.grabber,
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
                        gradient: _LoveDeckCardModalColors.goldGradient,
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
                        _cardText,
                        style: context.textTheme.urbanistRegular16.copyWith(
                          color: _LoveDeckCardModalColors.text,
                          height: 1.2,
                          letterSpacing: -0.408,
                        ),
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

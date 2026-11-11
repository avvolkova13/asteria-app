import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/core/localization/tarot_card_asset_resolver.dart';
import 'package:asteria_app/core/extensions/string_extensions.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class _KeltCardModalColors {
  static const surface = ModalGlassTokens.surface;
  static const grabber = ModalGlassTokens.grabber;
  static const text = ModalGlassTokens.text;
  static const secondaryText = Color(0xFFCFC4D8);
  static const cardSurface = Color(0xFF1A0D2C);
  static const goldGradient = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
  );
  static const purpleGradient = ModalGlassTokens.headingGradient;
}

class CardDescriptionModal extends StatelessWidget {
  final TarotCardModel card;
  final int cardNumber;

  const CardDescriptionModal({required this.card, required this.cardNumber});

  String _positionTitle(BuildContext context) => switch (cardNumber) {
    1 => context.l10n.keltPosition1Title,
    2 => context.l10n.keltPosition2Title,
    3 => context.l10n.keltPosition3Title,
    4 => context.l10n.keltPosition4Title,
    5 => context.l10n.keltPosition5Title,
    6 => context.l10n.keltPosition6Title,
    7 => context.l10n.keltPosition7Title,
    8 => context.l10n.keltPosition8Title,
    9 => context.l10n.keltPosition9Title,
    10 => context.l10n.keltPosition10Title,
    _ => '',
  };

  String _positionDescription(BuildContext context) => switch (cardNumber) {
    1 => context.l10n.keltPosition1Description,
    2 => context.l10n.keltPosition2Description,
    3 => context.l10n.keltPosition3Description,
    4 => context.l10n.keltPosition4Description,
    5 => context.l10n.keltPosition5Description,
    6 => context.l10n.keltPosition6Description,
    7 => context.l10n.keltPosition7Description,
    8 => context.l10n.keltPosition8Description,
    9 => context.l10n.keltPosition9Description,
    10 => context.l10n.keltPosition10Description,
    _ => '',
  };

  String get _cardMeaning {
    final index = cardNumber - 1;
    if (index >= 0 && card.keltDeck.length > index) {
      return card.keltDeck[index];
    }
    return card.generalDescription;
  }

  String get _cardImpact {
    final index = cardNumber - 1;
    if (index >= 0 && card.keltDeckImpact.length > index) {
      return card.keltDeckImpact[index].capitalize();
    }
    return card.generalDescription;
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final maxHeight = (mediaSize.height * .9).clamp(0.0, 700.0);
    final sheetHeight = (mediaSize.height * .83).clamp(0.0, maxHeight);

    return SizedBox(
      height: sheetHeight,
      child: ModalGlassSurface(
        color: _KeltCardModalColors.surface,
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
                    color: _KeltCardModalColors.grabber,
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
                        text: context.l10n.keltCardPositionTitle(
                          cardNumber,
                          _positionTitle(context),
                        ),
                        gradient: _KeltCardModalColors.goldGradient,
                        style: context.textTheme.playfairSemiBold24.copyWith(
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _positionDescription(context),
                        style: context.textTheme.urbanistRegular14.copyWith(
                          color: _KeltCardModalColors.secondaryText,
                          height: 1.2,
                          letterSpacing: -0.08,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _GradientText(
                        text: card.title,
                        gradient: _KeltCardModalColors.goldGradient,
                        style: context.textTheme.playfairMedium20.copyWith(
                          height: 1.1,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_cardMeaning, style: _bodyStyle(context)),
                      const SizedBox(height: 16),
                      Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: _KeltCardModalColors.cardSurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(11),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                TarotCardAssetResolver.resolve(
                                  imageName: card.imageName,
                                  languageCode: Localizations.localeOf(
                                    context,
                                  ).languageCode,
                                ),
                                width: 184,
                                height: 276,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _GradientText(
                        text: context.l10n.commonHowItAffects,
                        gradient: _KeltCardModalColors.purpleGradient,
                        style: context.textTheme.playfairMedium20.copyWith(
                          height: 1.1,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_cardImpact, style: _bodyStyle(context)),
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

  static TextStyle _bodyStyle(BuildContext context) {
    return context.textTheme.urbanistRegular16.copyWith(
      color: _KeltCardModalColors.text,
      height: 1.2,
      letterSpacing: -0.408,
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

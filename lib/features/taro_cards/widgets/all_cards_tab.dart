import 'package:asteria_app/core/ui_kit/widgets/tarot_card_frame.dart';
import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/localization/tarot_card_asset_resolver.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/locked_content_image.dart';
import 'package:flutter/material.dart';

class _AllCardsModalColors {
  static const surface = ModalGlassTokens.surface;
  static const grabber = ModalGlassTokens.grabber;
  static const text = ModalGlassTokens.text;
  static const goldGradient = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
  );
  static const purpleGradient = ModalGlassTokens.headingGradient;
}

class AllCardsTab extends StatelessWidget {
  const AllCardsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final contentProvider = di.get<ContentProvider>();
    final userProvider = di.get<UserProvider>();

    return ListenableBuilder(
      listenable: Listenable.merge([contentProvider, userProvider]),
      builder: (context, _) {
        final cards = contentProvider.tarotCards;

        if (cards.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                context.l10n.tarotCardsEmpty,
                style: context.textTheme.urbanistRegular16.copyWith(
                  color: _AllCardsModalColors.text,
                ),
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width - 32;
            final cardWidth = (availableWidth - 16) / 3;

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cards.map((card) {
                final bool canView = userProvider.isContentViewed(card.id);
                // final bool canView = true;
                return SizedBox(
                  width: cardWidth,
                  height: cardWidth / 0.67,
                  child: Semantics(
                    button: canView,
                    enabled: canView,
                    label: canView
                        ? context.l10n.tarotOpenCardLabel(card.title)
                        : context.l10n.tarotLockedCardLabel(card.title),
                    onTap: canView
                        ? LotusFeedback.action(
                            () => _showCardDescription(context, card),
                          )
                        : null,
                    child: TarotCardFrame(
                      radius: 12,
                      child: LockedContentImage(
                        imagePath: TarotCardAssetResolver.resolve(
                          imageName: card.imageName,
                          languageCode: Localizations.localeOf(
                            context,
                          ).languageCode,
                        ),
                        isLocked: !canView,
                        borderRadius: 12,
                        onTap: !canView
                            ? null
                            : () => _showCardDescription(context, card),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  void _showCardDescription(BuildContext context, TarotCardModel card) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: ModalGlassTokens.barrier,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _CardDescriptionModal(card: card);
      },
    );
  }
}

class _CardDescriptionModal extends StatelessWidget {
  final TarotCardModel card;

  const _CardDescriptionModal({required this.card});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxHeight = screenHeight * .9;
    final minHeight = maxHeight < 500.0 ? maxHeight : 500.0;
    final modalHeight = (screenHeight * .63)
        .clamp(minHeight, maxHeight)
        .toDouble();
    return SizedBox(
      height: modalHeight,
      child: ModalGlassSurface(
        color: _AllCardsModalColors.surface,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  height: 4,
                  width: 64,
                  decoration: BoxDecoration(
                    color: _AllCardsModalColors.grabber,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AsteriaEntrance.sections([
                      _GradientText(
                        text: card.title,
                        gradient: _AllCardsModalColors.goldGradient,
                        style: context.textTheme.playfairSemiBold24.copyWith(
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (card.keywords.isNotEmpty) ...[
                        _DescriptionSection(
                          title: context.l10n.commonKeywords,
                          body: '${card.keywords.join(', ')}.',
                        ),
                      ],
                      if (card.generalDescription.isNotEmpty) ...[
                        _DescriptionSection(
                          title: context.l10n.commonDescription,
                          body: card.generalDescription,
                        ),
                      ],
                      if (card.textInDecks.isNotEmpty) ...[
                        _DescriptionSection(
                          title: context.l10n.commonInReadings,
                          body: card.textInDecks
                              .map((text) => '— $text')
                              .join('\n'),
                        ),
                      ],
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

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GradientText(
            text: title,
            gradient: _AllCardsModalColors.purpleGradient,
            style: context.textTheme.playfairMedium20.copyWith(
              height: 1.1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: context.textTheme.urbanistRegular16.copyWith(
              color: _AllCardsModalColors.text,
              height: 1.2,
              letterSpacing: -0.408,
            ),
          ),
        ],
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

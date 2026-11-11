import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/tarot_card_asset_resolver.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/core/utils/enums.dart';
import 'package:asteria_app/features/love_deck/widgets/card_description_modal.dart';
import 'package:flutter/material.dart';

class LoveLayout extends StatefulWidget {
  const LoveLayout({Key? key}) : super(key: key);

  @override
  State<LoveLayout> createState() => _LoveLayoutState();
}

class _LoveLayoutState extends State<LoveLayout> {
  static const double _maxLayoutWidth = 358.0;
  static const double _cardAspectRatio = 114.0 / 171.0;
  static const double _gap = 8.0;
  static const int _cardsPerRow = 3;
  static const double _cardBorderRadius = 12.0;

  bool _isAnyCardAnimating = false;

  List<String> _getCardIdsInOrder(UserProvider userProvider) {
    final loveDeckCards =
        userProvider.currentUser?.loveDeck?.loveDeckCards ?? {};
    final cardIds = loveDeckCards.keys.toList();
    final result = <String>[];

    for (int i = 0; i < 6; i++) {
      if (i < cardIds.length) {
        result.add(cardIds[i]);
      } else {
        result.add('');
      }
    }

    return result;
  }

  TarotCardModel? _getCardById(String cardId, ContentProvider contentProvider) {
    if (cardId.isEmpty) return null;
    try {
      return contentProvider.tarotCards.firstWhere((card) => card.id == cardId);
    } catch (e) {
      return null;
    }
  }

  void _showCardModal(
    BuildContext context,
    TarotCardModel card,
    int cardNumber,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: ModalGlassTokens.barrier,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return LoveDeckCardDescriptionModal(card: card, cardNumber: cardNumber);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = di.get<UserProvider>();
    final contentProvider = di.get<ContentProvider>();

    return ListenableBuilder(
      listenable: userProvider,
      builder: (context, _) {
        final cardIds = _getCardIdsInOrder(userProvider);

        return LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : _maxLayoutWidth;
            final layoutWidth = availableWidth < _maxLayoutWidth
                ? availableWidth
                : _maxLayoutWidth;
            final totalGapWidth = _gap * (_cardsPerRow - 1);
            final cardWidth = (layoutWidth - totalGapWidth) / _cardsPerRow;
            final cardHeight = cardWidth / _cardAspectRatio;

            return Center(
              child: SizedBox(
                width: layoutWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LoveCardsRow(
                      startIndex: 0,
                      cardIds: cardIds,
                      cardWidth: cardWidth,
                      cardHeight: cardHeight,
                      buildCard: (context, cardNumber, cardId, width, height) =>
                          _buildCard(
                            context,
                            cardNumber,
                            cardId,
                            userProvider,
                            contentProvider,
                            width,
                            height,
                          ),
                    ),
                    const SizedBox(height: _gap),
                    _LoveCardsRow(
                      startIndex: 3,
                      cardIds: cardIds,
                      cardWidth: cardWidth,
                      cardHeight: cardHeight,
                      buildCard: (context, cardNumber, cardId, width, height) =>
                          _buildCard(
                            context,
                            cardNumber,
                            cardId,
                            userProvider,
                            contentProvider,
                            width,
                            height,
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    int cardNumber,
    String cardId,
    UserProvider userProvider,
    ContentProvider contentProvider,
    double cardWidth,
    double cardHeight,
  ) {
    final card = cardId.isNotEmpty
        ? _getCardById(cardId, contentProvider)
        : null;
    final isOpened =
        cardId.isNotEmpty &&
        userProvider.isDeckCardOpened(DeckType.love, cardId) &&
        card != null;

    return Semantics(
      label: isOpened
          ? context.l10n.deckOpenedCardLabel(cardNumber, card.title)
          : context.l10n.deckCardLabel(cardNumber),
      button: true,
      enabled: !_isAnyCardAnimating && cardId.isNotEmpty,
      child: FlipCardWidget(
        key: ValueKey('love_deck_card_$cardNumber'),
        front: card != null
            ? _buildCardFront(card, cardWidth, cardHeight)
            : _buildCardBack(cardNumber, cardWidth, cardHeight),
        back: _buildCardBack(cardNumber, cardWidth, cardHeight),
        isOpened: isOpened,
        width: cardWidth,
        height: cardHeight,
        flipOnTap: true,
        enabled: !_isAnyCardAnimating && cardId.isNotEmpty,
        onFlipStart: () {
          setState(() => _isAnyCardAnimating = true);
        },
        onFlipComplete: () async {
          if (cardId.isNotEmpty) {
            try {
              await userProvider.openLoveDeckCard(cardId);
            } catch (e) {
              debugPrint('[ERROR] Ошибка открытия карты: $e');
            }
          }
          if (mounted) {
            setState(() => _isAnyCardAnimating = false);
          }
        },
        onTap: () {
          if (card != null) {
            _showCardModal(context, card, cardNumber);
          }
        },
      ),
    );
  }

  Widget _buildCardBack(int cardNumber, double width, double height) {
    final imagePath =
        'assets/images/cards/card_back/love_card_back_$cardNumber.webp';

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        child: Image.asset(
          imagePath,
          width: width,
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(_cardBorderRadius),
              ),
              child: const ClayIcon(Icons.image_not_supported, size: 48),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardFront(TarotCardModel card, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_cardBorderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        child: Image.asset(
          TarotCardAssetResolver.resolve(
            imageName: card.imageName,
            languageCode: Localizations.localeOf(context).languageCode,
          ),
          frameBuilder: AsteriaEntrance.imageFrame,
          width: width,
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(_cardBorderRadius),
              ),
              child: const ClayIcon(Icons.image_not_supported, size: 48),
            );
          },
        ),
      ),
    );
  }
}

typedef _LoveCardBuilder =
    Widget Function(
      BuildContext context,
      int cardNumber,
      String cardId,
      double cardWidth,
      double cardHeight,
    );

class _LoveCardsRow extends StatelessWidget {
  const _LoveCardsRow({
    required this.startIndex,
    required this.cardIds,
    required this.cardWidth,
    required this.cardHeight,
    required this.buildCard,
  });

  final int startIndex;
  final List<String> cardIds;
  final double cardWidth;
  final double cardHeight;
  final _LoveCardBuilder buildCard;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_LoveLayoutState._cardsPerRow, (rowIndex) {
        final index = startIndex + rowIndex;
        final cardNumber = index + 1;
        final cardId = cardIds.length > index ? cardIds[index] : '';

        return Padding(
          padding: EdgeInsets.only(
            right: rowIndex < _LoveLayoutState._cardsPerRow - 1
                ? _LoveLayoutState._gap
                : 0,
          ),
          child: buildCard(context, cardNumber, cardId, cardWidth, cardHeight),
        );
      }),
    );
  }
}

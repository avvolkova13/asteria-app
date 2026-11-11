import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/const/keys_const.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/tarot_card_asset_resolver.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/features/taro_cards/widgets/card_description_modal.dart';
import 'package:flutter/material.dart';

class TarotLayout extends StatefulWidget {
  const TarotLayout({Key? key}) : super(key: key);

  @override
  State<TarotLayout> createState() => _TarotLayoutState();
}

class _TarotLayoutState extends State<TarotLayout> {
  static const double _layoutWidth = 358.0;
  static const double _layoutHeight = 186.0;
  static const double _cardWidth = 108.0;
  static const double _cardHeight = 162.0;
  static const double _centerCardTop = 24.0;
  static const double _cardBorderRadius = 6.0;
  static const String _cardBackAsset =
      'assets/images/home/daily_symbol_tarot_back.webp';

  bool _isAnyCardAnimating = false;

  List<String> _getCardIdsInOrder(UserProvider userProvider) {
    final tarotDeck = userProvider.currentUser?.tarotDeck;
    if (tarotDeck == null || tarotDeck.cards.isEmpty) {
      return ['', '', ''];
    }
    final cards = tarotDeck.cards;
    return [
      cards.length > 0 ? cards[0].id : '',
      cards.length > 1 ? cards[1].id : '',
      cards.length > 2 ? cards[2].id : '',
    ];
  }

  bool _isCardOpened(ContentProvider contentProvider, int index) {
    return contentProvider.isTarotCardInDeckOpened(_getHiveKeyForIndex(index));
  }

  String _getHiveKeyForIndex(int index) {
    switch (index) {
      case 0:
        return KeysConst.tarotDeckCardLeftKey;
      case 1:
        return KeysConst.tarotDeckCardCenterKey;
      case 2:
        return KeysConst.tarotDeckCardRightKey;
      default:
        return KeysConst.tarotDeckCardLeftKey;
    }
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
    int positionInDeck,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xCC0F0A1A),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return TarotLayoutCardDescriptionModal(
          card: card,
          positionInDeck: positionInDeck,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      di.get<ContentProvider>().ensureTarotDeckLayoutReady();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = di.get<UserProvider>();
    final contentProvider = di.get<ContentProvider>();

    return ListenableBuilder(
      listenable: Listenable.merge([userProvider, contentProvider]),
      builder: (context, _) {
        final cardIds = _getCardIdsInOrder(userProvider);
        final allClosed =
            cardIds.every((id) => id.isNotEmpty) &&
            cardIds.asMap().entries.every(
              (e) => !_isCardOpened(contentProvider, e.key),
            );
        if (_isAnyCardAnimating && allClosed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _isAnyCardAnimating = false);
          });
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : _layoutWidth;
            final scale = availableWidth < _layoutWidth
                ? availableWidth / _layoutWidth
                : 1.0;
            final cardWidth = _cardWidth * scale;
            final cardHeight = _cardHeight * scale;
            final layoutHeight = _layoutHeight * scale;
            final centerCardTop = _centerCardTop * scale;

            return SizedBox(
              width: availableWidth,
              height: layoutHeight,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: _buildCard(
                      context,
                      0,
                      cardIds[0],
                      userProvider,
                      contentProvider,
                      cardWidth,
                      cardHeight,
                    ),
                  ),
                  Positioned(
                    left: (availableWidth - cardWidth) / 2,
                    top: centerCardTop,
                    child: _buildCard(
                      context,
                      1,
                      cardIds[1],
                      userProvider,
                      contentProvider,
                      cardWidth,
                      cardHeight,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: _buildCard(
                      context,
                      2,
                      cardIds[2],
                      userProvider,
                      contentProvider,
                      cardWidth,
                      cardHeight,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    int positionIndex,
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
        _isCardOpened(contentProvider, positionIndex) &&
        card != null;
    final hiveKey = _getHiveKeyForIndex(positionIndex);

    return Semantics(
      button: cardId.isNotEmpty,
      enabled: !_isAnyCardAnimating && cardId.isNotEmpty,
      label: !isOpened
          ? context.l10n.tarotOpenSpreadCard(positionIndex + 1)
          : context.l10n.tarotOpenedSpreadCard(positionIndex + 1, card.title),
      child: ExcludeSemantics(
        child: FlipCardWidget(
          key: ValueKey('tarot_layout_card_$positionIndex'),
          front: card != null
              ? _buildCardFront(card, cardWidth, cardHeight, positionIndex)
              : _buildCardBack(cardWidth, cardHeight, positionIndex),
          back: _buildCardBack(cardWidth, cardHeight, positionIndex),
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
                await contentProvider.openTarotCardInDeck(
                  hiveKey,
                  cardId: cardId,
                );
              } catch (e) {
                debugPrint('[ERROR] Ошибка открытия карты таро: $e');
              }
            }
            if (mounted) {
              setState(() => _isAnyCardAnimating = false);
            }
          },
          onTap: () {
            if (card != null) {
              _showCardModal(context, card, positionIndex);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCardBack(double width, double height, int positionIndex) {
    return Container(
      key: ValueKey('tarot_layout_back_$positionIndex'),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        child: Image.asset(
          _cardBackAsset,
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
              child: const ClayIcon(Icons.image_not_supported, size: 64),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardFront(
    TarotCardModel card,
    double width,
    double height,
    int positionIndex,
  ) {
    return Container(
      key: ValueKey('tarot_layout_front_$positionIndex'),
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
              child: const ClayIcon(Icons.image_not_supported, size: 64),
            );
          },
        ),
      ),
    );
  }
}

import 'package:asteria_app/core/ui_kit/widgets/card_turn.dart';
import 'package:asteria_app/core/ui_kit/widgets/tarot_card_frame.dart';
import 'package:asteria_app/core/ui_kit/widgets/artwork_unavailable.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/tarot_card_asset_resolver.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/utils/enums.dart';
import 'package:asteria_app/features/kelt_deck/widgets/card_description_modal.dart';
import 'package:flutter/material.dart';

class CelticCrossLayout extends StatefulWidget {
  const CelticCrossLayout({super.key});

  @override
  State<CelticCrossLayout> createState() => _CelticCrossLayoutState();
}

class _CelticCrossLayoutState extends State<CelticCrossLayout>
    with TickerProviderStateMixin {
  static const double _verticalCardHeight = 129.0;
  static const double _horizontalCardWidth = 86.0;
  static const double _horizontalCardHeight = 129.0;
  static const double _gap = 4.0;
  static const double _layoutWidth = 358.0;
  static const double _layoutHeight = 528.0;

  final Map<int, AnimationController> _animationControllers = {};
  final Map<int, bool> _isAnimating = {};
  bool _isAnyCardAnimating = false;
  late final AnimationController _firstRetreat = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );

  @override
  void dispose() {
    for (final controller in _animationControllers.values) {
      controller.dispose();
    }
    _firstRetreat.dispose();
    super.dispose();
  }

  AnimationController _getAnimationController(int cardNumber) {
    if (!_animationControllers.containsKey(cardNumber)) {
      final controller = AnimationController(
        vsync: this,
        duration: CardTurn.duration,
      );
      _animationControllers[cardNumber] = controller;
    }
    return _animationControllers[cardNumber]!;
  }

  List<String> _getCardIdsInOrder(UserProvider userProvider) {
    final keltDeckCards =
        userProvider.currentUser?.keltDeck?.keltDeckCards ?? {};
    if (keltDeckCards.isEmpty) {
      return List.filled(10, '');
    }

    // Преобразуем Map в список, сохраняя порядок ключей (LinkedHashMap сохраняет порядок вставки)
    final cardIds = keltDeckCards.keys.toList();

    // Если карт меньше 10, дополняем пустыми строками
    final result = <String>[];
    for (int i = 0; i < 10; i++) {
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

  Future<void> _onCardTap(
    int cardNumber,
    String cardId,
    UserProvider userProvider,
    ContentProvider contentProvider,
  ) async {
    if (cardId.isEmpty || _getCardById(cardId, contentProvider) == null) return;

    if (!mounted) return;

    // Блокируем открытие новых карт, пока идет анимация любой другой карты
    if (_isAnyCardAnimating) return;

    final isOpened = userProvider.isDeckCardOpened(DeckType.kelt, cardId);

    if (isOpened) {
      final card = _getCardById(cardId, contentProvider);
      if (card != null) {
        _showCardModal(card, cardNumber);
      }
      return;
    }

    setState(() {
      _isAnimating[cardNumber] = true;
      _isAnyCardAnimating = true;
    });

    final controller = _getAnimationController(cardNumber);
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (cardNumber == 1) _firstRetreat.value = 0;
    try {
      if (reducedMotion) {
        controller.value = 1;
      } else {
        await controller.forward(from: 0).orCancel;
      }
      if (!mounted) return;
      await userProvider.openKeltDeckCard(cardId);
      if (!mounted) return;
      if (cardNumber == 1 &&
          userProvider.isDeckCardOpened(DeckType.kelt, cardId)) {
        if (reducedMotion) {
          _firstRetreat.value = 1;
        } else {
          await Future<void>.delayed(const Duration(milliseconds: 550));
          if (!mounted) return;
          await _firstRetreat.forward().orCancel;
        }
      }
    } on TickerCanceled {
      return;
    } catch (e) {
      debugPrint('[ERROR] Ошибка открытия карты: $e');
      // Если произошла ошибка, сбрасываем анимацию
      if (mounted) {
        controller.reset();
      }
    }

    if (!mounted) return;
    setState(() {
      _isAnimating[cardNumber] = false;
      _isAnyCardAnimating = false;
    });
  }

  void _showCardModal(TarotCardModel card, int cardNumber) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CardDescriptionModal(card: card, cardNumber: cardNumber);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = di.get<UserProvider>();
    final contentProvider = di.get<ContentProvider>();
    final hasGeneratedDeck =
        userProvider.currentUser?.keltDeck?.keltDeckCards.isNotEmpty ?? false;
    if (!hasGeneratedDeck) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: MediaQuery.sizeOf(context).shortestSide >= 600
          ? _layoutHeight * 1.35
          : _layoutHeight,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: _layoutWidth,
          height: _layoutHeight,
          child: ListenableBuilder(
            listenable: Listenable.merge([
              userProvider,
              contentProvider,
              _firstRetreat,
            ]),
            builder: (context, _) {
              final cardIds = _getCardIdsInOrder(userProvider);
              final slots = [
                _CelticCrossCardSlot(
                  left: 90,
                  top: 94,
                  cardNumber: 5,
                  cardId: cardIds[4],
                ),
                _CelticCrossCardSlot(
                  left: 0,
                  top: 227,
                  cardNumber: 3,
                  cardId: cardIds[2],
                ),
                _CelticCrossCardSlot(
                  left: 180,
                  top: 227,
                  cardNumber: 4,
                  cardId: cardIds[3],
                ),
                _CelticCrossCardSlot(
                  left: 68,
                  top: 270,
                  cardNumber: 2,
                  cardId: cardIds[1],
                  isHorizontal: true,
                ),
                _CelticCrossCardSlot(
                  left: 90,
                  top: 360,
                  cardNumber: 6,
                  cardId: cardIds[5],
                ),
                _CelticCrossCardSlot(
                  left: 272,
                  top: 0,
                  cardNumber: 10,
                  cardId: cardIds[9],
                ),
                _CelticCrossCardSlot(
                  left: 272,
                  top: _verticalCardHeight + _gap,
                  cardNumber: 9,
                  cardId: cardIds[8],
                ),
                _CelticCrossCardSlot(
                  left: 272,
                  top: (_verticalCardHeight + _gap) * 2,
                  cardNumber: 8,
                  cardId: cardIds[7],
                ),
                _CelticCrossCardSlot(
                  left: 272,
                  top: (_verticalCardHeight + _gap) * 3,
                  cardNumber: 7,
                  cardId: cardIds[6],
                ),
                _CelticCrossCardSlot(
                  left: 90,
                  top: 227,
                  cardNumber: 1,
                  cardId: cardIds[0],
                ),
              ];

              final firstOpened =
                  cardIds[0].isNotEmpty &&
                  userProvider.isDeckCardOpened(DeckType.kelt, cardIds[0]);
              final firstBehind =
                  firstOpened &&
                  (!(_isAnimating[1] ?? false) || _firstRetreat.value >= .5);
              if (firstBehind) {
                final first = slots.removeLast();
                slots.insert(0, first);
              }
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final slot in slots)
                    _positionedCard(
                      left: slot.left,
                      top: slot.top,
                      cardNumber: slot.cardNumber,
                      cardId: slot.cardId,
                      userProvider: userProvider,
                      contentProvider: contentProvider,
                      isHorizontal: slot.isHorizontal,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _positionedCard({
    required double left,
    required double top,
    required int cardNumber,
    required String cardId,
    required UserProvider userProvider,
    required ContentProvider contentProvider,
    bool isHorizontal = false,
  }) {
    final isEnabled = _getCardById(cardId, contentProvider) != null;

    return Positioned(
      key: ValueKey('celtic_slot_$cardNumber'),
      left: left,
      top: top,
      child: Transform.translate(
        offset: Offset(
          0,
          cardNumber == 1 ? -4 * _retreatProgress(userProvider, cardId) : 0,
        ),
        child: Transform.scale(
          scale: cardNumber == 1
              ? 1 - .04 * _retreatProgress(userProvider, cardId)
              : 1,
          child: _buildCard(
            _horizontalCardWidth,
            _horizontalCardHeight,
            cardNumber,
            cardId,
            userProvider,
            contentProvider,
            isEnabled: isEnabled,
            isHorizontal: isHorizontal,
          ),
        ),
      ),
    );
  }

  double _retreatProgress(UserProvider userProvider, String cardId) {
    if (!userProvider.isDeckCardOpened(DeckType.kelt, cardId)) return 0;
    if (!(_isAnimating[1] ?? false)) return 1;
    return Curves.easeInOutCubic.transform(_firstRetreat.value);
  }

  Widget _buildCard(
    double width,
    double height,
    int cardNumber,
    String cardId,
    UserProvider userProvider,
    ContentProvider contentProvider, {
    required bool isEnabled,
    bool isHorizontal = false,
  }) {
    // Получаем карту заранее, даже если она еще не открыта (для анимации)
    final card = cardId.isNotEmpty
        ? _getCardById(cardId, contentProvider)
        : null;
    final isAnimating = _isAnimating[cardNumber] ?? false;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: '${context.l10n.cardNumberLabel} $cardNumber',
      child: IgnorePointer(
        ignoring: !isEnabled,
        child: LotusTap(
          animateEntrance: false,
          behavior: HitTestBehavior.opaque,
          onTap: () =>
              _onCardTap(cardNumber, cardId, userProvider, contentProvider),
          child: SizedBox(
            width: isHorizontal ? height : width,
            height: isHorizontal ? width : height,
            child: AnimatedBuilder(
              animation: _getAnimationController(cardNumber),
              builder: (context, child) {
                final controller = _getAnimationController(cardNumber);
                final isOpened =
                    cardId.isNotEmpty &&
                    userProvider.isDeckCardOpened(DeckType.kelt, cardId);
                final progress = isAnimating
                    ? controller.value
                    : (isOpened ? 1.0 : 0.0);
                return CardTurn(
                  progress: card == null ? 0 : progress,
                  horizontal: isHorizontal,
                  back: _buildCardBack(
                    cardNumber,
                    isHorizontal ? height : width,
                    isHorizontal ? width : height,
                  ),
                  front: card == null
                      ? _buildCardBack(cardNumber, width, height)
                      : isHorizontal
                      ? RotatedBox(
                          quarterTurns: -1,
                          child: _buildCardFront(
                            card,
                            width,
                            height,
                            isHorizontal: true,
                          ),
                        )
                      : _buildCardFront(card, width, height),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack(int cardNumber, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: TarotCardFrame(
          radius: 12,
          child: Image.asset(
            'assets/images/cards/card_back/card_back_$cardNumber.webp',
            width: width,
            height: height,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return ArtworkUnavailable(
                width: width,
                height: height,
                radius: 12,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront(
    TarotCardModel card,
    double width,
    double height, {
    bool isHorizontal = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: TarotCardFrame(
          radius: 12,
          child: Image.asset(
            TarotCardAssetResolver.resolve(
              imageName: card.imageName,
              languageCode: Localizations.localeOf(context).languageCode,
            ),
            width: width,
            height: height,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return ArtworkUnavailable(
                width: width,
                height: height,
                radius: 12,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CelticCrossCardSlot {
  const _CelticCrossCardSlot({
    required this.left,
    required this.top,
    required this.cardNumber,
    required this.cardId,
    this.isHorizontal = false,
  });

  final double left;
  final double top;
  final int cardNumber;
  final String cardId;
  final bool isHorizontal;
}

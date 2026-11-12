import 'package:asteria_app/core/ui_kit/widgets/tarot_card_frame.dart';
import 'package:asteria_app/core/ui_kit/widgets/artwork_unavailable.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/core/localization/tarot_card_asset_resolver.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class TarotCardOfTheDayWidget extends StatefulWidget {
  final TarotCardModel? tarotCard;
  final bool isLoading;
  final bool isOpened;
  final VoidCallback? onRefresh;
  final VoidCallback? onCardTap;
  final bool? showMoreButton;
  final bool isDarkLayout;
  final EdgeInsetsGeometry margin;

  const TarotCardOfTheDayWidget({
    Key? key,
    this.tarotCard,
    this.isLoading = false,
    this.isOpened = false,
    this.showMoreButton = true,
    this.isDarkLayout = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
    this.onRefresh,
    this.onCardTap,
  }) : super(key: key);

  @override
  State<TarotCardOfTheDayWidget> createState() =>
      _TarotCardOfTheDayWidgetState();
}

class _TarotCardOfTheDayWidgetState extends State<TarotCardOfTheDayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isOpened) {
      _animationController.value = 1.0; // Показываем лицевую сторону
    } else {
      _animationController.value = 0.0; // Показываем обратную сторону
    }
  }

  @override
  void didUpdateWidget(TarotCardOfTheDayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpened != oldWidget.isOpened) {
      if (widget.isOpened) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: Column(
        children: [
          widget.isDarkLayout
              ? _buildDarkHeader(context)
              : _buildDefaultHeader(context),
          const SizedBox(height: 16),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildDefaultHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: 32),
        Text(
          context.l10n.dailyTarotTitle,
          textAlign: TextAlign.center,
          style: context.textTheme.playfairSemiBold32,
        ).withEntrance(),
        if (widget.onRefresh != null)
          Semantics(
            button: true,
            label: context.l10n.refreshDailyTarotLabel,
            child: ExcludeSemantics(
              child: LotusTap(
                onTap: widget.onRefresh,
                child: RepeatButtonWidget(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDarkHeader(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.dailyTarotTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.playfairSemiBold32.copyWith(
                color: AppColors.white,
                height: 1.0,
              ),
            ).withEntrance(),
          ),
          if (widget.onRefresh != null)
            Semantics(
              button: true,
              label: context.l10n.refreshDailyTarotLabel,
              child: ExcludeSemantics(
                child: LotusTap(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onRefresh,
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFF3B76A),
                        BlendMode.srcIn,
                      ),
                      child: const RepeatButtonWidget(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingContent();
    } else if (widget.tarotCard != null) {
      return _buildTarotContent(context, widget.tarotCard!);
    } else {
      // Если карта null и открыта - показываем загрузку (данные еще загружаются)
      // Если карта null и не открыта - показываем закрытую карту
      if (widget.isOpened) {
        return _buildLoadingContent();
      } else {
        return _buildClosedCardContent(context);
      }
    }
  }

  Widget _buildClosedCardContent(BuildContext context) {
    return Column(
      children: AsteriaEntrance.sections([
        // Показываем закрытую карту
        Center(
          child: Semantics(
            button: widget.onCardTap != null,
            label: context.l10n.dailyTarotFlipLabel,
            child: ExcludeSemantics(
              child: LotusTap(onTap: widget.onCardTap, child: _buildCardBack()),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Описание для закрытой карты
        _buildClosedDescription(context),
      ]),
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      children: AsteriaEntrance.sections([
        const SizedBox(height: 328, child: Center(child: LoadingWidget())),
        const SizedBox(height: 16),
        Text(
          context.l10n.dailyTarotLoading,
          style: AppTypography.text1.copyWith(
            color: widget.isDarkLayout ? const Color(0xFFEEEAFD) : null,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _buildTarotContent(BuildContext context, TarotCardModel tarotCard) {
    return Column(
      children: AsteriaEntrance.sections([
        // Animated tarot card
        Center(
          child: Semantics(
            button: !widget.isOpened && widget.onCardTap != null,
            label: widget.isOpened
                ? context.l10n.dailyTarotOpenedLabel(tarotCard.title)
                : context.l10n.dailyTarotFlipLabel,
            child: ExcludeSemantics(
              child: LotusTap(
                onTap: widget.isOpened ? null : widget.onCardTap,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(_flipAnimation.value * 3.14159),
                      child: _flipAnimation.value < 0.5
                          ? _buildCardBack()
                          : Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(3.14159),
                              child: _buildCardFront(tarotCard),
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Description
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: widget.isOpened
              ? _buildOpenedDescription(context, tarotCard)
              : _buildClosedDescription(context),
        ),
        if (widget.isOpened && widget.showMoreButton == true) ...[
          const SizedBox(height: 16),
          CustomButton(
            text: context.l10n.commonMore,
            onPressed: () {
              TaroCardsRoute.push(context);
            },
            isFullWidth: true,
          ),
        ],
      ]),
    );
  }

  Widget _buildCardBack() {
    final borderRadius = BorderRadius.circular(widget.isDarkLayout ? 16 : 12);
    return Container(
      height: 328,
      width: 219,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: TarotCardFrame(
          radius: borderRadius.topLeft.x,
          child: Image.asset(
            'assets/images/home/daily_symbol_tarot_back.webp',
            width: 219,
            height: 328,
            fit: BoxFit.fitWidth,
            errorBuilder: (context, error, stackTrace) {
              return ArtworkUnavailable(
                width: 219,
                height: 328,
                radius: borderRadius.topLeft.x,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront(TarotCardModel tarotCard) {
    final borderRadius = BorderRadius.circular(widget.isDarkLayout ? 16 : 12);
    return Container(
      height: 328,
      width: 219, // Фиксированная ширина
      decoration: BoxDecoration(borderRadius: borderRadius),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: TarotCardFrame(
          radius: borderRadius.topLeft.x,
          child: Image.asset(
            TarotCardAssetResolver.resolve(
              imageName: tarotCard.imageName,
              languageCode: Localizations.localeOf(context).languageCode,
            ),
            width: 219,
            height: 328,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return ArtworkUnavailable(
                width: 219,
                height: 328,
                radius: borderRadius.topLeft.x,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildClosedDescription(BuildContext context) {
    return Container(
      key: const ValueKey('closed'),
      child: Column(
        children: [
          Text(
            context.l10n.dailyTarotTap,
            textAlign: TextAlign.center,
            style: widget.isDarkLayout
                ? context.textTheme.urbanistRegular16.copyWith(
                    color: const Color(0xFFEEEAFD),
                    height: 1.2,
                  )
                : context.textTheme.secondaryUrbanistRegular16,
          ),
        ],
      ),
    );
  }

  Widget _buildOpenedDescription(
    BuildContext context,
    TarotCardModel tarotCard,
  ) {
    return Container(
      key: const ValueKey('opened'),
      child: Column(
        children: [
          if (!widget.isDarkLayout) ...[
            Text(tarotCard.title, style: context.textTheme.playfairSemiBold24),
            const SizedBox(height: 8),
          ],
          Text(
            tarotCard.cardOfDayDescription,
            textAlign: TextAlign.center,
            style: widget.isDarkLayout
                ? context.textTheme.urbanistRegular16.copyWith(
                    color: const Color(0xFFEEEAFD),
                    height: 1.2,
                  )
                : context.textTheme.secondaryUrbanistRegular16,
          ),
        ],
      ),
    );
  }
}

import 'package:asteria_app/core/ui_kit/widgets/tarot_card_frame.dart';
import 'package:asteria_app/core/ui_kit/widgets/artwork_unavailable.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'dart:math' as math;

import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/core/localization/tarot_card_asset_resolver.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

enum _DailySymbolTab { tarot, rune }

class DailySymbolOfTheDayWidget extends StatefulWidget {
  const DailySymbolOfTheDayWidget({
    super.key,
    required this.onTarotRefresh,
    required this.onRuneRefresh,
    this.tarotCard,
    this.rune,
    this.isTarotLoading = false,
    this.isRuneLoading = false,
    this.isTarotOpened = false,
    this.isRuneOpened = false,
    this.onCardTap,
    this.onRuneTap,
    this.onRuneTabSelected,
  });

  final TarotCardModel? tarotCard;
  final RuneOfDayModel? rune;
  final bool isTarotLoading;
  final bool isRuneLoading;
  final bool isTarotOpened;
  final bool isRuneOpened;
  final VoidCallback onTarotRefresh;
  final VoidCallback onRuneRefresh;
  final VoidCallback? onCardTap;
  final VoidCallback? onRuneTap;
  final VoidCallback? onRuneTabSelected;

  @override
  State<DailySymbolOfTheDayWidget> createState() =>
      _DailySymbolOfTheDayWidgetState();
}

class _DailySymbolOfTheDayWidgetState extends State<DailySymbolOfTheDayWidget>
    with TickerProviderStateMixin {
  static const double _cardWidth = 219;
  static const double _cardHeight = 328;
  static const double _runeWidth = 189;
  static const double _runeHeight = 307;
  static const double _runeRadius = 41;
  static const LinearGradient _orangeGradient = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
  );

  late final AnimationController _tarotAnimationController;
  late final Animation<double> _tarotFlipAnimation;
  late final AnimationController _runeAnimationController;
  late final Animation<double> _runeFlipAnimation;
  _DailySymbolTab _selectedTab = _DailySymbolTab.tarot;

  @override
  void initState() {
    super.initState();
    _tarotAnimationController = _createController(widget.isTarotOpened);
    _runeAnimationController = _createController(widget.isRuneOpened);
    _tarotFlipAnimation = _createAnimation(_tarotAnimationController);
    _runeFlipAnimation = _createAnimation(_runeAnimationController);
  }

  AnimationController _createController(bool isOpened) {
    return AnimationController(
      duration: const Duration(milliseconds: 600),
      value: isOpened ? 1 : 0,
      vsync: this,
    );
  }

  Animation<double> _createAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(DailySymbolOfTheDayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncFlipState(
      controller: _tarotAnimationController,
      isOpened: widget.isTarotOpened,
      wasOpened: oldWidget.isTarotOpened,
    );
    _syncFlipState(
      controller: _runeAnimationController,
      isOpened: widget.isRuneOpened,
      wasOpened: oldWidget.isRuneOpened,
    );
  }

  void _syncFlipState({
    required AnimationController controller,
    required bool isOpened,
    required bool wasOpened,
  }) {
    if (isOpened == wasOpened) {
      return;
    }

    if (isOpened) {
      if (MediaQuery.disableAnimationsOf(context)) {
        controller.value = 1;
      } else {
        controller.forward();
      }
    } else {
      controller.value = 0;
    }
  }

  @override
  void dispose() {
    _tarotAnimationController.dispose();
    _runeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.dailySymbolTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.inversePlayfairSemiBold24.copyWith(
                  fontFamily: 'Lora',
                  height: 1,
                  letterSpacing: 0,
                ),
              ).withEntrance(),
              const SizedBox(height: 16),
              SegmentedPicker<_DailySymbolTab>(
                surfaceBrightness: Brightness.dark,
                options: _DailySymbolTab.values,
                selectedValue: _selectedTab,
                labelBuilder: (tab) => tab == _DailySymbolTab.tarot
                    ? context.l10n.dailyTarotTab
                    : context.l10n.dailyRuneTab,
                onChanged: _selectTab,
              ).withEntrance(),
              const SizedBox(height: 9),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _selectedTab == _DailySymbolTab.tarot
                    ? _TarotSymbolContent(
                        key: const ValueKey(_DailySymbolTab.tarot),
                        tarotCard: widget.tarotCard,
                        isLoading: widget.isTarotLoading,
                        isOpened: widget.isTarotOpened,
                        flipAnimation: _tarotFlipAnimation,
                        onRefresh: widget.onTarotRefresh,
                        onCardTap: widget.isTarotOpened
                            ? null
                            : widget.onCardTap,
                        orangeGradient: _orangeGradient,
                        maxTextWidth: constraints.maxWidth,
                      )
                    : _RuneSymbolContent(
                        key: const ValueKey(_DailySymbolTab.rune),
                        rune: widget.rune,
                        isLoading: widget.isRuneLoading,
                        isOpened: widget.isRuneOpened,
                        flipAnimation: _runeFlipAnimation,
                        onRefresh: widget.onRuneRefresh,
                        onRuneTap: widget.isRuneOpened
                            ? null
                            : widget.onRuneTap,
                        orangeGradient: _orangeGradient,
                        maxTextWidth: constraints.maxWidth,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _selectTab(_DailySymbolTab tab) {
    if (_selectedTab == tab) {
      return;
    }

    setState(() => _selectedTab = tab);

    if (tab == _DailySymbolTab.rune) {
      widget.onRuneTabSelected?.call();
    }
  }
}

class _TarotSymbolContent extends StatelessWidget {
  const _TarotSymbolContent({
    super.key,
    required this.tarotCard,
    required this.isLoading,
    required this.isOpened,
    required this.flipAnimation,
    required this.onRefresh,
    required this.onCardTap,
    required this.orangeGradient,
    required this.maxTextWidth,
  });

  final TarotCardModel? tarotCard;
  final bool isLoading;
  final bool isOpened;
  final Animation<double> flipAnimation;
  final VoidCallback onRefresh;
  final VoidCallback? onCardTap;
  final LinearGradient orangeGradient;
  final double maxTextWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      children: AsteriaEntrance.sections([
        _SectionTitleRow(
          title: context.l10n.dailyTarotTitle,
          refreshSemanticLabel: context.l10n.refreshDailyTarotLabel,
          onRefresh: onRefresh,
        ),
        const SizedBox(height: 9),
        _buildContent(context),
      ]),
    );
  }

  Widget _buildContent(BuildContext context) {
    final symbol = tarotCard;
    if (symbol == null && (isLoading || isOpened)) {
      return _LoadingContent(text: context.l10n.dailyTarotLoading);
    }

    return Column(
      children: [
        Center(
          child: LotusFeedback(
            onActivate: symbol == null ? null : onCardTap,
            keyboard: true,
            builder: (activate) => Semantics(
              button: symbol != null && onCardTap != null,
              onTap: activate,
              label: symbol == null
                  ? context.l10n.commonUnavailable
                  : isOpened
                  ? context.l10n.dailyTarotOpenedLabel(symbol.title)
                  : context.l10n.dailyTarotFlipLabel,
              child: ExcludeSemantics(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: activate,
                  child: symbol == null
                      ? const DailyTarotCardFace()
                      : DailySymbolFlip(
                          animation: flipAnimation,
                          startsFaceDown: true,
                          back: const DailyTarotCardFace(),
                          front: DailyTarotCardFace(card: symbol),
                        ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: isOpened && symbol != null
              ? _OpenedDescription(
                  key: const ValueKey('tarot_opened'),
                  text: symbol.cardOfDayDescription,
                  maxTextWidth: maxTextWidth,
                )
              : _ClosedDescription(
                  key: const ValueKey('tarot_closed'),
                  text: symbol == null
                      ? context.l10n.commonUnavailable
                      : context.l10n.dailyTarotTap,
                  maxTextWidth: maxTextWidth,
                ),
        ),
        if (symbol != null) ...[
          const SizedBox(height: 8),
          _GradientActionText(
            text: context.l10n.dailyTarotReading,
            gradient: orangeGradient,
            onTap: () => TaroCardsRoute.push(
              context,
              params: const TaroCardsRouteParams.spread(),
            ),
          ),
        ],
      ],
    );
  }
}

class _RuneSymbolContent extends StatelessWidget {
  const _RuneSymbolContent({
    super.key,
    required this.rune,
    required this.isLoading,
    required this.isOpened,
    required this.flipAnimation,
    required this.onRefresh,
    required this.onRuneTap,
    required this.orangeGradient,
    required this.maxTextWidth,
  });

  final RuneOfDayModel? rune;
  final bool isLoading;
  final bool isOpened;
  final Animation<double> flipAnimation;
  final VoidCallback onRefresh;
  final VoidCallback? onRuneTap;
  final LinearGradient orangeGradient;
  final double maxTextWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      children: AsteriaEntrance.sections([
        _SectionTitleRow(
          title: context.l10n.dailyRuneTitle,
          refreshSemanticLabel: context.l10n.refreshDailyRuneLabel,
          onRefresh: onRefresh,
        ),
        const SizedBox(height: 9),
        _buildContent(context),
      ]),
    );
  }

  Widget _buildContent(BuildContext context) {
    final symbol = rune;
    if (symbol == null && (isLoading || isOpened)) {
      return _LoadingContent(text: context.l10n.dailyRuneLoading);
    }

    return Column(
      children: [
        Center(
          child: LotusFeedback(
            onActivate: symbol == null ? null : onRuneTap,
            keyboard: true,
            builder: (activate) => Semantics(
              button: symbol != null && onRuneTap != null,
              onTap: activate,
              label: symbol == null
                  ? context.l10n.commonUnavailable
                  : context.l10n.dailyRuneOpenedLabel(symbol.title),
              child: ExcludeSemantics(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: activate,
                  child: symbol == null
                      ? const _RuneBack()
                      : DailySymbolFlip(
                          animation: flipAnimation,
                          back: const _RuneBack(),
                          front: _RuneFront(rune: symbol),
                        ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: symbol != null
              ? _RuneOpenedDescription(
                  key: const ValueKey('rune_opened'),
                  rune: symbol,
                  maxTextWidth: maxTextWidth,
                )
              : _ClosedDescription(
                  key: const ValueKey('rune_closed'),
                  text: context.l10n.commonUnavailable,
                  maxTextWidth: maxTextWidth,
                ),
        ),
        if (symbol != null) ...[
          const SizedBox(height: 8),
          _GradientActionText(
            text: context.l10n.dailyRuneReading,
            gradient: orangeGradient,
            onTap: () => RunesRoute.push(
              context,
              params: const RunesRouteParams.spread(),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionTitleRow extends StatelessWidget {
  const _SectionTitleRow({
    required this.title,
    required this.refreshSemanticLabel,
    required this.onRefresh,
  });

  final String title;
  final String refreshSemanticLabel;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: context.textTheme.inversePlayfairSemiBold24.copyWith(
              fontFamily: 'Lora',
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
        Semantics(
          button: true,
          label: refreshSemanticLabel,
          child: LotusTap(
            behavior: HitTestBehavior.opaque,
            onTap: onRefresh,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Align(
                alignment: Alignment.center,
                child: LotusRefreshBubble(shuffle: true),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DailySymbolFlip extends StatelessWidget {
  const DailySymbolFlip({
    super.key,
    required this.animation,
    required this.back,
    required this.front,
    this.startsFaceDown = false,
  });

  final bool startsFaceDown;
  final Animation<double> animation;
  final Widget back;
  final Widget front;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        if (animation.isDismissed) return startsFaceDown ? back : front;
        if (animation.isCompleted) return front;
        final angle = startsFaceDown
            ? (animation.value - 1) * math.pi
            : animation.value * 2 * math.pi;
        final showBack = math.cos(angle) < 0;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: showBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: back,
                )
              : front,
        );
      },
    );
  }
}

class DailyTarotCardFace extends StatelessWidget {
  const DailyTarotCardFace({
    super.key,
    this.card,
    this.width = _DailySymbolOfTheDayWidgetState._cardWidth,
    this.height = _DailySymbolOfTheDayWidgetState._cardHeight,
  });
  final TarotCardModel? card;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final symbol = card;
    final asset = symbol == null
        ? 'assets/images/home/daily_symbol_tarot_back.webp'
        : TarotCardAssetResolver.resolve(
            imageName: symbol.imageName,
            languageCode: Localizations.localeOf(context).languageCode,
          );
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: TarotCardFrame(
        radius: 16,
        child: Image.asset(
          asset,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              ArtworkUnavailable(width: width, height: height, radius: 16),
        ),
      ),
    );
  }
}

class _RuneBack extends StatelessWidget {
  const _RuneBack();

  @override
  Widget build(BuildContext context) {
    return const RuneBackImage(
      width: _DailySymbolOfTheDayWidgetState._runeWidth,
      height: _DailySymbolOfTheDayWidgetState._runeHeight,
      borderRadius: _DailySymbolOfTheDayWidgetState._runeRadius,
    );
  }
}

class _RuneFront extends StatelessWidget {
  const _RuneFront({required this.rune});

  final RuneOfDayModel rune;

  String get _imagePath => 'assets/images/runes/${rune.imageName}.webp';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        _DailySymbolOfTheDayWidgetState._runeRadius,
      ),
      child: Image.asset(
        _imagePath,
        width: _DailySymbolOfTheDayWidgetState._runeWidth,
        height: _DailySymbolOfTheDayWidgetState._runeHeight,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const ArtworkUnavailable(
            width: _DailySymbolOfTheDayWidgetState._runeWidth,
            height: _DailySymbolOfTheDayWidgetState._runeHeight,
            radius: _DailySymbolOfTheDayWidgetState._runeRadius,
          );
        },
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(
            height: _DailySymbolOfTheDayWidgetState._cardHeight,
            child: Center(child: LoadingWidget()),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.textTheme.inverseUrbanistRegular16.copyWith(
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClosedDescription extends StatelessWidget {
  const _ClosedDescription({
    super.key,
    required this.text,
    required this.maxTextWidth,
  });

  final String text;
  final double maxTextWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxTextWidth),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.textTheme.inverseUrbanistRegular16.copyWith(
          color: AppColors.textInverse.withValues(alpha: 0.72),
          height: 1.2,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _OpenedDescription extends StatelessWidget {
  const _OpenedDescription({
    super.key,
    required this.text,
    required this.maxTextWidth,
  });

  final String text;
  final double maxTextWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxTextWidth),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.textTheme.inverseUrbanistRegular16.copyWith(
          fontFamily: 'Onest',
          color: AppColors.surface,
          height: 1.2,
          letterSpacing: -0.408,
        ),
      ),
    );
  }
}

class _RuneOpenedDescription extends StatelessWidget {
  const _RuneOpenedDescription({
    super.key,
    required this.rune,
    required this.maxTextWidth,
  });

  final RuneOfDayModel rune;
  final double maxTextWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxTextWidth),
      child: Column(
        children: [
          Text(
            rune.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.textTheme.inversePlayfairSemiBold20.copyWith(
              fontFamily: 'Lora',
              height: 1.1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rune.cardOfDayDescription,
            textAlign: TextAlign.center,
            style: context.textTheme.inverseUrbanistRegular16.copyWith(
              fontFamily: 'Onest',
              color: AppColors.surface,
              height: 1.2,
              letterSpacing: -0.408,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientActionText extends StatelessWidget {
  const _GradientActionText({
    required this.text,
    required this.gradient,
    required this.onTap,
  });

  final String text;
  final LinearGradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LotusFeedback(
      onActivate: onTap,
      keyboard: true,
      builder: (activate) => Semantics(
        button: true,
        label: text,
        onTap: activate,
        child: ExcludeSemantics(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: activate,
            child: SizedBox(
              height: LotusArrowBubble.hitExtent,
              child: Center(
                child: _GradientText(
                  text: text,
                  gradient: gradient,
                  style: context.textTheme.inverseUrbanistSemiBold16.copyWith(
                    fontFamily: 'Onest',
                    height: 1.2,
                    letterSpacing: -0.408,
                  ),
                ),
              ),
            ),
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
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}

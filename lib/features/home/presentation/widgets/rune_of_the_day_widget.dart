import 'package:asteria_app/core/ui_kit/widgets/responsive_heading.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_turn.dart';
import 'package:asteria_app/core/ui_kit/widgets/artwork_unavailable.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class RuneOfTheDayWidget extends StatefulWidget {
  final RuneOfDayModel? rune;
  final bool isLoading;
  final bool isOpened;
  final VoidCallback onRefresh;
  final VoidCallback? onRuneTap;
  final bool showMoreButton;
  final bool isDarkLayout;
  final EdgeInsetsGeometry margin;

  const RuneOfTheDayWidget({
    Key? key,
    this.rune,
    this.isLoading = false,
    this.isOpened = false,
    this.showMoreButton = true,
    this.isDarkLayout = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
    required this.onRefresh,
    this.onRuneTap,
  }) : super(key: key);

  @override
  State<RuneOfTheDayWidget> createState() => _RuneOfTheDayWidgetState();
}

class _RuneOfTheDayWidgetState extends State<RuneOfTheDayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: CardTurn.duration,
      vsync: this,
    );
    _flipAnimation = _animationController;

    if (widget.isOpened) {
      _animationController.value = 1.0; // Показываем руну
    } else {
      _animationController.value = 0.0; // Показываем заглушку
    }
  }

  @override
  void didUpdateWidget(RuneOfTheDayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpened != oldWidget.isOpened) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _animationController.value = widget.isOpened ? 1 : 0;
      } else if (widget.isOpened) {
        _animationController.forward();
      } else {
        // A refreshed symbol is already a different face; keep it hidden.
        _animationController.value = 0;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animationController.value = widget.isOpened ? 1 : 0;
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
          // Header with title and refresh icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ResponsiveHeading(
                  context.l10n.dailyRuneTitle,
                  style: context.textTheme.playfairSemiBold32.copyWith(
                    color: widget.isDarkLayout ? AppColors.white : null,
                    height: 1.2,
                  ),
                ).withEntrance(),
              ),
              const SizedBox(width: 8),
              // Refresh icon
              LotusTap(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onRefresh,
                child: widget.isDarkLayout
                    ? SizedBox(
                        width: LotusArrowBubble.hitExtent,
                        height: LotusArrowBubble.hitExtent,
                        child: Center(
                          child: LotusRefreshBubble(tint: Color(0xFFF3B76A)),
                        ),
                      )
                    : const RepeatButtonWidget(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingContent();
    } else if (widget.rune != null) {
      return _buildRuneContent(context, widget.rune!);
    } else {
      // Если руна null и открыта - показываем загрузку (данные еще загружаются)
      // Если руна null и не открыта - показываем закрытую карту
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
        AsteriaEntrance(
          animateInitially: false,
          child: Center(
            child: LotusTap(
              animateEntrance: false,
              onTap: widget.onRuneTap,
              child: _buildRuneBack(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Описание для закрытой карты
        _buildClosedDescription(context),
      ]),
    );
  }

  Size get _artSize {
    final size = widget.isDarkLayout
        ? const Size(182, 306)
        : const Size(219, 328);
    return !widget.showMoreButton &&
            MediaQuery.sizeOf(context).shortestSide >= 600
        ? size * 1.5
        : size;
  }

  Widget _buildLoadingContent() {
    return Column(
      children: AsteriaEntrance.sections([
        SizedBox(
          height: _artSize.height,
          child: const Center(child: LoadingWidget()),
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.dailyRuneLoading,
          style: TextStyle(
            fontSize: 16,
            color: widget.isDarkLayout ? const Color(0xFFEEEAFD) : null,
          ),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _buildRuneContent(BuildContext context, RuneOfDayModel rune) {
    return Column(
      children: AsteriaEntrance.sections([
        // Animated rune
        AsteriaEntrance(
          animateInitially: false,
          child: Center(
            child: LotusTap(
              animateEntrance: false,
              onTap: widget.isOpened
                  ? null
                  : widget.onRuneTap, // Блокируем нажатие если руна уже открыта
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  return CardTurn(
                    progress: _flipAnimation.value,
                    back: _buildRuneBack(),
                    front: _buildRuneFront(rune),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Description
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: widget.isOpened
              ? _buildOpenedDescription(context, rune)
              : _buildClosedDescription(context),
        ),
        const SizedBox(height: 16),
        // Button
        if (widget.isOpened && widget.showMoreButton)
          CustomButton(
            text: context.l10n.commonMore,
            onPressed: () {
              RunesRoute.push(context);
            },
            isFullWidth: true,
          ),
      ]),
    );
  }

  Widget _buildRuneBack() {
    final size = _artSize;
    final width = size.width;
    final height = size.height;
    return RuneBackImage(width: width, height: height, borderRadius: 12);
  }

  Widget _buildRuneFront(RuneOfDayModel rune) {
    final size = _artSize;
    final width = size.width;
    final height = size.height;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/runes/${rune.imageName}.webp',
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return ArtworkUnavailable(width: width, height: height, radius: 12);
          },
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
            context.l10n.dailyRuneTap,
            textAlign: TextAlign.center,
            style: context.textTheme.secondaryUrbanistRegular16.copyWith(
              color: widget.isDarkLayout ? const Color(0xFFEEEAFD) : null,
              height: widget.isDarkLayout ? 1.2 : null,
              letterSpacing: widget.isDarkLayout ? -0.408 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenedDescription(BuildContext context, RuneOfDayModel rune) {
    return Container(
      key: const ValueKey('opened'),
      child: Column(
        children: [
          // Title and subtitle
          Text(
            rune.title,
            style: context.textTheme.playfairSemiBold24.copyWith(
              color: widget.isDarkLayout ? AppColors.white : null,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          // Description text
          Text(
            rune.cardOfDayDescription,
            textAlign: widget.isDarkLayout ? TextAlign.left : TextAlign.center,
            style: context.textTheme.secondaryUrbanistRegular16.copyWith(
              color: widget.isDarkLayout ? const Color(0xFFEEEAFD) : null,
              fontSize: widget.isDarkLayout ? 16 : 14,
              height: widget.isDarkLayout ? 1.2 : null,
              letterSpacing: widget.isDarkLayout ? -0.408 : null,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

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
          // Header with title and refresh icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  context.l10n.dailyRuneTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                        width: 32,
                        height: 32,
                        child: Center(
                          child: LotusIconSurface(
                            diameter: 32,
                            child: ClayAssetIcon(
                              'assets/icons/repeat_icon.svg',
                              width: 24,
                              height: 24,
                              tint: Color(0xFFF3B76A),
                            ),
                          ),
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
        Center(
          child: LotusTap(
            onTap: widget.onRuneTap,
            child: _buildRuneBack(),
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
        SizedBox(
          height: widget.isDarkLayout ? 306 : 328,
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
        Center(
          child: LotusTap(
            onTap: widget.isOpened
                ? null
                : widget.onRuneTap, // Блокируем нажатие если руна уже открыта
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_flipAnimation.value * 3.14159),
                  child: _flipAnimation.value < 0.5
                      ? _buildRuneBack()
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(3.14159),
                          child: _buildRuneFront(rune),
                        ),
                );
              },
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
    final width = widget.isDarkLayout ? 182.0 : 219.0;
    final height = widget.isDarkLayout ? 306.0 : 328.0;
    return RuneBackImage(width: width, height: height, borderRadius: 12);
  }

  Widget _buildRuneFront(RuneOfDayModel rune) {
    final width = widget.isDarkLayout ? 182.0 : 219.0;
    final height = widget.isDarkLayout ? 306.0 : 328.0;
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
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const ClayIcon(Icons.image_not_supported, size: 64),
            );
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

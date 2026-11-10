import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class _RunesBlockColors {
  static const modalSurface = Color(0xFF140725);
  static const grabber = Color(0xFF332544);
  static const text = Color(0xFFEEEAFD);
}

class RunesBlock extends StatefulWidget {
  final RuneOfDayModel? rune1;
  final RuneOfDayModel? rune2;
  final RuneOfDayModel? rune3;
  final VoidCallback? onOpenRuneLeft;
  final VoidCallback? onOpenRuneCenter;
  final VoidCallback? onOpenRuneRight;
  final bool isRuneLeftOpened;
  final bool isRuneCenterOpened;
  final bool isRuneRightOpened;
  const RunesBlock({
    Key? key,
    required this.rune1,
    required this.rune2,
    required this.rune3,
    this.onOpenRuneLeft,
    this.onOpenRuneCenter,
    this.onOpenRuneRight,
    required this.isRuneLeftOpened,
    required this.isRuneCenterOpened,
    required this.isRuneRightOpened,
  }) : super(key: key);

  @override
  _RunesBlockState createState() => _RunesBlockState();
}

class _RunesBlockState extends State<RunesBlock> with TickerProviderStateMixin {
  late AnimationController _leftRuneController;
  late AnimationController _centerRuneController;
  late AnimationController _rightRuneController;
  late Animation<double> _leftRuneAnimation;
  late Animation<double> _centerRuneAnimation;
  late Animation<double> _rightRuneAnimation;

  @override
  void initState() {
    super.initState();
    _leftRuneController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _centerRuneController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rightRuneController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _leftRuneAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _leftRuneController, curve: Curves.easeInOut),
    );

    _centerRuneAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _centerRuneController, curve: Curves.easeInOut),
    );

    _rightRuneAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rightRuneController, curve: Curves.easeInOut),
    );

    if (widget.isRuneLeftOpened) {
      _leftRuneController.value = 1.0;
    }
    if (widget.isRuneCenterOpened) {
      _centerRuneController.value = 1.0;
    }
    if (widget.isRuneRightOpened) {
      _rightRuneController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(RunesBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRuneLeftOpened != oldWidget.isRuneLeftOpened) {
      if (widget.isRuneLeftOpened) {
        _leftRuneController.forward();
      } else {
        _leftRuneController.reverse();
      }
    }
    if (widget.isRuneCenterOpened != oldWidget.isRuneCenterOpened) {
      if (widget.isRuneCenterOpened) {
        _centerRuneController.forward();
      } else {
        _centerRuneController.reverse();
      }
    }
    if (widget.isRuneRightOpened != oldWidget.isRuneRightOpened) {
      if (widget.isRuneRightOpened) {
        _rightRuneController.forward();
      } else {
        _rightRuneController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _leftRuneController.dispose();
    _centerRuneController.dispose();
    _rightRuneController.dispose();
    super.dispose();
  }

  void _showRuneModal(RuneOfDayModel? rune, int positionInDeck) {
    if (rune == null) {
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _RuneDescriptionModal(
          rune: rune,
          positionInDeck: positionInDeck,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const layoutWidth = 358.0;
        const layoutHeight = 236.0;
        const runeWidth = 111.0;
        const runeHeight = 186.0;
        const centerTop = 32.0;
        const openedSideTop = 4.0;

        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : layoutWidth;
        final scale = availableWidth < layoutWidth
            ? availableWidth / layoutWidth
            : 1.0;
        final width = layoutWidth * scale;
        final height = layoutHeight * scale;
        final scaledRuneWidth = runeWidth * scale;
        final scaledRuneHeight = runeHeight * scale;
        final centerOffset = centerTop * scale;
        final openedSideOffset = openedSideTop * scale;

        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                _PositionedRune(
                  left: 0,
                  top: widget.isRuneLeftOpened ? openedSideOffset : 0,
                  width: scaledRuneWidth,
                  child: _buildAnimatedRune(
                    context: context,
                    animation: _leftRuneAnimation,
                    rune: widget.rune1,
                    isOpened: widget.isRuneLeftOpened,
                    width: scaledRuneWidth,
                    height: scaledRuneHeight,
                    closedSemanticLabel: context.l10n.runeOpenPast,
                    openedSemanticLabel: context.l10n.runeOpenPastMeaning(
                      widget.rune1?.title ?? '',
                    ),
                    onTapClosed: widget.onOpenRuneLeft,
                    onTapOpened: () => _showRuneModal(widget.rune1, 0),
                    positionIndex: 0,
                  ),
                ),
                _PositionedRune(
                  left: (width - scaledRuneWidth) / 2,
                  top: centerOffset,
                  width: scaledRuneWidth,
                  child: _buildAnimatedRune(
                    context: context,
                    animation: _centerRuneAnimation,
                    rune: widget.rune2,
                    isOpened: widget.isRuneCenterOpened,
                    width: scaledRuneWidth,
                    height: scaledRuneHeight,
                    closedSemanticLabel: context.l10n.runeOpenPresent,
                    openedSemanticLabel: context.l10n.runeOpenPresentMeaning(
                      widget.rune2?.title ?? '',
                    ),
                    onTapClosed: widget.onOpenRuneCenter,
                    onTapOpened: () => _showRuneModal(widget.rune2, 1),
                    positionIndex: 1,
                  ),
                ),
                _PositionedRune(
                  right: 0,
                  top: widget.isRuneRightOpened ? openedSideOffset : 0,
                  width: scaledRuneWidth,
                  child: _buildAnimatedRune(
                    context: context,
                    animation: _rightRuneAnimation,
                    rune: widget.rune3,
                    isOpened: widget.isRuneRightOpened,
                    width: scaledRuneWidth,
                    height: scaledRuneHeight,
                    closedSemanticLabel: context.l10n.runeOpenFuture,
                    openedSemanticLabel: context.l10n.runeOpenFutureMeaning(
                      widget.rune3?.title ?? '',
                    ),
                    onTapClosed: widget.onOpenRuneRight,
                    onTapOpened: () => _showRuneModal(widget.rune3, 2),
                    positionIndex: 2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedRune({
    required BuildContext context,
    required Animation<double> animation,
    required RuneOfDayModel? rune,
    required bool isOpened,
    required double width,
    required double height,
    required String closedSemanticLabel,
    required String openedSemanticLabel,
    required VoidCallback? onTapClosed,
    required VoidCallback onTapOpened,
    required int positionIndex,
  }) {
    final onTap = isOpened ? onTapOpened : onTapClosed;

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: isOpened ? openedSemanticLabel.trim() : closedSemanticLabel,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final showBack = animation.value < 0.5;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(animation.value * 3.14159),
              child: showBack
                  ? _buildRuneBack(positionIndex, width, height)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(3.14159),
                      child: _buildRuneFront(
                        context,
                        rune,
                        width,
                        height,
                        positionIndex,
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRuneBack(int positionIndex, double width, double height) {
    final visualHeight = width * 512 / 340;
    return Container(
      key: ValueKey('rune_layout_back_$positionIndex'),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: RuneBackImage(
          key: ValueKey('rune_layout_back_visual_$positionIndex'),
          width: width,
          height: visualHeight,
          borderRadius: 12,
        ),
      ),
    );
  }

  Widget _buildRuneFront(
    BuildContext context,
    RuneOfDayModel? rune,
    double width,
    double height,
    int positionIndex,
  ) {
    if (rune == null) {
      return Container(
        key: ValueKey('rune_layout_front_$positionIndex'),
        width: width,
        height: height,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      );
    }
    final visualHeight = width * 512 / 340;
    return Column(
      key: ValueKey('rune_layout_front_$positionIndex'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          key: ValueKey('rune_layout_front_visual_$positionIndex'),
          width: width,
          height: visualHeight,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/runes/${rune.imageName}.webp',
              width: width,
              height: visualHeight,
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: width,
                  height: visualHeight,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image_not_supported, size: 64),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: width,
          child: Text(
            rune.title,
            style: context.textTheme.urbanistRegular12.copyWith(
              color: AppColors.white,
              height: 1.2,
              letterSpacing: -0.408,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _RuneDescriptionModal extends StatelessWidget {
  final RuneOfDayModel rune;
  // 0 - left (past), 1 - center (present), 2 - right (future)
  final int positionInDeck;

  const _RuneDescriptionModal({
    required this.rune,
    required this.positionInDeck,
  });

  String _getTextByPositionInDeck() {
    switch (positionInDeck) {
      case 0:
        return rune.pastDeck;
      case 1:
        return rune.presentDeck;
      case 2:
        return rune.futureDeck;
      default:
        return rune.pastDeck;
    }
  }

  String _getTitleByPositionInDeck(BuildContext context) {
    switch (positionInDeck) {
      case 0:
        return context.l10n.runesPast;
      case 1:
        return context.l10n.runesPresent;
      case 2:
        return context.l10n.runesFuture;
      default:
        return context.l10n.runesPast;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final minHeight = mediaSize.height < 640 ? mediaSize.height * 0.72 : 420.0;
    final maxHeight = mediaSize.height * 0.9;
    final sheetHeight = 556.0.clamp(minHeight, maxHeight).toDouble();

    return SizedBox(
      height: sheetHeight,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: _RunesBlockColors.modalSurface,
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
                    color: _RunesBlockColors.grabber,
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
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${_getTitleByPositionInDeck(context)} — ${rune.title}',
                          style: context.textTheme.playfairSemiBold24.copyWith(
                            color: AppColors.white,
                            height: 1,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Image.asset(
                          'assets/images/runes/${rune.imageName}.webp',
                          width: 182,
                          height: 307,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getTextByPositionInDeck(),
                        style: context.textTheme.urbanistRegular16.copyWith(
                          color: _RunesBlockColors.text,
                          height: 1.2,
                          letterSpacing: -0.408,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 32),
                    ],
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

class _PositionedRune extends StatelessWidget {
  const _PositionedRune({
    this.left,
    this.right,
    required this.top,
    required this.width,
    required this.child,
  });

  final double? left;
  final double? right;
  final double top;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: SizedBox(width: width, child: child),
    );
  }
}

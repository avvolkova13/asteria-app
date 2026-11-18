import 'package:asteria_app/core/ui_kit/widgets/card_turn.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:flutter/material.dart';

/// Shared виджет анимации разворота карты (рубашка ↔ лицевая сторона).
/// Uses the same turn as the onboarding cards.
class FlipCardWidget extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool isOpened;
  final VoidCallback? onTap;
  final bool flipOnTap;
  final VoidCallback? onFlipStart;
  final VoidCallback? onFlipComplete;
  final double width;
  final double height;
  final Duration duration;
  final bool enabled;

  const FlipCardWidget({
    Key? key,
    required this.front,
    required this.back,
    required this.isOpened,
    this.onTap,
    this.flipOnTap = false,
    this.onFlipStart,
    this.onFlipComplete,
    required this.width,
    required this.height,
    this.duration = CardTurn.duration,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    if (widget.isOpened) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(FlipCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
    if (widget.isOpened != oldWidget.isOpened) {
      if (widget.isOpened) {
        if (MediaQuery.disableAnimationsOf(context)) {
          _controller.value = 1;
        } else {
          _controller.forward();
        }
      } else {
        // Reset before painting a replacement face, not one frame later.
        _controller.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _turning = false;

  Future<void> _onClosedCardTap() async {
    if (_turning) return;
    if (!widget.flipOnTap) {
      widget.onTap?.call();
      return;
    }
    _turning = true;
    widget.onFlipStart?.call();
    try {
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
      } else {
        await _controller.forward().orCancel;
      }
      if (mounted) widget.onFlipComplete?.call();
    } on TickerCanceled {
      // Leaving the screen cancels the turn without persisting an unopened card.
    } finally {
      _turning = false;
    }
  }

  void _onOpenedCardTap() {
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return LotusTap(
      animateEntrance: false,
      behavior: HitTestBehavior.opaque,
      onTap: widget.enabled
          ? () {
              if (_turning || _controller.isAnimating) return;
              final value = _controller.value;
              final isFlipping = value > 0.0 && value < 1.0;
              final isShowingFront =
                  value >= 0.5 || (widget.isOpened && !isFlipping);
              if (isShowingFront) {
                _onOpenedCardTap();
              } else {
                _onClosedCardTap();
              }
            }
          : null,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CardTurn(
              progress: _controller.value,
              front: widget.front,
              back: widget.back,
            );
          },
        ),
      ),
    );
  }
}

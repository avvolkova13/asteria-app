import 'package:flutter/material.dart';

/// Shared виджет анимации разворота карты (рубашка ↔ лицевая сторона).
/// Использует логику из love_layout для плавной анимации без бликов.
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
    this.duration = const Duration(milliseconds: 600),
    this.enabled = true,
  }) : super(key: key);

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget> with SingleTickerProviderStateMixin {
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
    if (widget.isOpened != oldWidget.isOpened) {
      if (widget.isOpened) {
        _controller.value = 1.0;
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !widget.isOpened) {
            _controller.value = 0.0;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onClosedCardTap() async {
    if (widget.flipOnTap) {
      widget.onFlipStart?.call();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _controller.forward();
        if (!mounted) return;
        widget.onFlipComplete?.call();
      });
    } else {
      widget.onTap?.call();
    }
  }

  void _onOpenedCardTap() {
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.enabled
          ? () {
        final value = _controller.value;
        final isFlipping = value > 0.0 && value < 1.0;
        final isShowingFront = value >= 0.5 || (widget.isOpened && !isFlipping);
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
            final value = _controller.value;
            final isFlipping = value > 0.0 && value < 1.0;

            if (!isFlipping) {
              return value >= 0.5 ? widget.front : widget.back;
            }

            final rotationAngle = value * 3.14159;
            final cardWidget = value < 0.5
                ? widget.back
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.14159),
                    child: widget.front,
                  );

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(rotationAngle),
              child: cardWidget,
            );
          },
        ),
      ),
    );
  }
}

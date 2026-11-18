import 'package:flutter/widgets.dart';

/// Retains the painted launch screen while the destination lays out underneath.
/// The destination keeps its element/state when the splash is finally removed.
class SplashHandoff extends StatefulWidget {
  const SplashHandoff({
    super.key,
    required this.splash,
    this.destination,
    this.canReveal = true,
  });

  final Widget splash;
  final Widget? destination;
  final bool canReveal;

  @override
  State<SplashHandoff> createState() => _SplashHandoffState();
}

class _SplashHandoffState extends State<SplashHandoff>
    with SingleTickerProviderStateMixin {
  late final _controller =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 640),
      )..addStatusListener((status) {
        if (status == AnimationStatus.completed) setState(() {});
      });
  late final _opacity = _controller.drive(
    Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOutCubic)),
  );
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _synchronize();
  }

  @override
  void didUpdateWidget(SplashHandoff oldWidget) {
    super.didUpdateWidget(oldWidget);
    _synchronize();
  }

  void _synchronize() {
    if (widget.destination == null || !widget.canReveal) {
      _controller.reset();
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (!_controller.isCompleted &&
        !_controller.isAnimating &&
        !_scheduled) {
      _scheduled = true;
      // Give the destination its first layout/paint before exposing it.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scheduled = false;
        if (mounted &&
            widget.destination != null &&
            widget.canReveal &&
            !_controller.isCompleted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final covered = !_controller.isCompleted;
    return Stack(
      fit: StackFit.expand,
      textDirection: TextDirection.ltr,
      children: [
        ExcludeSemantics(
          excluding: covered,
          child: ExcludeFocus(
            excluding: covered,
            child: IgnorePointer(
              ignoring: covered,
              child: widget.destination ?? const SizedBox.expand(),
            ),
          ),
        ),
        if (covered)
          FadeTransition(
            opacity: _opacity,
            child: RepaintBoundary(child: widget.splash),
          ),
      ],
    );
  }
}

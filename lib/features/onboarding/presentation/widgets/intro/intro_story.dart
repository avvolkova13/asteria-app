import 'dart:async';

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/responsive_heading.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:flutter/material.dart';

/// A finite demonstration. The result stays until the visitor leaves.
class IntroStory extends StatefulWidget {
  const IntroStory({
    super.key,
    required this.active,
    required this.builder,
    this.now = DateTime.now,
    this.duration = const Duration(seconds: 11),
  });

  final bool active;
  final DateTime Function() now;
  final Duration duration;
  final Widget Function(BuildContext, double, bool, DateTime) builder;

  @override
  State<IntroStory> createState() => _IntroStoryState();
}

class _IntroStoryState extends State<IntroStory>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  bool _static = false;
  bool _visible = true;
  bool _foreground = true;
  bool _paused = false;
  bool _initialized = false;
  Timer? _midnight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _scheduleDateRefresh() {
    _midnight?.cancel();
    if (!widget.active || !_foreground) return;
    final now = widget.now();
    final next = DateTime(now.year, now.month, now.day + 1);
    _midnight = Timer(next.difference(now), () {
      if (!mounted) return;
      setState(() {});
      _scheduleDateRefresh();
    });
  }

  void _sync({bool restart = false}) {
    _clock.stop();
    if (_static) {
      _clock.value = 1;
    } else if (widget.active && _visible && _foreground && !_paused) {
      _clock.forward(from: restart ? 0 : null);
    }
    _scheduleDateRefresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final media = MediaQuery.of(context);
    final static =
        media.disableAnimations ||
        media.accessibleNavigation ||
        media.textScaler.scale(16) > 22;
    final visible = TickerMode.valuesOf(context).enabled;
    if (!_initialized || static != _static || visible != _visible) {
      final restart = !_initialized || (_static && !static);
      _initialized = true;
      _static = static;
      _visible = visible;
      _sync(restart: restart);
    }
  }

  @override
  void didUpdateWidget(IntroStory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      _paused = false;
      _sync(restart: widget.active);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _sync();
    if (_foreground && mounted) setState(() {});
  }

  void _toggle() {
    if (!widget.active || _clock.isCompleted) return;
    setState(() {
      _paused = !_paused;
      _sync();
    });
  }

  @override
  void dispose() {
    _midnight?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _clock.dispose();
    super.dispose();
  }

  IntroPlaybackMode get _mode => _static
      ? IntroPlaybackMode.static
      : _clock.isCompleted
      ? IntroPlaybackMode.replay
      : _paused
      ? IntroPlaybackMode.resume
      : IntroPlaybackMode.pause;

  void _publishFooter(BuildContext context) {
    final controller = IntroPlaybackScope.maybeOf(context);
    if (controller == null) return;
    final mode = _mode;
    final progress = _clock.value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.progress.value = progress;
        controller.update(mode, _toggle);
      }
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _clock,
    builder: (context, _) {
      _publishFooter(context);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RepaintBoundary(
            child: widget.builder(
              context,
              _clock.value *
                  widget.duration.inMicroseconds /
                  Duration.microsecondsPerSecond,
              _static,
              widget.now(),
            ),
          ),
        ],
      );
    },
  );
}

/// Removes expired cards from hit testing and accessibility, not just painting.
class StoryReveal extends StatelessWidget {
  const StoryReveal({
    super.key,
    required this.time,
    required this.start,
    this.end,
    required this.child,
  });
  final double time, start;
  final double? end;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final entering = ((time - start) / .48).clamp(0.0, 1.0);
    final leaving = end == null ? 0.0 : ((time - end!) / .24).clamp(0.0, 1.0);
    if (entering <= 0 || leaving >= 1) return const SizedBox.shrink();
    final eased = Curves.easeOutCubic.transform(entering);
    return ExcludeSemantics(
      excluding: entering < 1 || leaving > 0,
      child: Opacity(
        opacity: (eased * (1 - leaving)).clamp(0.0, 1.0),
        child: child,
      ),
    );
  }
}

class StoryCard extends StatelessWidget {
  const StoryCard({
    super.key,
    this.title,
    required this.text,
    this.emphasis = false,
  });
  final String? title;
  final String text;
  final bool emphasis;

  @override
  Widget build(BuildContext context) => IntroStoryFocus(
    child: HomeGlassSurface(
      animateEntrance: false,
      tint: AppColorsDark.modal.withValues(alpha: .96),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: AppTypography.text2SemiBold.copyWith(
                  color: AppColorsDark.linkGold,
                ),
              ),
              const SizedBox(height: 7),
            ],
            if (emphasis)
              ResponsiveHeading(
                text,
                style: AppTypography.h3.copyWith(
                  color: AppColors.textInverse,
                  height: 1.3,
                ),
              )
            else
              Text(
                text,
                style: AppTypography.text1.copyWith(
                  color: AppColors.textInverse,
                  height: 1.3,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// Lets the automatic camera follow the current example, without UI focus.
class IntroStoryFocus extends StatefulWidget {
  const IntroStoryFocus({super.key, required this.child, this.enabled = true});
  final Widget child;
  final bool enabled;
  @override
  State<IntroStoryFocus> createState() => _IntroStoryFocusState();
}

class _IntroStoryFocusState extends State<IntroStoryFocus> {
  final _anchor = GlobalKey();
  IntroPlaybackController? _story;

  void _publish() {
    final story = _story;
    if (!widget.enabled || story == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.enabled && identical(story, _story)) {
        story.focus.value = _anchor;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final story = IntroPlaybackScope.maybeOf(context);
    if (!identical(story, _story)) {
      _story = story;
      _publish();
    }
  }

  @override
  void didUpdateWidget(IntroStoryFocus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.enabled && widget.enabled) _publish();
  }

  @override
  Widget build(BuildContext context) =>
      KeyedSubtree(key: _anchor, child: widget.child);
}

enum IntroPlaybackMode { pause, resume, replay, static }

class IntroPlaybackController extends ChangeNotifier {
  final progress = ValueNotifier<double>(0);
  final focus = ValueNotifier<GlobalKey?>(null);

  @override
  void dispose() {
    progress.dispose();
    focus.dispose();
    super.dispose();
  }

  IntroPlaybackMode? mode;
  VoidCallback? toggle;
  void update(IntroPlaybackMode value, VoidCallback action) {
    if (mode == value && toggle == action) return;
    mode = value;
    toggle = action;
    notifyListeners();
  }
}

class IntroPlaybackScope extends InheritedWidget {
  const IntroPlaybackScope({
    super.key,
    required this.controller,
    required super.child,
  });
  final IntroPlaybackController controller;
  static IntroPlaybackController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<IntroPlaybackScope>()
      ?.controller;
  @override
  bool updateShouldNotify(IntroPlaybackScope oldWidget) =>
      controller != oldWidget.controller;
}

class IntroPlaybackFooter extends StatelessWidget {
  const IntroPlaybackFooter({super.key, required this.controller});
  final IntroPlaybackController controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => controller.mode == IntroPlaybackMode.static
        ? const SizedBox.shrink()
        : SizedBox(
            height: 44,
            child: Center(
              child: controller.mode == null || controller.toggle == null
                  ? null
                  : _playbackButton(
                      context,
                      controller.mode!,
                      controller.toggle!,
                    ),
            ),
          ),
  );
}

Widget _playbackButton(
  BuildContext context,
  IntroPlaybackMode mode,
  VoidCallback toggle,
) => mode == IntroPlaybackMode.replay || mode == IntroPlaybackMode.static
    ? const SizedBox.shrink()
    : LotusButtons.text(
        onPressed: toggle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              mode == IntroPlaybackMode.resume
                  ? Icons.play_arrow_rounded
                  : Icons.pause_rounded,
              size: 18,
              color: AppColorsDark.linkGold,
            ),
            const SizedBox(width: 5),
            Text(
              mode == IntroPlaybackMode.resume
                  ? context.l10n.introStoryResume
                  : context.l10n.introStoryPause,
              style: AppTypography.text2.copyWith(
                color: AppColorsDark.linkGold,
              ),
            ),
          ],
        ),
      );

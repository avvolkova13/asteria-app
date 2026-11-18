import 'package:flutter/material.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_bar_geometry.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/features/auth/presentation/widgets/auth_flow_widgets.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_section_heading.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/onboarding_pagination_widget.dart';
import 'package:asteria_app/features/scenarios/scenario_sky.dart';
import '../../../data/models/onboarding_page_model.dart';
import 'intro_stories.dart';
import 'intro_natal_story.dart';
import 'intro_story.dart';
import 'intro_next_button.dart';

class OnboardingTour extends StatefulWidget {
  const OnboardingTour({
    super.key,
    required this.pages,
    required this.onComplete,
    required this.onPageChanged,
    this.now = DateTime.now,
  });
  final List<OnboardingPageModel> pages;
  final DateTime Function() now;
  final VoidCallback onComplete;
  final ValueChanged<int> onPageChanged;
  @override
  State<OnboardingTour> createState() => _TourState();
}

class _TourState extends State<OnboardingTour> with WidgetsBindingObserver {
  int _index = 0;
  late final _pages = PageController(initialPage: _index);
  bool _choosing = false;
  bool _foreground = true;
  bool _moving = false;
  bool _advanceQueued = false;
  int? _finishedIndex;
  late final _playback = List.generate(
    widget.pages.length,
    (index) =>
        IntroPlaybackController()..addListener(() => _onPlaybackChanged(index)),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _onPlaybackChanged(int index) {
    if (index != _index) return;
    _finishedIndex = _playback[index].mode == IntroPlaybackMode.replay
        ? index
        : null;
    _scheduleAdvance();
  }

  void _scheduleAdvance() {
    if (_advanceQueued ||
        _finishedIndex != _index ||
        _index == widget.pages.length - 1) {
      return;
    }
    _advanceQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _advanceQueued = false;
      if (!mounted ||
          !_foreground ||
          _choosing ||
          _moving ||
          _finishedIndex != _index ||
          _index >= widget.pages.length - 1 ||
          !_pages.hasClients) {
        return;
      }
      if (_pages.position.isScrollingNotifier.value ||
          ((_pages.page ?? _index.toDouble()) - _index).abs() > .01) {
        return;
      }
      _go(_index + 1);
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) _scheduleAdvance();
  }

  Future<void> _go(int index) async {
    if (_choosing || !_pages.hasClients) return;
    _moving = true;
    try {
      if (MediaQuery.disableAnimationsOf(context) ||
          MediaQuery.accessibleNavigationOf(context)) {
        _pages.jumpToPage(index);
      } else {
        await _pages.animateToPage(
          index,
          duration: const Duration(milliseconds: 560),
          curve: Curves.easeInOutCubic,
        );
      }
    } finally {
      _moving = false;
    }
  }

  void _finish() {
    if (_choosing) return;
    setState(() => _choosing = true);
    widget.onComplete();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pages.dispose();
    for (final controller in _playback) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AuthFlowScaffold(
    background: const ScenarioSky(),
    child: DefaultTextStyle.merge(
      style: const TextStyle(color: AppColors.textInverse),
      child: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    AsteriaTopBarFrame(
                      child: Row(
                        children: [
                          if (_index > 0)
                            LotusButtons.icon(
                              icon: const LotusArrowBubble(back: true),
                              tooltip: MaterialLocalizations.of(
                                context,
                              ).backButtonTooltip,
                              onPressed: () => _go(_index - 1),
                            ),
                          const Spacer(),
                          LotusButtons.text(
                            onPressed: _finish,
                            child: Text(
                              context.l10n.introSkip,
                              style: AppTypography.text1.copyWith(
                                color: AppColors.textInverse,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                      child: Semantics(
                        label: context.l10n.introProgress(
                          _index + 1,
                          widget.pages.length,
                        ),
                        child: ExcludeSemantics(
                          child: AnimatedBuilder(
                            animation: Listenable.merge([
                              _pages,
                              ..._playback.map((item) => item.progress),
                            ]),
                            builder: (context, _) => OnboardingPaginationWidget(
                              totalPages: widget.pages.length,
                              currentPage: _index,
                              page: _pages.hasClients
                                  ? (_pages.page ?? _index.toDouble())
                                  : _index.toDouble(),
                              progress: _playback
                                  .map((item) => item.progress.value)
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: NotificationListener<ScrollEndNotification>(
                        onNotification: (_) {
                          _scheduleAdvance();
                          return false;
                        },
                        child: PageView(
                          controller: _pages,
                          allowImplicitScrolling: false,
                          onPageChanged: (i) {
                            setState(() {
                              _index = i;
                              _finishedIndex = null;
                            });
                            widget.onPageChanged(i);
                          },
                          children: [
                            for (
                              var index = 0;
                              index < widget.pages.length;
                              index++
                            )
                              IntroPlaybackScope(
                                controller: _playback[index],
                                child: _Scene(
                                  controller: _pages,
                                  index: index,
                                  active: _index == index,
                                  title: widget.pages[index].title,
                                  body: widget.pages[index].description,
                                  child: switch (widget
                                      .pages[index]
                                      .visualKind) {
                                    OnboardingVisualKind.hero =>
                                      IntroCalendarStory(
                                        now: widget.now,
                                        active: _index == index && !_choosing,
                                      ),
                                    OnboardingVisualKind.natal =>
                                      IntroNatalStory(
                                        active: _index == index && !_choosing,
                                      ),
                                    OnboardingVisualKind.personal =>
                                      IntroPairStory(
                                        active: _index == index && !_choosing,
                                      ),
                                    OnboardingVisualKind.tarot =>
                                      IntroTarotStory(
                                        active: _index == index && !_choosing,
                                      ),
                                    OnboardingVisualKind.daily =>
                                      IntroMoodStory(
                                        active: _index == index && !_choosing,
                                      ),
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      child: AnimatedBuilder(
                        animation: _pages,
                        builder: (context, _) => IntroNextButton(
                          page: _pages.hasClients
                              ? (_pages.page ?? _index.toDouble())
                              : _index.toDouble(),
                          index: _index,
                          totalPages: widget.pages.length,
                          label: _index == widget.pages.length - 1
                              ? context.l10n.introStart
                              : context.l10n.next,
                          onPressed: _index == widget.pages.length - 1
                              ? _finish
                              : () => _go(_index + 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Scene extends StatefulWidget {
  const _Scene({
    required this.index,
    required this.controller,
    required this.active,
    required this.title,
    required this.body,
    required this.child,
  });
  final int index;
  final PageController controller;
  final bool active;
  final String title, body;
  final Widget child;

  @override
  State<_Scene> createState() => _SceneState();
}

class _SceneState extends State<_Scene> {
  final _scroll = ScrollController();
  IntroPlaybackController? _story;
  GlobalKey? _lastFocus;
  IntroPlaybackMode? _lastMode;
  double _lastProgress = 0;
  bool _queued = false;
  bool _dragging = false;
  bool _resumeAfterDrag = false;
  int get index => widget.index;
  PageController get controller => widget.controller;
  bool get active => widget.active;
  String get title => widget.title;
  String get body => widget.body;
  Widget get child => widget.child;

  void _rewind() {
    _lastFocus = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  void _onProgress() {
    final progress = _story?.progress.value ?? 0;
    if (progress < _lastProgress - .05) _rewind();
    _lastProgress = progress;
    _follow();
  }

  void _onMode() {
    final mode = _story?.mode;
    if (mode == IntroPlaybackMode.pause && mode != _lastMode) _lastFocus = null;
    _lastMode = mode;
    _follow();
  }

  void _follow() {
    if (_queued || !active || _dragging) return;
    _queued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queued = false;
      if (!mounted || !active || _dragging || !_scroll.hasClients) return;
      final media = MediaQuery.of(context);
      if (media.disableAnimations ||
          media.accessibleNavigation ||
          media.textScaler.scale(16) > 22 ||
          _story?.mode != IntroPlaybackMode.pause) {
        return;
      }
      // Let the scene heading settle before the camera follows its example.
      if ((_story?.progress.value ?? 0) < .1) return;
      final anchor = _story?.focus.value;
      final target = anchor?.currentContext?.findRenderObject();
      if (anchor == null ||
          anchor == _lastFocus ||
          target == null ||
          !target.attached) {
        return;
      }
      _lastFocus = anchor;
      _scroll.position.ensureVisible(
        target,
        alignment: 1,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _dragging = true;
      _lastFocus = null;
      if (_story?.mode == IntroPlaybackMode.pause) {
        _resumeAfterDrag = true;
        _story?.toggle?.call();
      }
    } else if (notification is ScrollEndNotification) {
      _dragging = false;
      if (_resumeAfterDrag) {
        _resumeAfterDrag = false;
        if (_story?.mode == IntroPlaybackMode.resume) _story?.toggle?.call();
      }
    }
    return false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final story = IntroPlaybackScope.maybeOf(context);
    if (identical(story, _story)) return;
    _story?.progress.removeListener(_onProgress);
    _story?.focus.removeListener(_follow);
    _story?.removeListener(_onMode);
    _story = story;
    story?.progress.addListener(_onProgress);
    story?.focus.addListener(_follow);
    story?.addListener(_onMode);
  }

  @override
  void didUpdateWidget(_Scene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.active && active) _rewind();
  }

  @override
  void dispose() {
    _story?.progress.removeListener(_onProgress);
    _story?.focus.removeListener(_follow);
    _story?.removeListener(_onMode);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      final reduced =
          MediaQuery.disableAnimationsOf(context) ||
          MediaQuery.accessibleNavigationOf(context);
      final page = controller.hasClients
          ? (controller.page ?? index.toDouble())
          : index.toDouble();
      final distance = reduced ? 0.0 : (page - index).abs().clamp(0.0, 1.0);
      return Transform.translate(
        offset: Offset(0, 12 * distance),
        child: Transform.scale(
          scale: 1 - .035 * distance,
          child: Opacity(opacity: 1 - .22 * distance, child: child),
        ),
      );
    },
    child: ExcludeSemantics(
      excluding: !active,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: ListView(
          controller: _scroll,
          key: ValueKey('onboarding-content-$index'),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          children: [
            HomeSectionHeading(title),
            const SizedBox(height: 10),
            Text(
              body,
              style: AppTypography.text1.copyWith(color: AppColors.textInverse),
            ),
            const SizedBox(height: 14),
            KeyedSubtree(
              key: ValueKey('onboarding-visual-$index'),
              child: child,
            ),
          ],
        ),
      ),
    ),
  );
}

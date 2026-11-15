import 'package:asteria_app/features/home/presentation/widgets/bottom_tab_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_bar_geometry.dart';

import '../../../data/models/onboarding_page_model.dart';

import 'package:asteria_app/core/ui_kit/ui_kit.dart';

import 'native_intro_pair.dart';

import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_glass_surface.dart';
import 'package:asteria_app/features/auth/presentation/widgets/auth_flow_widgets.dart';
import 'package:asteria_app/features/compatibility/presentation/widgets/compatibility_layout.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/widgets/day_status_icon.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_section_heading.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/onboarding_pagination_widget.dart';
import 'package:asteria_app/features/scenarios/scenario_sky.dart';

import 'native_intro_audio.dart';
import 'native_tarot_deal.dart';

class OnboardingTour extends StatefulWidget {
  const OnboardingTour({
    super.key,
    required this.pages,
    required this.onComplete,
    required this.onPageChanged,
  });
  final List<OnboardingPageModel> pages;
  final VoidCallback onComplete;
  final ValueChanged<int> onPageChanged;
  @override
  State<OnboardingTour> createState() => _TourState();
}

class _TourState extends State<OnboardingTour> {
  int _index = 0;
  late final _pages = PageController(initialPage: _index);
  bool _choosing = false;

  Future<void> _go(int index) async {
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(index);
    } else {
      await _pages.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _finish() {
    if (_choosing) return;
    setState(() => _choosing = true);
    widget.onComplete();
  }

  @override
  void dispose() {
    _pages.dispose();
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
                        label: context.l10n.introProgress(_index + 1, 4),
                        child: ExcludeSemantics(
                          child: OnboardingPaginationWidget(
                            totalPages: 4,
                            currentPage: _index,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pages,
                        allowImplicitScrolling: false,
                        onPageChanged: (i) {
                          setState(() => _index = i);
                          widget.onPageChanged(i);
                        },
                        children: [
                          _Scene(
                            index: 0,
                            active: _index == 0,
                            title: widget.pages[0].title,
                            body: widget.pages[0].description,
                            child: _Calendar(),
                          ),
                          _Scene(
                            index: 1,
                            active: _index == 1,
                            title: widget.pages[1].title,
                            body: widget.pages[1].description,
                            child: SizedBox(
                              height: (MediaQuery.sizeOf(context).height * .47)
                                  .clamp(250.0, 420.0),
                              child: TickerMode(
                                enabled: _index == 1 && !_choosing,
                                child: NativeIntroAudio(
                                  active: _index == 1 && !_choosing,
                                ),
                              ),
                            ),
                          ),
                          _Scene(
                            index: 2,
                            active: _index == 2,
                            title: widget.pages[2].title,
                            body: widget.pages[2].description,
                            child: _Pair(),
                          ),
                          _Scene(
                            index: 3,
                            active: _index == 3,
                            title: widget.pages[3].title,
                            body: widget.pages[3].description,
                            child: _Deal(active: _index == 3 && !_choosing),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: AuthGradientButton(
                        text: _index == 3
                            ? context.l10n.introStart
                            : context.l10n.next,
                        onPressed: _index == 3
                            ? _finish
                            : () => _go(_index + 1),
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

class _Scene extends StatelessWidget {
  const _Scene({
    required this.index,
    required this.active,
    required this.title,
    required this.body,
    required this.child,
  });
  final int index;
  final bool active;
  final String title, body;
  final Widget child;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    excluding: !active,
    child: ListView(
      key: ValueKey('onboarding-content-$index'),
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 12),
      children: [
        HomeSectionHeading(title),
        const SizedBox(height: 10),
        Text(
          body,
          style: AppTypography.text1.copyWith(color: AppColors.textInverse),
        ),
        const SizedBox(height: 24),
        KeyedSubtree(key: ValueKey('onboarding-visual-$index'), child: child),
      ],
    ),
  );
}

class _Calendar extends StatefulWidget {
  const _Calendar();
  @override
  State<_Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<_Calendar> {
  int date = 1;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(context.l10n.introCalendarExample, style: AppTypography.text1),
      const SizedBox(height: 12),
      ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset(
          'assets/images/onboarding/intro_scissors.webp',
          height: (MediaQuery.sizeOf(context).height * .24).clamp(130.0, 220.0),
          fit: BoxFit.cover,
          alignment: const Alignment(0, -.33),
          excludeFromSemantics: true,
        ),
      ),
      const SizedBox(height: 14),
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < 2; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  selected: date == i,
                  button: true,
                  child: LotusTap(
                    onTap: () => setState(() => date = i),
                    child: HomeGlassSurface(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                DayStatusIcon(
                                  status: i == 0
                                      ? DayStatus.neutral
                                      : DayStatus.favorable,
                                  size: 24,
                                ),
                                const Spacer(),
                                if (date == i)
                                  const Icon(
                                    Icons.check_rounded,
                                    color: AppColorsDark.linkGold,
                                    size: 20,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              i == 0
                                  ? context.l10n.introDateOne
                                  : context.l10n.introDateTwo,
                              style: AppTypography.h3,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              i == 0
                                  ? context.l10n.introNeutral
                                  : context.l10n.introFavorable,
                              style: AppTypography.text1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 18),
      Text(
        date == 0
            ? context.l10n.introNeutralTip
            : context.l10n.introFavorableTip,
        style: AppTypography.text1,
      ),
    ],
  );
}

class _Pair extends StatelessWidget {
  const _Pair();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      CompatibilityGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.introPairExample, style: AppTypography.text1),
            const SizedBox(height: 12),
            IntroPairHero(
              firstDate: DateTime(1995, 5, 13),
              secondDate: DateTime(1994, 5, 22),
              percentage: 74,
            ),
            const SizedBox(height: 16),
            Text(context.l10n.introPairTip, style: AppTypography.text1),
          ],
        ),
      ),
      const SizedBox(height: 16),
      CompatibilityGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.introPairQuestion, style: AppTypography.h3),
            SizedBox(height: 8),
            Text(context.l10n.introPairPrompt, style: AppTypography.text1),
          ],
        ),
      ),
    ],
  );
}

class _Deal extends StatefulWidget {
  const _Deal({required this.active});
  final bool active;
  @override
  State<_Deal> createState() => _DealState();
}

class _DealState extends State<_Deal>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2540),
  );
  bool _reduced = false;
  bool _visible = true;
  bool _foreground = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground) {
      _clock.stop();
    } else if (widget.active && _visible && !_reduced) {
      _clock.forward();
    }
  }

  void _sync() {
    if (!widget.active || _reduced || !_visible || !_foreground) {
      _clock.stop();
      _clock.value = _reduced ? 1 : 0;
    } else {
      _clock.forward(from: 0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    final visible = TickerMode.valuesOf(context).enabled;
    if (!_initialized || reduced != _reduced || visible != _visible) {
      _initialized = true;
      _reduced = reduced;
      _visible = visible;
      _sync();
    }
  }

  @override
  void didUpdateWidget(_Deal old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active) _sync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _clock,
    builder: (_, bubble) => Column(
      children: [
        Semantics(
          container: true,
          button: true,
          label: context.l10n.introReplay,
          onTap: _sync,
          child: LotusTap(
            onTap: _sync,
            child: NativeTarotDeal(seconds: _clock.value * 2.54),
          ),
        ),
        const SizedBox(height: 16),
        Opacity(
          opacity: ((_clock.value * 2.54 - 2.19) / .35).clamp(0.0, 1.0),
          child: bubble,
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ExcludeSemantics(
          child: TickerMode(
            enabled: widget.active,
            child: const AnakraIdleBadge(
              assetPath: 'assets/images/year_animals/horse.webp',
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AnakraGlassSurface(
            side: AnakraBubbleSide.incoming,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                context.l10n.introAnakraMessage,
                style: AppTypography.text1,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

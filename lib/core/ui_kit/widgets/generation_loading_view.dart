import 'dart:async';
import 'dart:math' as math;

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/profile_flow/profile_flow_ui.dart';
import 'package:asteria_app/features/scenarios/scenario_sky.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// One visual language for feature generation, independent of the request lifetime.
class GenerationLoadingView extends StatelessWidget {
  const GenerationLoadingView({
    super.key,
    required this.title,
    required this.phrases,
  });
  final String title;
  final List<String> phrases;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColorsDark.homeCanvas,
    child: Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(child: ScenarioSky()),
        SafeArea(
          child: Column(
            children: [
              ExcludeSemantics(
                child: IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: ProfileFlowHeader(title: title),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: GenerationLoadingContent(
                        phrases: phrases,
                        orbSize: (constraints.maxHeight * .62).clamp(
                          200.0,
                          350.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class GenerationLoadingContent extends StatefulWidget {
  const GenerationLoadingContent({
    super.key,
    required this.phrases,
    this.orbSize = 350,
    this.textChangeDuration = const Duration(seconds: 3),
  });
  final List<String> phrases;
  final double orbSize;
  final Duration textChangeDuration;

  @override
  State<GenerationLoadingContent> createState() =>
      _GenerationLoadingContentState();
}

class _GenerationLoadingContentState extends State<GenerationLoadingContent>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _orbit;
  Timer? _phraseTimer;
  int _index = 0;
  bool _foreground = true;
  bool _motion = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  @override
  void didUpdateWidget(GenerationLoadingContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.phrases, widget.phrases) ||
        oldWidget.textChangeDuration != widget.textChangeDuration) {
      _index = 0;
      _phraseTimer?.cancel();
      _phraseTimer = null;
      _syncMotion();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncMotion();
  }

  void _syncMotion() {
    _motion =
        _foreground &&
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
    if (_motion) {
      if (!_orbit.isAnimating) _orbit.repeat();
      if (widget.phrases.length > 1 && _phraseTimer == null) {
        final interval = widget.textChangeDuration < const Duration(seconds: 2)
            ? const Duration(seconds: 2)
            : widget.textChangeDuration;
        _phraseTimer = Timer.periodic(interval, (_) {
          if (mounted) {
            setState(() => _index = (_index + 1) % widget.phrases.length);
          }
        });
      }
    } else {
      _orbit.stop();
      _phraseTimer?.cancel();
      _phraseTimer = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _phraseTimer?.cancel();
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phrases = widget.phrases.isEmpty
        ? [context.l10n.loading]
        : widget.phrases;
    final text = phrases[_index % phrases.length];
    final style = AppTypography.h1.copyWith(color: AppColors.textInverse);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 390),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textWidth = math.max(1.0, constraints.maxWidth - 32);
          double textHeight = 0;
          for (final phrase in phrases) {
            final painter = TextPainter(
              text: TextSpan(text: phrase, style: style),
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
              locale: Localizations.localeOf(context),
            )..layout(maxWidth: textWidth);
            textHeight = math.max(textHeight, painter.height);
            painter.dispose();
          }
          final size = math.min(widget.orbSize, constraints.maxWidth);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Semantics(
                  liveRegion: true,
                  label: text,
                  child: ExcludeSemantics(
                    child: SizedBox(
                      height: textHeight + 2,
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: _motion
                              ? const Duration(milliseconds: 520)
                              : Duration.zero,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation.drive(
                                  CurveTween(
                                    curve: const Interval(
                                      .5,
                                      1,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                                ),
                                child: child,
                              ),
                          child: Text(
                            text,
                            key: ValueKey(text),
                            style: style,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              ExcludeSemantics(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _orbit,
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (bounds) => const RadialGradient(
                        colors: [
                          Colors.white,
                          Colors.white,
                          Colors.transparent,
                        ],
                        stops: [0, .64, 1],
                      ).createShader(bounds),
                      child: Image.asset(
                        'assets/images/loading/figma_sphere.png',
                        width: size,
                        height: size,
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      ),
                    ),
                    builder: (context, child) {
                      final phase = _motion ? _orbit.value * math.pi * 2 : 0.0;
                      return Transform.translate(
                        offset: Offset(0, math.sin(phase * 3) * 3),
                        child: Transform.rotate(angle: phase, child: child),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

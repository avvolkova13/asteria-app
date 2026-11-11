import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/features/scenarios/scenario_sky.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/auth/presentation/widgets/auth_flow_widgets.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_section_heading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'scenario_card_grid.dart' show ScenarioMood;

part 'scenario_choice_clouds.dart';

void scenarioHome(BuildContext context) {
  final router = GoRouter.of(context);
  context.read<HomeCubit>().changeTab(0);
  Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
  router.go(HomeRoute.routeName);
}

class ScenarioPage extends StatelessWidget {
  const ScenarioPage({
    super.key,
    required this.title,
    required this.child,
    this.background,
    this.scrollable = true,
    this.footer,
    this.showBack = true,
  });
  final String title;
  final Widget child;
  final Widget? background;
  final bool scrollable;
  final Widget? footer;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final back = showBack && Navigator.canPop(context);
    final darkTheme = Theme.of(context).copyWith(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      textTheme: Theme.of(context).textTheme.apply(
        bodyColor: AppColors.textInverse,
        displayColor: AppColors.textInverse,
      ),
    );
    return Theme(
      data: darkTheme,
      child: AuthFlowScaffold(
        background: background ?? const ScenarioSky(),
        backgroundOpacity: .25,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (back)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: LotusButtons.icon(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).backButtonTooltip,
                      onPressed: () => Navigator.maybePop(context),
                      icon: const LotusArrowBubble(back: true),
                    ),
                  ),
                if (!back) const SizedBox(height: 24),
                Expanded(
                  child: scrollable
                      ? ListView(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          children: [
                            HomeSectionHeading(title).withEntrance(),
                            const SizedBox(height: 24),
                            child,
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            HomeSectionHeading(title).withEntrance(),
                            const SizedBox(height: 12),
                            Expanded(child: child),
                          ],
                        ),
                ),
                if (footer != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: footer,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ScenarioTile extends StatelessWidget {
  const ScenarioTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.art,
  });
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final String? art;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        child: HomeGlassSurface(
          child: Material(
            color: Colors.transparent,
            child: LotusInkTap(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    if (art != null) ...[
                      ExcludeSemantics(
                        child: LotusRasterIcon(
                          art!,
                          width: 50,
                          height: 56,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.text1SemiBold.copyWith(
                              color: AppColors.textInverse,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 5),
                            Text(
                              subtitle!,
                              style: AppTypography.text2.copyWith(
                                color: AppColors.cardTinted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const ClayIcon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.cardTinted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Introductory artwork sits on the page sky, above the actionable choices.
class ScenarioChoiceHero extends StatelessWidget {
  const ScenarioChoiceHero({
    super.key,
    required this.description,
    required this.art,
  });

  final String description;
  final String art;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (MediaQuery.textScalerOf(context).scale(16) <= 22) ...[
        LotusRasterIcon(
          art,
          width: 84,
          height: 84,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
        const SizedBox(width: 16),
      ],
      Expanded(
        child: Text(
          description,
          style: AppTypography.text1.copyWith(
            color: AppColors.cardTinted,
            height: 1.35,
          ),
        ),
      ),
    ],
  );
}

class ScenarioChoiceGrid extends StatelessWidget {
  const ScenarioChoiceGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      const gap = 12.0;
      final paired =
          bounds.maxWidth >= 276 &&
          MediaQuery.textScalerOf(context).scale(16) <= 22;
      final columns = paired ? 2 : 1;
      Widget tile(int i, {required bool full}) => _ChoicePosition(
        index: i,
        width: full ? bounds.maxWidth : (bounds.maxWidth - gap) / 2,
        child: children[i],
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i += columns) ...[
            if (i != 0) const SizedBox(height: gap),
            if (!paired || i + 1 == children.length)
              tile(i, full: true)
            else
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: tile(i, full: false)),
                    const SizedBox(width: gap),
                    Expanded(child: tile(i + 1, full: false)),
                  ],
                ),
              ),
          ],
        ],
      );
    },
  );
}

class _ChoicePosition extends InheritedWidget {
  const _ChoicePosition({
    required this.index,
    required this.width,
    required super.child,
  });
  final int index;
  final double width;

  @override
  bool updateShouldNotify(_ChoicePosition oldWidget) =>
      index != oldWidget.index || width != oldWidget.width;
}

class ScenarioChoiceCard extends StatefulWidget {
  const ScenarioChoiceCard({
    super.key,
    required this.title,
    required this.art,
    required this.onTap,
    this.subtitle,
    this.selected = false,
    this.tint,
    this.wide = false,
  });

  final String title, art;
  final String? subtitle;
  final VoidCallback onTap;
  final bool selected, wide;
  final Color? tint;

  @override
  State<ScenarioChoiceCard> createState() => _ScenarioChoiceCardState();
}

class _ScenarioChoiceCardState extends State<ScenarioChoiceCard>
    with SingleTickerProviderStateMixin {
  late final _motion = AnimationController(vsync: this)
    ..addStatusListener(_onMotion);
  Timer? _rest;
  bool _active = false;
  bool _arriving = true;
  bool _hasEntered = false;
  int _order = 0;
  late int _seed;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _seed = widget.art.codeUnits.fold<int>(
      7,
      (value, unit) => (value * 31 + unit) % 65521,
    );
    _order =
        context.dependOnInheritedWidgetOfExactType<_ChoicePosition>()?.index ??
        0;
    final active =
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled &&
        (ModalRoute.isCurrentOf(context) ?? true);
    if (active == _active) return;
    _active = active;
    _rest?.cancel();
    if (!active) {
      _motion.stop();
      return;
    }
    if (!_hasEntered) {
      _hasEntered = true;
      _motion.duration = Duration(milliseconds: 400 + _order * 55);
      _motion.forward(from: 0);
    } else {
      _arriving = false;
      _motion.value = 0;
      _scheduleDrift();
    }
  }

  void _onMotion(AnimationStatus status) {
    if (status == AnimationStatus.completed && _active) _scheduleDrift();
  }

  void _scheduleDrift() {
    _rest?.cancel();
    _rest = Timer(
      Duration(milliseconds: (_arriving ? 2000 : 9600) + _seed % 3400),
      () {
        if (!mounted || !_active) return;
        _arriving = false;
        _motion.duration = Duration(milliseconds: 4200 + _seed % 1800);
        _motion.forward(from: 0);
      },
    );
  }

  @override
  void dispose() {
    _rest?.cancel();
    _motion.dispose();
    super.dispose();
  }

  double get _drift => !_active || _arriving
      ? 0
      : math.pow(math.sin(math.pi * _motion.value), 2).toDouble();

  @override
  Widget build(BuildContext context) {
    final slot = context.dependOnInheritedWidgetOfExactType<_ChoicePosition>();
    final width = slot?.width ?? MediaQuery.sizeOf(context).width - 32;
    final largeType = MediaQuery.textScalerOf(context).scale(16) > 22;
    final horizontal = widget.wide && !largeType;
    final compact = !widget.wide && width < 152;
    const moods = [
      ScenarioMood.calendar,
      ScenarioMood.strength,
      ScenarioMood.practice,
      ScenarioMood.relationships,
    ];
    final mood = slot == null
        ? ScenarioMood.practice
        : moods[_order % moods.length];
    final inset = compact ? 12.0 : 16.0;
    final artWidth = horizontal
        ? (width * .42).clamp(99.0, 172.0)
        : (width * .77).clamp(94.0, 162.0);
    final artHeight = horizontal
        ? 126.0
        : largeType
        ? 94.0
        : (width * .59).clamp(87.0, 129.0);
    final art = AnimatedBuilder(
      animation: _motion,
      child: RepaintBoundary(
        child: LotusRasterIcon(
          widget.art,
          width: artWidth,
          height: artHeight,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
      ),
      builder: (context, child) {
        final delay = 55 * _order;
        final entrance = _active && _arriving
            ? Curves.easeOutCubic.transform(
                ((_motion.value * (400 + delay) - delay) / 400).clamp(0.0, 1.0),
              )
            : 1.0;
        return Transform.translate(
          offset: Offset((_seed.isEven ? 1.4 : -1.4) * _drift, -2 * _drift),
          child: Transform.scale(scale: .95 + .05 * entrance, child: child),
        );
      },
    );
    final label = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: (compact ? AppTypography.h4 : AppTypography.h3).copyWith(
            color: AppColors.textInverse,
          ),
        ),
        if (widget.subtitle case final caption?) ...[
          const SizedBox(height: 6),
          Text(
            caption,
            style: AppTypography.text2.copyWith(
              color: AppColors.textInverse,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
    const radius = BorderRadius.all(Radius.circular(AsteriaCardRadii.card));
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: widget.selected ? true : null,
        child: Material(
          color: Colors.transparent,
          child: LotusInkTap(
            onTap: widget.onTap,
            borderRadius: radius,
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _ChoiceClouds(
                          mood: mood,
                          accent: widget.tint,
                          seed: _seed,
                          wide: horizontal,
                          motion: _motion,
                          drift: () => _drift,
                        ),
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: horizontal ? 152 : width.clamp(124.0, 220.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(inset, 9, inset, inset),
                      child: horizontal
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(child: label),
                                const SizedBox(width: 6),
                                art,
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(child: art),
                                const SizedBox(height: 5),
                                label,
                              ],
                            ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: CardLensDecoration(
                          borderRadius: radius,
                          intensity: .64,
                          border: widget.selected
                              ? Border.all(
                                  color: AppColors.textInverse,
                                  width: 1.5,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  if (widget.selected)
                    Positioned(
                      top: 10,
                      right: 11,
                      child: ExcludeSemantics(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: mood.ground,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(3),
                            child: ClayIcon(
                              Icons.check_rounded,
                              size: 16,
                              color: AppColors.textInverse,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

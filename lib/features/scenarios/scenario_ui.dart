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
      final columns =
          bounds.maxWidth >= 276 &&
              MediaQuery.textScalerOf(context).scale(16) <= 22
          ? 2
          : 1;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i += columns) ...[
            if (i != 0) const SizedBox(height: gap),
            if (columns == 1 || i + 1 == children.length)
              children[i]
            else
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: children[i]),
                    const SizedBox(width: gap),
                    Expanded(child: children[i + 1]),
                  ],
                ),
              ),
          ],
        ],
      );
    },
  );
}

class ScenarioChoiceCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final accent = tint ?? const Color(0xFFBDA4E3);
    final horizontal = wide && MediaQuery.textScalerOf(context).scale(16) <= 22;
    final titleStyle = !wide && MediaQuery.sizeOf(context).width < 350
        ? AppTypography.h4
        : AppTypography.h3;
    const radius = BorderRadius.all(Radius.circular(AsteriaCardRadii.card));
    final illustration = LotusRasterIcon(
      art,
      width: horizontal ? 94 : 82,
      height: horizontal ? 86 : 70,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: titleStyle.copyWith(color: AppColors.textInverse)),
        if (subtitle case final caption?) ...[
          const SizedBox(height: 6),
          Text(
            caption,
            style: AppTypography.text2.copyWith(
              color: AppColors.cardTinted,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected ? true : null,
        child: ClipRRect(
          borderRadius: radius,
          child: DecoratedBox(
            decoration: CardLensDecoration(
              borderRadius: radius,
              gradient: RadialGradient(
                center: horizontal
                    ? const Alignment(.77, -.8)
                    : const Alignment(.6, -.8),
                radius: 1.85,
                colors: [
                  Color.alphaBlend(
                    accent.withValues(alpha: selected ? .43 : .28),
                    AppColors.textPrimary,
                  ),
                  Color.alphaBlend(
                    accent.withValues(alpha: selected ? .20 : .11),
                    AppColors.textPrimary,
                  ),
                  AppColors.textPrimary,
                ],
              ),
              border: selected
                  ? Border.all(color: accent.withValues(alpha: .88), width: 1.5)
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: LotusInkTap(
                onTap: onTap,
                borderRadius: radius,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: horizontal
                          ? Row(
                              children: [
                                Expanded(child: text),
                                const SizedBox(width: 12),
                                illustration,
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: illustration,
                                ),
                                const SizedBox(height: 10),
                                text,
                              ],
                            ),
                    ),
                    if (selected)
                      Positioned(
                        top: 10,
                        left: horizontal ? null : 12,
                        right: horizontal ? 12 : null,
                        child: ExcludeSemantics(
                          child: ClayIcon(
                            Icons.check_rounded,
                            size: 18,
                            color: accent,
                          ),
                        ),
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

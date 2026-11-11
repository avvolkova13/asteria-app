import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/auth/presentation/widgets/auth_flow_widgets.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_section_heading.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void scenarioHome(BuildContext context) {
  final router = GoRouter.of(context);
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
        background: background,
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
                      icon: const LotusIconSurface(
                        child: ClayIcon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 24,
                          color: AppColors.textInverse,
                        ),
                      ),
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

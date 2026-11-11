import 'package:asteria_app/features/scenarios/scenario_sky.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CompatibilityLayout extends StatelessWidget {
  final Widget child;
  final bool resizeToAvoidBottomInset;
  final bool showRequestsBadge;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics physics;

  const CompatibilityLayout({
    super.key,
    required this.child,
    this.resizeToAvoidBottomInset = false,
    this.showRequestsBadge = true,
    this.padding = const EdgeInsets.fromLTRB(14, 24, 14, 28),
    this.physics = const ClampingScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.textPrimary,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (ScenarioSkyScope.of(context)) const ScenarioSky() else const _CompatibilityStarBackground().withEntrance(),
            CustomScrollView(
              physics: physics,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  floating: false,
                  delegate: TopNavBarDelegate(
                    userName: context.l10n.compatibilityTitle,
                    type: TopNavBarType.transparent,
                    canPop: true,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: padding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showRequestsBadge) ...[
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: CompatibilityRequestsBadge(),
                          ).withEntrance(),
                          const SizedBox(height: 28),
                        ],
                        child,
                        SizedBox(
                          height: MediaQuery.paddingOf(context).bottom + 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CompatibilityRequestsBadge extends StatelessWidget {
  const CompatibilityRequestsBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MonetizationProvider>(
      builder: (context, monetizationProvider, child) {
        if (monetizationProvider.effectivePro) return const SizedBox.shrink();
        final requestsLeft = monetizationProvider.requestsLeft('compatibility');

        return IntrinsicWidth(
          child: Container(
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB45E),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              context.l10n.requestsLeftCount(requestsLeft),
              style: context.textTheme.urbanistRegular12.copyWith(
                color: AppColors.textPrimary,
                height: 1,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CompatibilityStarBackground extends StatelessWidget {
  const _CompatibilityStarBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CompatibilityStarPainter(),
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0A18), Color(0xFF120B1D), Color(0xFF332B58)],
            stops: [0, 0.44, 1],
          ),
        ),
      ),
    );
  }
}

class _CompatibilityStarPainter extends CustomPainter {
  static const _stars = <Offset>[
    Offset(0.11, 0.22),
    Offset(0.27, 0.17),
    Offset(0.43, 0.28),
    Offset(0.62, 0.14),
    Offset(0.74, 0.25),
    Offset(0.91, 0.18),
    Offset(0.16, 0.43),
    Offset(0.48, 0.39),
    Offset(0.73, 0.48),
    Offset(0.82, 0.67),
    Offset(0.43, 0.74),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()..color = AppColors.white.withValues(alpha: 0.36);
    final accentPaint = Paint()
      ..color = const Color(0xFFFFF1B8).withValues(alpha: 0.46);

    for (var i = 0; i < _stars.length; i++) {
      final point = Offset(
        _stars[i].dx * size.width,
        _stars[i].dy * size.height,
      );
      final radius = i.isEven ? 1.3 : 2.4;
      canvas.drawCircle(point, radius, i % 3 == 0 ? accentPaint : starPaint);
    }

    final hazePaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFFEEEAFD).withValues(alpha: 0.16),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.5, size.height * 0.83),
              radius: size.width * 0.62,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.83),
      size.width * 0.62,
      hazePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CompatibilityGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;

  const CompatibilityGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: text,
      child: ExcludeSemantics(
        child: LotusTap(
          onTap: enabled ? onPressed : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: enabled ? 1 : 0.68,
            child: Container(
              height: height,
              alignment: Alignment.center,
              decoration: CardLensDecoration.button(
                enabled: enabled,
                borderRadius: BorderRadius.circular(16),
                gradient: enabled
                    ? const LinearGradient(
                        colors: [Color(0xFF7C4DFF), Color(0xFF5436D9)],
                      )
                    : null,
                color: enabled ? null : const Color(0xFF3B2E7B),
              ),
              child: Text(
                text,
                style: context.textTheme.inverseUrbanistRegular16.copyWith(
                  color: enabled
                      ? AppColors.white
                      : AppColors.white.withValues(alpha: 0.64),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CompatibilityGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Border? border;
  final BorderRadius borderRadius;
  final Gradient? gradient;

  const CompatibilityGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.border,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AsteriaCardRadii.tile),
    ),
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: CardLensDecoration(
        borderRadius: borderRadius,
        gradient:
            gradient ??
            const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x663E2F58), Color(0xAA4B3B74)],
            ),
        border:
            border ??
            Border.all(color: AppColors.white.withValues(alpha: 0.28)),
      ),
      child: child,
    );
  }
}

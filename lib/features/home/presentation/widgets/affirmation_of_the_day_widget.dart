import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/features/scenarios/scenario_card_grid.dart'
    show ScenarioMood;
import 'package:flutter/material.dart';

class AffirmationOfTheDayWidget extends StatelessWidget {
  const AffirmationOfTheDayWidget({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Semantics(
      button: true,
      child: LotusTap(
        onTap: () => AffirmationRoute.push(context),
        child: _AffirmationSurface(
          text: text,
          footer: Row(
            children: [
              Flexible(
                child: Text(
                  context.l10n.allAffirmations,
                  style: AppTypography.link.copyWith(
                    color: ScenarioMood.practice.rim,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ExcludeSemantics(
                child: ClayIcon(
                  Icons.chevron_right,
                  size: 18,
                  color: ScenarioMood.practice.rim,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class AffirmationUnavailableWidget extends StatelessWidget {
  const AffirmationUnavailableWidget({
    super.key,
    required this.isLoading,
    required this.onRetry,
  });

  final bool isLoading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Semantics(
      container: true,
      liveRegion: true,
      child: _AffirmationSurface(
        text: isLoading
            ? context.l10n.affirmationLoading
            : context.l10n.affirmationLoadError,
        footer: isLoading
            ? ExcludeSemantics(
                child: SizedBox.square(
                  dimension: 23,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ScenarioMood.practice.rim,
                  ),
                ),
              )
            : LotusButtons.text(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  minimumSize: const Size(44, 44),
                  padding: EdgeInsets.zero,
                  foregroundColor: ScenarioMood.practice.rim,
                ),
                child: Text(
                  context.l10n.commonRetry,
                  semanticsLabel: context.l10n.affirmationRetryLabel,
                  style: AppTypography.link,
                ),
              ),
      ),
    ),
  );
}

class _AffirmationSurface extends StatelessWidget {
  const _AffirmationSurface({required this.text, required this.footer});

  final String text;
  final Widget footer;

  static const _radius = BorderRadius.all(Radius.circular(26));
  static const _mood = ScenarioMood.practice;
  static const _lotus = 'assets/images/affirmation/lavender-clay-lotus.webp';

  @override
  Widget build(BuildContext context) {
    final title = Text(
      context.l10n.affirmationOfDay,
      style: AppTypography.h3.copyWith(color: AppColors.textInverse),
    );
    final quote = Text(
      text,
      style: AppTypography.text1.copyWith(color: AppColors.cardTinted),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: _radius,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [_mood.rim, _mood.ground, _mood.mist.withValues(alpha: .65)],
          stops: const [0, .62, 1],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.25),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius:
                _radius - const BorderRadius.all(Radius.circular(1.25)),
            gradient: RadialGradient(
              center: const Alignment(.79, -.72),
              radius: 1.24,
              colors: [
                Color.lerp(_mood.mist, _mood.ground, .28)!,
                _mood.ground,
                Color.lerp(_mood.ground, AppColorsDark.homeCanvas, .60)!,
              ],
              stops: const [0, .51, 1],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wideQuote =
                    constraints.maxWidth < 290 ||
                    MediaQuery.textScalerOf(context).scale(16) > 20 ||
                    text.length > 90;
                final art = LotusRasterIcon(
                  _lotus,
                  width: wideQuote ? 86 : 116,
                  height: wideQuote ? 57 : 78,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                );
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              title,
                              if (!wideQuote) ...[
                                const SizedBox(height: 10),
                                quote,
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        art,
                      ],
                    ),
                    if (wideQuote) ...[const SizedBox(height: 10), quote],
                    const SizedBox(height: 16),
                    footer,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

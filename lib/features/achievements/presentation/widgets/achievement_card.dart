import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'dart:ui' as ui;
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/static_glass_surface.dart';
import 'package:asteria_app/features/achievements/presentation/achievements_style.dart';
import 'package:flutter/material.dart';

class AchievementCard extends StatelessWidget {
  const AchievementCard({
    super.key,
    required this.id,
    required this.title,
    required this.completedCount,
    required this.totalCount,
    required this.imageAsset,
    this.imageSize = const Size(53, 80),
  }) : assert(totalCount > 0);

  final String id;
  final String title;
  final int completedCount;
  final int totalCount;
  final String imageAsset;
  final Size imageSize;
  bool get isLocked => completedCount <= 0;

  @override
  Widget build(BuildContext context) {
    final tablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    final completed = completedCount.clamp(0, totalCount);
    final remaining = context.l10n.achievementRemaining(
      totalCount - completed,
      totalCount,
    );
    return Semantics(
      container: true,
      label: isLocked ? context.l10n.achievementLocked(title) : title,
      value: remaining,
      child: ExcludeSemantics(
        child: StaticGlassSurface(
          radius: AsteriaCardRadii.tile,
          tint: AchievementsStyle.card,
          child: Padding(
            padding: EdgeInsets.all(tablet ? 18 : 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stackContent =
                    tablet ||
                    constraints.maxWidth <
                        MediaQuery.textScalerOf(context).scale(20) * 15;
                final artwork = Align(
                  alignment: Alignment.topCenter,
                  child: _Artwork(
                    imageAsset: imageAsset,
                    imageSize: tablet ? imageSize * 1.65 : imageSize,
                    extent: tablet ? 174 : 112,
                    isLocked: isLocked,
                  ),
                );
                final content = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: AchievementsStyle.title),
                    const SizedBox(height: 16),
                    AsteriaEntrance(
                      replayKey: completed,
                      animateInitially: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            key: ValueKey('achievement-progress-$id'),
                            children: [
                              for (var i = 0; i < totalCount; i++) ...[
                                Expanded(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: i < completed
                                          ? AchievementsStyle.accent
                                          : null,
                                      color: i < completed
                                          ? null
                                          : AchievementsStyle.imageBackground,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: const SizedBox(height: 4),
                                  ),
                                ),
                                if (i < totalCount - 1)
                                  const SizedBox(width: 2),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback:
                                AchievementsStyle.accent.createShader,
                            child: Text(
                              remaining,
                              style: AchievementsStyle.progress,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
                if (stackContent) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [artwork, const SizedBox(height: 12), content],
                  );
                }
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      artwork,
                      const SizedBox(width: 8),
                      Expanded(child: content),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({
    required this.imageAsset,
    required this.imageSize,
    required this.extent,
    required this.isLocked,
  });
  final String imageAsset;
  final Size imageSize;
  final bool isLocked;
  final double extent;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(AsteriaCardRadii.compact),
    child: SizedBox.square(
      dimension: extent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            imageAsset,
            frameBuilder: AsteriaEntrance.imageFrame,
            width: imageSize.width,
            height: imageSize.height,
            fit: BoxFit.contain,
          ),
          if (isLocked) ...[
            Positioned.fill(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: ColoredBox(
                  color: AppColorsDark.homeCanvas.withValues(alpha: 0.60),
                ),
              ),
            ),
            ClayAssetIcon(
              'assets/icons/white_lock_icon.svg',
              width: 26,
              height: 28,
              tint: AppColors.white,
            ),
          ],
        ],
      ),
    ),
  );
}

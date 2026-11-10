import 'dart:ui' as ui;
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/static_glass_surface.dart';
import 'package:asteria_app/features/achievements/presentation/achievements_style.dart';
import 'package:asteria_app/features/profile_flow/profile_flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          radius: 16,
          tint: AchievementsStyle.card,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: _Artwork(
                      imageAsset: imageAsset,
                      imageSize: imageSize,
                      isLocked: isLocked,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: AchievementsStyle.title),
                        const SizedBox(height: 16),
                        Column(
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
                      ],
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

class _Artwork extends StatelessWidget {
  const _Artwork({
    required this.imageAsset,
    required this.imageSize,
    required this.isLocked,
  });
  final String imageAsset;
  final Size imageSize;
  final bool isLocked;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(32),
    child: SizedBox.square(
      dimension: 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(
            child: ColoredBox(color: AchievementsStyle.imageBackground),
          ),
          Image.asset(
            imageAsset,
            width: imageSize.width,
            height: imageSize.height,
            fit: BoxFit.contain,
          ),
          if (isLocked) ...[
            Positioned.fill(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: const ColoredBox(color: Color(0x1AFFFFFF)),
              ),
            ),
            SvgPicture.asset(
              'assets/icons/white_lock_icon.svg',
              width: 26,
              height: 28,
              colorFilter: const ColorFilter.mode(
                ProfileFlowColors.purple,
                BlendMode.srcIn,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

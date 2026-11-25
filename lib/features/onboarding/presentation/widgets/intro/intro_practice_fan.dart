import 'dart:math' as math;

import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/features/affirmation/player/body_motion_artwork.dart';
import 'package:asteria_app/features/affirmation/player/player_artwork.dart'
    show PracticeScene;
import 'package:asteria_app/features/affirmation/player/player_subject_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'intro_story.dart';

/// Three illustrated covers orbit on the story clock. The rear cover passes
/// behind its neighbours when it returns to the other side of the fan.
class IntroPracticeFan extends StatelessWidget {
  const IntroPracticeFan({
    super.key,
    required this.cursor,
    required this.time,
    required this.still,
    required this.covers,
  }) : assert(covers.length == 3);

  final double cursor;
  final double time;
  final bool still;
  final List<({String title, String art})> covers;

  // The plum, rose and dusk finishes of the original illustrated shelf.
  static const _finishes = [
    [Color(0xFF855B8C), Color(0xFF33283D)],
    [Color(0xFF9A646E), Color(0xFF432A41)],
    [Color(0xFFB47B72), Color(0xFF4A314D)],
  ];

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 740;
    final angles = List.generate(3, (i) => (i - cursor) * 2 * math.pi / 3);
    final depths = [for (final angle in angles) (1 + math.cos(angle)) / 2];
    final order = [0, 1, 2]..sort((a, b) => depths[a].compareTo(depths[b]));
    return LayoutBuilder(
      builder: (context, bounds) {
        final spread = math.min(bounds.maxWidth, 440.0);
        final width = spread * .49;
        final height = math.min(width * .94, compact ? 86.0 : 142.0);
        // Leave room for the slanted outer rim throughout the orbit.
        double horizontalOffset(int i) {
          final tilt = math.sin(angles[i]) * .115;
          final scale = .73 + .27 * depths[i];
          final paintedWidth =
              scale * (width * math.cos(tilt) + height * math.sin(tilt).abs());
          return math.sin(angles[i]) * (spread - paintedWidth - 8) / 2;
        }

        return SizedBox(
          width: double.infinity,
          height: height + (compact ? 10 : 18),
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (final i in order)
                Transform.translate(
                  key: ValueKey(covers[i].art),
                  offset: Offset(horizontalOffset(i), (1 - depths[i]) * 9),
                  child: StoryEntrance(
                    time: time,
                    start: .15 + i * .07,
                    child: Transform.rotate(
                      angle: math.sin(angles[i]) * .115,
                      child: Transform.scale(
                        scale: .73 + .27 * depths[i],
                        child: Semantics(
                          image: true,
                          selected: i == cursor.round(),
                          label: covers[i].title,
                          sortKey: OrdinalSortKey(i.toDouble()),
                          child: Container(
                            key: ValueKey('intro-practice-cover-$i'),
                            width: width,
                            height: height,
                            padding: EdgeInsets.symmetric(
                              horizontal: compact ? 3 : 9,
                              vertical: compact ? 2 : 5,
                            ),
                            decoration: CardLensDecoration(
                              borderRadius: BorderRadius.circular(
                                AsteriaCardRadii.tile,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: _finishes[i],
                              ),
                              border: Border.all(
                                color: Color.lerp(
                                  AppColorsDark.textSecondary.withValues(
                                    alpha: .28,
                                  ),
                                  AppColorsDark.linkGold.withValues(alpha: .92),
                                  depths[i] * depths[i],
                                )!,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                  color: AppColorsDark.homeCanvas.withValues(
                                    alpha: .4,
                                  ),
                                ),
                              ],
                            ),
                            child:
                                PlayerSubjectMotion.forAsset(covers[i].art) ==
                                    PlayerSubjectMotion.workday
                                ? BodyMotionArtwork(
                                    motion: PlayerSubjectMotion.workday,
                                    phase:
                                        2 *
                                        math.pi *
                                        (still ? 0 : time) /
                                        PracticeScene.dusk.period,
                                  )
                                : Image.asset(
                                    covers[i].art,
                                    fit: BoxFit.contain,
                                    excludeFromSemantics: true,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

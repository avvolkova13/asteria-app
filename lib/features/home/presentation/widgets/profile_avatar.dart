import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/features/profile_avatar/avatar_catalog.dart';
import 'package:asteria_app/features/profile_avatar/avatar_preferences.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.size,
    this.gender,
    this.userId,
    this.presetId,
    this.preferences,
  });

  final double size;
  final Gender? gender;
  final String? userId;
  final String? presetId;
  final AvatarPreferences? preferences;

  @override
  Widget build(BuildContext context) {
    final store = preferences ?? AvatarPreferences.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final preset = presetId == null
            ? store.selectedFor(userId, gender)
            : AvatarPreset.resolve(presetId, gender);
        final radius = LotusPebbleContour.bookmark.resolve(size, size);
        final inset = (size * .055).clamp(1.4, 5.0);
        return SizedBox.square(
          dimension: size,
          child: Container(
            decoration: CardLensDecoration(
              borderRadius: radius,
              intensity: .5,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0x55F4D8EC),
                  Color(0x227E6AA4),
                  Color(0x55C4B4DD),
                ],
              ),
            ),
            foregroundDecoration: CardLensDecoration(
              borderRadius: radius,
              intensity: .8,
            ),
            padding: EdgeInsets.all(inset),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(-.35, -.55),
                        colors: [Color(0xFFA483B4), Color(0xFF51416D)],
                      ),
                    ),
                  ),
                  Image.asset(
                    preset.assetPath,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                    filterQuality: FilterQuality.medium,
                    cacheWidth: (size * MediaQuery.devicePixelRatioOf(context))
                        .ceil(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

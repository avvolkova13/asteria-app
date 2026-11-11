import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.size, this.gender});

  final double size;
  final Gender? gender;

  @override
  Widget build(BuildContext context) {
    final isMale = gender == Gender.male;
    final inset = (size * .055).clamp(1.4, 5.0);
    final portraitSize = (size - inset * 2).clamp(0.0, size);
    final radius = LotusPebbleContour.bookmark.resolve(size, size);

    return SizedBox.square(
      dimension: size,
      child: Container(
        decoration: CardLensDecoration(
          borderRadius: radius,
          intensity: .5,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x55F4D8EC), Color(0x227E6AA4), Color(0x55C4B4DD)],
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
              Image.asset(
                'assets/images/home/profile_avatar_background.webp',
                fit: BoxFit.cover,
                excludeFromSemantics: true,
              ),
              Positioned(
                // Match the portraits' headroom within the glass rim.
                top: isMale ? -portraitSize * .19 : 0,
                left: isMale ? portraitSize * .01 : 0,
                width: isMale ? portraitSize * .98 : portraitSize,
                child: Image.asset(
                  isMale
                      ? 'assets/images/home/profile_avatar_male.webp'
                      : 'assets/images/home/profile_avatar_female.webp',
                  fit: BoxFit.fitWidth,
                  excludeFromSemantics: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.size, this.gender});

  final double size;
  final Gender? gender;

  @override
  Widget build(BuildContext context) {
    final isMale = gender == Gender.male;

    return SizedBox.square(
      dimension: size,
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
              // The male source includes more transparent space above the head.
              // Match the portraits' headroom without resizing the source files.
              top: isMale ? -size * 0.19 : 0,
              left: isMale ? size * 0.01 : 0,
              width: isMale ? size * 0.98 : size,
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
    );
  }
}

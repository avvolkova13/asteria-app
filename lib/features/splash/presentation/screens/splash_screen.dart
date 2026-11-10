import 'package:asteria_app/core/ui_kit/app_colors/app_colors.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColorsDark.homeCanvas,
      child: Center(
        child: Image.asset(
          'assets/images/auth/asteria_mark.png',
          width: 104,
          height: 104,
          semanticLabel: 'Asteria',
        ),
      ),
    );
  }
}

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class HomeSectionHeading extends StatelessWidget {
  const HomeSectionHeading(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        title,
        style: AppTypography.h1.copyWith(color: AppColors.textInverse),
      ),
    );
  }
}

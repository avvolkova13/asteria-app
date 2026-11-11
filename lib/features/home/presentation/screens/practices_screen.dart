import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_section_heading.dart';
import 'package:asteria_app/features/home/presentation/widgets/widgets_index.dart';
import 'package:flutter/material.dart';

class PracticesScreen extends StatelessWidget {
  const PracticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.textPrimary,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            const HomeAccountBar(
              showAccountActions: false,
              backgroundColor: AppColors.textPrimary,
            ),
            const SizedBox(height: 26),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: HomeSectionHeading(context.l10n.navPractices),
            ),
            const SizedBox(height: 16),
            const AdvertisingBlockWidget(),
            const SizedBox(height: 32),
            ListenableBuilder(
              listenable: di.get<ContentProvider>(),
              builder: (context, _) => ArticlesSectionWidget(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

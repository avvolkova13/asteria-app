import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        context.l10n.navPractices,
                        style: context.textTheme.inversePlayfairSemiBold24,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => HomeProfileRoute.push(context),
                    icon: const Icon(Icons.person_outline_rounded),
                    label: Text(context.l10n.navProfile),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const EnergyOfTheDayWidget(),
            const SizedBox(height: 32),
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

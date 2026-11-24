import 'package:asteria_app/features/practices/presentation/notes_journal_screen.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/features/home/presentation/widgets/daily_practice_hub.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_section_heading.dart';
import 'package:asteria_app/features/home/presentation/widgets/widgets_index.dart';
import 'package:asteria_app/features/practices/practice_catalog_screen.dart';
import 'package:flutter/material.dart';

class PracticesScreen extends StatelessWidget {
  const PracticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    final openLabel = ru ? 'Открыть' : 'Open';
    final content = di.get<ContentProvider>();
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
            ).withEntrance(),
            const SizedBox(height: 26),
            AsteriaEntrance(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  children: [
                    HomeSectionHeading(context.l10n.navPractices),
                    const NotesJournalLink(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final twoColumns =
                          constraints.maxWidth >= 340 &&
                          MediaQuery.textScalerOf(context).scale(16) <= 20;
                      const meditation = PracticeCategory.meditation;
                      final affirmationsCard = HubEntryCard(
                        compact: true,
                        alignAction: twoColumns,
                        fitCompactTitle: true,
                        title: context.l10n.affirmationsTitle,
                        description: ru
                            ? 'Короткие фразы, к которым хочется возвращаться.'
                            : 'Short phrases worth coming back to.',
                        action: openLabel,
                        art: 'assets/images/scenarios/lotus.webp',
                        onTap: () => AffirmationRoute.push(context),
                      );
                      final meditationCard = HubEntryCard(
                        compact: true,
                        alignAction: twoColumns,
                        fitCompactTitle: true,
                        title: meditation.title(ru),
                        description: meditation.description(ru),
                        action: openLabel,
                        art: meditation.art,
                        onTap: () => openPracticeCatalog(context, meditation),
                      );
                      if (!twoColumns) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            affirmationsCard,
                            const SizedBox(height: 14),
                            meditationCard,
                          ],
                        );
                      }
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: affirmationsCard),
                            const SizedBox(width: 14),
                            Expanded(child: meditationCard),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  HubEntryCard(
                    title: PracticeCategory.body.title(ru),
                    description: PracticeCategory.body.description(ru),
                    action: openLabel,
                    art: PracticeCategory.body.art,
                    onTap: () =>
                        openPracticeCatalog(context, PracticeCategory.body),
                  ),
                  const SizedBox(height: 24),
                  const PracticeToolEntries(),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ListenableBuilder(
              listenable: content,
              builder: (context, _) => ArticlesSectionWidget(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

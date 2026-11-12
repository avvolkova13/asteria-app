import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:flutter/material.dart';
import 'home_glass_surface.dart';

class HubEntryCard extends StatelessWidget {
  const HubEntryCard({
    super.key,
    required this.title,
    required this.description,
    required this.action,
    required this.art,
    required this.onTap,
    this.compact = false,
    this.alignAction = false,
  });
  final String title, description, action, art;
  final VoidCallback onTap;
  final bool compact;
  final bool alignAction;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: HomeGlassSurface(
      child: Material(
        color: Colors.transparent,
        child: LotusInkTap(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (compact)
                  Center(
                    child: Image.asset(
                      art,
                      width: 126,
                      height: 126,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: context.textTheme.inversePlayfairSemiBold24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Image.asset(
                        art,
                        width: 88,
                        height: 88,
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      ),
                    ],
                  ),
                if (compact) ...[
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: context.textTheme.inversePlayfairSemiBold24,
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  description,
                  style: compact
                      ? AppTypography.body14.copyWith(color: AppColors.white)
                      : context.textTheme.inverseUrbanistRegular16,
                ),
                if (alignAction) const Spacer(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        action,
                        style:
                            (compact
                                    ? AppTypography.body14.copyWith(
                                        fontWeight: FontWeight.w600,
                                      )
                                    : context
                                          .textTheme
                                          .inverseUrbanistSemiBold16)
                                .copyWith(color: AppColorsDark.linkGold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const LotusArrowBubble(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class PracticeToolEntries extends StatelessWidget {
  const PracticeToolEntries({super.key});
  @override
  Widget build(BuildContext c) {
    final ru = Localizations.localeOf(c).languageCode == 'ru';
    return LayoutBuilder(
      builder: (c, b) {
        final twoColumns =
            b.maxWidth >= 340 && MediaQuery.textScalerOf(c).scale(16) <= 22;
        final cards = [
          HubEntryCard(
            compact: true,
            alignAction: twoColumns,
            title: ru ? 'Таро' : 'Tarot',
            description: ru
                ? 'Карта дня, расклады и значения карт.'
                : 'Your daily card, spreads and card meanings.',
            action: ru ? 'Открыть' : 'Explore',
            art: 'assets/images/home/practice_tarot_clay.webp',
            onTap: () => TaroCardsRoute.push(c),
          ),
          HubEntryCard(
            compact: true,
            alignAction: twoColumns,
            title: ru ? 'Руны' : 'Runes',
            description: ru
                ? 'Руна дня, расклады и значения рун.'
                : 'Your daily rune, spreads and symbol meanings.',
            action: ru ? 'Открыть' : 'Explore',
            art: 'assets/images/home/practice_runes_clay.webp',
            onTap: () => RunesRoute.push(c),
          ),
        ];
        if (!twoColumns) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [cards[0], const SizedBox(height: 14), cards[1]],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 14),
              Expanded(child: cards[1]),
            ],
          ),
        );
      },
    );
  }
}

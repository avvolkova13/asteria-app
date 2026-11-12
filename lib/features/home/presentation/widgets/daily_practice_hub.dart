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
  });
  final String title, description, action, art;
  final VoidCallback onTap;
  final bool compact;
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
                      height: 100,
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
                  style: context.textTheme.inverseUrbanistRegular16,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        action,
                        style: context.textTheme.inverseUrbanistSemiBold16
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
    final cards = [
      HubEntryCard(
        compact: true,
        title: ru ? 'Таро' : 'Tarot',
        description: ru
            ? 'Карта дня, расклады и знакомство с колодой.'
            : 'Your daily card, spreads and the full deck.',
        action: ru ? 'Открыть Таро' : 'Explore Tarot',
        art: 'assets/images/home/daily_symbol_tarot_back.webp',
        onTap: () => TaroCardsRoute.push(c),
      ),
      HubEntryCard(
        compact: true,
        title: ru ? 'Руны' : 'Runes',
        description: ru
            ? 'Руна дня, расклады и значения символов.'
            : 'Your daily rune, spreads and symbol meanings.',
        action: ru ? 'Открыть руны' : 'Explore runes',
        art: 'assets/images/home/runes_bag.webp',
        onTap: () => RunesRoute.push(c),
      ),
    ];
    return LayoutBuilder(
      builder: (c, b) {
        if (b.maxWidth < 340 || MediaQuery.textScalerOf(c).scale(16) > 22) {
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

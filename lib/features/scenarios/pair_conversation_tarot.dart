import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_activity_indicator.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:asteria_app/features/home/presentation/widgets/tarot_card_of_the_day_widget.dart';
import 'package:flutter/material.dart';

import 'pair_tarot_questions.dart';
import 'scenario_ui.dart';

class PairConversationTarot extends StatefulWidget {
  const PairConversationTarot({super.key});

  @override
  State<PairConversationTarot> createState() => _PairConversationTarotState();
}

class _PairConversationTarotState extends State<PairConversationTarot> {
  late final _content = di.get<ContentProvider>();
  late Future<void>? _load = _content.tarotCards.isEmpty
      ? Future.microtask(_content.loadContent)
      : null;

  Future<void> _openCard() async {
    try {
      await _content.revealTarotOn(DailyTarotScreen.pair);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.genericRefreshError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    return ScenarioPage(
      title: ru ? 'О чём поговорить вдвоём?' : 'What could we talk about?',
      child: FutureBuilder<void>(
        future: _load,
        builder: (context, snapshot) => ListenableBuilder(
          listenable: _content,
          builder: (context, _) {
            if (_content.tarotCards.isEmpty) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: AsteriaActivityIndicator());
              }
              return ErrorScreenWidget(
                error: context.l10n.tarotLoadError,
                onRetry: () => setState(() => _load = _content.loadContent()),
              );
            }

            final card = _content.getTodayTarotCard();
            final opened = _content.isTarotRevealedOn(DailyTarotScreen.pair);
            final prompt = pairTarotQuestions[card.imageName];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  ru
                      ? 'Посмотрите на карту вместе. Прочитайте её значение и по очереди ответьте на вопрос под картой.'
                      : 'Look at the card together. Read its meaning and take turns answering the question below.',
                  style: context.textTheme.inverseUrbanistRegular16,
                ),
                const SizedBox(height: 16),
                TarotCardOfTheDayWidget(
                  tarotCard: card,
                  isOpened: opened,
                  isDarkLayout: true,
                  margin: EdgeInsets.zero,
                  showMoreButton: false,
                  onCardTap: _openCard,
                ),
                if (opened) ...[
                  const SizedBox(height: 16),
                  Semantics(
                    container: true,
                    liveRegion: true,
                    child: HomeGlassSurface(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ru
                                  ? 'Вопрос для вас двоих'
                                  : 'A question for the two of you',
                              style:
                                  context.textTheme.inversePlayfairSemiBold20,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ru
                                  ? prompt?.ru ??
                                        'Что в образе этой карты напомнило тебе о нас?'
                                  : prompt?.en ??
                                        'What about this card reminded you of us?',
                              style: context.textTheme.inverseUrbanistRegular16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

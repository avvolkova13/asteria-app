part of 'relationships_scenario.dart';

class _RelationshipChoices extends StatelessWidget {
  const _RelationshipChoices();

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    const tarot = ScenarioSkyScope(child: PairConversationTarot());

    void open(WidgetBuilder builder) {
      if (ModalRoute.isCurrentOf(context) == true) {
        Navigator.of(context).push<void>(CupertinoPageRoute(builder: builder));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: AsteriaEntrance.sections([
        ScenarioChoiceCard(
          wide: true,
          title: ru ? 'Почему мы спорим?' : 'Why do we disagree?',
          art: 'assets/images/scenarios/conversation.webp',
          onTap: () => open(
            (routeContext) => FreeConflictScenario(
              onOpenTarot: () =>
                  Navigator.of(routeContext).pushReplacement<void, void>(
                    CupertinoPageRoute(builder: (_) => tarot),
                  ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ScenarioChoiceGrid(
          children: [
            ScenarioChoiceCard(
              title: ru ? 'О чём нам поговорить?' : 'What could we talk about?',
              art: 'assets/images/home/practice_tarot_clay.webp',
              onTap: () => open((_) => tarot),
            ),
            ScenarioChoiceCard(
              title: ru
                  ? 'Как сказать, что задело?'
                  : 'How can I say what hurt me?',
              art: 'assets/images/year_animals/horse.webp',
              onTap: () => open((_) => const RelationshipAnakraScenario()),
            ),
          ],
        ),
      ]),
    );
  }
}

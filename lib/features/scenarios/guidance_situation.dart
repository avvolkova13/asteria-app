import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';

typedef _Copy = (String, String);

extension _Language on _Copy {
  String inLocale(bool ru) => ru ? $1 : $2;
}

enum GuidanceSituation {
  decision(
    ('Принять решение', 'Make a decision'),
    'assets/images/scenarios/compass.webp',
    (
      'Представьте, что выбор уже сделан. Какой результат вам больше всего хочется сохранить? Давайте посмотрим, что добавит карта дня.',
      'Imagine you have already decided. Which outcome would you most want to keep? Let’s see what your daily card adds.',
    ),
    (
      'Какой из вариантов ближе к этому образу?',
      'Which option brings this image to mind?',
    ),
  ),
  conversation(
    ('Начать разговор', 'Start a conversation'),
    'assets/images/scenarios/conversation.webp',
    (
      'Вспомните одну вещь, которую хочется сказать, даже если разговор будет коротким. Карта дня поможет подобрать первые слова.',
      'Think of one thing you want to say, even if the conversation is brief. Your daily card can help you find the opening words.',
    ),
    (
      'Как сказать о том, что вам важно, через этот образ?',
      'How could this image help you say what matters?',
    ),
  ),
  beginning(
    ('Сделать первый шаг', 'Take a first step'),
    'assets/icons/clay/key.webp',
    (
      'Что можно попробовать за десять минут? Достаточно начать с маленького действия. Давайте поищем его в карте дня.',
      'What could you try in ten minutes? A small action is enough to begin. Let’s look for one in your daily card.',
    ),
    (
      'Как выглядел бы маленький шаг в духе этой карты?',
      'What would a small step in the spirit of this card look like?',
    ),
  ),
  change(
    ('Освоиться с переменами', 'Adjust to a change'),
    'assets/images/scenarios/lotus.webp',
    (
      'Когда многое меняется, помогает заметить одну знакомую вещь, которая всё ещё с вами. Посмотрим, за что предлагает держаться карта дня.',
      'When a lot is changing, notice one familiar thing that is still with you. Let’s see what your daily card suggests holding on to.',
    ),
    (
      'Что из знакомого поможет вам прожить сегодняшний день?',
      'What familiar thing could steady you today?',
    ),
  );

  const GuidanceSituation(
    this._title,
    this.art,
    this._opening,
    this._reflection,
  );
  final _Copy _title, _opening, _reflection;
  final String art;
  String title(bool ru) => _title.inLocale(ru);
  String opening(bool ru) => _opening.inLocale(ru);

  String nextStep(TarotCardModel card, bool ru) {
    final lens = _suit(card.imageName);
    if (lens == null) return _reflection.inLocale(ru);
    return _steps[this]![lens]!.inLocale(ru);
  }
}

enum _Lens { feelings, action, clarity, resources }

_Lens? _suit(String image) {
  if (image.endsWith('_of_cups')) return _Lens.feelings;
  if (image.endsWith('_of_wands')) return _Lens.action;
  if (image.endsWith('_of_swords')) return _Lens.clarity;
  if (image.endsWith('_of_pentacles')) return _Lens.resources;
  return switch (image) {
    'the_lovers' || 'the_empress' || 'the_star' || 'the_moon' => _Lens.feelings,
    'the_fool' ||
    'the_magician' ||
    'the_chariot' ||
    'strength' ||
    'the_sun' => _Lens.action,
    'justice' ||
    'the_high_priestess' ||
    'the_hermit' ||
    'judgement' ||
    'the_hanged_man' => _Lens.clarity,
    'the_emperor' ||
    'the_hierophant' ||
    'temperance' ||
    'the_world' => _Lens.resources,
    _ => null,
  };
}

const _steps = {
  GuidanceSituation.decision: {
    _Lens.feelings: (
      'Примерьте каждый вариант на один день. При каком решении вам становится спокойнее?',
      'Picture a day with each option. Which decision leaves you feeling more at ease?',
    ),
    _Lens.action: (
      'Устройте маленькую пробу одного из вариантов сегодня. Что вы узнаете из неё до окончательного выбора?',
      'Try a small version of one option today. What could it teach you before you commit?',
    ),
    _Lens.clarity: (
      'Назовите один факт, который изменил бы ваш выбор. Где его можно проверить?',
      'Name one fact that would change your choice. Where could you check it?',
    ),
    _Lens.resources: (
      'Посчитайте, сколько времени и сил потребует каждый вариант на этой неделе. Какой вам по силам?',
      'Estimate the time and energy each option takes this week. Which fits what you have?',
    ),
  },
  GuidanceSituation.conversation: {
    _Lens.feelings: (
      'Начните со слов «Я почувствовала…» или «Я почувствовал…». Затем дайте собеседнику рассказать, как это было для него.',
      'Start with “I felt…” Then give the other person room to describe their experience.',
    ),
    _Lens.action: (
      'Предложите одно небольшое совместное действие. Например, выбрать время и спокойно поговорить вдвоём.',
      'Suggest one small shared action, such as setting aside a quiet time to talk together.',
    ),
    _Lens.clarity: (
      'Вспомните конкретный момент. Начните с того, что заметили, и спросите: «Как это выглядело для тебя?»',
      'Pick a specific moment. Describe what you noticed and ask, “What was it like for you?”',
    ),
    _Lens.resources: (
      'Спросите, какая поддержка пригодилась бы сегодня. Скажите, что именно вы готовы сделать.',
      'Ask what support would help today. Say precisely what you can offer.',
    ),
  },
  GuidanceSituation.beginning: {
    _Lens.feelings: (
      'Выберите ту часть задачи, которая вам по-настоящему любопытна. Дайте себе десять минут на неё.',
      'Choose the part of the task you feel curious about. Give it ten minutes.',
    ),
    _Lens.action: (
      'Сделайте пробный вариант прямо сейчас. Хватит одного абзаца, одного звонка или одного наброска.',
      'Make a first attempt now. One paragraph, one call or one sketch is enough.',
    ),
    _Lens.clarity: (
      'Запишите один вопрос о задаче. Начните с поиска ответа на него.',
      'Write down one question about the task. Start by looking for its answer.',
    ),
    _Lens.resources: (
      'Соберите под рукой всё для первого действия и назначьте ему десять минут в сегодняшнем расписании.',
      'Gather what you need for the first action and give it ten minutes in today’s schedule.',
    ),
  },
  GuidanceSituation.change: {
    _Lens.feelings: (
      'Расскажите кому-то близкому, какого привычного момента вам не хватает. Можно ли вернуть его уже сегодня?',
      'Tell someone close which familiar moment you miss. Could you bring it back today?',
    ),
    _Lens.action: (
      'Выберите одну вещь в новом распорядке, которую сможете попробовать сегодня в своём темпе.',
      'Choose one part of the new routine you could try at your own pace today.',
    ),
    _Lens.clarity: (
      'Назовите одно изменение, которое уже случилось, и одно, которого пока только ждёте. Что требует внимания сегодня?',
      'Name one change that has happened and one you are still anticipating. Which needs your attention today?',
    ),
    _Lens.resources: (
      'Верните в день одну знакомую опору: привычный завтрак, прогулку или звонок в одно и то же время.',
      'Bring one familiar anchor into your day: a usual breakfast, a walk or a call at a regular time.',
    ),
  },
};

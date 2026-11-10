import 'dart:convert';

import 'package:asteria_app/app/data/models/natal_card/natal_card_model.dart';
import 'package:crypto/crypto.dart';

typedef _Copy = (String, String);

extension _Language on _Copy {
  String read(bool russian) => russian ? $1 : $2;
}

enum StrengthArea {
  work(('В работе или учёбе', 'At work or in learning')),
  communication(('В общении', 'In a conversation')),
  beginning(('В новом деле', 'When starting something new'));

  const StrengthArea(this._text);
  final _Copy _text;
  String label(bool ru) => _text.read(ru);
}

enum StrengthTask {
  explain(
    StrengthArea.work,
    ('Объяснить свою идею', 'Explain an idea'),
    (
      'Начните со слов «Представьте, что…». Возьмите один знакомый случай и через него объясните свою мысль.',
      'Start with “Imagine that…”. Use one familiar example to explain your idea.',
    ),
    (
      'Разложите идею на три коротких шага. Сначала покажите, что станет понятно уже после первого.',
      'Break your idea into three short steps. Show what becomes clear after the first one.',
    ),
  ),
  solve(
    StrengthArea.work,
    ('Разобраться в сложной задаче', 'Untangle a difficult task'),
    (
      'Найдите похожую задачу, которую уже решали. Выберите один приём, который можно попробовать снова.',
      'Think of a similar task you have solved. Choose one approach you can try again.',
    ),
    (
      'Разделите задачу на то, что уже известно, и то, что нужно уточнить. Начните с одного открытого вопроса.',
      'Separate what you know from what you need to find out. Start with one open question.',
    ),
  ),
  speak(
    StrengthArea.communication,
    ('Высказать своё мнение', 'Speak your mind'),
    (
      'Опишите один случай, который повлиял на ваше мнение. Затем скажите, какой вывод вы сделали.',
      'Describe one experience that shaped your opinion. Then say what you took away from it.',
    ),
    (
      'Сформулируйте своё мнение в одном предложении. Подкрепите его одним доводом и дайте собеседнику ответить.',
      'State your view in one sentence. Give one reason and leave room for a response.',
    ),
  ),
  help(
    StrengthArea.communication,
    ('Попросить о помощи', 'Ask for help'),
    (
      'Покажите один пример того, где вы застряли. Спросите: «Можешь помочь мне именно с этой частью?»',
      'Show one example of where you got stuck. Ask, “Could you help me with this part?”',
    ),
    (
      'Назовите, что уже сделано, что пока мешает и какая помощь нужна. Сформулируйте одну небольшую просьбу.',
      'Name what you have done, what is getting in the way, and what help you need. Make one small request.',
    ),
  ),
  start(
    StrengthArea.beginning,
    ('Сделать первый шаг', 'Take the first step'),
    (
      'Возьмите знакомый пример того, что хотите создать. Попробуйте воспроизвести одну небольшую часть.',
      'Pick a familiar example of what you want to make. Try recreating one small part.',
    ),
    (
      'Выберите самый маленький шаг, который можно закончить за пять минут. Выполните его до того, как планировать следующий.',
      'Choose the smallest step you can finish in five minutes. Do it before planning the next one.',
    ),
  ),
  settle(
    StrengthArea.beginning,
    ('Освоиться в незнакомой обстановке', 'Find your feet somewhere new'),
    (
      'Заметьте одну вещь, которая напоминает знакомое место. Используйте её как отправную точку для первого действия.',
      'Notice one thing that reminds you of a familiar place. Use it as a starting point for your first action.',
    ),
    (
      'Выясните, куда обратиться с вопросом и что нужно сделать в первую очередь. Начните с этого одного действия.',
      'Find out where to ask questions and what needs doing first. Start with that one action.',
    ),
  );

  const StrengthTask(
    this.area,
    this._text,
    this._exampleAction,
    this._orderedAction,
  );
  final StrengthArea area;
  final _Copy _text;
  final _Copy _exampleAction;
  final _Copy _orderedAction;
  String label(bool ru) => _text.read(ru);
}

enum _Approach { examples, order }

class StrengthTip {
  const StrengthTip({
    required this.task,
    required this.language,
    required this.date,
    required this.situation,
    required this.title,
    required this.action,
    this.natalSource,
    this.daySource,
  });
  final String task, language, situation, title, action;
  final DateTime date;
  final String? natalSource, daySource;

  String get id => sha256
      .convert(
        utf8.encode(
          jsonEncode([
            task,
            language,
            date.year,
            date.month,
            date.day,
            title,
            action,
            natalSource,
            daySource,
          ]),
        ),
      )
      .toString();

  Map<String, dynamic> toJson() => {
    'task': task,
    'language': language,
    'date': date.toIso8601String(),
    'situation': situation,
    'title': title,
    'action': action,
    'natal': natalSource,
    'day': daySource,
  };

  factory StrengthTip.fromJson(Map<dynamic, dynamic> map) => StrengthTip(
    task: map['task'] as String,
    language: map['language'] as String,
    date: DateTime.parse(map['date'] as String),
    situation: map['situation'] as String,
    title: map['title'] as String,
    action: map['action'] as String,
    natalSource: map['natal'] as String?,
    daySource: map['day'] as String?,
  );
}

Iterable<String> _sentences(String text) => text
    .split(RegExp(r'(?<=[.!?])\s+|[\r\n]+'))
    .map((line) => line.trim())
    .where((line) => line.length >= 12 && line.length <= 280);

// Only explicitly affirmative phrases can justify a paraphrased trait. In
// other cases quote the actual positive statement, or give situational advice.
final _positive = RegExp(
  r'^(?:вы (?:умеете|обладаете|способны|легко|хорошо)|вам (?:легко|хорошо) (?:уда[её]тся|да[её]тся)|ваш(?:а|и)? (?:талант|дар|способность|сильная сторона)|you (?:excel at|are skilled at|have a talent for|are able to|are adept at|are good at)|your (?:talent|strength|gift|ability))\s',
  caseSensitive: false,
);
final _negation = RegExp(
  r'(?:^|\s)(?:не|нет|нельзя|боитесь|избегайте|но|хотя|not|never|avoid|but|unless|lack)(?:\s|[,.!?]|$)',
  caseSensitive: false,
);
final _example = RegExp(
  r'объяснять (?:сложное |идеи |мысли )?(?:через|на) пример|объяснять наглядно|подбирать (?:наглядные|понятные) примеры|explain(?:ing)? [^.!?]{0,40}(?:through|with|using) examples|using analogies',
  caseSensitive: false,
);
final _order = RegExp(
  r'структурирова(?:ть|ния)|упорядочива(?:ть|ния)|разбивать (?:сложные |большие )?задачи на|организовывать информацию|организации информации|organi[sz](?:e|ing) (?:complex )?information|break(?:ing)? (?:complex )?(?:ideas|tasks) (?:down |into)',
  caseSensitive: false,
);
final _dialogue = RegExp(
  r'(?:задайте (?:уточняющий )?вопрос|начните (?:с вопроса|диалог)|выслушайте собеседника|спросите собеседника|ask (?:a |one )?(?:clarifying )?question|start (?:with a question|a conversation))',
  caseSensitive: false,
);
final _detail = RegExp(
  r'(?:уделите внимание деталям|сосредоточьтесь на деталях|проверьте детали|обратите внимание на детали|focus on (?:the )?details|check the details|pay attention to detail)',
  caseSensitive: false,
);

StrengthTip buildStrengthTip({
  required StrengthTask task,
  required String language,
  required DateTime date,
  NatalCardInterpretationModel? reading,
  String? todayFocus,
}) {
  final ru = language == 'ru';
  final sections = switch (task.area) {
    StrengthArea.work => [reading?.intellectualArea, reading?.talentArea],
    StrengthArea.communication => [
      reading?.talentArea,
      reading?.intellectualArea,
    ],
    StrengthArea.beginning => [reading?.talentArea, reading?.energyArea],
  };
  final statements = sections
      .whereType<String>()
      .expand(_sentences)
      .where((s) => _positive.hasMatch(s) && !_negation.hasMatch(s));
  String? natal;
  _Approach? approach;
  for (final sentence in statements) {
    natal ??= sentence;
    if (_example.hasMatch(sentence) || _order.hasMatch(sentence)) {
      natal = sentence;
      approach = _example.hasMatch(sentence)
          ? _Approach.examples
          : _Approach.order;
      break;
    }
  }
  final title = switch (approach) {
    _Approach.examples => (
      'Вы умеете объяснять через примеры',
      'You can explain through examples',
    ).read(ru),
    _Approach.order => (
      'Вы умеете упорядочивать сложное',
      'You can bring order to complex ideas',
    ).read(ru),
    null =>
      natal ?? ('Совет по ситуации', 'Advice for this situation').read(ru),
  };
  var action =
      (approach == _Approach.examples
              ? task._exampleAction
              : task._orderedAction)
          .read(ru);
  String? daily;
  if (natal != null) {
    for (final sentence in _sentences(todayFocus ?? '')) {
      if (_negation.hasMatch(sentence)) continue;
      if (_dialogue.hasMatch(sentence) &&
          {
            StrengthTask.explain,
            StrengthTask.speak,
            StrengthTask.help,
          }.contains(task)) {
        daily = sentence;
        action = switch (task) {
          StrengthTask.explain when approach == _Approach.examples => (
            'Спросите: «Вы сталкивались с чем-то похожим?». Возьмите пример собеседника и через него объясните идею.',
            'Ask, “Have you come across something similar?” Use their example to explain the idea.',
          ).read(ru),
          StrengthTask.explain => (
            'Спросите, какая часть идеи уже понятна. Начните с ближайшего к ней шага.',
            'Ask which part is already clear. Explain the next step from there.',
          ).read(ru),
          StrengthTask.help => (
            'Скажите, что уже попробовали, и спросите: «Как бы вы подошли к следующему шагу?»',
            'Say what you have tried, then ask, “How would you approach the next step?”',
          ).read(ru),
          _ => (
            'Коротко выскажите мнение. Спросите: «А что здесь важнее всего для тебя?» Дайте собеседнику ответить.',
            'Share your view briefly. Ask, “What matters most to you here?” Give them time to answer.',
          ).read(ru),
        };
        break;
      }
      if (_detail.hasMatch(sentence) &&
          task.area != StrengthArea.communication) {
        daily = sentence;
        action +=
            ' ${('Выберите одну деталь, от которой зависит результат, и проверьте её.', 'Pick one detail that could change the outcome and check it.').read(ru)}';
        break;
      }
    }
  }
  return StrengthTip(
    task: task.name,
    language: language,
    date: date,
    situation: task.label(ru),
    title: title,
    action: action,
    natalSource: natal,
    daySource: daily,
  );
}

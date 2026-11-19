import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'guidance_situation.dart';
import 'scenario_ui.dart';
import 'scenario_text_field.dart';

typedef _Words = (String, String);

extension on _Words {
  String read(bool ru) => ru ? $1 : $2;
}

extension SituationSummary on GuidanceSituation {
  String exerciseSummary(bool ru) => switch (this) {
    GuidanceSituation.decision => (
      'Сравнить два варианта',
      'Compare two options',
    ),
    GuidanceSituation.conversation => (
      'Подобрать первые слова',
      'Find your opening words',
    ),
    GuidanceSituation.beginning => (
      'План на десять минут',
      'Make a ten-minute plan',
    ),
    GuidanceSituation.change => ('Найти свою опору', 'Find something steady'),
  }.read(ru);
}

class SituationExercise extends StatefulWidget {
  const SituationExercise({super.key, required this.situation});
  final GuidanceSituation situation;

  @override
  State<SituationExercise> createState() => _SituationExerciseState();
}

class _SituationExerciseState extends State<SituationExercise> {
  final first = TextEditingController();
  final second = TextEditingController();
  int? selected;

  @override
  void dispose() {
    first.dispose();
    second.dispose();
    super.dispose();
  }

  void _finish() {
    final exercise = ModalRoute.of(context);
    final nav = Navigator.of(context);
    nav.popUntil((r) => r == exercise || r.isFirst);
    if (exercise?.isFirst == false) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    final a = first.text.trim();
    final b = second.text.trim();
    final choice = selected;
    final step = widget.situation;
    Widget field(TextEditingController controller, _Words label, _Words hint) =>
        ScenarioTextField(
          maxLines: 3,
          textInputAction: TextInputAction.done,
          inputFormatters: [LengthLimitingTextInputFormatter(240)],
          label: label.read(ru),
          hint: hint.read(ru),
          controller: controller,
          onChanged: (_) => setState(() {}),
        );
    final fields = <Widget>[];
    late String action;
    late bool ready;
    late VoidCallback complete;
    void result(_Words title, String text, _Words next, {String? copyText}) =>
        _push(
          context,
          _ExerciseResult(
            title: title.read(ru),
            text: text,
            next: next.read(ru),
            onFinish: _finish,
            copyText: copyText,
          ),
        );
    Widget choices(_Words label, List<_Words> items) => _Choices(
      label: label.read(ru),
      values: items.map((e) => e.read(ru)).toList(),
      value: choice,
      onChanged: (v) => setState(() => selected = v),
    );
    switch (step) {
      case GuidanceSituation.decision:
        fields.addAll([
          field(
            first,
            ('Первый вариант', 'First option'),
            (
              'Например, остаться в своей команде',
              'For example, stay with my team',
            ),
          ),
          field(
            second,
            ('Второй вариант', 'Second option'),
            ('Например, попробовать новую роль', 'For example, try a new role'),
          ),
        ]);
        action = ('Сравнить варианты', 'Compare options').read(ru);
        ready =
            a.isNotEmpty && b.isNotEmpty && a.toLowerCase() != b.toLowerCase();
        if (a.isNotEmpty && a.toLowerCase() == b.toLowerCase()) {
          fields.add(
            Text(
              (
                'Введите два разных варианта.',
                'Enter two different options.',
              ).read(ru),
            ),
          );
        }
        complete = () => _push(
          context,
          _CompareOptions(first: a, second: b, onFinish: _finish),
        );
      case GuidanceSituation.conversation:
        const goals = [
          ('Попросить о помощи', 'Ask for help'),
          ('Обозначить границу', 'Set a boundary'),
          ('Сверить ожидания', 'Compare expectations'),
        ];
        const openings = [
          ('Мне пригодилась бы твоя помощь.', 'I could use your help.'),
          (
            'Хочу сказать, где для меня проходит граница.',
            'I want to explain where my limit is.',
          ),
          (
            'Мне хочется понять, одинаково ли мы это видим.',
            'I’d like to see if we’re expecting the same thing.',
          ),
        ];
        fields.addAll([
          field(
            first,
            ('С кем хотите поговорить?', 'Who is this conversation with?'),
            ('Например, с коллегой', 'For example, my colleague'),
          ),
          choices((
            'Зачем вам этот разговор?',
            'What do you want to do?',
          ), goals),
          field(
            second,
            (
              'Что вы хотите сказать своими словами?',
              'What do you want to say in your own words?',
            ),
            (
              [
                'Сможешь посмотреть мой черновик?',
                'Давай договоримся о звонках заранее.',
                'Когда ты хочешь получить первый вариант?',
              ][choice ?? 0],
              [
                'Could you look over my draft?',
                'Could we arrange calls in advance?',
                'When would you like to see the first draft?',
              ][choice ?? 0],
            ),
          ),
        ]);
        action = ('Собрать фразу', 'Build my opening').read(ru);
        ready = choice != null && a.isNotEmpty && b.isNotEmpty;
        complete = () => result(
          ('Черновик разговора', 'Conversation draft'),
          '${('Разговор', 'Conversation').read(ru)} · $a\n\n${openings[choice!].read(ru)} $b',
          (
            'Прочитайте фразу вслух. После неё дайте собеседнику время ответить.',
            'Try saying it out loud. Pause after your opening to give the other person time to answer.',
          ),
          copyText: '${openings[choice].read(ru)} $b',
        );
      case GuidanceSituation.beginning:
        const times = [
          ('Сейчас', 'Right now'),
          ('После обеда', 'After lunch'),
          ('Сегодня вечером', 'This evening'),
          ('Завтра утром', 'Tomorrow morning'),
        ];
        fields.addAll([
          field(
            first,
            ('Что поместится в десять минут?', 'What fits into ten minutes?'),
            (
              'Например, набросать начало письма',
              'For example, draft the first lines of an email',
            ),
          ),
          choices(('Когда начнёте?', 'When will you start?'), times),
        ]);
        action = ('Составить план', 'Make my plan').read(ru);
        ready = a.isNotEmpty && choice != null;
        complete = () => result(
          ('Мой первый шаг', 'My first step'),
          '${times[choice!].read(ru)} · ${('10 минут', '10 minutes').read(ru)}\n\n$a',
          (
            'Когда десять минут пройдут, посмотрите, что уже получилось. На этом можно остановиться.',
            'At the end of ten minutes, look at what you have done. You can stop there.',
          ),
        );
      case GuidanceSituation.change:
        const anchors = [
          ('Знакомое место', 'A familiar place'),
          ('Близкий человек', 'Someone close'),
          ('Привычное занятие', 'A familiar routine'),
        ];
        const prompts = [
          (
            'Загляните сегодня в знакомое место. Что в нём по-прежнему ваше?',
            'Spend a moment in a familiar place today. What still feels like yours?',
          ),
          (
            'Напишите человеку, с которым вам легко. Расскажите об одной перемене.',
            'Get in touch with someone you feel at ease with. Tell them about one change.',
          ),
          (
            'Освободите сегодня несколько минут для этого занятия. Выберите удобное время.',
            'Set aside a few minutes today for that routine. Pick a time that suits you.',
          ),
        ];
        fields.addAll([
          field(
            first,
            ('Что изменилось?', 'What has changed?'),
            (
              'Например, я переехала в другой город',
              'For example, I moved to a new city',
            ),
          ),
          field(
            second,
            ('Что вы можете решить сами?', 'What can you choose for yourself?'),
            (
              'Например, как провести утро',
              'For example, how to spend my morning',
            ),
          ),
          choices((
            'На что можно опереться сегодня?',
            'What helps you feel grounded?',
          ), anchors),
        ]);
        action = ('Найти опору', 'Find my anchor').read(ru);
        ready = a.isNotEmpty && b.isNotEmpty && choice != null;
        complete = () => result(
          ('Моя опора', 'My anchor'),
          '${('Что изменилось', 'What changed').read(ru)}\n$a\n\n${('Что в моих руках', 'What I can choose').read(ru)}\n$b\n\n${('Моя опора сегодня', 'Today’s anchor').read(ru)}\n${anchors[choice!].read(ru)}',
          prompts[choice],
        );
    }
    return ScenarioPage(
      title: step.title(ru),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final child in fields) ...[child, const SizedBox(height: 20)],
          Semantics(
            container: true,
            child: CustomButton(
              isFullWidth: true,
              text: action,
              onPressed: ready ? complete : null,
            ),
          ),
        ],
      ),
    );
  }
}

void _push(BuildContext context, Widget screen) {
  FocusManager.instance.primaryFocus?.unfocus();
  Navigator.of(context).push<void>(CupertinoPageRoute(builder: (_) => screen));
}

class _Choices extends StatelessWidget {
  const _Choices({
    required this.label,
    required this.values,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final List<String> values;
  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: context.textTheme.inverseUrbanistRegular16),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (var i = 0; i < values.length; i++)
            ChoiceChip(
              label: Text(values[i]),
              selected: value == i,
              backgroundColor: AppColorsDark.modal,
              selectedColor: AppColors.primary,
              labelStyle: AppTypography.text2.copyWith(
                color: AppColors.textInverse,
              ),
              onSelected: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
                onChanged(i);
              },
            ),
        ],
      ),
    ],
  );
}

class _CompareOptions extends StatefulWidget {
  const _CompareOptions({
    required this.first,
    required this.second,
    required this.onFinish,
  });
  final VoidCallback onFinish;
  final String first, second;
  @override
  State<_CompareOptions> createState() => _CompareOptionsState();
}

class _CompareOptionsState extends State<_CompareOptions> {
  int? criterion, option;
  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    const criteria = [
      ('Время', 'Time'),
      ('Силы', 'Energy'),
      ('Интерес', 'Curiosity'),
    ];
    const questions = [
      (
        'В каком варианте легче найти время для важного?',
        'Which option leaves more room for what matters?',
      ),
      (
        'Какой вариант вам сейчас по силам?',
        'Which option feels manageable right now?',
      ),
      (
        'Какой вариант любопытнее попробовать?',
        'Which option are you more curious to try?',
      ),
    ];
    const trials = [
      (
        'Откройте расписание на завтра. Найдите место для одного действия из этого варианта. От чего придётся отказаться?',
        'Look at tomorrow’s schedule. Make room for one action this option requires. What would it displace?',
      ),
      (
        'Попробуйте самую лёгкую часть этого варианта. Через десять минут заметьте, сколько сил осталось.',
        'Try the easiest part of this option. After ten minutes, notice how much energy you have left.',
      ),
      (
        'Придумайте маленькую пробу этого варианта на сегодня. Что вам захотелось узнать, когда вы начали?',
        'Try a small sample of this option today. Once you start, what do you want to find out?',
      ),
    ];
    final options = [widget.first, widget.second];
    final c = criterion;
    final o = option;
    return ScenarioPage(
      title: ('Что для вас важнее?', 'What matters most?').read(ru),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Choices(
            label: (
              'С какой стороны сравним?',
              'What will you compare?',
            ).read(ru),
            values: [for (final item in criteria) item.read(ru)],
            value: c,
            onChanged: (v) => setState(() {
              if (criterion != v) option = null;
              criterion = v;
            }),
          ),
          if (c != null) ...[
            const SizedBox(height: 20),
            _Choices(
              label: questions[c].read(ru),
              values: options,
              value: o,
              onChanged: (v) => setState(() => option = v),
            ),
          ],
          const SizedBox(height: 24),
          Semantics(
            container: true,
            child: CustomButton(
              isFullWidth: true,
              text: ('Выбрать пробу', 'Choose a trial').read(ru),
              onPressed: c == null || o == null
                  ? null
                  : () => _push(
                      context,
                      _ExerciseResult(
                        title: (
                          'Проба перед выбором',
                          'A trial before deciding',
                        ).read(ru),
                        text:
                            '${('Хочу попробовать', 'I want to try').read(ru)}\n${options[o]}\n\n${('Что для меня важно', 'What matters to me').read(ru)}\n${criteria[c].read(ru)}',
                        next: trials[c].read(ru),
                        onFinish: widget.onFinish,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseResult extends StatefulWidget {
  const _ExerciseResult({
    required this.title,
    required this.text,
    required this.next,
    required this.onFinish,
    this.copyText,
  });
  final String title, text, next;
  final VoidCallback onFinish;
  final String? copyText;

  @override
  State<_ExerciseResult> createState() => _ExerciseResultState();
}

class _ExerciseResultState extends State<_ExerciseResult> {
  bool copied = false;

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    final copy = (copied ? ('Скопировано', 'Copied') : ('Скопировать', 'Copy'))
        .read(ru);
    return ScenarioPage(
      title: widget.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeGlassSurface(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                widget.text,
                style: context.textTheme.inversePlayfairSemiBold20,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(widget.next, style: context.textTheme.inverseUrbanistRegular16),
          const SizedBox(height: 24),
          Semantics(
            container: true,
            child: CustomButton(
              isFullWidth: true,
              text: copy,
              onPressed: () async {
                try {
                  await Clipboard.setData(
                    ClipboardData(
                      text:
                          widget.copyText ?? '${widget.text}\n\n${widget.next}',
                    ),
                  );
                  if (context.mounted) {
                    setState(() => copied = true);
                  }
                } on PlatformException {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ('Не удалось скопировать', 'Couldn’t copy').read(ru),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ),
          LotusButtons.text(
            onPressed: widget.onFinish,
            child: Text(
              ('Выбрать другую ситуацию', 'Choose another situation').read(ru),
            ),
          ),
        ],
      ),
    );
  }
}

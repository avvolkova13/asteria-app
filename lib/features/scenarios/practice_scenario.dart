import 'package:asteria_app/features/scenarios/scenario_sky.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/extensions/build_context_extensions.dart';
import 'package:asteria_app/features/affirmation/player/affirmation_player_screen.dart';
import 'package:asteria_app/features/affirmation/player/practice_link.dart';
import 'package:flutter/cupertino.dart';

import 'scenario_ui.dart';
import 'scenario_completion.dart';

enum PracticeMood {
  slowDown,
  focus,
  unwind;

  String get art => switch (this) {
    slowDown => 'assets/images/scenarios/lotus.webp',
    focus => 'assets/images/home/energy_focus.webp',
    unwind =>
      'assets/images/prediction_images/moon_card_health_sleep_recovery.webp',
  };

  String label(BuildContext context) => switch (this) {
    slowDown => context.l10n.scenarioPracticeSlowDown,
    focus => context.l10n.scenarioPracticeFocus,
    unwind => context.l10n.scenarioPracticeUnwind,
  };
}

class ScenarioPractice {
  const ScenarioPractice({
    required this.id,
    required this.mood,
    required this.title,
    required this.duration,
    required this.open,
    this.isAvailable,
  });

  final String id;
  final PracticeMood mood;
  final String title;
  final Duration duration;
  final Future<void> Function(BuildContext) open;
  final bool Function(BuildContext)? isAvailable;

  bool available(BuildContext c) => isAvailable?.call(c) ?? true;
}

const availablePracticeRecordings = [
  ScenarioPractice(
    id: PracticeLink.url,
    mood: PracticeMood.slowDown,
    title: 'У меня есть время',
    duration: Duration(seconds: 75),
    open: _openBundledPractice,
  ),
];

Future<void> _openBundledPractice(BuildContext context) =>
    Navigator.of(context).push<void>(
      CupertinoPageRoute(
        builder: (playerContext) => ScenarioSkyScope(
          child: AffirmationPlayerScreen(
            showBack: true,
            autoPlay: true,
            onCompleted: () =>
                Navigator.of(playerContext).pushReplacement<void, void>(
                  CupertinoPageRoute(
                    builder: (_) => const PracticeReflectionScreen(),
                  ),
                ),
          ),
        ),
      ),
    );

Future<void> openPracticeScenario(
  BuildContext context, {
  List<ScenarioPractice> recordings = availablePracticeRecordings,
}) => Navigator.of(context).push<void>(
  CupertinoPageRoute(builder: (_) => _PracticeMoods(recordings: recordings)),
);

class _PracticeMoods extends StatefulWidget {
  const _PracticeMoods({required this.recordings});
  final List<ScenarioPractice> recordings;

  @override
  State<_PracticeMoods> createState() => _PracticeMoodsState();
}

class _PracticeMoodsState extends State<_PracticeMoods> {
  final _lastPlayed = <PracticeMood, String>{};
  bool _opening = false;

  Future<void> _choose(PracticeMood mood) async {
    if (_opening) return;
    final available = widget.recordings
        .where((item) => item.available(context))
        .toList();
    if (available.isEmpty) {
      setState(() {});
      return;
    }
    final matches = available.where((item) => item.mood == mood).toList();
    final candidates = matches.isEmpty ? available : matches;
    _opening = true;
    try {
      final lastIndex = candidates.indexWhere(
        (item) => item.id == _lastPlayed[mood],
      );
      final next = candidates[(lastIndex + 1) % candidates.length];
      await next.open(context);
      _lastPlayed[mood] = next.id;
    } finally {
      _opening = false;
    }
  }

  Widget _choice(PracticeMood mood, {bool wide = false}) => ScenarioChoiceCard(
    title: mood.label(context),
    art: mood.art,
    wide: wide,
    onTap: () => _choose(mood),
  );

  @override
  Widget build(BuildContext context) => ScenarioPage(
    title: context.l10n.scenarioPracticeChooseMood,
    child: !widget.recordings.any((item) => item.available(context))
        ? Text(context.l10n.scenarioPracticeUnavailable)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: AsteriaEntrance.sections([
              _choice(PracticeMood.slowDown, wide: true),
              const SizedBox(height: 12),
              ScenarioChoiceGrid(
                children: [
                  _choice(PracticeMood.focus),
                  _choice(PracticeMood.unwind),
                ],
              ),
            ]),
          ),
  );
}

/// A short check-in after listening; it does not infer a therapeutic outcome.
class PracticeReflectionScreen extends StatefulWidget {
  const PracticeReflectionScreen({super.key, this.onHome});

  final VoidCallback? onHome;

  @override
  State<PracticeReflectionScreen> createState() =>
      _PracticeReflectionScreenState();
}

class _PracticeReflectionScreenState extends State<PracticeReflectionScreen> {
  bool? _calmer;

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    return ScenarioPage(
      title: ru ? 'Как вы сейчас?' : 'How do you feel now?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: AsteriaEntrance.sections([
          Text(
            ru
                ? 'Минута для себя уже позади. Заметьте, как вы себя чувствуете.'
                : 'You have taken a moment for yourself. Notice how you feel.',
          ),
          const SizedBox(height: 20),
          ScenarioChoiceCard(
            title: ru ? 'Стало спокойнее' : 'A little calmer',
            selected: _calmer == true,
            art: PracticeMood.slowDown.art,
            wide: true,
            onTap: () => setState(() => _calmer = true),
          ),
          const SizedBox(height: 12),
          ScenarioChoiceCard(
            title: ru ? 'Пока без изменений' : 'About the same',
            selected: _calmer == false,
            art: PracticeMood.unwind.art,
            wide: true,
            onTap: () => setState(() => _calmer = false),
          ),
          if (_calmer != null) ...[
            const SizedBox(height: 24),
            ScenarioCompletion(
              key: ValueKey(_calmer),
              message: _calmer == true
                  ? (ru
                        ? 'Сохраните этот темп: выберите одно небольшое действие, а остальному дайте подождать. На главной можно снова включить аффирмацию или выбрать день для своих планов.'
                        : 'Keep this pace: choose one small action and let the rest wait. From Home you can play the affirmation again or choose a date for your plans.')
                  : (ru
                        ? 'Не обязательно почувствовать перемену сразу. Можно сделать паузу и вернуться к записи позже. На главной вас ждут аффирмация дня и лунный календарь.'
                        : 'You do not have to feel a change immediately. Take a pause and return to the recording later. Find the daily affirmation and lunar calendar on Home.'),
              onHome: widget.onHome,
            ),
          ],
        ]),
      ),
    );
  }
}

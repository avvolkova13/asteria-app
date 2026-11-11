import 'package:asteria_app/features/scenarios/scenario_sky.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/extensions/build_context_extensions.dart';
import 'package:asteria_app/features/affirmation/player/affirmation_player_screen.dart';
import 'package:asteria_app/features/affirmation/player/practice_link.dart';
import 'package:flutter/cupertino.dart';

import 'scenario_ui.dart';

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
        builder: (_) => const ScenarioSkyScope(
          child: AffirmationPlayerScreen(showBack: true, autoPlay: true),
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

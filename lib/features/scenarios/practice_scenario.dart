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
        builder: (_) => const AffirmationPlayerScreen(showBack: true),
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
    final available = widget.recordings.where(
      (item) => item.available(context),
    );
    final matches = available.where((item) => item.mood == mood).toList();
    _opening = true;
    try {
      if (matches.isEmpty) {
        final alternative = available
            .where((item) => item.mood == PracticeMood.slowDown)
            .firstOrNull;
        await Navigator.of(context).push<void>(
          CupertinoPageRoute(
            builder: (_) => _PracticeAlternative(recording: alternative),
          ),
        );
        return;
      }
      final lastIndex = matches.indexWhere(
        (item) => item.id == _lastPlayed[mood],
      );
      final next = matches[(lastIndex + 1) % matches.length];
      await next.open(context);
      _lastPlayed[mood] = next.id;
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) => ScenarioPage(
    title: context.l10n.scenarioPracticeChooseMood,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: AsteriaEntrance.sections([
        if (!widget.recordings.any((item) => item.available(context)))
          Text(context.l10n.scenarioPracticeUnavailable)
        else
          for (final mood in PracticeMood.values)
            ScenarioTile(
              title: mood.label(context),
              onTap: () => _choose(mood),
            ),
      ]),
    ),
  );
}

class _PracticeAlternative extends StatefulWidget {
  const _PracticeAlternative({required this.recording});
  final ScenarioPractice? recording;

  @override
  State<_PracticeAlternative> createState() => _PracticeAlternativeState();
}

class _PracticeAlternativeState extends State<_PracticeAlternative> {
  bool _opening = false;

  Future<void> _play(ScenarioPractice item) async {
    if (_opening) return;
    if (!item.available(context)) {
      setState(() {});
      return;
    }
    _opening = true;
    try {
      await item.open(context);
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.recording;
    final canPlay = item != null && item.available(context);
    return ScenarioPage(
      title: context.l10n.scenarioPracticeAlternativeTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: AsteriaEntrance.sections([
          Text(
            canPlay
                ? context.l10n.scenarioPracticeAlternativeOffered
                : context.l10n.scenarioPracticeNoMatch,
          ),
          if (canPlay) ...[
            const SizedBox(height: 16),
            ScenarioTile(
              art: 'assets/images/scenarios/lotus.webp',
              title: item.title,
              subtitle: context.l10n.scenarioPracticeListen(
                '${item.duration.inMinutes}:${(item.duration.inSeconds % 60).toString().padLeft(2, '0')}',
              ),
              onTap: () => _play(item),
            ),
          ],
        ]),
      ),
    );
  }
}

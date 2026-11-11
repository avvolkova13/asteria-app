import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/extensions/build_context_extensions.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/features/affirmation/player/practice_link.dart';
import 'package:flutter/material.dart';

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
    open: AffirmationPlayerRoute.push,
  ),
];

Future<void> openPracticeScenario(
  BuildContext context, {
  List<ScenarioPractice> recordings = availablePracticeRecordings,
}) async {
  final available = recordings
      .where((item) => item.available(context))
      .toList();
  if (available.length == 1) {
    await available.single.open(context);
    return;
  }
  await Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => _PracticeMoods(recordings: available)),
  );
}

class _PracticeMoods extends StatefulWidget {
  const _PracticeMoods({required this.recordings});
  final List<ScenarioPractice> recordings;

  @override
  State<_PracticeMoods> createState() => _PracticeMoodsState();
}

class _PracticeMoodsState extends State<_PracticeMoods> {
  final _lastPlayed = <PracticeMood, String>{};
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
      if (mounted) setState(() => _lastPlayed[item.mood] = item.id);
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext c) {
    final groups = <PracticeMood, List<ScenarioPractice>>{};
    for (final item in widget.recordings.where((item) => item.available(c))) {
      (groups[item.mood] ??= []).add(item);
    }
    return ScenarioPage(
      title: c.l10n.scenarioPracticeChooseMood,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: AsteriaEntrance.sections([
          if (groups.isEmpty) Text(c.l10n.scenarioPracticeUnavailable),
          for (final entry in groups.entries)
            Builder(
              builder: (context) {
                final mood = entry.key;
                final choices = entry.value;
                final lastIndex = choices.indexWhere(
                  (item) => item.id == _lastPlayed[mood],
                );
                final next = choices[(lastIndex + 1) % choices.length];
                final mins = next.duration.inMinutes;
                final secs = (next.duration.inSeconds % 60).toString().padLeft(
                  2,
                  '0',
                );
                return ScenarioTile(
                  title: mood.label(context),
                  subtitle: '${next.title} · $mins:$secs',
                  onTap: () => _play(next),
                );
              },
            ),
        ]),
      ),
    );
  }
}

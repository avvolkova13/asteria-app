import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/core/const/keys_const.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_activity_indicator.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';

import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:asteria_app/features/runes/widgets/runes_block.dart';
import 'package:flutter/material.dart';

import 'scenario_ui.dart';

class FreeRuneScenario extends StatefulWidget {
  const FreeRuneScenario({super.key});

  @override
  State<FreeRuneScenario> createState() => _FreeRuneScenarioState();
}

class _FreeRuneScenarioState extends State<FreeRuneScenario> {
  static const _positions = [
    KeysConst.runeDeckLeftKey,
    KeysConst.runeDeckCenterKey,
    KeysConst.runeDeckRightKey,
  ];
  late final _content = di.get<ContentProvider>();
  late Future<void> _ready = Future.microtask(_prepare);

  @override
  void initState() {
    super.initState();
    _content.resetRuneDeckOpenState();
  }

  Future<void> _prepare() async {
    if (_content.runes.isEmpty) await _content.loadContent();
    await _content.ensureRuneDeckLayoutReady();
  }

  Future<void> _open(String key) async {
    try {
      await _content.openRuneInDeck(key);
    } catch (_) {
      if (!mounted) return;
      final ru = Localizations.localeOf(context).languageCode == 'ru';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ru
                ? 'Не удалось открыть руну. Коснитесь её ещё раз.'
                : 'Couldn’t reveal this rune. Tap it to try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    return ScenarioPage(
      title: ru ? 'О чём говорят руны?' : 'What do the runes say?',
      child: FutureBuilder<void>(
        future: _ready,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: AsteriaActivityIndicator());
          }
          return ListenableBuilder(
            listenable: _content,
            builder: (context, _) {
              final runes = _positions
                  .map(_content.getRuneInDeck)
                  .nonNulls
                  .toList();
              if (snapshot.hasError || runes.length != _positions.length) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ru
                          ? 'Не удалось загрузить расклад.'
                          : 'Couldn’t load the spread.',
                      style: context.textTheme.inverseUrbanistRegular16,
                    ),
                    LotusButtons.text(
                      onPressed: () => setState(() {
                        _ready = Future.microtask(_prepare);
                      }),
                      child: Text(context.l10n.commonRetry),
                    ),
                  ],
                );
              }
              final opened = _positions
                  .map(_content.isRuneInDeckOpened)
                  .toList();
              final titles = [
                context.l10n.runesPast,
                context.l10n.runesPresent,
                context.l10n.runesFuture,
              ];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    ru
                        ? 'Подумайте о своей ситуации. Откройте три руны, чтобы посмотреть, что к ней привело, что происходит сейчас и как события могут развиваться дальше.'
                        : 'Think of your situation. Reveal the three runes to explore what led up to it, what is happening now and where it might go.',
                    style: context.textTheme.inverseUrbanistRegular16,
                  ),
                  const SizedBox(height: 16),
                  RunesBlock(
                    rune1: runes[0],
                    rune2: runes[1],
                    rune3: runes[2],
                    isRuneLeftOpened: opened[0],
                    isRuneCenterOpened: opened[1],
                    isRuneRightOpened: opened[2],
                    onOpenRuneLeft: () => _open(_positions[0]),
                    onOpenRuneCenter: () => _open(_positions[1]),
                    onOpenRuneRight: () => _open(_positions[2]),
                  ),
                  for (var i = 0; i < runes.length; i++)
                    if (opened[i]) _meaning(context, titles[i], runes[i], i),
                  if (opened.every((value) => value) &&
                      Navigator.canPop(context))
                    LotusButtons.text(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        ru
                            ? 'Выбрать другую ситуацию'
                            : 'Choose another situation',
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _meaning(
    BuildContext context,
    String title,
    RuneOfDayModel rune,
    int index,
  ) {
    final meaning = switch (index) {
      0 => rune.pastDeck,
      1 => rune.presentDeck,
      _ => rune.futureDeck,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HomeGlassSurface(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title · ${rune.title}',
                style: context.textTheme.inversePlayfairSemiBold20,
              ),
              const SizedBox(height: 8),
              Text(meaning, style: context.textTheme.inverseUrbanistRegular16),
            ],
          ),
        ),
      ),
    );
  }
}

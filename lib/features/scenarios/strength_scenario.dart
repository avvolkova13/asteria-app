import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'dart:convert';

import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/services/hive/hive_service.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/utils/enums.dart';
import 'package:asteria_app/core/utils/horoscope_parsers/horoscope_request_helper.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:asteria_app/features/natal_card/natal_card_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'scenario_ui.dart';
import 'strength_guidance.dart';

class StrengthTipStore {
  const StrengthTipStore(this.box, this.owner);
  final Box<Map> box;
  final String owner;

  String get _prefix => 'strength-tip/${base64Url.encode(utf8.encode(owner))}/';
  List<StrengthTip> read() {
    if (owner.isEmpty) return [];
    final results = <StrengthTip>[];
    for (final key in box.keys.whereType<String>().where(
      (k) => k.startsWith(_prefix),
    )) {
      final data = box.get(key);
      if (data != null) results.add(StrengthTip.fromJson(data));
    }
    return results..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> save(StrengthTip tip) async {
    if (owner.isEmpty) throw StateError('Missing account');
    final key = '$_prefix${tip.id}';
    if (!box.containsKey(key)) await box.put(key, tip.toJson());
  }

  bool contains(StrengthTip tip) => box.containsKey('$_prefix${tip.id}');
}

Future<void> _open(BuildContext context, Widget child) => Navigator.of(
  context,
).push<void>(CupertinoPageRoute<void>(builder: (_) => child));

class StrengthScenarioScreen extends StatelessWidget {
  const StrengthScenarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = di.get<UserProvider>();
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    return ListenableBuilder(
      listenable: users,
      builder: (context, _) {
        final owner = users.currentUser?.id ?? '';
        final store = StrengthTipStore(HiveService.appSettingsBox, owner);
        return ScenarioPage(
          title: context.l10n.scenarioStrengthChooseArea,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: AsteriaEntrance.sections([
              for (final area in StrengthArea.values)
                ScenarioTile(
                  title: area.label(ru),
                  onTap: () =>
                      _open(context, _StrengthTasks(area: area, owner: owner)),
                ),
              StreamBuilder<BoxEvent>(
                stream: store.box.watch(),
                builder: (context, _) => store.read().isEmpty
                    ? const SizedBox.shrink()
                    : ScenarioTile(
                        title: context.l10n.scenarioStrengthSavedTips,
                        onTap: () =>
                            _open(context, _SavedStrengthTips(owner: owner)),
                      ),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class _StrengthTasks extends StatelessWidget {
  const _StrengthTasks({required this.area, required this.owner});
  final StrengthArea area;
  final String owner;
  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    return ScenarioPage(
      title: context.l10n.scenarioStrengthChooseSituation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: AsteriaEntrance.sections([
          for (final task in StrengthTask.values.where(
            (task) => task.area == area,
          ))
            ScenarioTile(
              title: task.label(ru),
              onTap: () =>
                  _open(context, _StrengthResult(task: task, owner: owner)),
            ),
        ]),
      ),
    );
  }
}

class _StrengthResult extends StatefulWidget {
  const _StrengthResult({this.task, this.saved, required this.owner})
    : assert((task == null) != (saved == null));
  final StrengthTask? task;
  final StrengthTip? saved;
  final String owner;
  @override
  State<_StrengthResult> createState() => _StrengthResultState();
}

class _StrengthResultState extends State<_StrengthResult> {
  bool _expanded = false;
  bool _saving = false;
  Future<void> _save(StrengthTip tip, StrengthTipStore store) async {
    if (_saving || di.get<UserProvider>().currentUser?.id != widget.owner) {
      return;
    }
    setState(() => _saving = true);
    try {
      await store.save(tip);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.scenarioStrengthSaveError)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = di.get<UserProvider>();
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    final lang = ru ? 'ru' : 'en';
    return ListenableBuilder(
      listenable: users,
      builder: (context, _) {
        final user = users.currentUser;
        if (user == null || user.id.isEmpty || user.id != widget.owner) {
          return _accountChanged(context);
        }
        final chart = user.natalCard;
        final reading = chart?.interpretations[lang];
        final day = user.horoscopeDay;
        final validDay =
            day != null &&
            users.showHoroscope(HoroscopeTypeEnum.day) &&
            isAiContentLocalized(day.focus, lang);
        final tip =
            widget.saved ??
            buildStrengthTip(
              task: widget.task!,
              language: lang,
              date: DateTime.now(),
              reading: reading,
              todayFocus: validDay ? day.focus : null,
            );
        final store = StrengthTipStore(
          HiveService.appSettingsBox,
          widget.owner,
        );
        final saved = widget.saved != null || store.contains(tip);
        final archive = widget.saved != null;
        return ScenarioPage(
          title: tip.situation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: AsteriaEntrance.sections([
              if (archive)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    MaterialLocalizations.of(
                      context,
                    ).formatMediumDate(tip.date),
                    style: context.textTheme.inverseUrbanistRegular16,
                  ),
                ),
              _ReadingPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip.title,
                      style: context.textTheme.inversePlayfairSemiBold24,
                    ),
                    if (tip.natalSource != null &&
                        tip.natalSource != tip.title) ...[
                      const SizedBox(height: 8),
                      Text(
                        tip.natalSource!,
                        style: context.textTheme.inverseUrbanistRegular16,
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      tip.daySource == null
                          ? context.l10n.scenarioStrengthTry
                          : context.l10n.scenarioStrengthTryToday,
                      style: context.textTheme.inversePlayfairMedium18,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tip.action,
                      style: context.textTheme.inverseUrbanistRegular16,
                    ),
                  ],
                ),
              ),
              if (!archive && tip.natalSource == null) ...[
                const SizedBox(height: 16),
                Text(
                  reading == null
                      ? context.l10n.scenarioStrengthNeedsReading
                      : context.l10n.scenarioStrengthNoPersonalMatch,
                  style: context.textTheme.inverseUrbanistRegular16,
                ),
                if (reading == null)
                  ScenarioTile(
                    title: context.l10n.scenarioStrengthOpenChart,
                    onTap: () => _open(context, const NatalCardScreen()),
                  ),
              ],
              if (tip.natalSource != null) ...[
                ScenarioTile(
                  title: context.l10n.scenarioStrengthExplanation,
                  onTap: () => setState(() => _expanded = !_expanded),
                ),
                if (_expanded)
                  _ReadingPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.scenarioStrengthChartSource,
                          style: context.textTheme.inversePlayfairMedium18,
                        ),
                        Text(
                          tip.natalSource!,
                          style: context.textTheme.inverseUrbanistRegular16,
                        ),
                        if (tip.daySource != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            context.l10n.scenarioStrengthForecastSource,
                            style: context.textTheme.inversePlayfairMedium18,
                          ),
                          Text(
                            tip.daySource!,
                            style: context.textTheme.inverseUrbanistRegular16,
                          ),
                        ],
                        if (reading != null)
                          CustomButton(
                            type: CustomButtonType.text,
                            text: context.l10n.scenarioStrengthFullReading,
                            onPressed: () =>
                                _open(context, const NatalCardScreen()),
                          ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 20),
              if (!archive) ...[
                if (saved)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      context.l10n.scenarioStrengthSaved,
                      style: context.textTheme.inverseUrbanistRegular16,
                    ),
                  ),
                CustomButton(
                  text: saved
                      ? context.l10n.scenarioStrengthViewSaved
                      : context.l10n.scenarioStrengthSave,
                  isLoading: _saving,
                  onPressed: saved
                      ? () => _open(
                          context,
                          _SavedStrengthTips(owner: widget.owner),
                        )
                      : () => _save(tip, store),
                ),
              ],
              CustomButton(
                type: CustomButtonType.text,
                text: context.l10n.scenarioGoHome,
                onPressed: () => scenarioHome(context),
              ),
            ]),
          ),
        );
      },
    );
  }
}

Widget _accountChanged(BuildContext context) => ScenarioPage(
  title: context.l10n.scenarioStrengthSavedTips,
  child: CustomButton(
    text: context.l10n.scenarioGoHome,
    onPressed: () => scenarioHome(context),
  ),
);

class _SavedStrengthTips extends StatelessWidget {
  const _SavedStrengthTips({required this.owner});
  final String owner;
  @override
  Widget build(BuildContext context) {
    final users = di.get<UserProvider>();
    return ListenableBuilder(
      listenable: users,
      builder: (context, _) {
        if (users.currentUser?.id != owner || owner.isEmpty) {
          return _accountChanged(context);
        }
        final tips = StrengthTipStore(HiveService.appSettingsBox, owner).read();
        return ScenarioPage(
          title: context.l10n.scenarioStrengthSavedTips,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: AsteriaEntrance.sections([
              for (final tip in tips)
                ScenarioTile(
                  title: tip.title,
                  subtitle:
                      '${tip.situation} · ${MaterialLocalizations.of(context).formatMediumDate(tip.date)}',
                  onTap: () =>
                      _open(context, _StrengthResult(saved: tip, owner: owner)),
                ),
            ]),
          ),
        );
      },
    );
  }
}

class _ReadingPanel extends StatelessWidget {
  const _ReadingPanel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => HomeGlassSurface(
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );
}

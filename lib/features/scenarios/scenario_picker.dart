import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/cupertino.dart';
import 'calendar_scenario.dart';
import 'first_session.dart';
import 'practice_scenario.dart';
import 'relationships_scenario.dart';
import 'scenario_ui.dart';
import 'strength_scenario.dart';

class ScenarioPicker extends StatefulWidget {
  const ScenarioPicker({super.key});
  @override
  State<ScenarioPicker> createState() => _ScenarioPickerState();
}

class _ScenarioPickerState extends State<ScenarioPicker> {
  bool _opening = false;

  Future<void> _choose(Future<void> Function() open) async {
    if (_opening) return;
    _opening = true;
    try {
      final uid = di.get<UserProvider>().currentUser?.id;
      if (uid != null && FirstSession.pending(uid)) {
        await FirstSession.finish(uid);
      }
      if (mounted) await open();
    } finally {
      _opening = false;
    }
  }

  Future<void> _screen(Widget screen) => Navigator.of(
    context,
  ).push<void>(CupertinoPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return ScenarioPage(
      title: context.l10n.scenarioStartTitle,
      showBack: false,
      footer: LotusButtons.text(
        onPressed: () => _choose(() async => scenarioHome(context)),
        child: Text(
          context.l10n.scenarioGoHome,
          style: context.textTheme.inversePlayfairSemiBold16.copyWith(
            color: AppColors.cardTinted,
          ),
        ),
      ),
      child: Column(
        children: [
          ScenarioTile(
            title: context.l10n.scenarioCalendarTitle,
            subtitle: context.l10n.scenarioCalendarSubtitle,
            art: 'assets/icons/clay/calendar_icon.webp',
            onTap: () => _choose(() => _screen(const CalendarScenarioScreen())),
          ),
          ScenarioTile(
            title: context.l10n.scenarioPracticeTitle,
            subtitle: context.l10n.scenarioPracticeSubtitle,
            art: 'assets/images/affirmation/lavender-clay-lotus.webp',
            onTap: () => _choose(() => openPracticeScenario(context)),
          ),
          ScenarioTile(
            title: context.l10n.scenarioRelationshipsTitle,
            subtitle: context.l10n.scenarioRelationshipsSubtitle,
            art: 'assets/icons/clay/ic_heart.webp',
            onTap: () =>
                _choose(() => _screen(const RelationshipsScenarioScreen())),
          ),
          ScenarioTile(
            title: context.l10n.scenarioStrengthTitle,
            subtitle: context.l10n.scenarioStrengthSubtitle,
            art: 'assets/icons/clay/natal_wheel.webp',
            onTap: () => _choose(() => _screen(const StrengthScenarioScreen())),
          ),
        ],
      ),
    );
  }
}

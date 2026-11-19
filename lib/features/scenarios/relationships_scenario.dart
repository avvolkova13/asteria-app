import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:flutter/cupertino.dart';

import 'free_conflict_scenario.dart';
import 'pair_conversation_tarot.dart';
import 'relationship_anakra_scenario.dart';
import 'scenario_sky.dart';
import 'scenario_ui.dart';

part 'relationship_exercise.dart';

class RelationshipsScenarioScreen extends StatelessWidget {
  const RelationshipsScenarioScreen({super.key});

  @override
  Widget build(BuildContext context) => ScenarioPage(
    title: context.l10n.scenarioRelationshipChooseSituation,
    child: const _RelationshipChoices(),
  );
}

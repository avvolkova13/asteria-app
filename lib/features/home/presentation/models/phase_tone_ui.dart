import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';

class PhaseToneUi {
  final String semanticKey;

  const PhaseToneUi._(this.semanticKey);

  factory PhaseToneUi.fromTone(PhaseTone tone) {
    return switch (tone) {
      PhaseTone.reset => const PhaseToneUi._('reset'),
      PhaseTone.growth => const PhaseToneUi._('growth'),
      PhaseTone.action => const PhaseToneUi._('action'),
      PhaseTone.refinement => const PhaseToneUi._('refinement'),
      PhaseTone.intensity => const PhaseToneUi._('intensity'),
      PhaseTone.integration => const PhaseToneUi._('integration'),
      PhaseTone.release => const PhaseToneUi._('release'),
      PhaseTone.recovery => const PhaseToneUi._('recovery'),
    };
  }
}

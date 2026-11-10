import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';
import 'package:asteria_app/features/home/presentation/models/phase_tone_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps every phase tone to a stable semantic key', () {
    expect(
      {
        for (final tone in PhaseTone.values)
          tone: PhaseToneUi.fromTone(tone).semanticKey,
      },
      {
        PhaseTone.reset: 'reset',
        PhaseTone.growth: 'growth',
        PhaseTone.action: 'action',
        PhaseTone.refinement: 'refinement',
        PhaseTone.intensity: 'intensity',
        PhaseTone.integration: 'integration',
        PhaseTone.release: 'release',
        PhaseTone.recovery: 'recovery',
      },
    );
  });
}

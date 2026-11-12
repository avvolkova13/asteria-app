import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/compatibility/presentation/widgets/compatibility_layout.dart';
import 'package:flutter/material.dart';
import 'scenario_ui.dart';

/// A deliberate end to a scenario, with navigation under the user's control.
class ScenarioCompletion extends StatelessWidget {
  const ScenarioCompletion({super.key, required this.message, this.onHome});
  final String message;
  final VoidCallback? onHome;
  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CompatibilityGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ru ? 'Что дальше?' : 'What’s next?',
                style: context.textTheme.inversePlayfairSemiBold20,
              ),
              const SizedBox(height: 10),
              Text(message, style: context.textTheme.inverseUrbanistRegular16),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CustomButton(
          isFullWidth: true,
          height: 50,
          text: context.l10n.scenarioGoHome,
          onPressed: onHome ?? () => scenarioHome(context),
        ),
      ],
    );
  }
}

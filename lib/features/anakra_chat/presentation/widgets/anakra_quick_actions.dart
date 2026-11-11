import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_quick_action_button.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class AnakraQuickActions extends StatelessWidget {
  final VoidCallback? onDrawCard;
  final VoidCallback? onCompatibility;
  final VoidCallback? onNatalChart;
  final VoidCallback? onPowerDay;

  const AnakraQuickActions({
    super.key,
    this.onDrawCard,
    this.onCompatibility,
    this.onNatalChart,
    this.onPowerDay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: AsteriaEntrance.sections([
          AnakraQuickActionButton(
            text: context.l10n.anakraQuickDrawCard,
            onPressed: onDrawCard,
          ),
          AnakraQuickActionButton(
            text: context.l10n.anakraQuickCompatibility,
            onPressed: onCompatibility,
          ),
          AnakraQuickActionButton(
            text: context.l10n.anakraQuickNatalChart,
            onPressed: onNatalChart,
          ),
          AnakraQuickActionButton(
            text: context.l10n.anakraQuickPowerDay,
            onPressed: onPowerDay,
          ),
        ]),
      ),
    );
  }
}

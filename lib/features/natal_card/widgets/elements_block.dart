import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/pearl_metric_row.dart';
import 'package:flutter/material.dart';

class ElementsBlock extends StatelessWidget {
  final String elementsDescription;
  const ElementsBlock({Key? key, required this.elementsDescription})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.natalElementsModalities.replaceAll('\n', ' '),
          style: context.textTheme.playfairSemiBold24,
        ),
        const SizedBox(height: 16),
        PearlMetricRow(
          lightSurface: true,
          metrics: [
            for (final (value, label) in [
              (3, context.l10n.elementFire),
              (4, context.l10n.elementWater),
              (2, context.l10n.elementAir),
              (6, context.l10n.elementEarth),
            ])
              PearlMetric(label, '$value', value / 10),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          elementsDescription,
          style: context.textTheme.urbanistRegular16,
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}

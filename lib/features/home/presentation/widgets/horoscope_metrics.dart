import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/pearl_metric_row.dart';
import 'package:flutter/material.dart';

/// Метрики гороскопа с круговыми индикаторами
class HoroscopeMetrics extends StatelessWidget {
  final String lovePercentage;
  final String financesPercentage;
  final String energyPercentage;
  const HoroscopeMetrics({
    Key? key,
    required this.lovePercentage,
    required this.financesPercentage,
    required this.energyPercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PearlMetricRow(
      lightSurface: true,
      metrics: [
        PearlMetric.percentage(context.l10n.personalLove, lovePercentage),
        PearlMetric.percentage(
          context.l10n.personalFinances,
          financesPercentage,
        ),
        PearlMetric.percentage(context.l10n.personalEnergy, energyPercentage),
      ],
    );
  }
}

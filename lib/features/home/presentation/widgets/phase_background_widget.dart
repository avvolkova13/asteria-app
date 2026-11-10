import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';
import 'package:asteria_app/features/home/presentation/models/day_status_advice.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/widgets/advice_widget.dart';
import 'package:flutter/material.dart';

class PhaseBackgroundWidget extends StatelessWidget {
  const PhaseBackgroundWidget({
    super.key,
    required this.background,
    this.recommendation,
  });

  final DailyBackgroundModel background;
  final SphereRecommendationModel? recommendation;

  @override
  Widget build(BuildContext context) {
    final status = recommendation == null
        ? null
        : DayStatus.fromRecommendation(recommendation!.status);
    return AdviceWidget(
      title: status?.title(context).replaceAll('\n', ' ') ?? background.title,
      text: background.summary,
      status: status,
    );
  }
}

import 'package:asteria_app/core/extensions/build_context_extensions.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:flutter/material.dart';

extension DayStatusAdvice on DayStatus {
  String title(BuildContext context) {
    switch (this) {
      case DayStatus.favorable:
        return context.l10n.dayFavorable;
      case DayStatus.neutral:
        return context.l10n.dayNeutral;
      case DayStatus.unfavorable:
        return context.l10n.dayUnfavorable;
    }
  }

  String description(BuildContext context) {
    switch (this) {
      case DayStatus.favorable:
        return context.l10n.dayFavorableDescription;
      case DayStatus.neutral:
        return context.l10n.dayNeutralDescription;
      case DayStatus.unfavorable:
        return context.l10n.dayUnfavorableDescription;
    }
  }
}

import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/extensions/build_context_extensions.dart';
import 'package:flutter/widgets.dart';

extension TimeOfDayEnumExtensions on TimeOfDayEnum {
  String label(BuildContext context) {
    switch (this) {
      case TimeOfDayEnum.morning:
        return context.l10n.dayTimeOptionLabel;
      case TimeOfDayEnum.night:
        return context.l10n.nightTimeOptionLabel;
      case TimeOfDayEnum.unknown:
        return context.l10n.unknownTimeOptionLabel;
    }
  }
}

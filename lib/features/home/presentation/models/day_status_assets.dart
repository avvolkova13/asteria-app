import 'package:asteria_app/features/home/presentation/models/day_status.dart';

extension DayStatusAssets on DayStatus {
  String get iconAssetPath {
    return switch (this) {
      DayStatus.favorable => 'assets/icons/day_status_favorable_star.png',
      DayStatus.neutral => 'assets/icons/day_status_neutral_star.png',
      DayStatus.unfavorable => 'assets/icons/day_status_unfavorable_star.png',
    };
  }
}

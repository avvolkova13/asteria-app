import 'package:asteria_app/app/data/models/lunar_calendar/personalized_lunar_month_model.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/widgets/sphere_selection_widget.dart';
import 'package:equatable/equatable.dart';

enum MoonScreenErrorCode { loadData }

class MoonScreenState extends Equatable {
  final bool isLoading;
  final MoonScreenErrorCode? error;
  final DateTime? selectedDate;
  final DateTime focusedDay;
  final Map<DateTime, DayStatus> dayStatuses;
  final Set<DateTime> primaryPhaseDates;
  final Sphere? selectedSphere;
  final PersonalizedLunarDayModel? selectedPersonalizedDayData;
  final DayStatus selectedDayStatus;

  const MoonScreenState({
    this.isLoading = false,
    this.error,
    this.selectedDate,
    required this.focusedDay,
    this.dayStatuses = const {},
    this.primaryPhaseDates = const {},
    this.selectedSphere,
    this.selectedPersonalizedDayData,
    this.selectedDayStatus = DayStatus.neutral,
  });

  MoonScreenState copyWith({
    bool? isLoading,
    MoonScreenErrorCode? error,
    bool clearError = false,
    DateTime? selectedDate,
    DateTime? focusedDay,
    Map<DateTime, DayStatus>? dayStatuses,
    Set<DateTime>? primaryPhaseDates,
    Sphere? selectedSphere,
    bool clearSelectedSphere = false,
    PersonalizedLunarDayModel? selectedPersonalizedDayData,
    bool clearSelectedPersonalizedDayData = false,
    DayStatus? selectedDayStatus,
  }) {
    return MoonScreenState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      selectedDate: selectedDate ?? this.selectedDate,
      focusedDay: focusedDay ?? this.focusedDay,
      dayStatuses: dayStatuses ?? this.dayStatuses,
      primaryPhaseDates: primaryPhaseDates ?? this.primaryPhaseDates,
      selectedSphere: clearSelectedSphere
          ? null
          : selectedSphere ?? this.selectedSphere,
      selectedPersonalizedDayData: clearSelectedPersonalizedDayData
          ? null
          : selectedPersonalizedDayData ?? this.selectedPersonalizedDayData,
      selectedDayStatus: selectedDayStatus ?? this.selectedDayStatus,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
    selectedDate,
    focusedDay,
    dayStatuses,
    primaryPhaseDates,
    selectedSphere,
    selectedPersonalizedDayData,
    selectedDayStatus,
  ];
}

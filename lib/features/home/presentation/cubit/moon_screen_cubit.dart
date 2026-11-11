import 'package:asteria_app/app/data/models/lunar_calendar/personalized_lunar_month_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_state.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/widgets/sphere_selection_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MoonScreenCubit extends Cubit<MoonScreenState> {
  final ContentProvider _contentProvider;

  MoonScreenCubit({ContentProvider? contentProvider})
    : _contentProvider = contentProvider ?? di.get<ContentProvider>(),
      super(MoonScreenState(focusedDay: DateTime.now()));

  int _requestGeneration = 0;

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final generation = ++_requestGeneration;
    try {
      final now = DateTime.now();
      final normalizedDate = DateTime(now.year, now.month, now.day);
      await _contentProvider.loadPersonalizedLunarMonth(now);
      if (isClosed || generation != _requestGeneration) return;
      final personalizedDay = _contentProvider.getPersonalizedLunarDayByDate(
        normalizedDate,
      );
      final dayStatuses = _generateDayStatuses(now, state.selectedSphere);
      final primaryPhaseDates = _generatePrimaryPhaseDates(now);
      final selectedDayStatus = _getStatusForPersonalizedDay(
        personalizedDay,
        state.selectedSphere,
      );

      emit(
        state.copyWith(
          isLoading: false,
          selectedDate: now,
          focusedDay: now,
          dayStatuses: dayStatuses,
          primaryPhaseDates: primaryPhaseDates,
          clearSelectedSphere: state.selectedSphere == null,
          selectedPersonalizedDayData: personalizedDay,
          clearSelectedPersonalizedDayData: personalizedDay == null,
          selectedDayStatus: selectedDayStatus,
        ),
      );
    } catch (e) {
      if (isClosed || generation != _requestGeneration) return;
      emit(
        state.copyWith(isLoading: false, error: MoonScreenErrorCode.loadData),
      );
    }
  }

  void selectDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final personalizedDay = _contentProvider.getPersonalizedLunarDayByDate(
      normalizedDate,
    );
    emit(
      state.copyWith(
        selectedDate: date,
        selectedPersonalizedDayData: personalizedDay,
        clearSelectedPersonalizedDayData: personalizedDay == null,
        selectedDayStatus: _getStatusForPersonalizedDay(
          personalizedDay,
          state.selectedSphere,
        ),
      ),
    );
  }

  Future<void> loadDayStatuses(DateTime month) async {
    await loadMonth(month);
  }

  Future<void> loadMonth(DateTime month, {bool forceRefresh = false}) async {
    final generation = ++_requestGeneration;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _contentProvider.loadPersonalizedLunarMonth(
        month,
        forceRefresh: forceRefresh,
      );
      if (isClosed || generation != _requestGeneration) return;
      final dayStatuses = _generateDayStatuses(month, state.selectedSphere);
      final primaryPhaseDates = _generatePrimaryPhaseDates(month);
      final selectedDate = _selectedDateForLoadedMonth(month);
      final personalizedDay = _contentProvider.getPersonalizedLunarDayByDate(
        selectedDate,
      );
      emit(
        state.copyWith(
          isLoading: false,
          focusedDay: month,
          selectedDate: selectedDate,
          dayStatuses: dayStatuses,
          primaryPhaseDates: primaryPhaseDates,
          selectedPersonalizedDayData: personalizedDay,
          clearSelectedPersonalizedDayData: personalizedDay == null,
          selectedDayStatus: _getStatusForPersonalizedDay(
            personalizedDay,
            state.selectedSphere,
          ),
        ),
      );
    } catch (_) {
      if (isClosed || generation != _requestGeneration) return;
      emit(
        state.copyWith(isLoading: false, error: MoonScreenErrorCode.loadData),
      );
    }
  }

  DateTime _selectedDateForLoadedMonth(DateTime month) {
    final previousSelectedDate = state.selectedDate ?? month;
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0).day;
    final clampedDay = previousSelectedDate.day.clamp(1, lastDayOfMonth);
    return DateTime(month.year, month.month, clampedDay);
  }

  void selectSphere(Sphere? sphere) {
    final dayStatuses = _generateDayStatuses(state.focusedDay, sphere);
    final primaryPhaseDates = _generatePrimaryPhaseDates(state.focusedDay);
    final selectedDate = state.selectedDate;
    final personalizedDay = selectedDate == null
        ? state.selectedPersonalizedDayData
        : _contentProvider.getPersonalizedLunarDayByDate(selectedDate);

    emit(
      state.copyWith(
        selectedSphere: sphere,
        clearSelectedSphere: sphere == null,
        dayStatuses: dayStatuses,
        primaryPhaseDates: primaryPhaseDates,
        selectedPersonalizedDayData: personalizedDay,
        clearSelectedPersonalizedDayData: personalizedDay == null,
        selectedDayStatus: _getStatusForPersonalizedDay(
          personalizedDay,
          sphere,
        ),
      ),
    );
  }

  Map<DateTime, DayStatus> _generateDayStatuses(
    DateTime month,
    Sphere? selectedSphere,
  ) {
    final Map<DateTime, DayStatus> statuses = {};
    final lastDay = DateTime(month.year, month.month + 1, 0);

    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(month.year, month.month, day);
      final normalizedDate = DateTime(date.year, date.month, date.day);

      final lunarDay = _contentProvider.getPersonalizedLunarDayByDate(
        normalizedDate,
      );

      if (lunarDay != null && selectedSphere != null) {
        final status = _getStatusForSphere(lunarDay, selectedSphere);
        statuses[normalizedDate] = status;
      }
    }

    return statuses;
  }

  Set<DateTime> _generatePrimaryPhaseDates(DateTime month) {
    final dates = <DateTime>{};
    final lastDay = DateTime(month.year, month.month + 1, 0);

    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(month.year, month.month, day);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final lunarDay = _contentProvider.getPersonalizedLunarDayByDate(
        normalizedDate,
      );

      if (lunarDay?.lunarContext.phaseEvent != null) {
        dates.add(normalizedDate);
      }
    }

    return dates;
  }

  DayStatus _getStatusForSphere(PersonalizedLunarDayModel day, Sphere sphere) {
    final recommendation = day.spheres[_sphereApiCode(sphere)];
    if (recommendation == null) return DayStatus.neutral;
    return DayStatus.fromRecommendation(recommendation.status);
  }

  DayStatus _getStatusForPersonalizedDay(
    PersonalizedLunarDayModel? lunarDay,
    Sphere? sphere,
  ) {
    if (lunarDay == null || sphere == null) {
      return DayStatus.neutral;
    }

    return _getStatusForSphere(lunarDay, sphere);
  }

  String _sphereApiCode(Sphere sphere) {
    return switch (sphere) {
      Sphere.beauty => 'beauty',
      Sphere.garden => 'gardening',
      Sphere.health => 'health',
      Sphere.workAndRest => 'work_and_rest',
      Sphere.relationships => 'relationships',
    };
  }
}

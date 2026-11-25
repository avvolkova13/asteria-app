import 'package:asteria_app/app/data/models/lunar_calendar/personalized_lunar_month_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_state.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/models/lunar_almanac.dart';
import 'package:asteria_app/features/home/presentation/widgets/sphere_selection_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MoonScreenCubit extends Cubit<MoonScreenState> {
  final ContentProvider _contentProvider;

  MoonScreenCubit({ContentProvider? contentProvider})
    : _contentProvider = contentProvider ?? di.get<ContentProvider>(),
      super(MoonScreenState(focusedDay: DateTime.now()));

  int _requestGeneration = 0;

  Future<void> loadData() => loadMonth(DateTime.now());

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
    final changingMonth =
        state.focusedDay.year != month.year ||
        state.focusedDay.month != month.month;
    emit(
      state.copyWith(
        focusedDay: month,
        selectedDate: _selectedDateForLoadedMonth(month),
        isLoading: true,
        clearError: true,
        dayStatuses: changingMonth ? const {} : null,
        primaryPhaseDates: changingMonth || state.selectedDate == null
            ? _generatePrimaryPhaseDates(month)
            : null,
        clearSelectedPersonalizedDayData: changingMonth,
        selectedDayStatus: changingMonth ? DayStatus.neutral : null,
      ),
    );
    try {
      await _contentProvider.loadPersonalizedLunarMonth(
        month,
        forceRefresh: forceRefresh,
      );
      if (isClosed || generation != _requestGeneration) return;
      final personalizedDay = _contentProvider.getPersonalizedLunarDayByDate(
        state.selectedDate!,
      );
      emit(
        state.copyWith(
          isLoading: false,
          dayStatuses: _generateDayStatuses(state.selectedSphere),
          primaryPhaseDates: _generatePrimaryPhaseDates(month),
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
    final date = state.selectedDate;
    final personalizedDay = date == null
        ? null
        : _contentProvider.getPersonalizedLunarDayByDate(date);
    emit(
      state.copyWith(
        selectedSphere: sphere,
        clearSelectedSphere: sphere == null,
        dayStatuses: _generateDayStatuses(sphere),
        primaryPhaseDates: _generatePrimaryPhaseDates(state.focusedDay),
        selectedPersonalizedDayData: personalizedDay,
        clearSelectedPersonalizedDayData: personalizedDay == null,
        selectedDayStatus: _getStatusForPersonalizedDay(
          personalizedDay,
          sphere,
        ),
      ),
    );
  }

  Map<DateTime, DayStatus> _generateDayStatuses(Sphere? sphere) {
    if (sphere == null) return const {};
    final month = state.focusedDay;
    final last = DateTime(month.year, month.month + 1, 0).day;
    final statuses = <DateTime, DayStatus>{};
    for (var day = 1; day <= last; day++) {
      final date = DateTime(month.year, month.month, day);
      final data = _contentProvider.getPersonalizedLunarDayByDate(date);
      if (data != null) statuses[date] = _getStatusForSphere(data, sphere);
    }
    return statuses;
  }

  Set<DateTime> _generatePrimaryPhaseDates(DateTime month) {
    final dates = <DateTime>{};
    final lastDay = DateTime(month.year, month.month + 1, 0);

    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(month.year, month.month, day);
      final lunarDay = _contentProvider.getPersonalizedLunarDayByDate(date);
      final marksPhaseChange = lunarDay == null
          ? LunarAlmanacDay.on(date)?.phase.marksPhaseChange == true
          : lunarDay.lunarContext.phaseEvent != null;
      if (marksPhaseChange) {
        dates.add(date);
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

import 'package:asteria_app/app/data/repositories/app_settings/app_settings_repository.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/onboarding_page_model.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final AppSettingsRepository _appSettingsRepository;

  /// Timestamp captured on the first onboarding screen; used to compute
  /// `completion_seconds` for `ast_onboarding_complete`.
  DateTime? _startedAt;

  OnboardingBloc(this._appSettingsRepository) : super(const OnboardingState()) {
    on<OnboardingInitialized>(_onInitialized);
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingNextPage>(_onNextPage);
    on<OnboardingPreviousPage>(_onPreviousPage);
    on<OnboardingSkip>(_onSkip);
    on<OnboardingFinish>(_onFinish);
  }

  void _onInitialized(
    OnboardingInitialized event,
    Emitter<OnboardingState> emit,
  ) {
    if (event.pages.isEmpty) {
      emit(state.copyWith(error: OnboardingErrorCode.emptyPages));
      return;
    }

    final bool showOnboarding = _appSettingsRepository.getShowOnboarding();

    debugPrint('showOnboarding: $showOnboarding');

    for (int i = 0; i < event.pages.length; i++) {}

    final facade = di.get<AnalyticsFacade>();
    facade.trackEvent(AnalyticsEvents.onboardingStart);
    facade.trackEvent(
      AnalyticsEvents.onboardingStepView,
      params: {EventParams.stepIndex: 0, EventParams.stepName: 'page_0'},
    );
    // ast_onboarding_start — fired alongside the legacy event so dashboards
    // can migrate to the new taxonomy without losing history. Also start
    // the completion-time timer.
    _startedAt = DateTime.now();
    di.get<ProductAnalyticsService>().trackOnboardingStart();

    emit(
      state.copyWith(
        pages: event.pages,
        currentPageIndex: 0,
        isLastPage: event.pages.length == 1,
        clearError: true,
      ),
    );
  }

  void _onPageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    if (event.pageIndex < 0 || event.pageIndex >= state.pages.length) {
      emit(state.copyWith(error: OnboardingErrorCode.invalidPageIndex));
      return;
    }

    final isLastPage = event.pageIndex == state.pages.length - 1;
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.onboardingStepView,
      params: {
        EventParams.stepIndex: event.pageIndex,
        EventParams.stepName: 'page_${event.pageIndex}',
      },
    );
    emit(
      state.copyWith(
        currentPageIndex: event.pageIndex,
        isLastPage: isLastPage,
        clearError: true,
      ),
    );
  }

  void _onNextPage(OnboardingNextPage event, Emitter<OnboardingState> emit) {
    if (state.currentPageIndex < state.pages.length - 1) {
      final nextIndex = state.currentPageIndex + 1;
      final isLastPage = nextIndex == state.pages.length - 1;
      final facade = di.get<AnalyticsFacade>();
      facade.trackEvent(
        AnalyticsEvents.onboardingStepCompleted,
        params: {
          EventParams.stepIndex: state.currentPageIndex,
          EventParams.stepName: 'page_${state.currentPageIndex}',
        },
      );
      // step_view fires from _onPageChanged once PageView finishes its
      // animation — emitting it here too caused a duplicate per tap.
      emit(
        state.copyWith(
          currentPageIndex: nextIndex,
          isLastPage: isLastPage,
          clearError: true,
        ),
      );
    }
  }

  void _onPreviousPage(
    OnboardingPreviousPage event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.currentPageIndex > 0) {
      final previousIndex = state.currentPageIndex - 1;
      final isLastPage = previousIndex == state.pages.length - 1;
      emit(
        state.copyWith(
          currentPageIndex: previousIndex,
          isLastPage: isLastPage,
          clearError: true,
        ),
      );
    }
  }

  void _onSkip(OnboardingSkip event, Emitter<OnboardingState> emit) {
    if (state.pages.isEmpty) return;

    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.onboardingSkipped,
      params: {
        EventParams.stepIndex: state.currentPageIndex,
        EventParams.stepName: 'page_${state.currentPageIndex}',
      },
    );

    emit(
      state.copyWith(
        currentPageIndex: state.pages.length - 1,
        isLastPage: true,
        clearError: true,
      ),
    );
  }

  void _onFinish(OnboardingFinish event, Emitter<OnboardingState> emit) {
    _appSettingsRepository.setShowOnboarding(false);
    final facade = di.get<AnalyticsFacade>();
    facade.trackEvent(AnalyticsEvents.onboardingCompleted);
    // ast_onboarding_complete with steps_count + completion_seconds.
    final int? completionSeconds = _startedAt == null
        ? null
        : DateTime.now().difference(_startedAt!).inSeconds;
    di.get<ProductAnalyticsService>().trackOnboardingComplete(
      stepsCount: state.pages.length,
      completionSeconds: completionSeconds,
    );
    emit(state.copyWith(isCompleted: true, clearError: true));
  }
}

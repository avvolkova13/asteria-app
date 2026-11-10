part of 'onboarding_bloc.dart';

enum OnboardingErrorCode { emptyPages, invalidPageIndex }

class OnboardingState {
  final List<OnboardingPageModel> pages;
  final int currentPageIndex;
  final bool isLastPage;
  final bool isCompleted;
  final OnboardingErrorCode? error;

  const OnboardingState({
    this.pages = const [],
    this.currentPageIndex = 0,
    this.isLastPage = false,
    this.isCompleted = false,
    this.error,
  });

  OnboardingState copyWith({
    List<OnboardingPageModel>? pages,
    int? currentPageIndex,
    bool? isLastPage,
    bool? isCompleted,
    OnboardingErrorCode? error,
    bool clearError = false,
  }) {
    return OnboardingState(
      pages: pages ?? this.pages,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      isLastPage: isLastPage ?? this.isLastPage,
      isCompleted: isCompleted ?? this.isCompleted,
      error: clearError ? null : error ?? this.error,
    );
  }

  OnboardingPageModel? get currentPage {
    if (pages.isEmpty || currentPageIndex >= pages.length) {
      return null;
    }
    return pages[currentPageIndex];
  }

  double get progress {
    if (pages.isEmpty) return 0.0;
    return (currentPageIndex + 1) / pages.length;
  }
}

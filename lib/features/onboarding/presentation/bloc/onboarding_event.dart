part of 'onboarding_bloc.dart';

abstract class OnboardingEvent {
  const OnboardingEvent();
}

class OnboardingInitialized extends OnboardingEvent {
  final List<OnboardingPageModel> pages;

  const OnboardingInitialized(this.pages);
}

class OnboardingPageChanged extends OnboardingEvent {
  final int pageIndex;

  const OnboardingPageChanged(this.pageIndex);
}

class OnboardingNextPage extends OnboardingEvent {}

class OnboardingPreviousPage extends OnboardingEvent {}

class OnboardingSkip extends OnboardingEvent {}

class OnboardingFinish extends OnboardingEvent {}

enum OnboardingVisualKind { hero, daily, tarot, personal }

class OnboardingPageModel {
  final String title;
  final String description;
  final OnboardingVisualKind visualKind;
  final int pageIndex;

  const OnboardingPageModel({
    required this.title,
    required this.description,
    required this.visualKind,
    required this.pageIndex,
  });
}

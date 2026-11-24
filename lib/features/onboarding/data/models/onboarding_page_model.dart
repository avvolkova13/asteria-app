enum OnboardingVisualKind {
  hero,
  daily,
  tarot,
  personal,
  natal,
  practice,
  dream,
  guide,
}

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

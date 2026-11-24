import 'package:asteria_app/core/localization/localization.dart';
import 'package:flutter/widgets.dart';

import 'models/onboarding_page_model.dart';

class OnboardingData {
  static List<OnboardingPageModel> getPages(BuildContext context) {
    final l = AppLocalizations.of(context);
    return [
      OnboardingPageModel(
        title: l.onboardingPage1Title,
        description: l.onboardingPage1Description,
        visualKind: OnboardingVisualKind.hero,
        pageIndex: 0,
      ),
      OnboardingPageModel(
        title: l.onboardingNatalTarotTitle,
        description: l.onboardingNatalTarotDescription,
        visualKind: OnboardingVisualKind.natalTarot,
        pageIndex: 1,
      ),
      OnboardingPageModel(
        title: l.onboardingDreamTitle,
        description: l.onboardingDreamDescription,
        visualKind: OnboardingVisualKind.dream,
        pageIndex: 2,
      ),
      OnboardingPageModel(
        title: l.onboardingPracticeTitle,
        description: l.onboardingPracticeDescription,
        visualKind: OnboardingVisualKind.practice,
        pageIndex: 3,
      ),
    ];
  }
}

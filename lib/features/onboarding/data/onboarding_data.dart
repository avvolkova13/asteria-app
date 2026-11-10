import 'models/onboarding_page_model.dart';
import '../localization/onboarding_localization_contract.dart';
import 'package:flutter/material.dart';

class OnboardingData {
  static List<OnboardingPageModel> getPages(BuildContext context) {
    final localization = OnboardingLocalization();

    final pages = [
      OnboardingPageModel(
        title: localization.onboardingPage1Title(context),
        description: localization.onboardingPage1Description(context),
        visualKind: OnboardingVisualKind.hero,
        pageIndex: 0,
      ),
      OnboardingPageModel(
        title: localization.onboardingPage2Title(context),
        description: localization.onboardingPage2Description(context),
        visualKind: OnboardingVisualKind.daily,
        pageIndex: 1,
      ),
      OnboardingPageModel(
        title: localization.onboardingPage3Title(context),
        description: localization.onboardingPage3Description(context),
        visualKind: OnboardingVisualKind.tarot,
        pageIndex: 2,
      ),
      OnboardingPageModel(
        title: localization.onboardingPage4Title(context),
        description: localization.onboardingPage4Description(context),
        visualKind: OnboardingVisualKind.personal,
        pageIndex: 3,
      ),
    ];

    return pages;
  }
}

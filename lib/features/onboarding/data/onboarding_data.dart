import 'package:asteria_app/core/localization/localization.dart';
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
        visualKind: OnboardingVisualKind.natal,
        pageIndex: 1,
      ),
      OnboardingPageModel(
        title: localization.onboardingPage3Title(context),
        description: localization.onboardingPage3Description(context),
        visualKind: OnboardingVisualKind.personal,
        pageIndex: 2,
      ),
      OnboardingPageModel(
        title: localization.onboardingPage4Title(context),
        description: localization.onboardingPage4Description(context),
        visualKind: OnboardingVisualKind.tarot,
        pageIndex: 3,
      ),
      OnboardingPageModel(
        title: localization.onboardingPage5Title(context),
        description: localization.onboardingPage5Description(context),
        visualKind: OnboardingVisualKind.daily,
        pageIndex: 4,
      ),
      OnboardingPageModel(
        title: AppLocalizations.of(context).onboardingPracticeTitle,
        description: AppLocalizations.of(context).onboardingPracticeDescription,
        visualKind: OnboardingVisualKind.practice,
        pageIndex: 5,
      ),
      OnboardingPageModel(
        title: AppLocalizations.of(context).onboardingDreamTitle,
        description: AppLocalizations.of(context).onboardingDreamDescription,
        visualKind: OnboardingVisualKind.dream,
        pageIndex: 6,
      ),
      OnboardingPageModel(
        title: AppLocalizations.of(context).onboardingGuideTitle,
        description: AppLocalizations.of(context).onboardingGuideDescription,
        visualKind: OnboardingVisualKind.guide,
        pageIndex: 7,
      ),
    ];

    return pages;
  }
}

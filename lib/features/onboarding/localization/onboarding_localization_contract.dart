import 'package:flutter/material.dart';
import '../../../core/localization/localization.dart';

abstract class OnboardingLocalizationContract {
  String onboardingPage1Title(BuildContext context);
  String onboardingPage1Description(BuildContext context);
  String onboardingPage2Title(BuildContext context);
  String onboardingPage2Description(BuildContext context);
  String onboardingPage3Title(BuildContext context);
  String onboardingPage3Description(BuildContext context);
  String onboardingPage4Title(BuildContext context);
  String onboardingPage4Description(BuildContext context);

  String nextButton(BuildContext context);
  String finishButton(BuildContext context);
}

class OnboardingLocalization implements OnboardingLocalizationContract {
  @override
  String onboardingPage1Title(BuildContext context) =>
      AppLocalizations.of(context).onboardingPage1Title;

  @override
  String onboardingPage1Description(BuildContext context) =>
      AppLocalizations.of(context).onboardingPage1Description;

  @override
  String onboardingPage2Title(BuildContext context) =>
      AppLocalizations.of(context).onboardingPage2Title;

  @override
  String onboardingPage2Description(BuildContext context) =>
      AppLocalizations.of(context).onboardingPage2Description;

  @override
  String onboardingPage3Title(BuildContext context) =>
      AppLocalizations.of(context).onboardingPage3Title;

  @override
  String onboardingPage3Description(BuildContext context) =>
      AppLocalizations.of(context).onboardingPage3Description;

  @override
  String onboardingPage4Title(BuildContext context) =>
      AppLocalizations.of(context).onboardingPage4Title;

  @override
  String onboardingPage4Description(BuildContext context) =>
      AppLocalizations.of(context).onboardingPage4Description;

  @override
  String nextButton(BuildContext context) => AppLocalizations.of(context).next;

  @override
  String finishButton(BuildContext context) =>
      AppLocalizations.of(context).done;
}

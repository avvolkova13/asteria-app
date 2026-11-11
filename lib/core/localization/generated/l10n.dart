// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class AppLocalizations {
  AppLocalizations();

  static AppLocalizations? _current;

  static AppLocalizations get current {
    assert(
      _current != null,
      'No instance of AppLocalizations was loaded. Try to initialize the AppLocalizations delegate before accessing AppLocalizations.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<AppLocalizations> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = AppLocalizations();
      AppLocalizations._current = instance;

      return instance;
    });
  }

  static AppLocalizations of(BuildContext context) {
    final instance = AppLocalizations.maybeOf(context);
    assert(
      instance != null,
      'No instance of AppLocalizations present in the widget tree. Did you add AppLocalizations.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// `Asteria\nYour universe of\nforecasts and signs`
  String get onboardingPage1Title {
    return Intl.message(
      'Asteria\nYour universe of\nforecasts and signs',
      name: 'onboardingPage1Title',
      desc: '',
      args: [],
    );
  }

  /// `Moon phases, tarot, your birth chart,\nand personal guidance every day`
  String get onboardingPage1Description {
    return Intl.message(
      'Moon phases, tarot, your birth chart,\nand personal guidance every day',
      name: 'onboardingPage1Description',
      desc: '',
      args: [],
    );
  }

  /// `Discover\nwhat today holds\nfor you`
  String get onboardingPage2Title {
    return Intl.message(
      'Discover\nwhat today holds\nfor you',
      name: 'onboardingPage2Title',
      desc: '',
      args: [],
    );
  }

  /// `Moon phases, daily energy,\nfavorable periods, and guidance`
  String get onboardingPage2Description {
    return Intl.message(
      'Moon phases, daily energy,\nfavorable periods, and guidance',
      name: 'onboardingPage2Description',
      desc: '',
      args: [],
    );
  }

  /// `Find answers\nthrough tarot\nand an AI astrologer`
  String get onboardingPage3Title {
    return Intl.message(
      'Find answers\nthrough tarot\nand an AI astrologer',
      name: 'onboardingPage3Title',
      desc: '',
      args: [],
    );
  }

  /// `Readings, advice,\nand personal interpretations`
  String get onboardingPage3Description {
    return Intl.message(
      'Readings, advice,\nand personal interpretations',
      name: 'onboardingPage3Description',
      desc: '',
      args: [],
    );
  }

  /// `Learn more\nabout yourself and\nyour energy`
  String get onboardingPage4Title {
    return Intl.message(
      'Learn more\nabout yourself and\nyour energy',
      name: 'onboardingPage4Title',
      desc: '',
      args: [],
    );
  }

  /// `Your birth chart, compatibility,\nand personal forecasts`
  String get onboardingPage4Description {
    return Intl.message(
      'Your birth chart, compatibility,\nand personal forecasts',
      name: 'onboardingPage4Description',
      desc: '',
      args: [],
    );
  }

  /// `Discover new possibilities`
  String get step1Title {
    return Intl.message(
      'Discover new possibilities',
      name: 'step1Title',
      desc: '',
      args: [],
    );
  }

  /// `Explore every feature and start using Asteria today`
  String get step1Description {
    return Intl.message(
      'Explore every feature and start using Asteria today',
      name: 'step1Description',
      desc: '',
      args: [],
    );
  }

  /// `Simple and convenient`
  String get step2Title {
    return Intl.message(
      'Simple and convenient',
      name: 'step2Title',
      desc: '',
      args: [],
    );
  }

  /// `An intuitive interface helps you get started quickly`
  String get step2Description {
    return Intl.message(
      'An intuitive interface helps you get started quickly',
      name: 'step2Description',
      desc: '',
      args: [],
    );
  }

  /// `Ready to begin?`
  String get step3Title {
    return Intl.message(
      'Ready to begin?',
      name: 'step3Title',
      desc: '',
      args: [],
    );
  }

  /// `Join the community and unlock everything Asteria offers`
  String get step3Description {
    return Intl.message(
      'Join the community and unlock everything Asteria offers',
      name: 'step3Description',
      desc: '',
      args: [],
    );
  }

  /// `Get started`
  String get getStartedButton {
    return Intl.message(
      'Get started',
      name: 'getStartedButton',
      desc: '',
      args: [],
    );
  }

  /// `Onboarding content is unavailable.`
  String get onboardingEmptyPagesError {
    return Intl.message(
      'Onboarding content is unavailable.',
      name: 'onboardingEmptyPagesError',
      desc: '',
      args: [],
    );
  }

  /// `This onboarding page is unavailable.`
  String get onboardingInvalidPageError {
    return Intl.message(
      'This onboarding page is unavailable.',
      name: 'onboardingInvalidPageError',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `Theme demo`
  String get demoTheme {
    return Intl.message('Theme demo', name: 'demoTheme', desc: '', args: []);
  }

  /// `Get code`
  String get getCodeText {
    return Intl.message('Get code', name: 'getCodeText', desc: '', args: []);
  }

  /// `Privacy Policy`
  String get policyText {
    return Intl.message(
      'Privacy Policy',
      name: 'policyText',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Use`
  String get agreementText {
    return Intl.message(
      'Terms of Use',
      name: 'agreementText',
      desc: '',
      args: [],
    );
  }

  /// `and`
  String get legalTermsConnector {
    return Intl.message('and', name: 'legalTermsConnector', desc: '', args: []);
  }

  /// `Resend code in`
  String get resendCodeText {
    return Intl.message(
      'Resend code in',
      name: 'resendCodeText',
      desc: '',
      args: [],
    );
  }

  /// `Send a new code`
  String get resendCodeButtonText {
    return Intl.message(
      'Send a new code',
      name: 'resendCodeButtonText',
      desc: '',
      args: [],
    );
  }

  /// `Saving...`
  String get saveButtonLoadingText {
    return Intl.message(
      'Saving...',
      name: 'saveButtonLoadingText',
      desc: '',
      args: [],
    );
  }

  /// `Discover your cosmic self`
  String get personalInfoTitle {
    return Intl.message(
      'Discover your cosmic self',
      name: 'personalInfoTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tune in to the Moon and reveal your birth chart—it can illuminate your path.`
  String get personalInfoSubtitle {
    return Intl.message(
      'Tune in to the Moon and reveal your birth chart—it can illuminate your path.',
      name: 'personalInfoSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter your date, time, and place of birth, and let the Universe speak to you.`
  String get personalInfoDescription {
    return Intl.message(
      'Enter your date, time, and place of birth, and let the Universe speak to you.',
      name: 'personalInfoDescription',
      desc: '',
      args: [],
    );
  }

  /// `Man`
  String get maleGender {
    return Intl.message('Man', name: 'maleGender', desc: '', args: []);
  }

  /// `Woman`
  String get femaleGender {
    return Intl.message('Woman', name: 'femaleGender', desc: '', args: []);
  }

  /// `Place of birth`
  String get birthPlaceLabel {
    return Intl.message(
      'Place of birth',
      name: 'birthPlaceLabel',
      desc: '',
      args: [],
    );
  }

  /// `Date of birth`
  String get birthDateLabel {
    return Intl.message(
      'Date of birth',
      name: 'birthDateLabel',
      desc: '',
      args: [],
    );
  }

  /// `Time of birth`
  String get birthTimeLabel {
    return Intl.message(
      'Time of birth',
      name: 'birthTimeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Exact time is unknown`
  String get exactTimeUnknown {
    return Intl.message(
      'Exact time is unknown',
      name: 'exactTimeUnknown',
      desc: '',
      args: [],
    );
  }

  /// `Daytime`
  String get dayTimeOptionLabel {
    return Intl.message(
      'Daytime',
      name: 'dayTimeOptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Nighttime`
  String get nightTimeOptionLabel {
    return Intl.message(
      'Nighttime',
      name: 'nightTimeOptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Time unknown`
  String get unknownTimeOptionLabel {
    return Intl.message(
      'Time unknown',
      name: 'unknownTimeOptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Select your date of birth`
  String get birthDatePickerTitle {
    return Intl.message(
      'Select your date of birth',
      name: 'birthDatePickerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select your time of birth`
  String get birthTimePickerTitle {
    return Intl.message(
      'Select your time of birth',
      name: 'birthTimePickerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get nameLabel {
    return Intl.message('Name', name: 'nameLabel', desc: '', args: []);
  }

  /// `Place of birth`
  String get placeLabel {
    return Intl.message(
      'Place of birth',
      name: 'placeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Your birth time affects calculation accuracy. If you don't know it, you can enter an approximate time. Some details may be less precise without an exact time.`
  String get exactTimeUnknownDescription {
    return Intl.message(
      'Your birth time affects calculation accuracy. If you don\'t know it, you can enter an approximate time. Some details may be less precise without an exact time.',
      name: 'exactTimeUnknownDescription',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get homeTitle {
    return Intl.message('Home', name: 'homeTitle', desc: '', args: []);
  }

  /// `Hello`
  String get helloText {
    return Intl.message('Hello', name: 'helloText', desc: '', args: []);
  }

  /// `Log out`
  String get logoutButton {
    return Intl.message('Log out', name: 'logoutButton', desc: '', args: []);
  }

  /// `Unable to log out`
  String get logoutError {
    return Intl.message(
      'Unable to log out',
      name: 'logoutError',
      desc: '',
      args: [],
    );
  }

  /// `User not found`
  String get userNotFoundError {
    return Intl.message(
      'User not found',
      name: 'userNotFoundError',
      desc: '',
      args: [],
    );
  }

  /// `Unable to load data`
  String get loadingDataError {
    return Intl.message(
      'Unable to load data',
      name: 'loadingDataError',
      desc: '',
      args: [],
    );
  }

  /// `Sign in or create\nan account with email`
  String get emailAuthTitle {
    return Intl.message(
      'Sign in or create\nan account with email',
      name: 'emailAuthTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email and we'll send you a six-digit verification code.`
  String get emailAuthMessage {
    return Intl.message(
      'Enter your email and we\'ll send you a six-digit verification code.',
      name: 'emailAuthMessage',
      desc: '',
      args: [],
    );
  }

  /// `By requesting a code, you accept the`
  String get emailAuthConsentPrefix {
    return Intl.message(
      'By requesting a code, you accept the',
      name: 'emailAuthConsentPrefix',
      desc: '',
      args: [],
    );
  }

  /// `Email address`
  String get emailHint {
    return Intl.message('Email address', name: 'emailHint', desc: '', args: []);
  }

  /// `Enter a valid email address`
  String get emailInvalidError {
    return Intl.message(
      'Enter a valid email address',
      name: 'emailInvalidError',
      desc: '',
      args: [],
    );
  }

  /// `We sent a code to your email`
  String get emailCodeSentText {
    return Intl.message(
      'We sent a code to your email',
      name: 'emailCodeSentText',
      desc: '',
      args: [],
    );
  }

  /// `Use a different email address`
  String get emailAccessIssueText {
    return Intl.message(
      'Use a different email address',
      name: 'emailAccessIssueText',
      desc: '',
      args: [],
    );
  }

  /// `Unable to start Asteria`
  String get initializationError {
    return Intl.message(
      'Unable to start Asteria',
      name: 'initializationError',
      desc: '',
      args: [],
    );
  }

  /// `Try again`
  String get retry {
    return Intl.message('Try again', name: 'retry', desc: '', args: []);
  }

  /// `The approved English legal document is not available in this build.`
  String get legalDocumentUnavailable {
    return Intl.message(
      'The approved English legal document is not available in this build.',
      name: 'legalDocumentUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `About Asteria`
  String get aboutTitle {
    return Intl.message(
      'About Asteria',
      name: 'aboutTitle',
      desc: '',
      args: [],
    );
  }

  /// `Terms governing access to Asteria, digital content, subscriptions, and store purchases.`
  String get agreementSummary {
    return Intl.message(
      'Terms governing access to Asteria, digital content, subscriptions, and store purchases.',
      name: 'agreementSummary',
      desc: '',
      args: [],
    );
  }

  /// `How Asteria collects, uses, stores, and protects personal data.`
  String get privacySummary {
    return Intl.message(
      'How Asteria collects, uses, stores, and protects personal data.',
      name: 'privacySummary',
      desc: '',
      args: [],
    );
  }

  /// `Subscription information`
  String get subscriptionInfoTitle {
    return Intl.message(
      'Subscription information',
      name: 'subscriptionInfoTitle',
      desc: '',
      args: [],
    );
  }

  /// `A subscription provides access to Asteria's advanced features:\n• Unlimited Dream Dictionary, Tarot, and AI Astrologer requests\n• A complete personal horoscope\n• Detailed Lunar Calendar insights\n• Full compatibility reports\n• Unlimited affirmations\nPayment is charged to your App Store or Google Play account after confirmation. The subscription renews automatically unless auto-renew is turned off at least 24 hours before the end of the current period. You can manage or cancel it in your store account settings. Payments are not refunded for unused time. See the Terms of Use for details.`
  String get subscriptionInfoDescription {
    return Intl.message(
      'A subscription provides access to Asteria\'s advanced features:\n• Unlimited Dream Dictionary, Tarot, and AI Astrologer requests\n• A complete personal horoscope\n• Detailed Lunar Calendar insights\n• Full compatibility reports\n• Unlimited affirmations\nPayment is charged to your App Store or Google Play account after confirmation. The subscription renews automatically unless auto-renew is turned off at least 24 hours before the end of the current period. You can manage or cancel it in your store account settings. Payments are not refunded for unused time. See the Terms of Use for details.',
      name: 'subscriptionInfoDescription',
      desc: '',
      args: [],
    );
  }

  /// `More signs\nfrom the stars`
  String get homeProSubscriptionTitle {
    return Intl.message(
      'More signs\nfrom the stars',
      name: 'homeProSubscriptionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Full access to Dream Dictionary, Tarot, AI Astrologer, horoscope, and Lunar Calendar`
  String get homeProSubscriptionDescription {
    return Intl.message(
      'Full access to Dream Dictionary, Tarot, AI Astrologer, horoscope, and Lunar Calendar',
      name: 'homeProSubscriptionDescription',
      desc: '',
      args: [],
    );
  }

  /// `Try 7 days free`
  String get homeProSubscriptionCta {
    return Intl.message(
      'Try 7 days free',
      name: 'homeProSubscriptionCta',
      desc: '',
      args: [],
    );
  }

  /// `Materials and licenses`
  String get licensesTitle {
    return Intl.message(
      'Materials and licenses',
      name: 'licensesTitle',
      desc: '',
      args: [],
    );
  }

  /// `Icons by HadiSharifani from Figma Community, licensed under CC BY 4.0.`
  String get licensesDescription {
    return Intl.message(
      'Icons by HadiSharifani from Figma Community, licensed under CC BY 4.0.',
      name: 'licensesDescription',
      desc: '',
      args: [],
    );
  }

  /// `Contact us`
  String get contactsTitle {
    return Intl.message(
      'Contact us',
      name: 'contactsTitle',
      desc: '',
      args: [],
    );
  }

  /// `For support, email us at:\nsupport@asteria-calendar.com`
  String get contactsDescription {
    return Intl.message(
      'For support, email us at:\nsupport@asteria-calendar.com',
      name: 'contactsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get commonError {
    return Intl.message('Error', name: 'commonError', desc: '', args: []);
  }

  /// `Cancel`
  String get commonCancel {
    return Intl.message('Cancel', name: 'commonCancel', desc: '', args: []);
  }

  /// `Select`
  String get commonSelect {
    return Intl.message('Select', name: 'commonSelect', desc: '', args: []);
  }

  /// `Back`
  String get commonBack {
    return Intl.message('Back', name: 'commonBack', desc: '', args: []);
  }

  /// `Buy`
  String get commonBuy {
    return Intl.message('Buy', name: 'commonBuy', desc: '', args: []);
  }

  /// `More`
  String get commonMore {
    return Intl.message('More', name: 'commonMore', desc: '', args: []);
  }

  /// `Not available yet`
  String get commonUnavailable {
    return Intl.message(
      'Not available yet',
      name: 'commonUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Try again`
  String get commonRetry {
    return Intl.message('Try again', name: 'commonRetry', desc: '', args: []);
  }

  /// `Continue`
  String get commonContinue {
    return Intl.message('Continue', name: 'commonContinue', desc: '', args: []);
  }

  /// `Close`
  String get commonClose {
    return Intl.message('Close', name: 'commonClose', desc: '', args: []);
  }

  /// `OK`
  String get commonOk {
    return Intl.message('OK', name: 'commonOk', desc: '', args: []);
  }

  /// `Clear`
  String get commonClear {
    return Intl.message('Clear', name: 'commonClear', desc: '', args: []);
  }

  /// `Subscription only`
  String get subscriptionOnlyTitle {
    return Intl.message(
      'Subscription only',
      name: 'subscriptionOnlyTitle',
      desc: '',
      args: [],
    );
  }

  /// `View subscription options`
  String get openSubscription {
    return Intl.message(
      'View subscription options',
      name: 'openSubscription',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong`
  String get genericSomethingWrong {
    return Intl.message(
      'Something went wrong',
      name: 'genericSomethingWrong',
      desc: '',
      args: [],
    );
  }

  /// `Check your internet connection and try again.`
  String get genericCheckConnection {
    return Intl.message(
      'Check your internet connection and try again.',
      name: 'genericCheckConnection',
      desc: '',
      args: [],
    );
  }

  /// `Error: {details}`
  String errorWithDetails(String details) {
    return Intl.message(
      'Error: $details',
      name: 'errorWithDetails',
      desc: '',
      args: [details],
    );
  }

  /// `Your profile isn't ready yet. Return to the previous step and try again.`
  String get authUserNotInitialized {
    return Intl.message(
      'Your profile isn\'t ready yet. Return to the previous step and try again.',
      name: 'authUserNotInitialized',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't save your profile. Check your connection and try again.`
  String get authSaveUserError {
    return Intl.message(
      'We couldn\'t save your profile. Check your connection and try again.',
      name: 'authSaveUserError',
      desc: '',
      args: [],
    );
  }

  /// `Welcome. I am Anakra, keeper of the star signs and your celestial path. Ask your question or choose where to begin.`
  String get anakraWelcomeMessage {
    return Intl.message(
      'Welcome. I am Anakra, keeper of the star signs and your celestial path. Ask your question or choose where to begin.',
      name: 'anakraWelcomeMessage',
      desc: '',
      args: [],
    );
  }

  /// `The server couldn't answer. Try again.`
  String get anakraServerError {
    return Intl.message(
      'The server couldn\'t answer. Try again.',
      name: 'anakraServerError',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't load the available packages. Try again later.`
  String get paymentPackagesLoadError {
    return Intl.message(
      'We couldn\'t load the available packages. Try again later.',
      name: 'paymentPackagesLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Sign in to continue with this payment.`
  String get paymentAuthenticationRequired {
    return Intl.message(
      'Sign in to continue with this payment.',
      name: 'paymentAuthenticationRequired',
      desc: '',
      args: [],
    );
  }

  /// `There is no unfinished payment to restore.`
  String get paymentNoPendingPayment {
    return Intl.message(
      'There is no unfinished payment to restore.',
      name: 'paymentNoPendingPayment',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't create the payment. Try again.`
  String get paymentCreateError {
    return Intl.message(
      'We couldn\'t create the payment. Try again.',
      name: 'paymentCreateError',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't load the available Arc Pay plans.`
  String get arcSubscriptionProductsError {
    return Intl.message(
      'We couldn\'t load the available Arc Pay plans.',
      name: 'arcSubscriptionProductsError',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't create the subscription. Try again later.`
  String get arcSubscriptionCreateError {
    return Intl.message(
      'We couldn\'t create the subscription. Try again later.',
      name: 'arcSubscriptionCreateError',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't cancel the subscription. Try again later.`
  String get arcSubscriptionCancelError {
    return Intl.message(
      'We couldn\'t cancel the subscription. Try again later.',
      name: 'arcSubscriptionCancelError',
      desc: '',
      args: [],
    );
  }

  /// `No Arc Pay subscription was found.`
  String get arcSubscriptionNotFound {
    return Intl.message(
      'No Arc Pay subscription was found.',
      name: 'arcSubscriptionNotFound',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't retry the payment. Try again later.`
  String get arcSubscriptionRetryError {
    return Intl.message(
      'We couldn\'t retry the payment. Try again later.',
      name: 'arcSubscriptionRetryError',
      desc: '',
      args: [],
    );
  }

  /// `Decrease quantity`
  String get shopDecreaseQuantity {
    return Intl.message(
      'Decrease quantity',
      name: 'shopDecreaseQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Increase quantity`
  String get shopIncreaseQuantity {
    return Intl.message(
      'Increase quantity',
      name: 'shopIncreaseQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get commonYes {
    return Intl.message('Yes', name: 'commonYes', desc: '', args: []);
  }

  /// `No`
  String get commonNo {
    return Intl.message('No', name: 'commonNo', desc: '', args: []);
  }

  /// `Name`
  String get commonName {
    return Intl.message('Name', name: 'commonName', desc: '', args: []);
  }

  /// `Date of birth`
  String get commonBirthDate {
    return Intl.message(
      'Date of birth',
      name: 'commonBirthDate',
      desc: '',
      args: [],
    );
  }

  /// `Time of birth`
  String get commonBirthTime {
    return Intl.message(
      'Time of birth',
      name: 'commonBirthTime',
      desc: '',
      args: [],
    );
  }

  /// `Place of birth`
  String get commonBirthPlace {
    return Intl.message(
      'Place of birth',
      name: 'commonBirthPlace',
      desc: '',
      args: [],
    );
  }

  /// `Description:`
  String get commonDescription {
    return Intl.message(
      'Description:',
      name: 'commonDescription',
      desc: '',
      args: [],
    );
  }

  /// `Keywords:`
  String get commonKeywords {
    return Intl.message(
      'Keywords:',
      name: 'commonKeywords',
      desc: '',
      args: [],
    );
  }

  /// `Meaning:`
  String get commonMeaning {
    return Intl.message('Meaning:', name: 'commonMeaning', desc: '', args: []);
  }

  /// `In readings:`
  String get commonInReadings {
    return Intl.message(
      'In readings:',
      name: 'commonInReadings',
      desc: '',
      args: [],
    );
  }

  /// `How it affects you:`
  String get commonHowItAffects {
    return Intl.message(
      'How it affects you:',
      name: 'commonHowItAffects',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get navHome {
    return Intl.message('Home', name: 'navHome', desc: '', args: []);
  }

  /// `Personal`
  String get navPersonal {
    return Intl.message('Personal', name: 'navPersonal', desc: '', args: []);
  }

  /// `Moon`
  String get navMoon {
    return Intl.message('Moon', name: 'navMoon', desc: '', args: []);
  }

  /// `Profile`
  String get navProfile {
    return Intl.message('Profile', name: 'navProfile', desc: '', args: []);
  }

  /// `Practices`
  String get navPractices {
    return Intl.message('Practices', name: 'navPractices', desc: '', args: []);
  }

  /// `Anakra AI Astrologer`
  String get anakraTitle {
    return Intl.message(
      'Anakra AI Astrologer',
      name: 'anakraTitle',
      desc: '',
      args: [],
    );
  }

  /// `Ask your question`
  String get anakraInputHint {
    return Intl.message(
      'Ask your question',
      name: 'anakraInputHint',
      desc: '',
      args: [],
    );
  }

  /// `Send message`
  String get anakraSendMessageLabel {
    return Intl.message(
      'Send message',
      name: 'anakraSendMessageLabel',
      desc: '',
      args: [],
    );
  }

  /// `Anakra requests left`
  String get anakraRequestsLeftLabel {
    return Intl.message(
      'Anakra requests left',
      name: 'anakraRequestsLeftLabel',
      desc: '',
      args: [],
    );
  }

  /// `Draw a card`
  String get anakraQuickDrawCard {
    return Intl.message(
      'Draw a card',
      name: 'anakraQuickDrawCard',
      desc: '',
      args: [],
    );
  }

  /// `Check compatibility`
  String get anakraQuickCompatibility {
    return Intl.message(
      'Check compatibility',
      name: 'anakraQuickCompatibility',
      desc: '',
      args: [],
    );
  }

  /// `Show my birth chart`
  String get anakraQuickNatalChart {
    return Intl.message(
      'Show my birth chart',
      name: 'anakraQuickNatalChart',
      desc: '',
      args: [],
    );
  }

  /// `When is my next power day?`
  String get anakraQuickPowerDay {
    return Intl.message(
      'When is my next power day?',
      name: 'anakraQuickPowerDay',
      desc: '',
      args: [],
    );
  }

  /// `Dream Dictionary`
  String get dreamDictionaryTitle {
    return Intl.message(
      'Dream Dictionary',
      name: 'dreamDictionaryTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tell us about your dream`
  String get dreamInputHint {
    return Intl.message(
      'Tell us about your dream',
      name: 'dreamInputHint',
      desc: '',
      args: [],
    );
  }

  /// `Choose a package`
  String get choosePackageTitle {
    return Intl.message(
      'Choose a package',
      name: 'choosePackageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Buy requests`
  String get buyAttemptsTitle {
    return Intl.message(
      'Buy requests',
      name: 'buyAttemptsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Get a subscription`
  String get subscribeTitle {
    return Intl.message(
      'Get a subscription',
      name: 'subscribeTitle',
      desc: '',
      args: [],
    );
  }

  /// `View history`
  String get viewHistory {
    return Intl.message(
      'View history',
      name: 'viewHistory',
      desc: '',
      args: [],
    );
  }

  /// `Interpret another dream`
  String get dreamDecodeAgain {
    return Intl.message(
      'Interpret another dream',
      name: 'dreamDecodeAgain',
      desc: '',
      args: [],
    );
  }

  /// `Check compatibility`
  String get compatibilityCheck {
    return Intl.message(
      'Check compatibility',
      name: 'compatibilityCheck',
      desc: '',
      args: [],
    );
  }

  /// `Check another couple`
  String get compatibilityNewPair {
    return Intl.message(
      'Check another couple',
      name: 'compatibilityNewPair',
      desc: '',
      args: [],
    );
  }

  /// `Add your date of birth in Profile`
  String get compatibilityFillBirthDate {
    return Intl.message(
      'Add your date of birth in Profile',
      name: 'compatibilityFillBirthDate',
      desc: '',
      args: [],
    );
  }

  /// `Add your partner's information`
  String get compatibilityFillPartner {
    return Intl.message(
      'Add your partner\'s information',
      name: 'compatibilityFillPartner',
      desc: '',
      args: [],
    );
  }

  /// `Calculate`
  String get compatibilityCalculate {
    return Intl.message(
      'Calculate',
      name: 'compatibilityCalculate',
      desc: '',
      args: [],
    );
  }

  /// `Love`
  String get compatibilityLove {
    return Intl.message('Love', name: 'compatibilityLove', desc: '', args: []);
  }

  /// `Conflicts`
  String get compatibilityConflicts {
    return Intl.message(
      'Conflicts',
      name: 'compatibilityConflicts',
      desc: '',
      args: [],
    );
  }

  /// `Family`
  String get compatibilityFamily {
    return Intl.message(
      'Family',
      name: 'compatibilityFamily',
      desc: '',
      args: [],
    );
  }

  /// `More about compatibility`
  String get compatibilityDetailsLabel {
    return Intl.message(
      'More about compatibility',
      name: 'compatibilityDetailsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Read more`
  String get compatibilityReadMore {
    return Intl.message(
      'Read more',
      name: 'compatibilityReadMore',
      desc: '',
      args: [],
    );
  }

  /// `Check your compatibility`
  String get compatibilityUnlockTitle {
    return Intl.message(
      'Check your compatibility',
      name: 'compatibilityUnlockTitle',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get settingsNotifications {
    return Intl.message(
      'Notifications',
      name: 'settingsNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Daily horoscope`
  String get settingsDailyHoroscope {
    return Intl.message(
      'Daily horoscope',
      name: 'settingsDailyHoroscope',
      desc: '',
      args: [],
    );
  }

  /// `Lunar Calendar`
  String get settingsLunarCalendar {
    return Intl.message(
      'Lunar Calendar',
      name: 'settingsLunarCalendar',
      desc: '',
      args: [],
    );
  }

  /// `Daily affirmations`
  String get settingsDailyAffirmations {
    return Intl.message(
      'Daily affirmations',
      name: 'settingsDailyAffirmations',
      desc: '',
      args: [],
    );
  }

  /// `Push notifications`
  String get settingsPushNotifications {
    return Intl.message(
      'Push notifications',
      name: 'settingsPushNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profileTitle {
    return Intl.message('Profile', name: 'profileTitle', desc: '', args: []);
  }

  /// `About Asteria`
  String get profileAbout {
    return Intl.message(
      'About Asteria',
      name: 'profileAbout',
      desc: '',
      args: [],
    );
  }

  /// `My achievements`
  String get profileAchievements {
    return Intl.message(
      'My achievements',
      name: 'profileAchievements',
      desc: '',
      args: [],
    );
  }

  /// `Shop`
  String get profileShop {
    return Intl.message('Shop', name: 'profileShop', desc: '', args: []);
  }

  /// `Delete account`
  String get profileDeleteAccount {
    return Intl.message(
      'Delete account',
      name: 'profileDeleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete your account?`
  String get profileDeleteAccountQuestion {
    return Intl.message(
      'Are you sure you want to delete your account?',
      name: 'profileDeleteAccountQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Confirm your email before deleting your account`
  String get profileConfirmEmailDelete {
    return Intl.message(
      'Confirm your email before deleting your account',
      name: 'profileConfirmEmailDelete',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get profileLogoutTitle {
    return Intl.message(
      'Log out',
      name: 'profileLogoutTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out?`
  String get profileLogoutQuestion {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'profileLogoutQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Unable to open the website`
  String get profileOpenWebsiteError {
    return Intl.message(
      'Unable to open the website',
      name: 'profileOpenWebsiteError',
      desc: '',
      args: [],
    );
  }

  /// `Article not found`
  String get articleNotFound {
    return Intl.message(
      'Article not found',
      name: 'articleNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Affirmation of the day`
  String get affirmationOfDay {
    return Intl.message(
      'Affirmation of the day',
      name: 'affirmationOfDay',
      desc: '',
      args: [],
    );
  }

  /// `Reload affirmation`
  String get affirmationRetryLabel {
    return Intl.message(
      'Reload affirmation',
      name: 'affirmationRetryLabel',
      desc: '',
      args: [],
    );
  }

  /// `Focus`
  String get energyFocus {
    return Intl.message('Focus', name: 'energyFocus', desc: '', args: []);
  }

  /// `Risks`
  String get energyRisks {
    return Intl.message('Risks', name: 'energyRisks', desc: '', args: []);
  }

  /// `Scroll articles`
  String get articlesScrollLabel {
    return Intl.message(
      'Scroll articles',
      name: 'articlesScrollLabel',
      desc: '',
      args: [],
    );
  }

  /// `min`
  String get readingTimeMinutes {
    return Intl.message('min', name: 'readingTimeMinutes', desc: '', args: []);
  }

  /// `lunar day`
  String get lunarDay {
    return Intl.message('lunar day', name: 'lunarDay', desc: '', args: []);
  }

  /// `Pick a day in the lunar calendar`
  String get openLunarCalendarLabel {
    return Intl.message(
      'Pick a day in the lunar calendar',
      name: 'openLunarCalendarLabel',
      desc: '',
      args: [],
    );
  }

  /// `Birth chart`
  String get natalChartTitle {
    return Intl.message(
      'Birth chart',
      name: 'natalChartTitle',
      desc: '',
      args: [],
    );
  }

  /// `Key positions`
  String get natalMainPositions {
    return Intl.message(
      'Key positions',
      name: 'natalMainPositions',
      desc: '',
      args: [],
    );
  }

  /// `General information`
  String get natalGeneralData {
    return Intl.message(
      'General information',
      name: 'natalGeneralData',
      desc: '',
      args: [],
    );
  }

  /// `Elements\nand modalities`
  String get natalElementsModalities {
    return Intl.message(
      'Elements\nand modalities',
      name: 'natalElementsModalities',
      desc: '',
      args: [],
    );
  }

  /// `Houses and themes`
  String get natalHousesThemes {
    return Intl.message(
      'Houses and themes',
      name: 'natalHousesThemes',
      desc: '',
      args: [],
    );
  }

  /// `Magical summary`
  String get natalMagicSummary {
    return Intl.message(
      'Magical summary',
      name: 'natalMagicSummary',
      desc: '',
      args: [],
    );
  }

  /// `Fire`
  String get elementFire {
    return Intl.message('Fire', name: 'elementFire', desc: '', args: []);
  }

  /// `Water`
  String get elementWater {
    return Intl.message('Water', name: 'elementWater', desc: '', args: []);
  }

  /// `Air`
  String get elementAir {
    return Intl.message('Air', name: 'elementAir', desc: '', args: []);
  }

  /// `Earth`
  String get elementEarth {
    return Intl.message('Earth', name: 'elementEarth', desc: '', args: []);
  }

  /// `How to use the cards`
  String get deckHowToUse {
    return Intl.message(
      'How to use the cards',
      name: 'deckHowToUse',
      desc: '',
      args: [],
    );
  }

  /// `Get insight`
  String get deckGetInsight {
    return Intl.message(
      'Get insight',
      name: 'deckGetInsight',
      desc: '',
      args: [],
    );
  }

  /// `Card`
  String get cardNumberLabel {
    return Intl.message('Card', name: 'cardNumberLabel', desc: '', args: []);
  }

  /// `Star Coins`
  String get balanceTitle {
    return Intl.message('Star Coins', name: 'balanceTitle', desc: '', args: []);
  }

  /// `Buy Star Coins`
  String get balanceBuy {
    return Intl.message(
      'Buy Star Coins',
      name: 'balanceBuy',
      desc: '',
      args: [],
    );
  }

  /// `Prefer unlimited access?`
  String get balanceSubscriptionPrompt {
    return Intl.message(
      'Prefer unlimited access?',
      name: 'balanceSubscriptionPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Choose a subscription`
  String get balanceChooseSubscription {
    return Intl.message(
      'Choose a subscription',
      name: 'balanceChooseSubscription',
      desc: '',
      args: [],
    );
  }

  /// `Nothing here yet. Earn or spend star credits to see your history!`
  String get balanceHistoryEmpty {
    return Intl.message(
      'Nothing here yet. Earn or spend star credits to see your history!',
      name: 'balanceHistoryEmpty',
      desc: '',
      args: [],
    );
  }

  /// `No credits yet`
  String get balanceHistoryNoDeposits {
    return Intl.message(
      'No credits yet',
      name: 'balanceHistoryNoDeposits',
      desc: '',
      args: [],
    );
  }

  /// `No charges yet`
  String get balanceHistoryNoWithdrawals {
    return Intl.message(
      'No charges yet',
      name: 'balanceHistoryNoWithdrawals',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't load history`
  String get balanceHistoryLoadError {
    return Intl.message(
      'Couldn\'t load history',
      name: 'balanceHistoryLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't refresh history`
  String get balanceHistoryRefreshError {
    return Intl.message(
      'Couldn\'t refresh history',
      name: 'balanceHistoryRefreshError',
      desc: '',
      args: [],
    );
  }

  /// `Try again`
  String get balanceRewardRetry {
    return Intl.message(
      'Try again',
      name: 'balanceRewardRetry',
      desc: '',
      args: [],
    );
  }

  /// `AI Astrologer chat — 1 question`
  String get balanceServiceAnakra {
    return Intl.message(
      'AI Astrologer chat — 1 question',
      name: 'balanceServiceAnakra',
      desc: '',
      args: [],
    );
  }

  /// `Dream interpretation`
  String get balanceServiceDream {
    return Intl.message(
      'Dream interpretation',
      name: 'balanceServiceDream',
      desc: '',
      args: [],
    );
  }

  /// `Additional compatibility report`
  String get balanceServiceCompatibility {
    return Intl.message(
      'Additional compatibility report',
      name: 'balanceServiceCompatibility',
      desc: '',
      args: [],
    );
  }

  /// `Tarot reading: Love / Celtic Cross`
  String get balanceServiceTarot {
    return Intl.message(
      'Tarot reading: Love / Celtic Cross',
      name: 'balanceServiceTarot',
      desc: '',
      args: [],
    );
  }

  /// `Personal yearly forecast`
  String get balanceServiceYearForecast {
    return Intl.message(
      'Personal yearly forecast',
      name: 'balanceServiceYearForecast',
      desc: '',
      args: [],
    );
  }

  /// `Birth chart`
  String get balanceServiceNatal {
    return Intl.message(
      'Birth chart',
      name: 'balanceServiceNatal',
      desc: '',
      args: [],
    );
  }

  /// `Subscription`
  String get subscriptionTitle {
    return Intl.message(
      'Subscription',
      name: 'subscriptionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Subscription activated`
  String get subscriptionActivated {
    return Intl.message(
      'Subscription activated',
      name: 'subscriptionActivated',
      desc: '',
      args: [],
    );
  }

  /// `Restoring purchases…`
  String get subscriptionRestoreInProgress {
    return Intl.message(
      'Restoring purchases…',
      name: 'subscriptionRestoreInProgress',
      desc: '',
      args: [],
    );
  }

  /// `Cancel subscription`
  String get subscriptionDisable {
    return Intl.message(
      'Cancel subscription',
      name: 'subscriptionDisable',
      desc: '',
      args: [],
    );
  }

  /// `Open payment again`
  String get subscriptionOpenPaymentAgain {
    return Intl.message(
      'Open payment again',
      name: 'subscriptionOpenPaymentAgain',
      desc: '',
      args: [],
    );
  }

  /// `Unlimited Dream Dictionary, Tarot, and AI Astrologer requests`
  String get subscriptionBenefitUnlimited {
    return Intl.message(
      'Unlimited Dream Dictionary, Tarot, and AI Astrologer requests',
      name: 'subscriptionBenefitUnlimited',
      desc: '',
      args: [],
    );
  }

  /// `Complete personal horoscope`
  String get subscriptionBenefitHoroscope {
    return Intl.message(
      'Complete personal horoscope',
      name: 'subscriptionBenefitHoroscope',
      desc: '',
      args: [],
    );
  }

  /// `All Lunar Calendar areas`
  String get subscriptionBenefitMoon {
    return Intl.message(
      'All Lunar Calendar areas',
      name: 'subscriptionBenefitMoon',
      desc: '',
      args: [],
    );
  }

  /// `Unlimited compatibility reports`
  String get subscriptionBenefitCompatibility {
    return Intl.message(
      'Unlimited compatibility reports',
      name: 'subscriptionBenefitCompatibility',
      desc: '',
      args: [],
    );
  }

  /// `Unlimited affirmations in every category`
  String get subscriptionBenefitAffirmations {
    return Intl.message(
      'Unlimited affirmations in every category',
      name: 'subscriptionBenefitAffirmations',
      desc: '',
      args: [],
    );
  }

  /// `Confirming payment`
  String get paymentConfirming {
    return Intl.message(
      'Confirming payment',
      name: 'paymentConfirming',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for payment`
  String get paymentWaiting {
    return Intl.message(
      'Waiting for payment',
      name: 'paymentWaiting',
      desc: '',
      args: [],
    );
  }

  /// `Open payment page`
  String get paymentOpenPage {
    return Intl.message(
      'Open payment page',
      name: 'paymentOpenPage',
      desc: '',
      args: [],
    );
  }

  /// `Leave this attempt`
  String get paymentLeaveAttempt {
    return Intl.message(
      'Leave this attempt',
      name: 'paymentLeaveAttempt',
      desc: '',
      args: [],
    );
  }

  /// `Creating payment`
  String get paymentCreating {
    return Intl.message(
      'Creating payment',
      name: 'paymentCreating',
      desc: '',
      args: [],
    );
  }

  /// `Getting a secure Arc Pay link…`
  String get paymentCreatingMessage {
    return Intl.message(
      'Getting a secure Arc Pay link…',
      name: 'paymentCreatingMessage',
      desc: '',
      args: [],
    );
  }

  /// `Leave this payment attempt?`
  String get paymentLeaveQuestion {
    return Intl.message(
      'Leave this payment attempt?',
      name: 'paymentLeaveQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Continue payment`
  String get paymentContinue {
    return Intl.message(
      'Continue payment',
      name: 'paymentContinue',
      desc: '',
      args: [],
    );
  }

  /// `Payment attempt saved`
  String get paymentAttemptLeft {
    return Intl.message(
      'Payment attempt saved',
      name: 'paymentAttemptLeft',
      desc: '',
      args: [],
    );
  }

  /// `Create a new payment`
  String get paymentCreateNew {
    return Intl.message(
      'Create a new payment',
      name: 'paymentCreateNew',
      desc: '',
      args: [],
    );
  }

  /// `Payment failed`
  String get paymentFailed {
    return Intl.message(
      'Payment failed',
      name: 'paymentFailed',
      desc: '',
      args: [],
    );
  }

  /// `Unable to open the payment page`
  String get paymentOpenError {
    return Intl.message(
      'Unable to open the payment page',
      name: 'paymentOpenError',
      desc: '',
      args: [],
    );
  }

  /// `Purchase`
  String get purchaseTitle {
    return Intl.message('Purchase', name: 'purchaseTitle', desc: '', args: []);
  }

  /// `Confirm purchase`
  String get purchaseConfirmTitle {
    return Intl.message(
      'Confirm purchase',
      name: 'purchaseConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Buy {title} for {price}`
  String purchaseForPrice(String title, int price) {
    return Intl.message(
      'Buy $title for $price',
      name: 'purchaseForPrice',
      desc: '',
      args: [title, price],
    );
  }

  /// `Buy {title} for {price} Star Coins`
  String purchaseForCoinsLabel(String title, int price) {
    return Intl.message(
      'Buy $title for $price Star Coins',
      name: 'purchaseForCoinsLabel',
      desc: '',
      args: [title, price],
    );
  }

  /// `Not enough Star Coins for this purchase`
  String get purchaseNotEnoughGeneric {
    return Intl.message(
      'Not enough Star Coins for this purchase',
      name: 'purchaseNotEnoughGeneric',
      desc: '',
      args: [],
    );
  }

  /// `Not enough to buy requests`
  String get purchaseNotEnoughRequests {
    return Intl.message(
      'Not enough to buy requests',
      name: 'purchaseNotEnoughRequests',
      desc: '',
      args: [],
    );
  }

  /// `Not enough to buy this reading`
  String get purchaseNotEnoughReading {
    return Intl.message(
      'Not enough to buy this reading',
      name: 'purchaseNotEnoughReading',
      desc: '',
      args: [],
    );
  }

  /// `Not enough Star Coins`
  String get notEnoughStarsTitle {
    return Intl.message(
      'Not enough Star Coins',
      name: 'notEnoughStarsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Go to chat`
  String get purchaseGoToChat {
    return Intl.message(
      'Go to chat',
      name: 'purchaseGoToChat',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong. Try again later.`
  String get purchaseErrorTryAgain {
    return Intl.message(
      'Something went wrong. Try again later.',
      name: 'purchaseErrorTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Purchase complete`
  String get purchaseSuccess {
    return Intl.message(
      'Purchase complete',
      name: 'purchaseSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get shopProceed {
    return Intl.message('Continue', name: 'shopProceed', desc: '', args: []);
  }

  /// `Balance:`
  String get shopBalance {
    return Intl.message('Balance:', name: 'shopBalance', desc: '', args: []);
  }

  /// `items`
  String get shopItemSuffix {
    return Intl.message('items', name: 'shopItemSuffix', desc: '', args: []);
  }

  /// `Unable to load products`
  String get shopLoadError {
    return Intl.message(
      'Unable to load products',
      name: 'shopLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Unable to complete the purchase`
  String get shopPurchaseError {
    return Intl.message(
      'Unable to complete the purchase',
      name: 'shopPurchaseError',
      desc: '',
      args: [],
    );
  }

  /// `Unable to get your insight. Try again later.`
  String get insightLoadError {
    return Intl.message(
      'Unable to get your insight. Try again later.',
      name: 'insightLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Today's limit`
  String get dailyLimitTitle {
    return Intl.message(
      'Today\'s limit',
      name: 'dailyLimitTitle',
      desc: '',
      args: [],
    );
  }

  /// `Past`
  String get runesPast {
    return Intl.message('Past', name: 'runesPast', desc: '', args: []);
  }

  /// `Present`
  String get runesPresent {
    return Intl.message('Present', name: 'runesPresent', desc: '', args: []);
  }

  /// `Future`
  String get runesFuture {
    return Intl.message('Future', name: 'runesFuture', desc: '', args: []);
  }

  /// `How to use runes`
  String get runesHowToUse {
    return Intl.message(
      'How to use runes',
      name: 'runesHowToUse',
      desc: '',
      args: [],
    );
  }

  /// `Favorable\nday`
  String get dayFavorable {
    return Intl.message(
      'Favorable\nday',
      name: 'dayFavorable',
      desc: '',
      args: [],
    );
  }

  /// `Neutral\nday`
  String get dayNeutral {
    return Intl.message('Neutral\nday', name: 'dayNeutral', desc: '', args: []);
  }

  /// `Unfavorable\nday`
  String get dayUnfavorable {
    return Intl.message(
      'Unfavorable\nday',
      name: 'dayUnfavorable',
      desc: '',
      args: [],
    );
  }

  /// `Moon phase change`
  String get moonPhaseChange {
    return Intl.message(
      'Moon phase change',
      name: 'moonPhaseChange',
      desc: '',
      args: [],
    );
  }

  /// `Your essence`
  String get horoscopeEssence {
    return Intl.message(
      'Your essence',
      name: 'horoscopeEssence',
      desc: '',
      args: [],
    );
  }

  /// `General characteristics`
  String get horoscopeGeneral {
    return Intl.message(
      'General characteristics',
      name: 'horoscopeGeneral',
      desc: '',
      args: [],
    );
  }

  /// `Life areas`
  String get horoscopeLifeAreas {
    return Intl.message(
      'Life areas',
      name: 'horoscopeLifeAreas',
      desc: '',
      args: [],
    );
  }

  /// `Your evolution`
  String get horoscopeEvolution {
    return Intl.message(
      'Your evolution',
      name: 'horoscopeEvolution',
      desc: '',
      args: [],
    );
  }

  /// `Guidance`
  String get horoscopeAdvice {
    return Intl.message(
      'Guidance',
      name: 'horoscopeAdvice',
      desc: '',
      args: [],
    );
  }

  /// `Emotions\nand inner world`
  String get horoscopeEmotions {
    return Intl.message(
      'Emotions\nand inner world',
      name: 'horoscopeEmotions',
      desc: '',
      args: [],
    );
  }

  /// `Love\nand relationships`
  String get horoscopeLove {
    return Intl.message(
      'Love\nand relationships',
      name: 'horoscopeLove',
      desc: '',
      args: [],
    );
  }

  /// `Well-being`
  String get horoscopeWellbeing {
    return Intl.message(
      'Well-being',
      name: 'horoscopeWellbeing',
      desc: '',
      args: [],
    );
  }

  /// `Work\nand purpose`
  String get horoscopeWork {
    return Intl.message(
      'Work\nand purpose',
      name: 'horoscopeWork',
      desc: '',
      args: [],
    );
  }

  /// `Examples`
  String get horoscopeExamples {
    return Intl.message(
      'Examples',
      name: 'horoscopeExamples',
      desc: '',
      args: [],
    );
  }

  /// `Finances\nand the material\nworld`
  String get horoscopeFinances {
    return Intl.message(
      'Finances\nand the material\nworld',
      name: 'horoscopeFinances',
      desc: '',
      args: [],
    );
  }

  /// `Periods of power\nand transformation`
  String get horoscopePowerPeriods {
    return Intl.message(
      'Periods of power\nand transformation',
      name: 'horoscopePowerPeriods',
      desc: '',
      args: [],
    );
  }

  /// `Current transits`
  String get horoscopeTransits {
    return Intl.message(
      'Current transits',
      name: 'horoscopeTransits',
      desc: '',
      args: [],
    );
  }

  /// `Weak points and cautions`
  String get horoscopeWeakPoints {
    return Intl.message(
      'Weak points and cautions',
      name: 'horoscopeWeakPoints',
      desc: '',
      args: [],
    );
  }

  /// `Personal guidance`
  String get horoscopePersonalAdvice {
    return Intl.message(
      'Personal guidance',
      name: 'horoscopePersonalAdvice',
      desc: '',
      args: [],
    );
  }

  /// `Tarot`
  String get dailyTarotTab {
    return Intl.message('Tarot', name: 'dailyTarotTab', desc: '', args: []);
  }

  /// `Rune`
  String get dailyRuneTab {
    return Intl.message('Rune', name: 'dailyRuneTab', desc: '', args: []);
  }

  /// `Tarot card of the day`
  String get dailyTarotTitle {
    return Intl.message(
      'Tarot card of the day',
      name: 'dailyTarotTitle',
      desc: '',
      args: [],
    );
  }

  /// `Loading your Tarot card…`
  String get dailyTarotLoading {
    return Intl.message(
      'Loading your Tarot card…',
      name: 'dailyTarotLoading',
      desc: '',
      args: [],
    );
  }

  /// `Flip the Tarot card of the day`
  String get dailyTarotFlipLabel {
    return Intl.message(
      'Flip the Tarot card of the day',
      name: 'dailyTarotFlipLabel',
      desc: '',
      args: [],
    );
  }

  /// `Tarot card of the day: {card}`
  String dailyTarotOpenedLabel(Object card) {
    return Intl.message(
      'Tarot card of the day: $card',
      name: 'dailyTarotOpenedLabel',
      desc: '',
      args: [card],
    );
  }

  /// `Tap the card to flip it`
  String get dailyTarotTap {
    return Intl.message(
      'Tap the card to flip it',
      name: 'dailyTarotTap',
      desc: '',
      args: [],
    );
  }

  /// `Get a reading`
  String get dailyTarotReading {
    return Intl.message(
      'Get a reading',
      name: 'dailyTarotReading',
      desc: '',
      args: [],
    );
  }

  /// `Rune of the day`
  String get dailyRuneTitle {
    return Intl.message(
      'Rune of the day',
      name: 'dailyRuneTitle',
      desc: '',
      args: [],
    );
  }

  /// `Loading your rune…`
  String get dailyRuneLoading {
    return Intl.message(
      'Loading your rune…',
      name: 'dailyRuneLoading',
      desc: '',
      args: [],
    );
  }

  /// `Flip the rune of the day`
  String get dailyRuneFlipLabel {
    return Intl.message(
      'Flip the rune of the day',
      name: 'dailyRuneFlipLabel',
      desc: '',
      args: [],
    );
  }

  /// `Rune of the day: {rune}`
  String dailyRuneOpenedLabel(Object rune) {
    return Intl.message(
      'Rune of the day: $rune',
      name: 'dailyRuneOpenedLabel',
      desc: '',
      args: [rune],
    );
  }

  /// `Tap the rune to flip it`
  String get dailyRuneTap {
    return Intl.message(
      'Tap the rune to flip it',
      name: 'dailyRuneTap',
      desc: '',
      args: [],
    );
  }

  /// `Cast the runes`
  String get dailyRuneReading {
    return Intl.message(
      'Cast the runes',
      name: 'dailyRuneReading',
      desc: '',
      args: [],
    );
  }

  /// `Personal yearly horoscope`
  String get personalYearForecast {
    return Intl.message(
      'Personal yearly horoscope',
      name: 'personalYearForecast',
      desc: '',
      args: [],
    );
  }

  /// `Open chart`
  String get personalOpenChart {
    return Intl.message(
      'Open chart',
      name: 'personalOpenChart',
      desc: '',
      args: [],
    );
  }

  /// `Unlock your forecast`
  String get personalOpenForecast {
    return Intl.message(
      'Unlock your forecast',
      name: 'personalOpenForecast',
      desc: '',
      args: [],
    );
  }

  /// `Unlock for free`
  String get personalOpenFree {
    return Intl.message(
      'Unlock for free',
      name: 'personalOpenFree',
      desc: '',
      args: [],
    );
  }

  /// `Unlock`
  String get personalUnlock {
    return Intl.message('Unlock', name: 'personalUnlock', desc: '', args: []);
  }

  /// `Inner harmony balance`
  String get personalHarmony {
    return Intl.message(
      'Inner harmony balance',
      name: 'personalHarmony',
      desc: '',
      args: [],
    );
  }

  /// `Love\nand relationships`
  String get personalLoveRelationships {
    return Intl.message(
      'Love\nand relationships',
      name: 'personalLoveRelationships',
      desc: '',
      args: [],
    );
  }

  /// `Financial stability`
  String get personalFinancialStability {
    return Intl.message(
      'Financial stability',
      name: 'personalFinancialStability',
      desc: '',
      args: [],
    );
  }

  /// `Element`
  String get personalElement {
    return Intl.message('Element', name: 'personalElement', desc: '', args: []);
  }

  /// `Planet`
  String get personalPlanet {
    return Intl.message('Planet', name: 'personalPlanet', desc: '', args: []);
  }

  /// `Character`
  String get personalCharacter {
    return Intl.message(
      'Character',
      name: 'personalCharacter',
      desc: '',
      args: [],
    );
  }

  /// `Love`
  String get personalLove {
    return Intl.message('Love', name: 'personalLove', desc: '', args: []);
  }

  /// `Finances`
  String get personalFinances {
    return Intl.message(
      'Finances',
      name: 'personalFinances',
      desc: '',
      args: [],
    );
  }

  /// `Energy`
  String get personalEnergy {
    return Intl.message('Energy', name: 'personalEnergy', desc: '', args: []);
  }

  /// `PRO subscription\nis active`
  String get subscriptionActive {
    return Intl.message(
      'PRO subscription\nis active',
      name: 'subscriptionActive',
      desc: '',
      args: [],
    );
  }

  /// `PRO subscription\nis not active`
  String get subscriptionInactive {
    return Intl.message(
      'PRO subscription\nis not active',
      name: 'subscriptionInactive',
      desc: '',
      args: [],
    );
  }

  /// `Get PRO`
  String get subscriptionConnect {
    return Intl.message(
      'Get PRO',
      name: 'subscriptionConnect',
      desc: '',
      args: [],
    );
  }

  /// `Complete onboarding`
  String get rewardCompleteOnboarding {
    return Intl.message(
      'Complete onboarding',
      name: 'rewardCompleteOnboarding',
      desc: '',
      args: [],
    );
  }

  /// `Get a Tarot reading`
  String get rewardTarotReading {
    return Intl.message(
      'Get a Tarot reading',
      name: 'rewardTarotReading',
      desc: '',
      args: [],
    );
  }

  /// `Read 3 articles`
  String get rewardReadArticles {
    return Intl.message(
      'Read 3 articles',
      name: 'rewardReadArticles',
      desc: '',
      args: [],
    );
  }

  /// `Share on social media`
  String get rewardShare {
    return Intl.message(
      'Share on social media',
      name: 'rewardShare',
      desc: '',
      args: [],
    );
  }

  /// `Open Asteria 5 days in a row`
  String get rewardLoginStreak {
    return Intl.message(
      'Open Asteria 5 days in a row',
      name: 'rewardLoginStreak',
      desc: '',
      args: [],
    );
  }

  /// `My achievements`
  String get achievementsTitle {
    return Intl.message(
      'My achievements',
      name: 'achievementsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Get a Tarot reading`
  String get achievementTarot {
    return Intl.message(
      'Get a Tarot reading',
      name: 'achievementTarot',
      desc: '',
      args: [],
    );
  }

  /// `Open your horoscope`
  String get achievementHoroscope {
    return Intl.message(
      'Open your horoscope',
      name: 'achievementHoroscope',
      desc: '',
      args: [],
    );
  }

  /// `Open the runes`
  String get achievementRunes {
    return Intl.message(
      'Open the runes',
      name: 'achievementRunes',
      desc: '',
      args: [],
    );
  }

  /// `{count} of {total} remaining`
  String achievementRemaining(int count, int total) {
    return Intl.message(
      '$count of $total remaining',
      name: 'achievementRemaining',
      desc: '',
      args: [count, total],
    );
  }

  /// `{title}. Locked`
  String achievementLocked(String title) {
    return Intl.message(
      '$title. Locked',
      name: 'achievementLocked',
      desc: '',
      args: [title],
    );
  }

  /// `Included in PRO`
  String get natalIncludedInPro {
    return Intl.message(
      'Included in PRO',
      name: 'natalIncludedInPro',
      desc: '',
      args: [],
    );
  }

  /// `Create your birth chart`
  String get natalCreateCard {
    return Intl.message(
      'Create your birth chart',
      name: 'natalCreateCard',
      desc: '',
      args: [],
    );
  }

  /// `No Star Coins required. Your chart is yours to keep.`
  String get natalProAccessDescription {
    return Intl.message(
      'No Star Coins required. Your chart is yours to keep.',
      name: 'natalProAccessDescription',
      desc: '',
      args: [],
    );
  }

  /// `Could not check your subscription. Please try again.`
  String get natalAccessUnavailable {
    return Intl.message(
      'Could not check your subscription. Please try again.',
      name: 'natalAccessUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Could not create your chart. Please try again.`
  String get natalGenerationFailed {
    return Intl.message(
      'Could not create your chart. Please try again.',
      name: 'natalGenerationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Your birth chart`
  String get natalPaywallTitle {
    return Intl.message(
      'Your birth chart',
      name: 'natalPaywallTitle',
      desc: '',
      args: [],
    );
  }

  /// `A birth chart is your unique celestial passport, created at the moment you were born.`
  String get natalPaywallIntro {
    return Intl.message(
      'A birth chart is your unique celestial passport, created at the moment you were born.',
      name: 'natalPaywallIntro',
      desc: '',
      args: [],
    );
  }

  /// `What you'll discover`
  String get natalInsideTitle {
    return Intl.message(
      'What you\'ll discover',
      name: 'natalInsideTitle',
      desc: '',
      args: [],
    );
  }

  /// `— your inner balance of energies.`
  String get natalElementsDescription {
    return Intl.message(
      '— your inner balance of energies.',
      name: 'natalElementsDescription',
      desc: '',
      args: [],
    );
  }

  /// `— keys to life areas and your talents.`
  String get natalHousesDescription {
    return Intl.message(
      '— keys to life areas and your talents.',
      name: 'natalHousesDescription',
      desc: '',
      args: [],
    );
  }

  /// `— a personal message from the Universe.`
  String get natalSummaryDescription {
    return Intl.message(
      '— a personal message from the Universe.',
      name: 'natalSummaryDescription',
      desc: '',
      args: [],
    );
  }

  /// `Lifetime access`
  String get natalForeverAccess {
    return Intl.message(
      'Lifetime access',
      name: 'natalForeverAccess',
      desc: '',
      args: [],
    );
  }

  /// `Access opens immediately after payment.`
  String get natalInstantAccess {
    return Intl.message(
      'Access opens immediately after payment.',
      name: 'natalInstantAccess',
      desc: '',
      args: [],
    );
  }

  /// `Unlock birth chart`
  String get natalBuy {
    return Intl.message(
      'Unlock birth chart',
      name: 'natalBuy',
      desc: '',
      args: [],
    );
  }

  /// `Livia`
  String get adLiviaName {
    return Intl.message('Livia', name: 'adLiviaName', desc: '', args: []);
  }

  /// `Had a dream?`
  String get adDreamTitle {
    return Intl.message(
      'Had a dream?',
      name: 'adDreamTitle',
      desc: '',
      args: [],
    );
  }

  /// `Tell her your dream — she will reveal its meaning.`
  String get adDreamDescription {
    return Intl.message(
      'Tell her your dream — she will reveal its meaning.',
      name: 'adDreamDescription',
      desc: '',
      args: [],
    );
  }

  /// `guardian of dreams.`
  String get adLiviaSubtitle {
    return Intl.message(
      'guardian of dreams.',
      name: 'adLiviaSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Interpret`
  String get adDecode {
    return Intl.message('Interpret', name: 'adDecode', desc: '', args: []);
  }

  /// `Interpret`
  String get dreamDecode {
    return Intl.message('Interpret', name: 'dreamDecode', desc: '', args: []);
  }

  /// `Open compatibility`
  String get openCompatibilityLabel {
    return Intl.message(
      'Open compatibility',
      name: 'openCompatibilityLabel',
      desc: '',
      args: [],
    );
  }

  /// `How can I earn more?`
  String get rewardsHowEarn {
    return Intl.message(
      'How can I earn more?',
      name: 'rewardsHowEarn',
      desc: '',
      args: [],
    );
  }

  /// `Available next month`
  String get rewardAvailableNextMonth {
    return Intl.message(
      'Available next month',
      name: 'rewardAvailableNextMonth',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get rewardCompleted {
    return Intl.message(
      'Completed',
      name: 'rewardCompleted',
      desc: '',
      args: [],
    );
  }

  /// `One time`
  String get rewardOneTime {
    return Intl.message('One time', name: 'rewardOneTime', desc: '', args: []);
  }

  /// `Once a month`
  String get rewardMonthly {
    return Intl.message(
      'Once a month',
      name: 'rewardMonthly',
      desc: '',
      args: [],
    );
  }

  /// `Star Coins added`
  String get rewardGranted {
    return Intl.message(
      'Star Coins added',
      name: 'rewardGranted',
      desc: '',
      args: [],
    );
  }

  /// `of`
  String get commonOf {
    return Intl.message('of', name: 'commonOf', desc: '', args: []);
  }

  /// `Shop`
  String get shopTitle {
    return Intl.message('Shop', name: 'shopTitle', desc: '', args: []);
  }

  /// `Spend Star Coins on useful features`
  String get shopSubtitle {
    return Intl.message(
      'Spend Star Coins on useful features',
      name: 'shopSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `No products found`
  String get shopNoProducts {
    return Intl.message(
      'No products found',
      name: 'shopNoProducts',
      desc: '',
      args: [],
    );
  }

  /// `Left`
  String get shopItemsLeft {
    return Intl.message('Left', name: 'shopItemsLeft', desc: '', args: []);
  }

  /// `price per item`
  String get shopUnitPrice {
    return Intl.message(
      'price per item',
      name: 'shopUnitPrice',
      desc: '',
      args: [],
    );
  }

  /// `How many would you like?`
  String get shopQuantityQuestion {
    return Intl.message(
      'How many would you like?',
      name: 'shopQuantityQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Purchase complete`
  String get shopPurchaseComplete {
    return Intl.message(
      'Purchase complete',
      name: 'shopPurchaseComplete',
      desc: '',
      args: [],
    );
  }

  /// `Required for purchase`
  String get purchaseRequired {
    return Intl.message(
      'Required for purchase',
      name: 'purchaseRequired',
      desc: '',
      args: [],
    );
  }

  /// `Required`
  String get shopRequired {
    return Intl.message('Required', name: 'shopRequired', desc: '', args: []);
  }

  /// `After purchase:`
  String get shopAfterPurchase {
    return Intl.message(
      'After purchase:',
      name: 'shopAfterPurchase',
      desc: '',
      args: [],
    );
  }

  /// `Open article: {title}`
  String openArticleLabel(String title) {
    return Intl.message(
      'Open article: $title',
      name: 'openArticleLabel',
      desc: '',
      args: [title],
    );
  }

  /// `Buy for {price}`
  String buyForPrice(String price) {
    return Intl.message(
      'Buy for $price',
      name: 'buyForPrice',
      desc: '',
      args: [price],
    );
  }

  /// `Buy {title} for {price} Star Coins`
  String buySpecialReadingLabel(String title, String price) {
    return Intl.message(
      'Buy $title for $price Star Coins',
      name: 'buySpecialReadingLabel',
      desc: '',
      args: [title, price],
    );
  }

  /// `{count, plural, =0{No free requests left this week} one{{count} free request left this week} other{{count} free requests left this week}}`
  String requestsLeftThisWeek(int count) {
    return Intl.plural(
      count,
      zero: 'No free requests left this week',
      one: '$count free request left this week',
      other: '$count free requests left this week',
      name: 'requestsLeftThisWeek',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =0{No purchased requests} one{{count} purchased request} other{{count} purchased requests}}`
  String paidRequestsLeft(int count) {
    return Intl.plural(
      count,
      zero: 'No purchased requests',
      one: '$count purchased request',
      other: '$count purchased requests',
      name: 'paidRequestsLeft',
      desc: '',
      args: [count],
    );
  }

  /// `Your limit resets in {count, plural, one{{count} day} other{{count} days}}.`
  String limitResetsIn(int count) {
    return Intl.message(
      'Your limit resets in ${Intl.plural(count, one: '$count day', other: '$count days')}.',
      name: 'limitResetsIn',
      desc: '',
      args: [count],
    );
  }

  /// `Your free requests reset in {count, plural, one{{count} day} other{{count} days}}.`
  String freeLimitResetsIn(int count) {
    return Intl.message(
      'Your free requests reset in ${Intl.plural(count, one: '$count day', other: '$count days')}.',
      name: 'freeLimitResetsIn',
      desc: '',
      args: [count],
    );
  }

  /// `You've used all your requests.\nWant to continue?`
  String get requestsExhausted {
    return Intl.message(
      'You\'ve used all your requests.\nWant to continue?',
      name: 'requestsExhausted',
      desc: '',
      args: [],
    );
  }

  /// `Get a PRO subscription`
  String get offerProTitle {
    return Intl.message(
      'Get a PRO subscription',
      name: 'offerProTitle',
      desc: '',
      args: [],
    );
  }

  /// `You'll get:`
  String get offerIncludesTitle {
    return Intl.message(
      'You\'ll get:',
      name: 'offerIncludesTitle',
      desc: '',
      args: [],
    );
  }

  /// `Unlimited Dream Dictionary, Tarot, AI Astrologer, and compatibility requests`
  String get offerUnlimitedDescription {
    return Intl.message(
      'Unlimited Dream Dictionary, Tarot, AI Astrologer, and compatibility requests',
      name: 'offerUnlimitedDescription',
      desc: '',
      args: [],
    );
  }

  /// `Unable to refresh. Try again.`
  String get genericRefreshError {
    return Intl.message(
      'Unable to refresh. Try again.',
      name: 'genericRefreshError',
      desc: '',
      args: [],
    );
  }

  /// `Unable to calculate compatibility. Try again.`
  String get compatibilityCalculationError {
    return Intl.message(
      'Unable to calculate compatibility. Try again.',
      name: 'compatibilityCalculationError',
      desc: '',
      args: [],
    );
  }

  /// `Unable to interpret your dream. Try again.`
  String get dreamCalculationError {
    return Intl.message(
      'Unable to interpret your dream. Try again.',
      name: 'dreamCalculationError',
      desc: '',
      args: [],
    );
  }

  /// `Unable to delete the account. Try again.`
  String get profileDeleteError {
    return Intl.message(
      'Unable to delete the account. Try again.',
      name: 'profileDeleteError',
      desc: '',
      args: [],
    );
  }

  /// `Unable to load data`
  String get homeLoadError {
    return Intl.message(
      'Unable to load data',
      name: 'homeLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Balance`
  String get balanceLabel {
    return Intl.message('Balance', name: 'balanceLabel', desc: '', args: []);
  }

  /// `Balance: {balance} Star Coins`
  String balanceStarsLabel(int balance) {
    return Intl.message(
      'Balance: $balance Star Coins',
      name: 'balanceStarsLabel',
      desc: '',
      args: [balance],
    );
  }

  /// `Purchased attempts are added to your free attempts`
  String get purchasedAttemptsAdd {
    return Intl.message(
      'Purchased attempts are added to your free attempts',
      name: 'purchasedAttemptsAdd',
      desc: '',
      args: [],
    );
  }

  /// `{count} of {total} requests left`
  String requestsRemaining(int count, int total) {
    return Intl.message(
      '$count of $total requests left',
      name: 'requestsRemaining',
      desc: '',
      args: [count, total],
    );
  }

  /// `Buy attempts`
  String get buyAttemptsLabel {
    return Intl.message(
      'Buy attempts',
      name: 'buyAttemptsLabel',
      desc: '',
      args: [],
    );
  }

  /// `No subscription?`
  String get noSubscriptionQuestion {
    return Intl.message(
      'No subscription?',
      name: 'noSubscriptionQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Buy attempts`
  String get buyAttempts {
    return Intl.message(
      'Buy attempts',
      name: 'buyAttempts',
      desc: '',
      args: [],
    );
  }

  /// `1 question = {price}`
  String questionCoinPrice(int price) {
    return Intl.message(
      '1 question = $price',
      name: 'questionCoinPrice',
      desc: '',
      args: [price],
    );
  }

  /// `{count} pcs`
  String shopItemCount(int count) {
    return Intl.message(
      '$count pcs',
      name: 'shopItemCount',
      desc: '',
      args: [count],
    );
  }

  /// `price per item = {price}`
  String shopUnitPriceValue(int price) {
    return Intl.message(
      'price per item = $price',
      name: 'shopUnitPriceValue',
      desc: '',
      args: [price],
    );
  }

  /// `Articles`
  String get articlesTitle {
    return Intl.message('Articles', name: 'articlesTitle', desc: '', args: []);
  }

  /// `Read more`
  String get articlesReadMore {
    return Intl.message(
      'Read more',
      name: 'articlesReadMore',
      desc: '',
      args: [],
    );
  }

  /// `Compatibility`
  String get compatibilityTitle {
    return Intl.message(
      'Compatibility',
      name: 'compatibilityTitle',
      desc: '',
      args: [],
    );
  }

  /// `Astrology for the two of you`
  String get compatibilityAboutPair {
    return Intl.message(
      'Astrology for the two of you',
      name: 'compatibilityAboutPair',
      desc: '',
      args: [],
    );
  }

  /// `See how your elements, planets, and signs work together—not only in love, but also in energy, support, and growth.`
  String get compatibilityAboutPairDescription {
    return Intl.message(
      'See how your elements, planets, and signs work together—not only in love, but also in energy, support, and growth.',
      name: 'compatibilityAboutPairDescription',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get defaultUserName {
    return Intl.message('User', name: 'defaultUserName', desc: '', args: []);
  }

  /// `Asteria website`
  String get asteriaWebsite {
    return Intl.message(
      'Asteria website',
      name: 'asteriaWebsite',
      desc: '',
      args: [],
    );
  }

  /// `Special readings`
  String get specialReadingsTitle {
    return Intl.message(
      'Special readings',
      name: 'specialReadingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Explore what is happening in your love life. For relationships, doubts, being single, or attraction.`
  String get loveReadingDescription {
    return Intl.message(
      'Explore what is happening in your love life. For relationships, doubts, being single, or attraction.',
      name: 'loveReadingDescription',
      desc: '',
      args: [],
    );
  }

  /// `A deep, precise ten-card reading that reveals the heart of a situation and its hidden influences to help you make an important decision.`
  String get celticCrossDescription {
    return Intl.message(
      'A deep, precise ten-card reading that reveals the heart of a situation and its hidden influences to help you make an important decision.',
      name: 'celticCrossDescription',
      desc: '',
      args: [],
    );
  }

  /// `Affirmations`
  String get affirmationsTitle {
    return Intl.message(
      'Affirmations',
      name: 'affirmationsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Hello!\nThis is Livia,\nthe guardian of dreams.`
  String get dreamGreeting {
    return Intl.message(
      'Hello!\nThis is Livia,\nthe guardian of dreams.',
      name: 'dreamGreeting',
      desc: '',
      args: [],
    );
  }

  /// `Tell her your dream,\nand she'll reveal its meaning.`
  String get dreamTellPrompt {
    return Intl.message(
      'Tell her your dream,\nand she\'ll reveal its meaning.',
      name: 'dreamTellPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Refresh reading`
  String get refreshReadingLabel {
    return Intl.message(
      'Refresh reading',
      name: 'refreshReadingLabel',
      desc: '',
      args: [],
    );
  }

  /// `Your reading is complete`
  String get readingComplete {
    return Intl.message(
      'Your reading is complete',
      name: 'readingComplete',
      desc: '',
      args: [],
    );
  }

  /// `Your personal yearly horoscope\nfor {price} Star Coins`
  String yearHoroscopePriceTitle(int price) {
    return Intl.message(
      'Your personal yearly horoscope\nfor $price Star Coins',
      name: 'yearHoroscopePriceTitle',
      desc: '',
      args: [price],
    );
  }

  /// `Open your map of destiny and glimpse the future created just for you.`
  String get yearHoroscopeIntro {
    return Intl.message(
      'Open your map of destiny and glimpse the future created just for you.',
      name: 'yearHoroscopeIntro',
      desc: '',
      args: [],
    );
  }

  /// `Each chapter includes:`
  String get yearHoroscopeChapters {
    return Intl.message(
      'Each chapter includes:',
      name: 'yearHoroscopeChapters',
      desc: '',
      args: [],
    );
  }

  /// `— strengths and hidden talents.`
  String get horoscopeEssenceDescription {
    return Intl.message(
      '— strengths and hidden talents.',
      name: 'horoscopeEssenceDescription',
      desc: '',
      args: [],
    );
  }

  /// `— where good fortune awaits and what deserves your attention.`
  String get horoscopeLifeAreasDescription {
    return Intl.message(
      '— where good fortune awaits and what deserves your attention.',
      name: 'horoscopeLifeAreasDescription',
      desc: '',
      args: [],
    );
  }

  /// `— your path of growth and key changes.`
  String get horoscopeEvolutionDescription {
    return Intl.message(
      '— your path of growth and key changes.',
      name: 'horoscopeEvolutionDescription',
      desc: '',
      args: [],
    );
  }

  /// `Lifetime access—read whenever you like, return, and discover new meaning in every word.`
  String get horoscopeLifetimeDescription {
    return Intl.message(
      'Lifetime access—read whenever you like, return, and discover new meaning in every word.',
      name: 'horoscopeLifetimeDescription',
      desc: '',
      args: [],
    );
  }

  /// `Buy a personal yearly horoscope for {price} Star Coins`
  String buyYearHoroscopeLabel(int price) {
    return Intl.message(
      'Buy a personal yearly horoscope for $price Star Coins',
      name: 'buyYearHoroscopeLabel',
      desc: '',
      args: [price],
    );
  }

  /// `Your birth chart\nfor {price} Star Coins`
  String natalCardPriceTitle(int price) {
    return Intl.message(
      'Your birth chart\nfor $price Star Coins',
      name: 'natalCardPriceTitle',
      desc: '',
      args: [price],
    );
  }

  /// `A detailed interpretation that's yours to keep.`
  String get natalForeverDescription {
    return Intl.message(
      'A detailed interpretation that\'s yours to keep.',
      name: 'natalForeverDescription',
      desc: '',
      args: [],
    );
  }

  /// `Buy a birth chart for {price} Star Coins`
  String buyNatalCardLabel(int price) {
    return Intl.message(
      'Buy a birth chart for $price Star Coins',
      name: 'buyNatalCardLabel',
      desc: '',
      args: [price],
    );
  }

  /// `Unable to load your birth chart. Try again.`
  String get natalLoadError {
    return Intl.message(
      'Unable to load your birth chart. Try again.',
      name: 'natalLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get natalPositionsTab {
    return Intl.message('Today', name: 'natalPositionsTab', desc: '', args: []);
  }

  /// `Elements`
  String get natalElementsTab {
    return Intl.message(
      'Elements',
      name: 'natalElementsTab',
      desc: '',
      args: [],
    );
  }

  /// `Personality foundation`
  String get natalPersonalityFoundation {
    return Intl.message(
      'Personality foundation',
      name: 'natalPersonalityFoundation',
      desc: '',
      args: [],
    );
  }

  /// `Relationships and expression`
  String get natalRelationshipsExpression {
    return Intl.message(
      'Relationships and expression',
      name: 'natalRelationshipsExpression',
      desc: '',
      args: [],
    );
  }

  /// `Growth and life`
  String get natalGrowthLife {
    return Intl.message(
      'Growth and life',
      name: 'natalGrowthLife',
      desc: '',
      args: [],
    );
  }

  /// `Destiny and depth`
  String get natalDestinyDepth {
    return Intl.message(
      'Destiny and depth',
      name: 'natalDestinyDepth',
      desc: '',
      args: [],
    );
  }

  /// `Strong house {number}`
  String natalStrongHouse(int number) {
    return Intl.message(
      'Strong house $number',
      name: 'natalStrongHouse',
      desc: '',
      args: [number],
    );
  }

  /// `Weak house {number}`
  String natalWeakHouse(int number) {
    return Intl.message(
      'Weak house $number',
      name: 'natalWeakHouse',
      desc: '',
      args: [number],
    );
  }

  /// `Emphasis on house {number}`
  String natalAccentHouse(int number) {
    return Intl.message(
      'Emphasis on house $number',
      name: 'natalAccentHouse',
      desc: '',
      args: [number],
    );
  }

  /// `Get interpretation`
  String get natalGetInterpretation {
    return Intl.message(
      'Get interpretation',
      name: 'natalGetInterpretation',
      desc: '',
      args: [],
    );
  }

  /// `Sun`
  String get planetSun {
    return Intl.message('Sun', name: 'planetSun', desc: '', args: []);
  }

  /// `Moon`
  String get planetMoon {
    return Intl.message('Moon', name: 'planetMoon', desc: '', args: []);
  }

  /// `Mercury`
  String get planetMercury {
    return Intl.message('Mercury', name: 'planetMercury', desc: '', args: []);
  }

  /// `Venus`
  String get planetVenus {
    return Intl.message('Venus', name: 'planetVenus', desc: '', args: []);
  }

  /// `Mars`
  String get planetMars {
    return Intl.message('Mars', name: 'planetMars', desc: '', args: []);
  }

  /// `Jupiter`
  String get planetJupiter {
    return Intl.message('Jupiter', name: 'planetJupiter', desc: '', args: []);
  }

  /// `Saturn`
  String get planetSaturn {
    return Intl.message('Saturn', name: 'planetSaturn', desc: '', args: []);
  }

  /// `Uranus`
  String get planetUranus {
    return Intl.message('Uranus', name: 'planetUranus', desc: '', args: []);
  }

  /// `Neptune`
  String get planetNeptune {
    return Intl.message('Neptune', name: 'planetNeptune', desc: '', args: []);
  }

  /// `Pluto`
  String get planetPluto {
    return Intl.message('Pluto', name: 'planetPluto', desc: '', args: []);
  }

  /// `Chiron`
  String get planetChiron {
    return Intl.message('Chiron', name: 'planetChiron', desc: '', args: []);
  }

  /// `Lilith`
  String get planetLilith {
    return Intl.message('Lilith', name: 'planetLilith', desc: '', args: []);
  }

  /// `Selena`
  String get planetSelena {
    return Intl.message('Selena', name: 'planetSelena', desc: '', args: []);
  }

  /// `North Node`
  String get planetNorthNode {
    return Intl.message(
      'North Node',
      name: 'planetNorthNode',
      desc: '',
      args: [],
    );
  }

  /// `South Node`
  String get planetSouthNode {
    return Intl.message(
      'South Node',
      name: 'planetSouthNode',
      desc: '',
      args: [],
    );
  }

  /// `Part of Fortune`
  String get planetParsFortunae {
    return Intl.message(
      'Part of Fortune',
      name: 'planetParsFortunae',
      desc: '',
      args: [],
    );
  }

  /// `Vertex`
  String get planetVertex {
    return Intl.message('Vertex', name: 'planetVertex', desc: '', args: []);
  }

  /// `Hello, {name}!`
  String personalGreeting(String name) {
    return Intl.message(
      'Hello, $name!',
      name: 'personalGreeting',
      desc: '',
      args: [name],
    );
  }

  /// `Hello!`
  String get personalGreetingGeneral {
    return Intl.message(
      'Hello!',
      name: 'personalGreetingGeneral',
      desc: '',
      args: [],
    );
  }

  /// `You were born under a sign of stability and deep sensitivity. You have a strong connection to emotion and intuition.`
  String get personalDefaultDescription {
    return Intl.message(
      'You were born under a sign of stability and deep sensitivity. You have a strong connection to emotion and intuition.',
      name: 'personalDefaultDescription',
      desc: '',
      args: [],
    );
  }

  /// `Your horoscope`
  String get personalYourHoroscope {
    return Intl.message(
      'Your horoscope',
      name: 'personalYourHoroscope',
      desc: '',
      args: [],
    );
  }

  /// `Your detailed personal horoscope for today is available free of charge.`
  String get personalTodayFree {
    return Intl.message(
      'Your detailed personal horoscope for today is available free of charge.',
      name: 'personalTodayFree',
      desc: '',
      args: [],
    );
  }

  /// `Impact on life areas`
  String get personalImpactAreas {
    return Intl.message(
      'Impact on life areas',
      name: 'personalImpactAreas',
      desc: '',
      args: [],
    );
  }

  /// `Advice for the day`
  String get personalAdviceDay {
    return Intl.message(
      'Advice for the day',
      name: 'personalAdviceDay',
      desc: '',
      args: [],
    );
  }

  /// `Advice for the week`
  String get personalAdviceWeek {
    return Intl.message(
      'Advice for the week',
      name: 'personalAdviceWeek',
      desc: '',
      args: [],
    );
  }

  /// `Advice for the month`
  String get personalAdviceMonth {
    return Intl.message(
      'Advice for the month',
      name: 'personalAdviceMonth',
      desc: '',
      args: [],
    );
  }

  /// `Unlock key theme`
  String get personalUnlockKeyTheme {
    return Intl.message(
      'Unlock key theme',
      name: 'personalUnlockKeyTheme',
      desc: '',
      args: [],
    );
  }

  /// `Unlock weak points`
  String get personalUnlockWeaknesses {
    return Intl.message(
      'Unlock weak points',
      name: 'personalUnlockWeaknesses',
      desc: '',
      args: [],
    );
  }

  /// `Weak points for {price}`
  String personalWeaknessesPrice(int price) {
    return Intl.message(
      'Weak points for $price',
      name: 'personalWeaknessesPrice',
      desc: '',
      args: [price],
    );
  }

  /// `Unlock forecast\nfor {price} Star Coins`
  String personalForecastPrice(int price) {
    return Intl.message(
      'Unlock forecast\nfor $price Star Coins',
      name: 'personalForecastPrice',
      desc: '',
      args: [price],
    );
  }

  /// `A detailed personal horoscope for the week is available as a one-time purchase.`
  String get personalWeekPurchaseDescription {
    return Intl.message(
      'A detailed personal horoscope for the week is available as a one-time purchase.',
      name: 'personalWeekPurchaseDescription',
      desc: '',
      args: [],
    );
  }

  /// `A detailed personal horoscope for the month is available as a one-time purchase.`
  String get personalMonthPurchaseDescription {
    return Intl.message(
      'A detailed personal horoscope for the month is available as a one-time purchase.',
      name: 'personalMonthPurchaseDescription',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get personalTodayTab {
    return Intl.message('Today', name: 'personalTodayTab', desc: '', args: []);
  }

  /// `Week`
  String get personalWeekTab {
    return Intl.message('Week', name: 'personalWeekTab', desc: '', args: []);
  }

  /// `Month`
  String get personalMonthTab {
    return Intl.message('Month', name: 'personalMonthTab', desc: '', args: []);
  }

  /// `Favorable periods`
  String get personalFavorablePeriods {
    return Intl.message(
      'Favorable periods',
      name: 'personalFavorablePeriods',
      desc: '',
      args: [],
    );
  }

  /// `Key themes\nthis month`
  String get personalMonthKeyThemes {
    return Intl.message(
      'Key themes\nthis month',
      name: 'personalMonthKeyThemes',
      desc: '',
      args: [],
    );
  }

  /// `Unlock today's horoscope`
  String get purchaseDayHoroscope {
    return Intl.message(
      'Unlock today\'s horoscope',
      name: 'purchaseDayHoroscope',
      desc: '',
      args: [],
    );
  }

  /// `Unlock weekly horoscope`
  String get purchaseWeekHoroscope {
    return Intl.message(
      'Unlock weekly horoscope',
      name: 'purchaseWeekHoroscope',
      desc: '',
      args: [],
    );
  }

  /// `Unlock monthly horoscope`
  String get purchaseMonthHoroscope {
    return Intl.message(
      'Unlock monthly horoscope',
      name: 'purchaseMonthHoroscope',
      desc: '',
      args: [],
    );
  }

  /// `Unlock yearly horoscope`
  String get purchaseYearHoroscope {
    return Intl.message(
      'Unlock yearly horoscope',
      name: 'purchaseYearHoroscope',
      desc: '',
      args: [],
    );
  }

  /// `Energy of the day`
  String get energyOfDay {
    return Intl.message(
      'Energy of the day',
      name: 'energyOfDay',
      desc: '',
      args: [],
    );
  }

  /// `Symbol of the day`
  String get dailySymbolTitle {
    return Intl.message(
      'Symbol of the day',
      name: 'dailySymbolTitle',
      desc: '',
      args: [],
    );
  }

  /// `Refresh Tarot card of the day`
  String get refreshDailyTarotLabel {
    return Intl.message(
      'Refresh Tarot card of the day',
      name: 'refreshDailyTarotLabel',
      desc: '',
      args: [],
    );
  }

  /// `Refresh Tarot spread`
  String get refreshTarotSpreadLabel {
    return Intl.message(
      'Refresh Tarot spread',
      name: 'refreshTarotSpreadLabel',
      desc: '',
      args: [],
    );
  }

  /// `Refresh rune of the day`
  String get refreshDailyRuneLabel {
    return Intl.message(
      'Refresh rune of the day',
      name: 'refreshDailyRuneLabel',
      desc: '',
      args: [],
    );
  }

  /// `Refresh rune spread`
  String get refreshRuneSpreadLabel {
    return Intl.message(
      'Refresh rune spread',
      name: 'refreshRuneSpreadLabel',
      desc: '',
      args: [],
    );
  }

  /// `Loading affirmation of the day`
  String get affirmationLoadingLabel {
    return Intl.message(
      'Loading affirmation of the day',
      name: 'affirmationLoadingLabel',
      desc: '',
      args: [],
    );
  }

  /// `Affirmation of the day unavailable`
  String get affirmationUnavailableLabel {
    return Intl.message(
      'Affirmation of the day unavailable',
      name: 'affirmationUnavailableLabel',
      desc: '',
      args: [],
    );
  }

  /// `Loading affirmation…`
  String get affirmationLoading {
    return Intl.message(
      'Loading affirmation…',
      name: 'affirmationLoading',
      desc: '',
      args: [],
    );
  }

  /// `Unable to load the affirmation. Check your connection.`
  String get affirmationLoadError {
    return Intl.message(
      'Unable to load the affirmation. Check your connection.',
      name: 'affirmationLoadError',
      desc: '',
      args: [],
    );
  }

  /// `All affirmations`
  String get allAffirmations {
    return Intl.message(
      'All affirmations',
      name: 'allAffirmations',
      desc: '',
      args: [],
    );
  }

  /// `Discover your cosmic essence`
  String get authCosmicEssence {
    return Intl.message(
      'Discover your cosmic essence',
      name: 'authCosmicEssence',
      desc: '',
      args: [],
    );
  }

  /// `Tune in to the Moon's rhythms and open your birth chart—it can guide your path.`
  String get authMoonRhythms {
    return Intl.message(
      'Tune in to the Moon\'s rhythms and open your birth chart—it can guide your path.',
      name: 'authMoonRhythms',
      desc: '',
      args: [],
    );
  }

  /// `Enter your birth date, time, and place—and let the Universe speak to you.`
  String get authBirthDetailsPrompt {
    return Intl.message(
      'Enter your birth date, time, and place—and let the Universe speak to you.',
      name: 'authBirthDetailsPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Moon phase`
  String get moonPhaseTitle {
    return Intl.message(
      'Moon phase',
      name: 'moonPhaseTitle',
      desc: '',
      args: [],
    );
  }

  /// `Pick a day`
  String get homeOpenCalendar {
    return Intl.message(
      'Pick a day',
      name: 'homeOpenCalendar',
      desc: '',
      args: [],
    );
  }

  /// `Loading moon phase`
  String get moonPhaseLoadingTitle {
    return Intl.message(
      'Loading moon phase',
      name: 'moonPhaseLoadingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Checking your current location and recalculating lunar data.`
  String get moonPhaseLoadingDescription {
    return Intl.message(
      'Checking your current location and recalculating lunar data.',
      name: 'moonPhaseLoadingDescription',
      desc: '',
      args: [],
    );
  }

  /// `Based on your location and time`
  String get moonLocationNote {
    return Intl.message(
      'Based on your location and time',
      name: 'moonLocationNote',
      desc: '',
      args: [],
    );
  }

  /// `Occurs at {time} in your local time`
  String moonPhaseEventTime(Object time) {
    return Intl.message(
      'Occurs at $time in your local time',
      name: 'moonPhaseEventTime',
      desc: '',
      args: [time],
    );
  }

  /// `New Moon`
  String get moonPhaseNewMoon {
    return Intl.message(
      'New Moon',
      name: 'moonPhaseNewMoon',
      desc: '',
      args: [],
    );
  }

  /// `Waxing Crescent`
  String get moonPhaseWaxingCrescent {
    return Intl.message(
      'Waxing Crescent',
      name: 'moonPhaseWaxingCrescent',
      desc: '',
      args: [],
    );
  }

  /// `First Quarter`
  String get moonPhaseFirstQuarter {
    return Intl.message(
      'First Quarter',
      name: 'moonPhaseFirstQuarter',
      desc: '',
      args: [],
    );
  }

  /// `Waxing Gibbous`
  String get moonPhaseWaxingGibbous {
    return Intl.message(
      'Waxing Gibbous',
      name: 'moonPhaseWaxingGibbous',
      desc: '',
      args: [],
    );
  }

  /// `Full Moon`
  String get moonPhaseFullMoon {
    return Intl.message(
      'Full Moon',
      name: 'moonPhaseFullMoon',
      desc: '',
      args: [],
    );
  }

  /// `Waning Gibbous`
  String get moonPhaseWaningGibbous {
    return Intl.message(
      'Waning Gibbous',
      name: 'moonPhaseWaningGibbous',
      desc: '',
      args: [],
    );
  }

  /// `Last Quarter`
  String get moonPhaseLastQuarter {
    return Intl.message(
      'Last Quarter',
      name: 'moonPhaseLastQuarter',
      desc: '',
      args: [],
    );
  }

  /// `Waning Crescent`
  String get moonPhaseWaningCrescent {
    return Intl.message(
      'Waning Crescent',
      name: 'moonPhaseWaningCrescent',
      desc: '',
      args: [],
    );
  }

  /// `Moon phase`
  String get moonPhaseUnknown {
    return Intl.message(
      'Moon phase',
      name: 'moonPhaseUnknown',
      desc: '',
      args: [],
    );
  }

  /// `A gentle reset: listen inward, set intentions, and avoid rushed decisions.`
  String get moonDescriptionNewMoon {
    return Intl.message(
      'A gentle reset: listen inward, set intentions, and avoid rushed decisions.',
      name: 'moonDescriptionNewMoon',
      desc: '',
      args: [],
    );
  }

  /// `Energy is building. Take the first steps, strengthen your plans, and keep your focus.`
  String get moonDescriptionWaxingCrescent {
    return Intl.message(
      'Energy is building. Take the first steps, strengthen your plans, and keep your focus.',
      name: 'moonDescriptionWaxingCrescent',
      desc: '',
      args: [],
    );
  }

  /// `Stay focused: choose what matters, move consistently, and protect your energy.`
  String get moonDescriptionFirstQuarter {
    return Intl.message(
      'Stay focused: choose what matters, move consistently, and protect your energy.',
      name: 'moonDescriptionFirstQuarter',
      desc: '',
      args: [],
    );
  }

  /// `Refine important work, review the details, and move calmly toward the result.`
  String get moonDescriptionWaxingGibbous {
    return Intl.message(
      'Refine important work, review the details, and move calmly toward the result.',
      name: 'moonDescriptionWaxingGibbous',
      desc: '',
      args: [],
    );
  }

  /// `Emotions may feel brighter than usual. Keep your balance, finish what you started, and make room for rest.`
  String get moonDescriptionFullMoon {
    return Intl.message(
      'Emotions may feel brighter than usual. Keep your balance, finish what you started, and make room for rest.',
      name: 'moonDescriptionFullMoon',
      desc: '',
      args: [],
    );
  }

  /// `A good time to share experience, practice gratitude, and release excess tension.`
  String get moonDescriptionWaningGibbous {
    return Intl.message(
      'A good time to share experience, practice gratitude, and release excess tension.',
      name: 'moonDescriptionWaningGibbous',
      desc: '',
      args: [],
    );
  }

  /// `Energy is easing. Slow down, avoid overload, and postpone major new beginnings.`
  String get moonDescriptionLastQuarter {
    return Intl.message(
      'Energy is easing. Slow down, avoid overload, and postpone major new beginnings.',
      name: 'moonDescriptionLastQuarter',
      desc: '',
      args: [],
    );
  }

  /// `A time for rest and quiet. Close loose ends and don't ask too much of yourself.`
  String get moonDescriptionWaningCrescent {
    return Intl.message(
      'A time for rest and quiet. Close loose ends and don\'t ask too much of yourself.',
      name: 'moonDescriptionWaningCrescent',
      desc: '',
      args: [],
    );
  }

  /// `Slow down, check in with yourself, and choose what supports your energy.`
  String get moonDescriptionDefault {
    return Intl.message(
      'Slow down, check in with yourself, and choose what supports your energy.',
      name: 'moonDescriptionDefault',
      desc: '',
      args: [],
    );
  }

  /// `Lunar calendar`
  String get lunarCalendarTitle {
    return Intl.message(
      'Lunar calendar',
      name: 'lunarCalendarTitle',
      desc: '',
      args: [],
    );
  }

  /// `Previous month`
  String get calendarPreviousMonth {
    return Intl.message(
      'Previous month',
      name: 'calendarPreviousMonth',
      desc: '',
      args: [],
    );
  }

  /// `Next month`
  String get calendarNextMonth {
    return Intl.message(
      'Next month',
      name: 'calendarNextMonth',
      desc: '',
      args: [],
    );
  }

  /// `The Moon supports your plans today. Make important plans, act with confidence, and choose what helps you move forward.`
  String get dayFavorableDescription {
    return Intl.message(
      'The Moon supports your plans today. Make important plans, act with confidence, and choose what helps you move forward.',
      name: 'dayFavorableDescription',
      desc: '',
      args: [],
    );
  }

  /// `This is a pause between impulse and action. The Moon neither adds nor takes away energy. Don't wait for inspiration—take care of yourself and avoid overload. Inner quiet is a strength too.`
  String get dayNeutralDescription {
    return Intl.message(
      'This is a pause between impulse and action. The Moon neither adds nor takes away energy. Don\'t wait for inspiration—take care of yourself and avoid overload. Inner quiet is a strength too.',
      name: 'dayNeutralDescription',
      desc: '',
      args: [],
    );
  }

  /// `Ease your workload today and don't force events. Postpone abrupt decisions, conserve your energy, and choose a calmer pace.`
  String get dayUnfavorableDescription {
    return Intl.message(
      'Ease your workload today and don\'t force events. Postpone abrupt decisions, conserve your energy, and choose a calmer pace.',
      name: 'dayUnfavorableDescription',
      desc: '',
      args: [],
    );
  }

  /// `Day tone: {title}`
  String moonBackgroundTitle(Object title) {
    return Intl.message(
      'Day tone: $title',
      name: 'moonBackgroundTitle',
      desc: '',
      args: [title],
    );
  }

  /// `{sphere}: {status}`
  String moonSphereStatusTitle(Object sphere, Object status) {
    return Intl.message(
      '$sphere: $status',
      name: 'moonSphereStatusTitle',
      desc: '',
      args: [sphere, status],
    );
  }

  /// `favorable`
  String get moonStatusFavorableShort {
    return Intl.message(
      'favorable',
      name: 'moonStatusFavorableShort',
      desc: '',
      args: [],
    );
  }

  /// `neutral`
  String get moonStatusNeutralShort {
    return Intl.message(
      'neutral',
      name: 'moonStatusNeutralShort',
      desc: '',
      args: [],
    );
  }

  /// `unfavorable`
  String get moonStatusUnfavorableShort {
    return Intl.message(
      'unfavorable',
      name: 'moonStatusUnfavorableShort',
      desc: '',
      args: [],
    );
  }

  /// `Showing the general lunar calendar`
  String get moonGenericFallbackNotice {
    return Intl.message(
      'Showing the general lunar calendar',
      name: 'moonGenericFallbackNotice',
      desc: '',
      args: [],
    );
  }

  /// `Loading lunar day`
  String get moonCalendarLoadingDayTitle {
    return Intl.message(
      'Loading lunar day',
      name: 'moonCalendarLoadingDayTitle',
      desc: '',
      args: [],
    );
  }

  /// `Checking today's date, Moon phase, and recommendations.`
  String get moonCalendarLoadingDayDescription {
    return Intl.message(
      'Checking today\'s date, Moon phase, and recommendations.',
      name: 'moonCalendarLoadingDayDescription',
      desc: '',
      args: [],
    );
  }

  /// `Beauty`
  String get sphereBeauty {
    return Intl.message('Beauty', name: 'sphereBeauty', desc: '', args: []);
  }

  /// `Gardening`
  String get sphereGarden {
    return Intl.message('Gardening', name: 'sphereGarden', desc: '', args: []);
  }

  /// `Health`
  String get sphereHealth {
    return Intl.message('Health', name: 'sphereHealth', desc: '', args: []);
  }

  /// `Work and rest`
  String get sphereWorkRest {
    return Intl.message(
      'Work and rest',
      name: 'sphereWorkRest',
      desc: '',
      args: [],
    );
  }

  /// `Relationships`
  String get sphereRelationships {
    return Intl.message(
      'Relationships',
      name: 'sphereRelationships',
      desc: '',
      args: [],
    );
  }

  /// `Choose an area`
  String get sphereSelect {
    return Intl.message(
      'Choose an area',
      name: 'sphereSelect',
      desc: '',
      args: [],
    );
  }

  /// `Subscribe to discover how the Moon affects you`
  String get sphereSubscriptionRequired {
    return Intl.message(
      'Subscribe to discover how the Moon affects you',
      name: 'sphereSubscriptionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Moscow`
  String get defaultLocationMoscow {
    return Intl.message(
      'Moscow',
      name: 'defaultLocationMoscow',
      desc: '',
      args: [],
    );
  }

  /// `Set your current location`
  String get moonLocationSetupTitle {
    return Intl.message(
      'Set your current location',
      name: 'moonLocationSetupTitle',
      desc: '',
      args: [],
    );
  }

  /// `The lunar day and moonrise time depend on where you are now. Allow location access or enter a city manually.`
  String get moonLocationSetupDescription {
    return Intl.message(
      'The lunar day and moonrise time depend on where you are now. Allow location access or enter a city manually.',
      name: 'moonLocationSetupDescription',
      desc: '',
      args: [],
    );
  }

  /// `Allow location`
  String get locationAllowButton {
    return Intl.message(
      'Allow location',
      name: 'locationAllowButton',
      desc: '',
      args: [],
    );
  }

  /// `Choose city manually`
  String get locationManualButton {
    return Intl.message(
      'Choose city manually',
      name: 'locationManualButton',
      desc: '',
      args: [],
    );
  }

  /// `City`
  String get locationManualInputHint {
    return Intl.message(
      'City',
      name: 'locationManualInputHint',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't detect your location. Allow access in device settings or enter a city manually.`
  String get locationPermissionDenied {
    return Intl.message(
      'We couldn\'t detect your location. Allow access in device settings or enter a city manually.',
      name: 'locationPermissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `Detected automatically`
  String get currentLocationAutoLabel {
    return Intl.message(
      'Detected automatically',
      name: 'currentLocationAutoLabel',
      desc: '',
      args: [],
    );
  }

  /// `Set manually`
  String get currentLocationManualLabel {
    return Intl.message(
      'Set manually',
      name: 'currentLocationManualLabel',
      desc: '',
      args: [],
    );
  }

  /// `Choose a city`
  String get citySelectionTitle {
    return Intl.message(
      'Choose a city',
      name: 'citySelectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `is this your city?`
  String get cityConfirmationQuestion {
    return Intl.message(
      'is this your city?',
      name: 'cityConfirmationQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Could not save the city. Please try again.`
  String get citySaveError {
    return Intl.message(
      'Could not save the city. Please try again.',
      name: 'citySaveError',
      desc: '',
      args: [],
    );
  }

  /// `No cities found`
  String get citySearchEmpty {
    return Intl.message(
      'No cities found',
      name: 'citySearchEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Correct`
  String get citySelectionConfirm {
    return Intl.message(
      'Correct',
      name: 'citySelectionConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Change`
  String get citySelectionChange {
    return Intl.message(
      'Change',
      name: 'citySelectionChange',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't load cities. Check the city name or try again.`
  String get citySearchError {
    return Intl.message(
      'We couldn\'t load cities. Check the city name or try again.',
      name: 'citySearchError',
      desc: '',
      args: [],
    );
  }

  /// `Geolocation`
  String get settingsGeolocation {
    return Intl.message(
      'Geolocation',
      name: 'settingsGeolocation',
      desc: '',
      args: [],
    );
  }

  /// `We use your current city for the lunar calendar and moon phase. Birth place stays only for your natal chart.`
  String get settingsCurrentLocationDescription {
    return Intl.message(
      'We use your current city for the lunar calendar and moon phase. Birth place stays only for your natal chart.',
      name: 'settingsCurrentLocationDescription',
      desc: '',
      args: [],
    );
  }

  /// `Current location is not set`
  String get locationNotConfigured {
    return Intl.message(
      'Current location is not set',
      name: 'locationNotConfigured',
      desc: '',
      args: [],
    );
  }

  /// `Your next payment\nwill be charged`
  String get subscriptionNextPayment {
    return Intl.message(
      'Your next payment\nwill be charged',
      name: 'subscriptionNextPayment',
      desc: '',
      args: [],
    );
  }

  /// `Your next payment\nwill be charged on\n{date}`
  String subscriptionNextPaymentOn(String date) {
    return Intl.message(
      'Your next payment\nwill be charged on\n$date',
      name: 'subscriptionNextPaymentOn',
      desc: '',
      args: [date],
    );
  }

  /// `Manage`
  String get manage {
    return Intl.message('Manage', name: 'manage', desc: '', args: []);
  }

  /// `Unlock advanced PRO\nfeatures and cancel\nany time.`
  String get subscriptionInactiveDescription {
    return Intl.message(
      'Unlock advanced PRO\nfeatures and cancel\nany time.',
      name: 'subscriptionInactiveDescription',
      desc: '',
      args: [],
    );
  }

  /// `Refreshing the Tarot card is available with a subscription. Subscribe to receive a new card every day.`
  String get tarotRefreshSubscriptionRequired {
    return Intl.message(
      'Refreshing the Tarot card is available with a subscription. Subscribe to receive a new card every day.',
      name: 'tarotRefreshSubscriptionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Refreshing the rune of the day is available with a subscription. Subscribe to receive a new rune every day.`
  String get runeRefreshSubscriptionRequired {
    return Intl.message(
      'Refreshing the rune of the day is available with a subscription. Subscribe to receive a new rune every day.',
      name: 'runeRefreshSubscriptionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Loading…`
  String get loading {
    return Intl.message('Loading…', name: 'loading', desc: '', args: []);
  }

  /// `Payment received. Your subscription will activate within a few minutes.`
  String get subscriptionActivationPending {
    return Intl.message(
      'Payment received. Your subscription will activate within a few minutes.',
      name: 'subscriptionActivationPending',
      desc: '',
      args: [],
    );
  }

  /// `No purchases were found to restore`
  String get subscriptionNoPurchasesToRestore {
    return Intl.message(
      'No purchases were found to restore',
      name: 'subscriptionNoPurchasesToRestore',
      desc: '',
      args: [],
    );
  }

  /// `Purchases restored: {count}`
  String subscriptionPurchasesRestored(int count) {
    return Intl.message(
      'Purchases restored: $count',
      name: 'subscriptionPurchasesRestored',
      desc: '',
      args: [count],
    );
  }

  /// `Arc Pay subscriptions are not available yet`
  String get arcPaySubscriptionUnavailable {
    return Intl.message(
      'Arc Pay subscriptions are not available yet',
      name: 'arcPaySubscriptionUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Star Coins can be purchased through the Faster Payments System. Subscriptions will become available after saved-card testing is complete.`
  String get arcPaySubscriptionUnavailableDescription {
    return Intl.message(
      'Star Coins can be purchased through the Faster Payments System. Subscriptions will become available after saved-card testing is complete.',
      name: 'arcPaySubscriptionUnavailableDescription',
      desc: '',
      args: [],
    );
  }

  /// `Confirming your card and first payment…`
  String get subscriptionConfirmingCard {
    return Intl.message(
      'Confirming your card and first payment…',
      name: 'subscriptionConfirmingCard',
      desc: '',
      args: [],
    );
  }

  /// `Choose a plan`
  String get subscriptionChoosePlan {
    return Intl.message(
      'Choose a plan',
      name: 'subscriptionChoosePlan',
      desc: '',
      args: [],
    );
  }

  /// `Load plans`
  String get subscriptionLoadPlans {
    return Intl.message(
      'Load plans',
      name: 'subscriptionLoadPlans',
      desc: '',
      args: [],
    );
  }

  /// `Subscriptions are currently unavailable. Try again later.`
  String get subscriptionPlansUnavailable {
    return Intl.message(
      'Subscriptions are currently unavailable. Try again later.',
      name: 'subscriptionPlansUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Access will remain available until\n`
  String get subscriptionAccessUntil {
    return Intl.message(
      'Access will remain available until\n',
      name: 'subscriptionAccessUntil',
      desc: '',
      args: [],
    );
  }

  /// `Your next payment will be\ncharged on `
  String get subscriptionNextPaymentInline {
    return Intl.message(
      'Your next payment will be\ncharged on ',
      name: 'subscriptionNextPaymentInline',
      desc: '',
      args: [],
    );
  }

  /// `What your subscription includes`
  String get subscriptionBenefitsTitle {
    return Intl.message(
      'What your subscription includes',
      name: 'subscriptionBenefitsTitle',
      desc: '',
      args: [],
    );
  }

  /// `You have access to:`
  String get subscriptionAvailableToYou {
    return Intl.message(
      'You have access to:',
      name: 'subscriptionAvailableToYou',
      desc: '',
      args: [],
    );
  }

  /// `Restore purchases`
  String get subscriptionRestorePurchases {
    return Intl.message(
      'Restore purchases',
      name: 'subscriptionRestorePurchases',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to\ncancel your subscription?`
  String get subscriptionCancelQuestion {
    return Intl.message(
      'Are you sure you want to\ncancel your subscription?',
      name: 'subscriptionCancelQuestion',
      desc: '',
      args: [],
    );
  }

  /// `All services will remain available\nuntil the end of the paid period`
  String get subscriptionCancelDescription {
    return Intl.message(
      'All services will remain available\nuntil the end of the paid period',
      name: 'subscriptionCancelDescription',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Clear message`
  String get clearMessage {
    return Intl.message(
      'Clear message',
      name: 'clearMessage',
      desc: '',
      args: [],
    );
  }

  /// `Free requests will reset in {count, plural, one{{count} day} other{{count} days}}.`
  String freeRequestsResetIn(int count) {
    return Intl.message(
      'Free requests will reset in ${Intl.plural(count, one: '$count day', other: '$count days')}.',
      name: 'freeRequestsResetIn',
      desc: '',
      args: [count],
    );
  }

  /// `The limit will reset in {count, plural, one{{count} day} other{{count} days}}.`
  String requestLimitResetIn(int count) {
    return Intl.message(
      'The limit will reset in ${Intl.plural(count, one: '$count day', other: '$count days')}.',
      name: 'requestLimitResetIn',
      desc: '',
      args: [count],
    );
  }

  /// `Unlimited`
  String get unlimited {
    return Intl.message('Unlimited', name: 'unlimited', desc: '', args: []);
  }

  /// `Purchased requests are added to your free requests`
  String get purchasedAttemptsCombine {
    return Intl.message(
      'Purchased requests are added to your free requests',
      name: 'purchasedAttemptsCombine',
      desc: '',
      args: [],
    );
  }

  /// `Payment`
  String get paymentTitle {
    return Intl.message('Payment', name: 'paymentTitle', desc: '', args: []);
  }

  /// `Arc Pay accepted the payment. Your coins will appear after the server credits them.`
  String get paymentConfirmingMessage {
    return Intl.message(
      'Arc Pay accepted the payment. Your coins will appear after the server credits them.',
      name: 'paymentConfirmingMessage',
      desc: '',
      args: [],
    );
  }

  /// `Complete the payment in your external browser. The status updates automatically.`
  String get paymentWaitingMessage {
    return Intl.message(
      'Complete the payment in your external browser. The status updates automatically.',
      name: 'paymentWaitingMessage',
      desc: '',
      args: [],
    );
  }

  /// `Payment successful!`
  String get paymentSuccess {
    return Intl.message(
      'Payment successful!',
      name: 'paymentSuccess',
      desc: '',
      args: [],
    );
  }

  /// `{coins} coins credited. Balance: {balance}`
  String paymentCoinsCredited(int coins, int balance) {
    return Intl.message(
      '$coins coins credited. Balance: $balance',
      name: 'paymentCoinsCredited',
      desc: '',
      args: [coins, balance],
    );
  }

  /// `{coins} coins credited. Your balance was updated.`
  String paymentCoinsCreditedBalanceUpdated(int coins) {
    return Intl.message(
      '$coins coins credited. Your balance was updated.',
      name: 'paymentCoinsCreditedBalanceUpdated',
      desc: '',
      args: [coins],
    );
  }

  /// `You can create a new payment. If your bank has already confirmed this one, your Star Coins will still be credited after server verification.`
  String get paymentLeaveDescription {
    return Intl.message(
      'You can create a new payment. If your bank has already confirmed this one, your Star Coins will still be credited after server verification.',
      name: 'paymentLeaveDescription',
      desc: '',
      args: [],
    );
  }

  /// `You can create a new payment. A later bank confirmation for the previous payment won't be lost.`
  String get paymentAbandonedServerConfirmed {
    return Intl.message(
      'You can create a new payment. A later bank confirmation for the previous payment won\'t be lost.',
      name: 'paymentAbandonedServerConfirmed',
      desc: '',
      args: [],
    );
  }

  /// `The attempt was closed on this device. The server will continue to process any bank confirmation safely.`
  String get paymentAbandonedLocal {
    return Intl.message(
      'The attempt was closed on this device. The server will continue to process any bank confirmation safely.',
      name: 'paymentAbandonedLocal',
      desc: '',
      args: [],
    );
  }

  /// `Your bank declined the payment.`
  String get paymentDeclined {
    return Intl.message(
      'Your bank declined the payment.',
      name: 'paymentDeclined',
      desc: '',
      args: [],
    );
  }

  /// `The payment expired.`
  String get paymentExpired {
    return Intl.message(
      'The payment expired.',
      name: 'paymentExpired',
      desc: '',
      args: [],
    );
  }

  /// `The payment was sent for manual review.`
  String get paymentManualReview {
    return Intl.message(
      'The payment was sent for manual review.',
      name: 'paymentManualReview',
      desc: '',
      args: [],
    );
  }

  /// `The payment was not completed.`
  String get paymentNotCompleted {
    return Intl.message(
      'The payment was not completed.',
      name: 'paymentNotCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Payment diagnostics\nStore region: {countryCode}\nSelected provider: {provider}`
  String paymentDiagnostics(String countryCode, String provider) {
    return Intl.message(
      'Payment diagnostics\nStore region: $countryCode\nSelected provider: $provider',
      name: 'paymentDiagnostics',
      desc: '',
      args: [countryCode, provider],
    );
  }

  /// `Subscribe for unlimited access to everything.`
  String get subscriptionUnlimitedAccess {
    return Intl.message(
      'Subscribe for unlimited access to everything.',
      name: 'subscriptionUnlimitedAccess',
      desc: '',
      args: [],
    );
  }

  /// `Packages are currently unavailable`
  String get coinPackagesUnavailable {
    return Intl.message(
      'Packages are currently unavailable',
      name: 'coinPackagesUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Packages are currently unavailable. Try again later.`
  String get coinPackagesUnavailableRetry {
    return Intl.message(
      'Packages are currently unavailable. Try again later.',
      name: 'coinPackagesUnavailableRetry',
      desc: '',
      args: [],
    );
  }

  /// `Load packages`
  String get coinPackagesLoad {
    return Intl.message(
      'Load packages',
      name: 'coinPackagesLoad',
      desc: '',
      args: [],
    );
  }

  /// `{coins} Star Coin package`
  String coinPackageFallback(int coins) {
    return Intl.message(
      '$coins Star Coin package',
      name: 'coinPackageFallback',
      desc: '',
      args: [coins],
    );
  }

  /// `Save`
  String get savings {
    return Intl.message('Save', name: 'savings', desc: '', args: []);
  }

  /// `Payment received. Your Star Coins will appear within a few minutes.`
  String get coinPurchasePending {
    return Intl.message(
      'Payment received. Your Star Coins will appear within a few minutes.',
      name: 'coinPurchasePending',
      desc: '',
      args: [],
    );
  }

  /// `Store products could not be loaded. Try again.`
  String get storeProductsLoadError {
    return Intl.message(
      'Store products could not be loaded. Try again.',
      name: 'storeProductsLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Sign in to continue with your purchase.`
  String get storeSignInRequiredError {
    return Intl.message(
      'Sign in to continue with your purchase.',
      name: 'storeSignInRequiredError',
      desc: '',
      args: [],
    );
  }

  /// `The purchase could not be started. Try again.`
  String get storePurchaseStartError {
    return Intl.message(
      'The purchase could not be started. Try again.',
      name: 'storePurchaseStartError',
      desc: '',
      args: [],
    );
  }

  /// `Purchase canceled.`
  String get storePurchaseCanceled {
    return Intl.message(
      'Purchase canceled.',
      name: 'storePurchaseCanceled',
      desc: '',
      args: [],
    );
  }

  /// `The purchase could not be completed. Try again.`
  String get storePurchaseFailedError {
    return Intl.message(
      'The purchase could not be completed. Try again.',
      name: 'storePurchaseFailedError',
      desc: '',
      args: [],
    );
  }

  /// `The purchase could not be verified. Contact support if you were charged.`
  String get storePurchaseVerificationError {
    return Intl.message(
      'The purchase could not be verified. Contact support if you were charged.',
      name: 'storePurchaseVerificationError',
      desc: '',
      args: [],
    );
  }

  /// `There was a purchase error. Please contact support.`
  String get storePurchaseSupportError {
    return Intl.message(
      'There was a purchase error. Please contact support.',
      name: 'storePurchaseSupportError',
      desc: '',
      args: [],
    );
  }

  /// `Purchases could not be restored. Try again.`
  String get storeRestorePurchasesError {
    return Intl.message(
      'Purchases could not be restored. Try again.',
      name: 'storeRestorePurchasesError',
      desc: '',
      args: [],
    );
  }

  /// `First Moon`
  String get coinPackageFirstMoon {
    return Intl.message(
      'First Moon',
      name: 'coinPackageFirstMoon',
      desc: '',
      args: [],
    );
  }

  /// `Retrograde Path`
  String get coinPackageRetrogradePath {
    return Intl.message(
      'Retrograde Path',
      name: 'coinPackageRetrogradePath',
      desc: '',
      args: [],
    );
  }

  /// `Sunlight`
  String get coinPackageSunlight {
    return Intl.message(
      'Sunlight',
      name: 'coinPackageSunlight',
      desc: '',
      args: [],
    );
  }

  /// `Star Path`
  String get coinPackageStarPath {
    return Intl.message(
      'Star Path',
      name: 'coinPackageStarPath',
      desc: '',
      args: [],
    );
  }

  /// `Secret of the Universe`
  String get coinPackageUniverseSecret {
    return Intl.message(
      'Secret of the Universe',
      name: 'coinPackageUniverseSecret',
      desc: '',
      args: [],
    );
  }

  /// `Enough for one request`
  String get coinPackageDescription10 {
    return Intl.message(
      'Enough for one request',
      name: 'coinPackageDescription10',
      desc: '',
      args: [],
    );
  }

  /// `Enough for a couple of readings`
  String get coinPackageDescription30 {
    return Intl.message(
      'Enough for a couple of readings',
      name: 'coinPackageDescription30',
      desc: '',
      args: [],
    );
  }

  /// `Most popular`
  String get coinPackageDescription60 {
    return Intl.message(
      'Most popular',
      name: 'coinPackageDescription60',
      desc: '',
      args: [],
    );
  }

  /// `A lasting supply`
  String get coinPackageDescription120 {
    return Intl.message(
      'A lasting supply',
      name: 'coinPackageDescription120',
      desc: '',
      args: [],
    );
  }

  /// `For every wish`
  String get coinPackageDescription300 {
    return Intl.message(
      'For every wish',
      name: 'coinPackageDescription300',
      desc: '',
      args: [],
    );
  }

  /// `Love`
  String get affirmationCategoryLove {
    return Intl.message(
      'Love',
      name: 'affirmationCategoryLove',
      desc: '',
      args: [],
    );
  }

  /// `Abundance`
  String get affirmationCategoryAbundance {
    return Intl.message(
      'Abundance',
      name: 'affirmationCategoryAbundance',
      desc: '',
      args: [],
    );
  }

  /// `Strength`
  String get affirmationCategoryStrength {
    return Intl.message(
      'Strength',
      name: 'affirmationCategoryStrength',
      desc: '',
      args: [],
    );
  }

  /// `Creativity`
  String get affirmationCategoryCreativity {
    return Intl.message(
      'Creativity',
      name: 'affirmationCategoryCreativity',
      desc: '',
      args: [],
    );
  }

  /// `Lunar`
  String get affirmationCategoryLunar {
    return Intl.message(
      'Lunar',
      name: 'affirmationCategoryLunar',
      desc: '',
      args: [],
    );
  }

  /// `Calm`
  String get affirmationCategoryCalm {
    return Intl.message(
      'Calm',
      name: 'affirmationCategoryCalm',
      desc: '',
      args: [],
    );
  }

  /// `{category}. Subscription only`
  String affirmationCategoryLocked(String category) {
    return Intl.message(
      '$category. Subscription only',
      name: 'affirmationCategoryLocked',
      desc: '',
      args: [category],
    );
  }

  /// `This affirmation is included with a subscription. Get access to every affirmation, including locked categories, and other exclusive features.`
  String get affirmationSubscriptionRequired {
    return Intl.message(
      'This affirmation is included with a subscription. Get access to every affirmation, including locked categories, and other exclusive features.',
      name: 'affirmationSubscriptionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Open the audio player`
  String get affirmationOpenPlayer {
    return Intl.message(
      'Open the audio player',
      name: 'affirmationOpenPlayer',
      desc: '',
      args: [],
    );
  }

  /// `Swipe left or right to change the affirmation`
  String get affirmationSwipeHint {
    return Intl.message(
      'Swipe left or right to change the affirmation',
      name: 'affirmationSwipeHint',
      desc: '',
      args: [],
    );
  }

  /// `Affirmation: {text}`
  String affirmationSemantics(String text) {
    return Intl.message(
      'Affirmation: $text',
      name: 'affirmationSemantics',
      desc: '',
      args: [text],
    );
  }

  /// `Card of the day`
  String get tarotTabDay {
    return Intl.message(
      'Card of the day',
      name: 'tarotTabDay',
      desc: '',
      args: [],
    );
  }

  /// `Spread`
  String get tarotTabSpread {
    return Intl.message('Spread', name: 'tarotTabSpread', desc: '', args: []);
  }

  /// `All cards`
  String get tarotTabAllCards {
    return Intl.message(
      'All cards',
      name: 'tarotTabAllCards',
      desc: '',
      args: [],
    );
  }

  /// `Tarot cards`
  String get tarotCardsTitle {
    return Intl.message(
      'Tarot cards',
      name: 'tarotCardsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Unable to load Tarot cards.`
  String get tarotLoadError {
    return Intl.message(
      'Unable to load Tarot cards.',
      name: 'tarotLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Love spread`
  String get loveDeckTitle {
    return Intl.message(
      'Love spread',
      name: 'loveDeckTitle',
      desc: '',
      args: [],
    );
  }

  /// `Celtic Cross`
  String get keltDeckTitle {
    return Intl.message(
      'Celtic Cross',
      name: 'keltDeckTitle',
      desc: '',
      args: [],
    );
  }

  /// `Spread insights are available with a subscription. Subscribe to discover the meaning of your spread.`
  String get tarotInsightSubscriptionRequired {
    return Intl.message(
      'Spread insights are available with a subscription. Subscribe to discover the meaning of your spread.',
      name: 'tarotInsightSubscriptionRequired',
      desc: '',
      args: [],
    );
  }

  /// `You've already changed your spread today. You can choose a new spread again tomorrow, or subscribe for unlimited changes.`
  String get tarotSpreadDailyLimit {
    return Intl.message(
      'You\'ve already changed your spread today. You can choose a new spread again tomorrow, or subscribe for unlimited changes.',
      name: 'tarotSpreadDailyLimit',
      desc: '',
      args: [],
    );
  }

  /// `Tarot spread`
  String get tarotSpreadTitle {
    return Intl.message(
      'Tarot spread',
      name: 'tarotSpreadTitle',
      desc: '',
      args: [],
    );
  }

  /// `A Tarot spread answers a specific question.\nOpen the cards in order—together they form one complete answer.\nFirst phrase your question, then reveal each card and choose the area it relates to.`
  String get tarotSpreadDescription {
    return Intl.message(
      'A Tarot spread answers a specific question.\nOpen the cards in order—together they form one complete answer.\nFirst phrase your question, then reveal each card and choose the area it relates to.',
      name: 'tarotSpreadDescription',
      desc: '',
      args: [],
    );
  }

  /// `Tap a card to flip it`
  String get tarotTapToFlip {
    return Intl.message(
      'Tap a card to flip it',
      name: 'tarotTapToFlip',
      desc: '',
      args: [],
    );
  }

  /// `Open card {position} of 3`
  String tarotOpenSpreadCard(int position) {
    return Intl.message(
      'Open card $position of 3',
      name: 'tarotOpenSpreadCard',
      desc: '',
      args: [position],
    );
  }

  /// `Card {position} of 3: {card}`
  String tarotOpenedSpreadCard(int position, String card) {
    return Intl.message(
      'Card $position of 3: $card',
      name: 'tarotOpenedSpreadCard',
      desc: '',
      args: [position, card],
    );
  }

  /// `Choose an area\nto receive an insight`
  String get tarotChooseSphere {
    return Intl.message(
      'Choose an area\nto receive an insight',
      name: 'tarotChooseSphere',
      desc: '',
      args: [],
    );
  }

  /// `Love and relationships`
  String get tarotSphereLove {
    return Intl.message(
      'Love and relationships',
      name: 'tarotSphereLove',
      desc: '',
      args: [],
    );
  }

  /// `Self-realization`
  String get tarotSphereSelfRealization {
    return Intl.message(
      'Self-realization',
      name: 'tarotSphereSelfRealization',
      desc: '',
      args: [],
    );
  }

  /// `Spirituality`
  String get tarotSphereSpirituality {
    return Intl.message(
      'Spirituality',
      name: 'tarotSphereSpirituality',
      desc: '',
      args: [],
    );
  }

  /// `Health and energy`
  String get tarotSphereHealth {
    return Intl.message(
      'Health and energy',
      name: 'tarotSphereHealth',
      desc: '',
      args: [],
    );
  }

  /// `Family and home`
  String get tarotSphereFamily {
    return Intl.message(
      'Family and home',
      name: 'tarotSphereFamily',
      desc: '',
      args: [],
    );
  }

  /// `Career and money`
  String get tarotSphereCareer {
    return Intl.message(
      'Career and money',
      name: 'tarotSphereCareer',
      desc: '',
      args: [],
    );
  }

  /// `1. Center yourself. Think about your question or situation.\n\n2. Choose a card or a spread—intuitively or by following the instructions.\n\n3. Read each card's meaning and relate it to current events.\n\n4. Trust your intuition. Tarot doesn't deliver rigid verdicts; it helps reveal what is hidden.\n\n5. Choose the area of life your question concerns for a more precise interpretation.`
  String get tarotHowToSteps {
    return Intl.message(
      '1. Center yourself. Think about your question or situation.\n\n2. Choose a card or a spread—intuitively or by following the instructions.\n\n3. Read each card\'s meaning and relate it to current events.\n\n4. Trust your intuition. Tarot doesn\'t deliver rigid verdicts; it helps reveal what is hidden.\n\n5. Choose the area of life your question concerns for a more precise interpretation.',
      name: 'tarotHowToSteps',
      desc: '',
      args: [],
    );
  }

  /// `Remember: an interpretation is guidance, not a verdict. You are always in charge of your life.`
  String get tarotHowToReminder {
    return Intl.message(
      'Remember: an interpretation is guidance, not a verdict. You are always in charge of your life.',
      name: 'tarotHowToReminder',
      desc: '',
      args: [],
    );
  }

  /// `No cards found`
  String get tarotCardsEmpty {
    return Intl.message(
      'No cards found',
      name: 'tarotCardsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Open {title}`
  String tarotOpenCardLabel(String title) {
    return Intl.message(
      'Open $title',
      name: 'tarotOpenCardLabel',
      desc: '',
      args: [title],
    );
  }

  /// `{title} is locked`
  String tarotLockedCardLabel(String title) {
    return Intl.message(
      '$title is locked',
      name: 'tarotLockedCardLabel',
      desc: '',
      args: [title],
    );
  }

  /// `Rune of the day`
  String get runesTabDay {
    return Intl.message(
      'Rune of the day',
      name: 'runesTabDay',
      desc: '',
      args: [],
    );
  }

  /// `Spread`
  String get runesTabSpread {
    return Intl.message('Spread', name: 'runesTabSpread', desc: '', args: []);
  }

  /// `All runes`
  String get runesTabAll {
    return Intl.message('All runes', name: 'runesTabAll', desc: '', args: []);
  }

  /// `Runes`
  String get runesTitle {
    return Intl.message('Runes', name: 'runesTitle', desc: '', args: []);
  }

  /// `Unable to load runes.`
  String get runesLoadError {
    return Intl.message(
      'Unable to load runes.',
      name: 'runesLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Spread insights are available with a subscription. Subscribe to discover the meaning of your spread.`
  String get runesInsightSubscriptionRequired {
    return Intl.message(
      'Spread insights are available with a subscription. Subscribe to discover the meaning of your spread.',
      name: 'runesInsightSubscriptionRequired',
      desc: '',
      args: [],
    );
  }

  /// `You've already changed your spread today. You can choose a new spread again tomorrow, or subscribe for unlimited changes.`
  String get runesSpreadDailyLimit {
    return Intl.message(
      'You\'ve already changed your spread today. You can choose a new spread again tomorrow, or subscribe for unlimited changes.',
      name: 'runesSpreadDailyLimit',
      desc: '',
      args: [],
    );
  }

  /// `Rune spread`
  String get runesSpreadTitle {
    return Intl.message(
      'Rune spread',
      name: 'runesSpreadTitle',
      desc: '',
      args: [],
    );
  }

  /// `Each rune in this spread represents a different part of your situation:`
  String get runesSpreadDescription {
    return Intl.message(
      'Each rune in this spread represents a different part of your situation:',
      name: 'runesSpreadDescription',
      desc: '',
      args: [],
    );
  }

  /// `What brought you to this point: experience, lessons, and the root of the question.`
  String get runesPastDescription {
    return Intl.message(
      'What brought you to this point: experience, lessons, and the root of the question.',
      name: 'runesPastDescription',
      desc: '',
      args: [],
    );
  }

  /// `Where you are now: your inner state and current influences.`
  String get runesPresentDescription {
    return Intl.message(
      'Where you are now: your inner state and current influences.',
      name: 'runesPresentDescription',
      desc: '',
      args: [],
    );
  }

  /// `Where things are heading: a possible outcome, direction, or guidance for the path ahead.`
  String get runesFutureDescription {
    return Intl.message(
      'Where things are heading: a possible outcome, direction, or guidance for the path ahead.',
      name: 'runesFutureDescription',
      desc: '',
      args: [],
    );
  }

  /// `Tap a rune to flip it`
  String get runesTapToFlip {
    return Intl.message(
      'Tap a rune to flip it',
      name: 'runesTapToFlip',
      desc: '',
      args: [],
    );
  }

  /// `Runes are not fortune-telling in the literal sense. They are symbols that reveal your inner knowledge, help you hear your intuition, and find answers already within you.`
  String get runesHowToIntroduction {
    return Intl.message(
      'Runes are not fortune-telling in the literal sense. They are symbols that reveal your inner knowledge, help you hear your intuition, and find answers already within you.',
      name: 'runesHowToIntroduction',
      desc: '',
      args: [],
    );
  }

  /// `1. Set an intention. Ask yourself a question or choose an area where you want guidance.\n\n2. Settle into the moment. Quiet your thoughts. Runes work best in inner and outer stillness.\n\n3. Choose a rune. Don't overthink it. Trust yourself—your rune will find you.\n\n4. Read its meaning. Notice the symbol and its essence. Don't look for a simple yes or no; look deeper.\n\n5. Listen to yourself. Notice what resonates. Runes offer direction, but you walk the path.`
  String get runesHowToSteps {
    return Intl.message(
      '1. Set an intention. Ask yourself a question or choose an area where you want guidance.\n\n2. Settle into the moment. Quiet your thoughts. Runes work best in inner and outer stillness.\n\n3. Choose a rune. Don\'t overthink it. Trust yourself—your rune will find you.\n\n4. Read its meaning. Notice the symbol and its essence. Don\'t look for a simple yes or no; look deeper.\n\n5. Listen to yourself. Notice what resonates. Runes offer direction, but you walk the path.',
      name: 'runesHowToSteps',
      desc: '',
      args: [],
    );
  }

  /// `Runes are neither a verdict nor a prediction of fate. They are a mirror that can help you see yourself more clearly. Treat them with respect, and they can become wise companions on your path.`
  String get runesHowToReminder {
    return Intl.message(
      'Runes are neither a verdict nor a prediction of fate. They are a mirror that can help you see yourself more clearly. Treat them with respect, and they can become wise companions on your path.',
      name: 'runesHowToReminder',
      desc: '',
      args: [],
    );
  }

  /// `No runes found`
  String get runesEmpty {
    return Intl.message(
      'No runes found',
      name: 'runesEmpty',
      desc: '',
      args: [],
    );
  }

  /// `{title} is locked`
  String runeLockedLabel(String title) {
    return Intl.message(
      '$title is locked',
      name: 'runeLockedLabel',
      desc: '',
      args: [title],
    );
  }

  /// `Open {title}`
  String runeOpenLabel(String title) {
    return Intl.message(
      'Open $title',
      name: 'runeOpenLabel',
      desc: '',
      args: [title],
    );
  }

  /// `Open the past rune`
  String get runeOpenPast {
    return Intl.message(
      'Open the past rune',
      name: 'runeOpenPast',
      desc: '',
      args: [],
    );
  }

  /// `Open the present rune`
  String get runeOpenPresent {
    return Intl.message(
      'Open the present rune',
      name: 'runeOpenPresent',
      desc: '',
      args: [],
    );
  }

  /// `Open the future rune`
  String get runeOpenFuture {
    return Intl.message(
      'Open the future rune',
      name: 'runeOpenFuture',
      desc: '',
      args: [],
    );
  }

  /// `Open the meaning of the past rune {title}`
  String runeOpenPastMeaning(String title) {
    return Intl.message(
      'Open the meaning of the past rune $title',
      name: 'runeOpenPastMeaning',
      desc: '',
      args: [title],
    );
  }

  /// `Open the meaning of the present rune {title}`
  String runeOpenPresentMeaning(String title) {
    return Intl.message(
      'Open the meaning of the present rune $title',
      name: 'runeOpenPresentMeaning',
      desc: '',
      args: [title],
    );
  }

  /// `Open the meaning of the future rune {title}`
  String runeOpenFutureMeaning(String title) {
    return Intl.message(
      'Open the meaning of the future rune $title',
      name: 'runeOpenFutureMeaning',
      desc: '',
      args: [title],
    );
  }

  /// `Look into your partner's feelings and discover where your relationship is heading`
  String get loveDeckTagline {
    return Intl.message(
      'Look into your partner\'s feelings and discover where your relationship is heading',
      name: 'loveDeckTagline',
      desc: '',
      args: [],
    );
  }

  /// `Six cards reveal your relationship's past, present, and possible future.\nOpen them in order to understand what is happening between you.`
  String get loveDeckDescription {
    return Intl.message(
      'Six cards reveal your relationship\'s past, present, and possible future.\nOpen them in order to understand what is happening between you.',
      name: 'loveDeckDescription',
      desc: '',
      args: [],
    );
  }

  /// `The Love spread helps you understand yourself, your partner, and your connection. Its six cards each represent an important aspect of your relationship:`
  String get loveDeckHowToIntroduction {
    return Intl.message(
      'The Love spread helps you understand yourself, your partner, and your connection. Its six cards each represent an important aspect of your relationship:',
      name: 'loveDeckHowToIntroduction',
      desc: '',
      args: [],
    );
  }

  /// `Open the cards one at a time and read each meaning in the context of your situation.`
  String get loveDeckHowToClosing {
    return Intl.message(
      'Open the cards one at a time and read each meaning in the context of your situation.',
      name: 'loveDeckHowToClosing',
      desc: '',
      args: [],
    );
  }

  /// `Their feelings—what they feel toward you`
  String get loveDeckPositionPartnerFeelings {
    return Intl.message(
      'Their feelings—what they feel toward you',
      name: 'loveDeckPositionPartnerFeelings',
      desc: '',
      args: [],
    );
  }

  /// `Your feelings—your emotions and wishes`
  String get loveDeckPositionYourFeelings {
    return Intl.message(
      'Your feelings—your emotions and wishes',
      name: 'loveDeckPositionYourFeelings',
      desc: '',
      args: [],
    );
  }

  /// `Shared energy—how your energies interact`
  String get loveDeckPositionSharedEnergy {
    return Intl.message(
      'Shared energy—how your energies interact',
      name: 'loveDeckPositionSharedEnergy',
      desc: '',
      args: [],
    );
  }

  /// `What gets in the way—obstacles or misunderstandings`
  String get loveDeckPositionObstacles {
    return Intl.message(
      'What gets in the way—obstacles or misunderstandings',
      name: 'loveDeckPositionObstacles',
      desc: '',
      args: [],
    );
  }

  /// `What helps—resources and support in the relationship`
  String get loveDeckPositionSupport {
    return Intl.message(
      'What helps—resources and support in the relationship',
      name: 'loveDeckPositionSupport',
      desc: '',
      args: [],
    );
  }

  /// `The relationship's future—how the situation may develop`
  String get loveDeckPositionFuture {
    return Intl.message(
      'The relationship\'s future—how the situation may develop',
      name: 'loveDeckPositionFuture',
      desc: '',
      args: [],
    );
  }

  /// `Card {number}`
  String deckCardLabel(int number) {
    return Intl.message(
      'Card $number',
      name: 'deckCardLabel',
      desc: '',
      args: [number],
    );
  }

  /// `Card {number}: {title}`
  String deckOpenedCardLabel(int number, String title) {
    return Intl.message(
      'Card $number: $title',
      name: 'deckOpenedCardLabel',
      desc: '',
      args: [number, title],
    );
  }

  /// `A Tarot spread answers a specific question. Open the cards in order—together they form one complete answer. First phrase your question, then reveal each card and choose the area it relates to.`
  String get keltDeckDescription {
    return Intl.message(
      'A Tarot spread answers a specific question. Open the cards in order—together they form one complete answer. First phrase your question, then reveal each card and choose the area it relates to.',
      name: 'keltDeckDescription',
      desc: '',
      args: [],
    );
  }

  /// `You've opened all 10 cards of the Celtic Cross. This spread offers a complete view of the situation: from roots in the past to future trends, and from inner motives to outside influences.\n✨ Reflect on the question you brought. What resonates most now? Did one card stand out?\nTo explore the spread more deeply:\n• Return to key positions 1, 4, and 6\n• Notice what repeats\n• Consider the guidance in position 10`
  String get keltDeckCompletedDescription {
    return Intl.message(
      'You\'ve opened all 10 cards of the Celtic Cross. This spread offers a complete view of the situation: from roots in the past to future trends, and from inner motives to outside influences.\n✨ Reflect on the question you brought. What resonates most now? Did one card stand out?\nTo explore the spread more deeply:\n• Return to key positions 1, 4, and 6\n• Notice what repeats\n• Consider the guidance in position 10',
      name: 'keltDeckCompletedDescription',
      desc: '',
      args: [],
    );
  }

  /// `The Celtic Cross is one of the most detailed Tarot spreads. It helps reveal hidden causes, outside influences, and a likely outcome. Each of its 10 cards represents a specific aspect; read the card and consider its position.`
  String get keltDeckHowToIntroduction {
    return Intl.message(
      'The Celtic Cross is one of the most detailed Tarot spreads. It helps reveal hidden causes, outside influences, and a likely outcome. Each of its 10 cards represents a specific aspect; read the card and consider its position.',
      name: 'keltDeckHowToIntroduction',
      desc: '',
      args: [],
    );
  }

  /// `Read each card carefully. Don't rush: consider the position first, then the card. The interpretations can help you understand the situation and choose your path.`
  String get keltDeckHowToClosing {
    return Intl.message(
      'Read each card carefully. Don\'t rush: consider the position first, then the card. The interpretations can help you understand the situation and choose your path.',
      name: 'keltDeckHowToClosing',
      desc: '',
      args: [],
    );
  }

  /// `The present situation`
  String get keltPosition1Title {
    return Intl.message(
      'The present situation',
      name: 'keltPosition1Title',
      desc: '',
      args: [],
    );
  }

  /// `The challenge`
  String get keltPosition2Title {
    return Intl.message(
      'The challenge',
      name: 'keltPosition2Title',
      desc: '',
      args: [],
    );
  }

  /// `The foundation`
  String get keltPosition3Title {
    return Intl.message(
      'The foundation',
      name: 'keltPosition3Title',
      desc: '',
      args: [],
    );
  }

  /// `The past`
  String get keltPosition4Title {
    return Intl.message(
      'The past',
      name: 'keltPosition4Title',
      desc: '',
      args: [],
    );
  }

  /// `Potential`
  String get keltPosition5Title {
    return Intl.message(
      'Potential',
      name: 'keltPosition5Title',
      desc: '',
      args: [],
    );
  }

  /// `The near future`
  String get keltPosition6Title {
    return Intl.message(
      'The near future',
      name: 'keltPosition6Title',
      desc: '',
      args: [],
    );
  }

  /// `Yourself`
  String get keltPosition7Title {
    return Intl.message(
      'Yourself',
      name: 'keltPosition7Title',
      desc: '',
      args: [],
    );
  }

  /// `Your environment`
  String get keltPosition8Title {
    return Intl.message(
      'Your environment',
      name: 'keltPosition8Title',
      desc: '',
      args: [],
    );
  }

  /// `Advice or caution`
  String get keltPosition9Title {
    return Intl.message(
      'Advice or caution',
      name: 'keltPosition9Title',
      desc: '',
      args: [],
    );
  }

  /// `Outcome`
  String get keltPosition10Title {
    return Intl.message(
      'Outcome',
      name: 'keltPosition10Title',
      desc: '',
      args: [],
    );
  }

  /// `The present situation—what is happening now`
  String get keltPosition1Item {
    return Intl.message(
      'The present situation—what is happening now',
      name: 'keltPosition1Item',
      desc: '',
      args: [],
    );
  }

  /// `The challenge—what blocks you or creates difficulty`
  String get keltPosition2Item {
    return Intl.message(
      'The challenge—what blocks you or creates difficulty',
      name: 'keltPosition2Item',
      desc: '',
      args: [],
    );
  }

  /// `The foundation—the root and deeper cause`
  String get keltPosition3Item {
    return Intl.message(
      'The foundation—the root and deeper cause',
      name: 'keltPosition3Item',
      desc: '',
      args: [],
    );
  }

  /// `The past—events that shaped the current situation`
  String get keltPosition4Item {
    return Intl.message(
      'The past—events that shaped the current situation',
      name: 'keltPosition4Item',
      desc: '',
      args: [],
    );
  }

  /// `Potential—what may happen if the current path continues`
  String get keltPosition5Item {
    return Intl.message(
      'Potential—what may happen if the current path continues',
      name: 'keltPosition5Item',
      desc: '',
      args: [],
    );
  }

  /// `The near future—what may emerge soon`
  String get keltPosition6Item {
    return Intl.message(
      'The near future—what may emerge soon',
      name: 'keltPosition6Item',
      desc: '',
      args: [],
    );
  }

  /// `Yourself—your mindset and behavior`
  String get keltPosition7Item {
    return Intl.message(
      'Yourself—your mindset and behavior',
      name: 'keltPosition7Item',
      desc: '',
      args: [],
    );
  }

  /// `Your environment—other people and outside factors`
  String get keltPosition8Item {
    return Intl.message(
      'Your environment—other people and outside factors',
      name: 'keltPosition8Item',
      desc: '',
      args: [],
    );
  }

  /// `Advice or caution—what you need to know or consider`
  String get keltPosition9Item {
    return Intl.message(
      'Advice or caution—what you need to know or consider',
      name: 'keltPosition9Item',
      desc: '',
      args: [],
    );
  }

  /// `Outcome—where the situation may lead`
  String get keltPosition10Item {
    return Intl.message(
      'Outcome—where the situation may lead',
      name: 'keltPosition10Item',
      desc: '',
      args: [],
    );
  }

  /// `This position shows what is happening at the time of your question.`
  String get keltPosition1Description {
    return Intl.message(
      'This position shows what is happening at the time of your question.',
      name: 'keltPosition1Description',
      desc: '',
      args: [],
    );
  }

  /// `This position shows what is blocking you or creating difficulty.`
  String get keltPosition2Description {
    return Intl.message(
      'This position shows what is blocking you or creating difficulty.',
      name: 'keltPosition2Description',
      desc: '',
      args: [],
    );
  }

  /// `This position points to the root and deeper cause of the situation.`
  String get keltPosition3Description {
    return Intl.message(
      'This position points to the root and deeper cause of the situation.',
      name: 'keltPosition3Description',
      desc: '',
      args: [],
    );
  }

  /// `This position points to past events or influences that shaped the current situation.`
  String get keltPosition4Description {
    return Intl.message(
      'This position points to past events or influences that shaped the current situation.',
      name: 'keltPosition4Description',
      desc: '',
      args: [],
    );
  }

  /// `This position shows the potential and likely development of events.`
  String get keltPosition5Description {
    return Intl.message(
      'This position shows the potential and likely development of events.',
      name: 'keltPosition5Description',
      desc: '',
      args: [],
    );
  }

  /// `This position shows the near future and what may emerge soon.`
  String get keltPosition6Description {
    return Intl.message(
      'This position shows the near future and what may emerge soon.',
      name: 'keltPosition6Description',
      desc: '',
      args: [],
    );
  }

  /// `This position reveals your inner mindset and behavior.`
  String get keltPosition7Description {
    return Intl.message(
      'This position reveals your inner mindset and behavior.',
      name: 'keltPosition7Description',
      desc: '',
      args: [],
    );
  }

  /// `This position shows the influence of other people and outside factors.`
  String get keltPosition8Description {
    return Intl.message(
      'This position shows the influence of other people and outside factors.',
      name: 'keltPosition8Description',
      desc: '',
      args: [],
    );
  }

  /// `This position offers advice or a caution worth considering.`
  String get keltPosition9Description {
    return Intl.message(
      'This position offers advice or a caution worth considering.',
      name: 'keltPosition9Description',
      desc: '',
      args: [],
    );
  }

  /// `This position shows the outcome and direction of the situation.`
  String get keltPosition10Description {
    return Intl.message(
      'This position shows the outcome and direction of the situation.',
      name: 'keltPosition10Description',
      desc: '',
      args: [],
    );
  }

  /// `Card {number} — {position}`
  String keltCardPositionTitle(int number, String position) {
    return Intl.message(
      'Card $number — $position',
      name: 'keltCardPositionTitle',
      desc: '',
      args: [number, position],
    );
  }

  /// `{count, plural, =0{No requests left} one{{count} request left} other{{count} requests left}}`
  String requestsLeftCount(int count) {
    return Intl.plural(
      count,
      zero: 'No requests left',
      one: '$count request left',
      other: '$count requests left',
      name: 'requestsLeftCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{{count} attempt left} other{{count} attempts left}}`
  String attemptsLeftCount(int count) {
    return Intl.plural(
      count,
      one: '$count attempt left',
      other: '$count attempts left',
      name: 'attemptsLeftCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count}/{total} requests left`
  String requestsLeftOfTotal(int count, int total) {
    return Intl.message(
      '$count/$total requests left',
      name: 'requestsLeftOfTotal',
      desc: '',
      args: [count, total],
    );
  }

  /// `{count, plural, one{{count} request} other{{count} requests}}`
  String requestPackageCount(int count) {
    return Intl.plural(
      count,
      one: '$count request',
      other: '$count requests',
      name: 'requestPackageCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{{count} request for {price} Star Coins} other{{count} requests for {price} Star Coins}}`
  String requestPackageForCoins(int count, int price) {
    return Intl.plural(
      count,
      one: '$count request for $price Star Coins',
      other: '$count requests for $price Star Coins',
      name: 'requestPackageForCoins',
      desc: '',
      args: [count, price],
    );
  }

  /// `Buy {count, plural, one{{count} request} other{{count} requests}}`
  String purchaseRequestsTitle(int count) {
    return Intl.message(
      'Buy ${Intl.plural(count, one: '$count request', other: '$count requests')}',
      name: 'purchaseRequestsTitle',
      desc: '',
      args: [count],
    );
  }

  /// `Anakra`
  String get anakraName {
    return Intl.message('Anakra', name: 'anakraName', desc: '', args: []);
  }

  /// `Welcome.\nI'm Anakra—\nguardian of\nthe stars and\nyour path.`
  String get anakraGreetingTitle {
    return Intl.message(
      'Welcome.\nI\'m Anakra—\nguardian of\nthe stars and\nyour path.',
      name: 'anakraGreetingTitle',
      desc: '',
      args: [],
    );
  }

  /// `The stars are ready to answer.`
  String get anakraReady {
    return Intl.message(
      'The stars are ready to answer.',
      name: 'anakraReady',
      desc: '',
      args: [],
    );
  }

  /// `Welcome. I'm Anakra, guardian of the stars and your celestial path. Ask me a question or choose where to begin.`
  String get anakraGreetingMessage {
    return Intl.message(
      'Welcome. I\'m Anakra, guardian of the stars and your celestial path. Ask me a question or choose where to begin.',
      name: 'anakraGreetingMessage',
      desc: '',
      args: [],
    );
  }

  /// `Anakra is typing…`
  String get anakraTyping {
    return Intl.message(
      'Anakra is typing…',
      name: 'anakraTyping',
      desc: '',
      args: [],
    );
  }

  /// `{free}/{total} free + {paid} purchased`
  String anakraFreeAndPurchased(int free, int total, int paid) {
    return Intl.message(
      '$free/$total free + $paid purchased',
      name: 'anakraFreeAndPurchased',
      desc: '',
      args: [free, total, paid],
    );
  }

  /// `Enter your partner's\ndetails`
  String get compatibilityPartnerDetailsTitle {
    return Intl.message(
      'Enter your partner\'s\ndetails',
      name: 'compatibilityPartnerDetailsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Partner's date of birth`
  String get compatibilityPartnerBirthDate {
    return Intl.message(
      'Partner\'s date of birth',
      name: 'compatibilityPartnerBirthDate',
      desc: '',
      args: [],
    );
  }

  /// `You`
  String get compatibilityYou {
    return Intl.message('You', name: 'compatibilityYou', desc: '', args: []);
  }

  /// `Compatibility\nhistory`
  String get compatibilityHistoryTitle {
    return Intl.message(
      'Compatibility\nhistory',
      name: 'compatibilityHistoryTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your compatibility history is empty`
  String get compatibilityHistoryEmpty {
    return Intl.message(
      'Your compatibility history is empty',
      name: 'compatibilityHistoryEmpty',
      desc: '',
      args: [],
    );
  }

  /// `No compatibility data`
  String get compatibilityNoData {
    return Intl.message(
      'No compatibility data',
      name: 'compatibilityNoData',
      desc: '',
      args: [],
    );
  }

  /// `Request history`
  String get dreamHistoryTitle {
    return Intl.message(
      'Request history',
      name: 'dreamHistoryTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your Dream Dictionary history is empty`
  String get dreamHistoryEmpty {
    return Intl.message(
      'Your Dream Dictionary history is empty',
      name: 'dreamHistoryEmpty',
      desc: '',
      args: [],
    );
  }

  /// `No dream interpretation data`
  String get dreamNoData {
    return Intl.message(
      'No dream interpretation data',
      name: 'dreamNoData',
      desc: '',
      args: [],
    );
  }

  /// `Subscribe for unlimited access to everything.`
  String get balanceSubscriptionDescription {
    return Intl.message(
      'Subscribe for unlimited access to everything.',
      name: 'balanceSubscriptionDescription',
      desc: '',
      args: [],
    );
  }

  /// ` is the in-app currency. Use it for spreads, forecasts, and chats with the AI Astrologer.`
  String get balanceCurrencyDescription {
    return Intl.message(
      ' is the in-app currency. Use it for spreads, forecasts, and chats with the AI Astrologer.',
      name: 'balanceCurrencyDescription',
      desc: '',
      args: [],
    );
  }

  /// `Balance history`
  String get balanceHistoryTitle {
    return Intl.message(
      'Balance history',
      name: 'balanceHistoryTitle',
      desc: '',
      args: [],
    );
  }

  /// `Where can I spend it?`
  String get balanceWhereToSpend {
    return Intl.message(
      'Where can I spend it?',
      name: 'balanceWhereToSpend',
      desc: '',
      args: [],
    );
  }

  /// `Credits`
  String get balanceDeposits {
    return Intl.message('Credits', name: 'balanceDeposits', desc: '', args: []);
  }

  /// `Charges`
  String get balanceWithdrawals {
    return Intl.message(
      'Charges',
      name: 'balanceWithdrawals',
      desc: '',
      args: [],
    );
  }

  /// `All activity`
  String get balanceAllOperations {
    return Intl.message(
      'All activity',
      name: 'balanceAllOperations',
      desc: '',
      args: [],
    );
  }

  /// `Horoscope`
  String get horoscopeTitle {
    return Intl.message(
      'Horoscope',
      name: 'horoscopeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Unable to load your horoscope.`
  String get horoscopeLoadError {
    return Intl.message(
      'Unable to load your horoscope.',
      name: 'horoscopeLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Unable to create your horoscope.`
  String get horoscopeCreateError {
    return Intl.message(
      'Unable to create your horoscope.',
      name: 'horoscopeCreateError',
      desc: '',
      args: [],
    );
  }

  /// `Astrological\nmetaphor`
  String get horoscopeMetaphor {
    return Intl.message(
      'Astrological\nmetaphor',
      name: 'horoscopeMetaphor',
      desc: '',
      args: [],
    );
  }

  /// `Creating your destiny chart…`
  String get astrologyLoadingChart {
    return Intl.message(
      'Creating your destiny chart…',
      name: 'astrologyLoadingChart',
      desc: '',
      args: [],
    );
  }

  /// `Reading messages from the stars…`
  String get astrologyLoadingStars {
    return Intl.message(
      'Reading messages from the stars…',
      name: 'astrologyLoadingStars',
      desc: '',
      args: [],
    );
  }

  /// `Interpreting astrological symbols…`
  String get astrologyLoadingSymbols {
    return Intl.message(
      'Interpreting astrological symbols…',
      name: 'astrologyLoadingSymbols',
      desc: '',
      args: [],
    );
  }

  /// `Preparing your personal horoscope…`
  String get astrologyLoadingPersonal {
    return Intl.message(
      'Preparing your personal horoscope…',
      name: 'astrologyLoadingPersonal',
      desc: '',
      args: [],
    );
  }

  /// `The stars are consulting…`
  String get compatibilityLoadingConsulting {
    return Intl.message(
      'The stars are consulting…',
      name: 'compatibilityLoadingConsulting',
      desc: '',
      args: [],
    );
  }

  /// `The Universe is revealing its secrets…`
  String get compatibilityLoadingSecrets {
    return Intl.message(
      'The Universe is revealing its secrets…',
      name: 'compatibilityLoadingSecrets',
      desc: '',
      args: [],
    );
  }

  /// `Comparing your paths…`
  String get compatibilityLoadingDestinies {
    return Intl.message(
      'Comparing your paths…',
      name: 'compatibilityLoadingDestinies',
      desc: '',
      args: [],
    );
  }

  /// `Reading the celestial signs…`
  String get compatibilityLoadingSigns {
    return Intl.message(
      'Reading the celestial signs…',
      name: 'compatibilityLoadingSigns',
      desc: '',
      args: [],
    );
  }

  /// `Connecting the stars into your destiny pattern…`
  String get natalLoadingPattern {
    return Intl.message(
      'Connecting the stars into your destiny pattern…',
      name: 'natalLoadingPattern',
      desc: '',
      args: [],
    );
  }

  /// `Reading the secret language of the planets…`
  String get natalLoadingLanguage {
    return Intl.message(
      'Reading the secret language of the planets…',
      name: 'natalLoadingLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Revealing your celestial personality code…`
  String get natalLoadingCode {
    return Intl.message(
      'Revealing your celestial personality code…',
      name: 'natalLoadingCode',
      desc: '',
      args: [],
    );
  }

  /// `The Universe is creating your star portrait…`
  String get natalLoadingPortrait {
    return Intl.message(
      'The Universe is creating your star portrait…',
      name: 'natalLoadingPortrait',
      desc: '',
      args: [],
    );
  }

  /// `Unable to start rewards.`
  String get rewardStartError {
    return Intl.message(
      'Unable to start rewards.',
      name: 'rewardStartError',
      desc: '',
      args: [],
    );
  }

  /// `Unable to load rewards.`
  String get rewardLoadError {
    return Intl.message(
      'Unable to load rewards.',
      name: 'rewardLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Unable to share Asteria.`
  String get rewardShareError {
    return Intl.message(
      'Unable to share Asteria.',
      name: 'rewardShareError',
      desc: '',
      args: [],
    );
  }

  /// `Discover Asteria—horoscopes, Tarot, and the lunar calendar: {link}`
  String rewardShareText(String link) {
    return Intl.message(
      'Discover Asteria—horoscopes, Tarot, and the lunar calendar: $link',
      name: 'rewardShareText',
      desc: '',
      args: [link],
    );
  }

  /// `Asteria—your personal astrology guide`
  String get rewardShareSubject {
    return Intl.message(
      'Asteria—your personal astrology guide',
      name: 'rewardShareSubject',
      desc: '',
      args: [],
    );
  }

  /// `Choose your payment method on Arc Pay's secure page when buying Star Coins.`
  String get paymentSettingsDescription {
    return Intl.message(
      'Choose your payment method on Arc Pay\'s secure page when buying Star Coins.',
      name: 'paymentSettingsDescription',
      desc: '',
      args: [],
    );
  }

  /// `Unable to send the code. Try again.`
  String get emailSendCodeError {
    return Intl.message(
      'Unable to send the code. Try again.',
      name: 'emailSendCodeError',
      desc: '',
      args: [],
    );
  }

  /// `The code is incorrect or has expired.`
  String get emailInvalidOrExpiredCodeError {
    return Intl.message(
      'The code is incorrect or has expired.',
      name: 'emailInvalidOrExpiredCodeError',
      desc: '',
      args: [],
    );
  }

  /// `Too many attempts. Try again later.`
  String get emailRateLimitedError {
    return Intl.message(
      'Too many attempts. Try again later.',
      name: 'emailRateLimitedError',
      desc: '',
      args: [],
    );
  }

  /// `Unable to send the email. Try again later.`
  String get emailDeliveryError {
    return Intl.message(
      'Unable to send the email. Try again later.',
      name: 'emailDeliveryError',
      desc: '',
      args: [],
    );
  }

  /// `Email sign-in is temporarily unavailable.`
  String get emailUnavailableError {
    return Intl.message(
      'Email sign-in is temporarily unavailable.',
      name: 'emailUnavailableError',
      desc: '',
      args: [],
    );
  }

  /// `Unable to connect to the server.`
  String get emailNetworkError {
    return Intl.message(
      'Unable to connect to the server.',
      name: 'emailNetworkError',
      desc: '',
      args: [],
    );
  }

  /// `Unable to sign in. Check your connection and try again.`
  String get emailSignInError {
    return Intl.message(
      'Unable to sign in. Check your connection and try again.',
      name: 'emailSignInError',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong. Try again.`
  String get emailUnknownError {
    return Intl.message(
      'Something went wrong. Try again.',
      name: 'emailUnknownError',
      desc: '',
      args: [],
    );
  }

  /// `This content is not available in English yet. Please try again later.`
  String get contentTranslationUnavailable {
    return Intl.message(
      'This content is not available in English yet. Please try again later.',
      name: 'contentTranslationUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Haircuts`
  String get lunarHaircut {
    return Intl.message('Haircuts', name: 'lunarHaircut', desc: '', args: []);
  }

  /// `Hair coloring`
  String get lunarHairColoring {
    return Intl.message(
      'Hair coloring',
      name: 'lunarHairColoring',
      desc: '',
      args: [],
    );
  }

  /// `Skin care`
  String get lunarSkinCare {
    return Intl.message('Skin care', name: 'lunarSkinCare', desc: '', args: []);
  }

  /// `Manicure and pedicure`
  String get lunarManicurePedicure {
    return Intl.message(
      'Manicure and pedicure',
      name: 'lunarManicurePedicure',
      desc: '',
      args: [],
    );
  }

  /// `Cosmetology`
  String get lunarCosmetology {
    return Intl.message(
      'Cosmetology',
      name: 'lunarCosmetology',
      desc: '',
      args: [],
    );
  }

  /// `Hair removal`
  String get lunarEpilationDepilation {
    return Intl.message(
      'Hair removal',
      name: 'lunarEpilationDepilation',
      desc: '',
      args: [],
    );
  }

  /// `Spa and relaxation`
  String get lunarSpaRelaxation {
    return Intl.message(
      'Spa and relaxation',
      name: 'lunarSpaRelaxation',
      desc: '',
      args: [],
    );
  }

  /// `Fragrance and magnetism`
  String get lunarFragrancesMagnetism {
    return Intl.message(
      'Fragrance and magnetism',
      name: 'lunarFragrancesMagnetism',
      desc: '',
      args: [],
    );
  }

  /// `Sowing and planting`
  String get lunarSowingPlanting {
    return Intl.message(
      'Sowing and planting',
      name: 'lunarSowingPlanting',
      desc: '',
      args: [],
    );
  }

  /// `Transplanting and pricking out`
  String get lunarTransplantingPricking {
    return Intl.message(
      'Transplanting and pricking out',
      name: 'lunarTransplantingPricking',
      desc: '',
      args: [],
    );
  }

  /// `Watering and fertilizing`
  String get lunarWateringFertilizing {
    return Intl.message(
      'Watering and fertilizing',
      name: 'lunarWateringFertilizing',
      desc: '',
      args: [],
    );
  }

  /// `Pest control`
  String get lunarPestControl {
    return Intl.message(
      'Pest control',
      name: 'lunarPestControl',
      desc: '',
      args: [],
    );
  }

  /// `Harvesting and preserving`
  String get lunarHarvestingPreserving {
    return Intl.message(
      'Harvesting and preserving',
      name: 'lunarHarvestingPreserving',
      desc: '',
      args: [],
    );
  }

  /// `Houseplants`
  String get lunarHouseplants {
    return Intl.message(
      'Houseplants',
      name: 'lunarHouseplants',
      desc: '',
      args: [],
    );
  }

  /// `Garden`
  String get lunarGarden {
    return Intl.message('Garden', name: 'lunarGarden', desc: '', args: []);
  }

  /// `Health and immunity`
  String get lunarHealthImmunity {
    return Intl.message(
      'Health and immunity',
      name: 'lunarHealthImmunity',
      desc: '',
      args: [],
    );
  }

  /// `Daily diet`
  String get lunarDailyDiet {
    return Intl.message(
      'Daily diet',
      name: 'lunarDailyDiet',
      desc: '',
      args: [],
    );
  }

  /// `Weight loss and fasting days`
  String get lunarWeightLossFasting {
    return Intl.message(
      'Weight loss and fasting days',
      name: 'lunarWeightLossFasting',
      desc: '',
      args: [],
    );
  }

  /// `Sleep and recovery`
  String get lunarSleepRecovery {
    return Intl.message(
      'Sleep and recovery',
      name: 'lunarSleepRecovery',
      desc: '',
      args: [],
    );
  }

  /// `Physical activity and sports`
  String get lunarPhysicalActivitySports {
    return Intl.message(
      'Physical activity and sports',
      name: 'lunarPhysicalActivitySports',
      desc: '',
      args: [],
    );
  }

  /// `Medical procedures`
  String get lunarMedicalProcedures {
    return Intl.message(
      'Medical procedures',
      name: 'lunarMedicalProcedures',
      desc: '',
      args: [],
    );
  }

  /// `Meditation`
  String get lunarMeditations {
    return Intl.message(
      'Meditation',
      name: 'lunarMeditations',
      desc: '',
      args: [],
    );
  }

  /// `Changing jobs`
  String get lunarJobChange {
    return Intl.message(
      'Changing jobs',
      name: 'lunarJobChange',
      desc: '',
      args: [],
    );
  }

  /// `Career growth`
  String get lunarCareerGrowth {
    return Intl.message(
      'Career growth',
      name: 'lunarCareerGrowth',
      desc: '',
      args: [],
    );
  }

  /// `Work`
  String get lunarWork {
    return Intl.message('Work', name: 'lunarWork', desc: '', args: []);
  }

  /// `Travel`
  String get lunarTravel {
    return Intl.message('Travel', name: 'lunarTravel', desc: '', args: []);
  }

  /// `Important decisions`
  String get lunarImportantDecisions {
    return Intl.message(
      'Important decisions',
      name: 'lunarImportantDecisions',
      desc: '',
      args: [],
    );
  }

  /// `Family`
  String get lunarFamily {
    return Intl.message('Family', name: 'lunarFamily', desc: '', args: []);
  }

  /// `Couple`
  String get lunarCouple {
    return Intl.message('Couple', name: 'lunarCouple', desc: '', args: []);
  }

  /// `Friends`
  String get lunarFriends {
    return Intl.message('Friends', name: 'lunarFriends', desc: '', args: []);
  }

  /// `Sex`
  String get lunarSex {
    return Intl.message('Sex', name: 'lunarSex', desc: '', args: []);
  }

  /// `For singles`
  String get lunarForThoseAlone {
    return Intl.message(
      'For singles',
      name: 'lunarForThoseAlone',
      desc: '',
      args: [],
    );
  }

  /// `My inner strength grows with every breath, filling me with confidence and calm in every moment of life.`
  String get onboardingPreviewAffirmation {
    return Intl.message(
      'My inner strength grows with every breath, filling me with confidence and calm in every moment of life.',
      name: 'onboardingPreviewAffirmation',
      desc: '',
      args: [],
    );
  }

  /// `Lower attention and focus`
  String get onboardingPreviewRiskPhrase {
    return Intl.message(
      'Lower attention and focus',
      name: 'onboardingPreviewRiskPhrase',
      desc: '',
      args: [],
    );
  }

  /// `Be careful with financial investments.`
  String get onboardingPreviewRiskDescription {
    return Intl.message(
      'Be careful with financial investments.',
      name: 'onboardingPreviewRiskDescription',
      desc: '',
      args: [],
    );
  }

  /// `Strong focus and energy`
  String get onboardingPreviewFocusPhrase {
    return Intl.message(
      'Strong focus and energy',
      name: 'onboardingPreviewFocusPhrase',
      desc: '',
      args: [],
    );
  }

  /// `A day for breakthrough ideas. The planets support clarity and action. A good time to take the initiative.`
  String get onboardingPreviewFocusDescription {
    return Intl.message(
      'A day for breakthrough ideas. The planets support clarity and action. A good time to take the initiative.',
      name: 'onboardingPreviewFocusDescription',
      desc: '',
      args: [],
    );
  }

  /// `Hi, why am I feeling so tired?`
  String get onboardPreviewAnakraQuestion {
    return Intl.message(
      'Hi, why am I feeling so tired?',
      name: 'onboardPreviewAnakraQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Welcome ✨ Today your energy asks you to slow down, restore your inner balance and give yourself more rest 🌙`
  String get onboardPreviewAnakraReply {
    return Intl.message(
      'Welcome ✨ Today your energy asks you to slow down, restore your inner balance and give yourself more rest 🌙',
      name: 'onboardPreviewAnakraReply',
      desc: '',
      args: [],
    );
  }

  /// `Taurus`
  String get onboardPreviewTaurus {
    return Intl.message(
      'Taurus',
      name: 'onboardPreviewTaurus',
      desc: '',
      args: [],
    );
  }

  /// `13 May 1995`
  String get onboardPreviewTaurusDates {
    return Intl.message(
      '13 May 1995',
      name: 'onboardPreviewTaurusDates',
      desc: '',
      args: [],
    );
  }

  /// `Gemini`
  String get onboardPreviewGemini {
    return Intl.message(
      'Gemini',
      name: 'onboardPreviewGemini',
      desc: '',
      args: [],
    );
  }

  /// `22 May 1994`
  String get onboardPreviewGeminiDates {
    return Intl.message(
      '22 May 1994',
      name: 'onboardPreviewGeminiDates',
      desc: '',
      args: [],
    );
  }

  /// `69%`
  String get onboardPreviewCompatibilityScore {
    return Intl.message(
      '69%',
      name: 'onboardPreviewCompatibilityScore',
      desc: '',
      args: [],
    );
  }

  /// `Magical insight`
  String get onboardPreviewMagicTitle {
    return Intl.message(
      'Magical insight',
      name: 'onboardPreviewMagicTitle',
      desc: '',
      args: [],
    );
  }

  /// `You came into this world to care for yourself and others while keeping your boundaries. You carry Earth's strength and Water's sensitivity. The Moon guides your inner world — remember to listen to her whispers.`
  String get onboardPreviewMagicDescription {
    return Intl.message(
      'You came into this world to care for yourself and others while keeping your boundaries. You carry Earth\'s strength and Water\'s sensitivity. The Moon guides your inner world — remember to listen to her whispers.',
      name: 'onboardPreviewMagicDescription',
      desc: '',
      args: [],
    );
  }

  /// `You are learning to let go of expectations and trust the flow.`
  String get onboardPreviewPersonalState {
    return Intl.message(
      'You are learning to let go of expectations and trust the flow.',
      name: 'onboardPreviewPersonalState',
      desc: '',
      args: [],
    );
  }

  /// `{price} per week`
  String googleSubscriptionPerWeek(String price) {
    return Intl.message(
      '$price per week',
      name: 'googleSubscriptionPerWeek',
      desc: '',
      args: [price],
    );
  }

  /// `{price} per month`
  String googleSubscriptionPerMonth(String price) {
    return Intl.message(
      '$price per month',
      name: 'googleSubscriptionPerMonth',
      desc: '',
      args: [price],
    );
  }

  /// `{price} per year`
  String googleSubscriptionPerYear(String price) {
    return Intl.message(
      '$price per year',
      name: 'googleSubscriptionPerYear',
      desc: '',
      args: [price],
    );
  }

  /// `7 days free, then {price}. Renews automatically. Cancel anytime.`
  String googleSubscriptionTrialTerms(String price) {
    return Intl.message(
      '7 days free, then $price. Renews automatically. Cancel anytime.',
      name: 'googleSubscriptionTrialTerms',
      desc: '',
      args: [price],
    );
  }

  /// `{price}. Renews automatically. Cancel anytime.`
  String googleSubscriptionRecurringTerms(String price) {
    return Intl.message(
      '$price. Renews automatically. Cancel anytime.',
      name: 'googleSubscriptionRecurringTerms',
      desc: '',
      args: [price],
    );
  }

  /// `Apple has not confirmed the purchase yet. Check its status before trying again.`
  String get applePurchaseWaiting {
    return Intl.message(
      'Apple has not confirmed the purchase yet. Check its status before trying again.',
      name: 'applePurchaseWaiting',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for purchase approval. You can check the status here later.`
  String get applePurchaseApproval {
    return Intl.message(
      'Waiting for purchase approval. You can check the status here later.',
      name: 'applePurchaseApproval',
      desc: '',
      args: [],
    );
  }

  /// `This Apple purchase belongs to another Asteria account. Sign in to that account to use it.`
  String get applePurchaseAccount {
    return Intl.message(
      'This Apple purchase belongs to another Asteria account. Sign in to that account to use it.',
      name: 'applePurchaseAccount',
      desc: '',
      args: [],
    );
  }

  /// `Your subscription is already active. You can manage it in the App Store.`
  String get applePurchaseActive {
    return Intl.message(
      'Your subscription is already active. You can manage it in the App Store.',
      name: 'applePurchaseActive',
      desc: '',
      args: [],
    );
  }

  /// `Purchase status could not be checked. Reconnect and check again.`
  String get applePurchaseOffline {
    return Intl.message(
      'Purchase status could not be checked. Reconnect and check again.',
      name: 'applePurchaseOffline',
      desc: '',
      args: [],
    );
  }

  /// `This purchase could not be verified. Contact support.`
  String get applePurchaseInvalid {
    return Intl.message(
      'This purchase could not be verified. Contact support.',
      name: 'applePurchaseInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Check status`
  String get applePurchaseCheckStatus {
    return Intl.message(
      'Check status',
      name: 'applePurchaseCheckStatus',
      desc: '',
      args: [],
    );
  }

  /// `Affirmation  ·  1 min 15 sec`
  String get playerMetadata {
    return Intl.message(
      'Affirmation  ·  1 min 15 sec',
      name: 'playerMetadata',
      desc: '',
      args: [],
    );
  }

  /// `Close player`
  String get playerClose {
    return Intl.message(
      'Close player',
      name: 'playerClose',
      desc: '',
      args: [],
    );
  }

  /// `Repeat recording`
  String get playerRepeat {
    return Intl.message(
      'Repeat recording',
      name: 'playerRepeat',
      desc: '',
      args: [],
    );
  }

  /// `Repeat on`
  String get playerRepeatOn {
    return Intl.message(
      'Repeat on',
      name: 'playerRepeatOn',
      desc: '',
      args: [],
    );
  }

  /// `Repeat off`
  String get playerRepeatOff {
    return Intl.message(
      'Repeat off',
      name: 'playerRepeatOff',
      desc: '',
      args: [],
    );
  }

  /// `Share affirmation`
  String get playerShare {
    return Intl.message(
      'Share affirmation',
      name: 'playerShare',
      desc: '',
      args: [],
    );
  }

  /// `Play`
  String get playerPlay {
    return Intl.message('Play', name: 'playerPlay', desc: '', args: []);
  }

  /// `Play again`
  String get playerReplay {
    return Intl.message('Play again', name: 'playerReplay', desc: '', args: []);
  }

  /// `Pause`
  String get playerPause {
    return Intl.message('Pause', name: 'playerPause', desc: '', args: []);
  }

  /// `Favorite`
  String get playerFavorite {
    return Intl.message('Favorite', name: 'playerFavorite', desc: '', args: []);
  }

  /// `Added to favorites`
  String get playerAddedFavorite {
    return Intl.message(
      'Added to favorites',
      name: 'playerAddedFavorite',
      desc: '',
      args: [],
    );
  }

  /// `Removed from favorites`
  String get playerRemovedFavorite {
    return Intl.message(
      'Removed from favorites',
      name: 'playerRemovedFavorite',
      desc: '',
      args: [],
    );
  }

  /// `Playback position`
  String get playerPosition {
    return Intl.message(
      'Playback position',
      name: 'playerPosition',
      desc: '',
      args: [],
    );
  }

  /// `Show full transcript`
  String get playerShowTranscript {
    return Intl.message(
      'Show full transcript',
      name: 'playerShowTranscript',
      desc: '',
      args: [],
    );
  }

  /// `Collapse transcript`
  String get playerHideTranscript {
    return Intl.message(
      'Collapse transcript',
      name: 'playerHideTranscript',
      desc: '',
      args: [],
    );
  }

  /// `Unable to play this recording`
  String get playerPlayError {
    return Intl.message(
      'Unable to play this recording',
      name: 'playerPlayError',
      desc: '',
      args: [],
    );
  }

  /// `Could not open sharing options`
  String get playerShareError {
    return Intl.message(
      'Could not open sharing options',
      name: 'playerShareError',
      desc: '',
      args: [],
    );
  }

  /// `Unable to save favorites`
  String get playerFavoriteError {
    return Intl.message(
      'Unable to save favorites',
      name: 'playerFavoriteError',
      desc: '',
      args: [],
    );
  }

  /// `Repotting plants`
  String get scenarioCalendarRepotPlants {
    return Intl.message(
      'Repotting plants',
      name: 'scenarioCalendarRepotPlants',
      desc: '',
      args: [],
    );
  }

  /// `What are you planning?`
  String get scenarioCalendarChooseActivity {
    return Intl.message(
      'What are you planning?',
      name: 'scenarioCalendarChooseActivity',
      desc: '',
      args: [],
    );
  }

  /// `No activity recommendations are available for this month yet.`
  String get scenarioCalendarNoActivities {
    return Intl.message(
      'No activity recommendations are available for this month yet.',
      name: 'scenarioCalendarNoActivities',
      desc: '',
      args: [],
    );
  }

  /// `Deselect one date first.`
  String get scenarioCalendarRemoveDate {
    return Intl.message(
      'Deselect one date first.',
      name: 'scenarioCalendarRemoveDate',
      desc: '',
      args: [],
    );
  }

  /// `Which dates work for you?`
  String get scenarioCalendarChooseDates {
    return Intl.message(
      'Which dates work for you?',
      name: 'scenarioCalendarChooseDates',
      desc: '',
      args: [],
    );
  }

  /// `Could not load this month.`
  String get scenarioCalendarMonthError {
    return Intl.message(
      'Could not load this month.',
      name: 'scenarioCalendarMonthError',
      desc: '',
      args: [],
    );
  }

  /// `Compare dates`
  String get scenarioCalendarCompareAction {
    return Intl.message(
      'Compare dates',
      name: 'scenarioCalendarCompareAction',
      desc: '',
      args: [],
    );
  }

  /// `View this day`
  String get scenarioCalendarSingleDate {
    return Intl.message(
      'View this day',
      name: 'scenarioCalendarSingleDate',
      desc: '',
      args: [],
    );
  }

  /// `Compare dates`
  String get scenarioCalendarComparisonTitle {
    return Intl.message(
      'Compare dates',
      name: 'scenarioCalendarComparisonTitle',
      desc: '',
      args: [],
    );
  }

  /// `Both dates have the same rating for this activity.`
  String get scenarioCalendarEqualRating {
    return Intl.message(
      'Both dates have the same rating for this activity.',
      name: 'scenarioCalendarEqualRating',
      desc: '',
      args: [],
    );
  }

  /// `Choose this day`
  String get scenarioCalendarSelectDay {
    return Intl.message(
      'Choose this day',
      name: 'scenarioCalendarSelectDay',
      desc: '',
      args: [],
    );
  }

  /// `There is no recommendation for this activity on this date yet.`
  String get scenarioCalendarRecommendationMissing {
    return Intl.message(
      'There is no recommendation for this activity on this date yet.',
      name: 'scenarioCalendarRecommendationMissing',
      desc: '',
      args: [],
    );
  }

  /// `Change date`
  String get scenarioCalendarChangeDate {
    return Intl.message(
      'Change date',
      name: 'scenarioCalendarChangeDate',
      desc: '',
      args: [],
    );
  }

  /// `Save plan`
  String get scenarioCalendarSavePlan {
    return Intl.message(
      'Save plan',
      name: 'scenarioCalendarSavePlan',
      desc: '',
      args: [],
    );
  }

  /// `Activity name`
  String get scenarioCalendarActivityName {
    return Intl.message(
      'Activity name',
      name: 'scenarioCalendarActivityName',
      desc: '',
      args: [],
    );
  }

  /// `Could not save the plan. Try again.`
  String get scenarioCalendarSaveError {
    return Intl.message(
      'Could not save the plan. Try again.',
      name: 'scenarioCalendarSaveError',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get scenarioSave {
    return Intl.message('Save', name: 'scenarioSave', desc: '', args: []);
  }

  /// `Plan saved`
  String get scenarioCalendarSaved {
    return Intl.message(
      'Plan saved',
      name: 'scenarioCalendarSaved',
      desc: '',
      args: [],
    );
  }

  /// `Go home`
  String get scenarioGoHome {
    return Intl.message('Go home', name: 'scenarioGoHome', desc: '', args: []);
  }

  /// `Back to calendar`
  String get scenarioCalendarBackToCalendar {
    return Intl.message(
      'Back to calendar',
      name: 'scenarioCalendarBackToCalendar',
      desc: '',
      args: [],
    );
  }

  /// `My plans`
  String get scenarioCalendarMyPlans {
    return Intl.message(
      'My plans',
      name: 'scenarioCalendarMyPlans',
      desc: '',
      args: [],
    );
  }

  /// `Activities you schedule will appear here.`
  String get scenarioCalendarEmptyPlans {
    return Intl.message(
      'Activities you schedule will appear here.',
      name: 'scenarioCalendarEmptyPlans',
      desc: '',
      args: [],
    );
  }

  /// `Choose a date`
  String get scenarioCalendarChooseDate {
    return Intl.message(
      'Choose a date',
      name: 'scenarioCalendarChooseDate',
      desc: '',
      args: [],
    );
  }

  /// `Find a day for an activity`
  String get scenarioCalendarFindDate {
    return Intl.message(
      'Find a day for an activity',
      name: 'scenarioCalendarFindDate',
      desc: '',
      args: [],
    );
  }

  /// `Could not open your plans.`
  String get scenarioCalendarPlansError {
    return Intl.message(
      'Could not open your plans.',
      name: 'scenarioCalendarPlansError',
      desc: '',
      args: [],
    );
  }

  /// `We show affection differently`
  String get scenarioRelationshipCare {
    return Intl.message(
      'We show affection differently',
      name: 'scenarioRelationshipCare',
      desc: '',
      args: [],
    );
  }

  /// `It is hard to talk after an argument`
  String get scenarioRelationshipDisagreement {
    return Intl.message(
      'It is hard to talk after an argument',
      name: 'scenarioRelationshipDisagreement',
      desc: '',
      args: [],
    );
  }

  /// `I want to understand my feelings`
  String get scenarioRelationshipOwnFeelings {
    return Intl.message(
      'I want to understand my feelings',
      name: 'scenarioRelationshipOwnFeelings',
      desc: '',
      args: [],
    );
  }

  /// `Choose a saved pair or enter your partner’s details. Explore how you show care and find a question to discuss.`
  String get scenarioRelationshipCareOffer {
    return Intl.message(
      'Choose a saved pair or enter your partner’s details. Explore how you show care and find a question to discuss.',
      name: 'scenarioRelationshipCareOffer',
      desc: '',
      args: [],
    );
  }

  /// `Choose a saved pair or enter your partner’s details. Explore disagreements and find a way to start talking.`
  String get scenarioRelationshipDisagreementOffer {
    return Intl.message(
      'Choose a saved pair or enter your partner’s details. Explore disagreements and find a way to start talking.',
      name: 'scenarioRelationshipDisagreementOffer',
      desc: '',
      args: [],
    );
  }

  /// `Explore your feelings from several angles with a love spread. You can do this on your own.`
  String get scenarioRelationshipSpreadOffer {
    return Intl.message(
      'Explore your feelings from several angles with a love spread. You can do this on your own.',
      name: 'scenarioRelationshipSpreadOffer',
      desc: '',
      args: [],
    );
  }

  /// `What little thing tells you that I care about you?`
  String get scenarioRelationshipCareQuestion {
    return Intl.message(
      'What little thing tells you that I care about you?',
      name: 'scenarioRelationshipCareQuestion',
      desc: '',
      args: [],
    );
  }

  /// `I would like to come back to our conversation. Would now or a little later work better for you?`
  String get scenarioRelationshipDisagreementQuestion {
    return Intl.message(
      'I would like to come back to our conversation. Would now or a little later work better for you?',
      name: 'scenarioRelationshipDisagreementQuestion',
      desc: '',
      args: [],
    );
  }

  /// `What am I hoping the other person will do? Have we talked about it?`
  String get scenarioRelationshipReflectionQuestion {
    return Intl.message(
      'What am I hoping the other person will do? Have we talked about it?',
      name: 'scenarioRelationshipReflectionQuestion',
      desc: '',
      args: [],
    );
  }

  /// `What is on your mind?`
  String get scenarioRelationshipChooseSituation {
    return Intl.message(
      'What is on your mind?',
      name: 'scenarioRelationshipChooseSituation',
      desc: '',
      args: [],
    );
  }

  /// `Open pair reading`
  String get scenarioRelationshipOpenPair {
    return Intl.message(
      'Open pair reading',
      name: 'scenarioRelationshipOpenPair',
      desc: '',
      args: [],
    );
  }

  /// `Open love spread`
  String get scenarioRelationshipOpenSpread {
    return Intl.message(
      'Open love spread',
      name: 'scenarioRelationshipOpenSpread',
      desc: '',
      args: [],
    );
  }

  /// `For your conversation`
  String get scenarioRelationshipConversationLabel {
    return Intl.message(
      'For your conversation',
      name: 'scenarioRelationshipConversationLabel',
      desc: '',
      args: [],
    );
  }

  /// `Share question`
  String get scenarioRelationshipShareQuestion {
    return Intl.message(
      'Share question',
      name: 'scenarioRelationshipShareQuestion',
      desc: '',
      args: [],
    );
  }

  /// `See full reading`
  String get scenarioRelationshipFullReading {
    return Intl.message(
      'See full reading',
      name: 'scenarioRelationshipFullReading',
      desc: '',
      args: [],
    );
  }

  /// `A question to reflect on`
  String get scenarioRelationshipReflectionLabel {
    return Intl.message(
      'A question to reflect on',
      name: 'scenarioRelationshipReflectionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Where could you use some guidance?`
  String get scenarioStrengthChooseArea {
    return Intl.message(
      'Where could you use some guidance?',
      name: 'scenarioStrengthChooseArea',
      desc: '',
      args: [],
    );
  }

  /// `My saved tips`
  String get scenarioStrengthSavedTips {
    return Intl.message(
      'My saved tips',
      name: 'scenarioStrengthSavedTips',
      desc: '',
      args: [],
    );
  }

  /// `What lies ahead?`
  String get scenarioStrengthChooseSituation {
    return Intl.message(
      'What lies ahead?',
      name: 'scenarioStrengthChooseSituation',
      desc: '',
      args: [],
    );
  }

  /// `Could not save this tip. Please try again.`
  String get scenarioStrengthSaveError {
    return Intl.message(
      'Could not save this tip. Please try again.',
      name: 'scenarioStrengthSaveError',
      desc: '',
      args: [],
    );
  }

  /// `Try this`
  String get scenarioStrengthTry {
    return Intl.message(
      'Try this',
      name: 'scenarioStrengthTry',
      desc: '',
      args: [],
    );
  }

  /// `Try this today`
  String get scenarioStrengthTryToday {
    return Intl.message(
      'Try this today',
      name: 'scenarioStrengthTryToday',
      desc: '',
      args: [],
    );
  }

  /// `A personal tip uses your birth chart reading.`
  String get scenarioStrengthNeedsReading {
    return Intl.message(
      'A personal tip uses your birth chart reading.',
      name: 'scenarioStrengthNeedsReading',
      desc: '',
      args: [],
    );
  }

  /// `Your reading has no specific guidance for this situation yet.`
  String get scenarioStrengthNoPersonalMatch {
    return Intl.message(
      'Your reading has no specific guidance for this situation yet.',
      name: 'scenarioStrengthNoPersonalMatch',
      desc: '',
      args: [],
    );
  }

  /// `Open birth chart reading`
  String get scenarioStrengthOpenChart {
    return Intl.message(
      'Open birth chart reading',
      name: 'scenarioStrengthOpenChart',
      desc: '',
      args: [],
    );
  }

  /// `Why this tip?`
  String get scenarioStrengthExplanation {
    return Intl.message(
      'Why this tip?',
      name: 'scenarioStrengthExplanation',
      desc: '',
      args: [],
    );
  }

  /// `From your birth chart`
  String get scenarioStrengthChartSource {
    return Intl.message(
      'From your birth chart',
      name: 'scenarioStrengthChartSource',
      desc: '',
      args: [],
    );
  }

  /// `From this day’s forecast`
  String get scenarioStrengthForecastSource {
    return Intl.message(
      'From this day’s forecast',
      name: 'scenarioStrengthForecastSource',
      desc: '',
      args: [],
    );
  }

  /// `Open full reading`
  String get scenarioStrengthFullReading {
    return Intl.message(
      'Open full reading',
      name: 'scenarioStrengthFullReading',
      desc: '',
      args: [],
    );
  }

  /// `Tip saved`
  String get scenarioStrengthSaved {
    return Intl.message(
      'Tip saved',
      name: 'scenarioStrengthSaved',
      desc: '',
      args: [],
    );
  }

  /// `View saved tips`
  String get scenarioStrengthViewSaved {
    return Intl.message(
      'View saved tips',
      name: 'scenarioStrengthViewSaved',
      desc: '',
      args: [],
    );
  }

  /// `Save tip`
  String get scenarioStrengthSave {
    return Intl.message(
      'Save tip',
      name: 'scenarioStrengthSave',
      desc: '',
      args: [],
    );
  }

  /// `Where shall we start?`
  String get scenarioStartTitle {
    return Intl.message(
      'Where shall we start?',
      name: 'scenarioStartTitle',
      desc: '',
      args: [],
    );
  }

  /// `Find a day for a plan`
  String get scenarioCalendarTitle {
    return Intl.message(
      'Find a day for a plan',
      name: 'scenarioCalendarTitle',
      desc: '',
      args: [],
    );
  }

  /// `Compare two dates in the lunar calendar and save your plan.`
  String get scenarioCalendarSubtitle {
    return Intl.message(
      'Compare two dates in the lunar calendar and save your plan.',
      name: 'scenarioCalendarSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Take a minute for yourself`
  String get scenarioPracticeTitle {
    return Intl.message(
      'Take a minute for yourself',
      name: 'scenarioPracticeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Slow down with a short audio practice, “I Have Time”.`
  String get scenarioPracticeSubtitle {
    return Intl.message(
      'Slow down with a short audio practice, “I Have Time”.',
      name: 'scenarioPracticeSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Understand our relationship`
  String get scenarioRelationshipsTitle {
    return Intl.message(
      'Understand our relationship',
      name: 'scenarioRelationshipsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose what is on your mind. Asteria will suggest a place to start.`
  String get scenarioRelationshipsSubtitle {
    return Intl.message(
      'Choose what is on your mind. Asteria will suggest a place to start.',
      name: 'scenarioRelationshipsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Find a personal strength`
  String get scenarioStrengthTitle {
    return Intl.message(
      'Find a personal strength',
      name: 'scenarioStrengthTitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose a situation and find a strength you can draw on today.`
  String get scenarioStrengthSubtitle {
    return Intl.message(
      'Choose a situation and find a strength you can draw on today.',
      name: 'scenarioStrengthSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Slow down`
  String get scenarioPracticeSlowDown {
    return Intl.message(
      'Slow down',
      name: 'scenarioPracticeSlowDown',
      desc: '',
      args: [],
    );
  }

  /// `Find focus`
  String get scenarioPracticeFocus {
    return Intl.message(
      'Find focus',
      name: 'scenarioPracticeFocus',
      desc: '',
      args: [],
    );
  }

  /// `Unwind after a long day`
  String get scenarioPracticeUnwind {
    return Intl.message(
      'Unwind after a long day',
      name: 'scenarioPracticeUnwind',
      desc: '',
      args: [],
    );
  }

  /// `What do you need right now?`
  String get scenarioPracticeChooseMood {
    return Intl.message(
      'What do you need right now?',
      name: 'scenarioPracticeChooseMood',
      desc: '',
      args: [],
    );
  }

  /// `No audio practices are available right now.`
  String get scenarioPracticeUnavailable {
    return Intl.message(
      'No audio practices are available right now.',
      name: 'scenarioPracticeUnavailable',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'en', countryCode: 'AU'),
      Locale.fromSubtags(languageCode: 'en', countryCode: 'CA'),
      Locale.fromSubtags(languageCode: 'en', countryCode: 'GB'),
      Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}

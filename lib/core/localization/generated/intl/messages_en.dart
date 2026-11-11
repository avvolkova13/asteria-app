// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(title) => "${title}. Locked";

  static String m1(count, total) => "${count} of ${total} remaining";

  static String m2(category) => "${category}. Subscription only";

  static String m3(text) => "Affirmation: ${text}";

  static String m4(free, total, paid) =>
      "${free}/${total} free + ${paid} purchased";

  static String m5(count) =>
      "${Intl.plural(count, one: '${count} attempt left', other: '${count} attempts left')}";

  static String m6(balance) => "Balance: ${balance} Star Coins";

  static String m7(price) => "Buy for ${price}";

  static String m8(price) => "Buy a birth chart for ${price} Star Coins";

  static String m9(title, price) => "Buy ${title} for ${price} Star Coins";

  static String m10(price) =>
      "Buy a personal yearly horoscope for ${price} Star Coins";

  static String m11(coins) => "${coins} Star Coin package";

  static String m12(rune) => "Rune of the day: ${rune}";

  static String m13(card) => "Tarot card of the day: ${card}";

  static String m14(number) => "Card ${number}";

  static String m15(number, title) => "Card ${number}: ${title}";

  static String m16(details) => "Error: ${details}";

  static String m17(count) =>
      "Your free requests reset in ${Intl.plural(count, one: '${count} day', other: '${count} days')}.";

  static String m18(count) =>
      "Free requests will reset in ${Intl.plural(count, one: '${count} day', other: '${count} days')}.";

  static String m19(price) => "${price} per month";

  static String m20(price) => "${price} per week";

  static String m21(price) => "${price} per year";

  static String m22(price) => "${price}. Renews automatically. Cancel anytime.";

  static String m23(price) =>
      "7 days free, then ${price}. Renews automatically. Cancel anytime.";

  static String m24(number, position) => "Card ${number} — ${position}";

  static String m25(count) =>
      "Your limit resets in ${Intl.plural(count, one: '${count} day', other: '${count} days')}.";

  static String m26(title) => "Day tone: ${title}";

  static String m27(number) => "Lunar day ${number}";

  static String m28(phase, date) => "The next phase is ${phase} on ${date}.";

  static String m29(time) => "Occurs at ${time} in your local time";

  static String m30(sphere, status) => "${sphere}: ${status}";

  static String m31(number) => "Emphasis on house ${number}";

  static String m32(price) => "Your birth chart\nfor ${price} Star Coins";

  static String m33(number) => "Strong house ${number}";

  static String m34(number) => "Weak house ${number}";

  static String m35(title) => "Open article: ${title}";

  static String m36(count) =>
      "${Intl.plural(count, zero: 'No purchased requests', one: '${count} purchased request', other: '${count} purchased requests')}";

  static String m37(coins, balance) =>
      "${coins} coins credited. Balance: ${balance}";

  static String m38(coins) =>
      "${coins} coins credited. Your balance was updated.";

  static String m39(countryCode, provider) =>
      "Payment diagnostics\nStore region: ${countryCode}\nSelected provider: ${provider}";

  static String m40(price) => "Unlock forecast\nfor ${price} Star Coins";

  static String m41(name) => "Hello, ${name}!";

  static String m42(price) => "Weak points for ${price}";

  static String m43(title, price) => "Buy ${title} for ${price} Star Coins";

  static String m44(title, price) => "Buy ${title} for ${price}";

  static String m45(count) =>
      "Buy ${Intl.plural(count, one: '${count} request', other: '${count} requests')}";

  static String m46(price) => "1 question = ${price}";

  static String m47(count) =>
      "The limit will reset in ${Intl.plural(count, one: '${count} day', other: '${count} days')}.";

  static String m48(count) =>
      "${Intl.plural(count, one: '${count} request', other: '${count} requests')}";

  static String m49(count, price) =>
      "${Intl.plural(count, one: '${count} request for ${price} Star Coins', other: '${count} requests for ${price} Star Coins')}";

  static String m50(count) =>
      "${Intl.plural(count, zero: 'No requests left', one: '${count} request left', other: '${count} requests left')}";

  static String m51(count, total) => "${count}/${total} requests left";

  static String m52(count) =>
      "${Intl.plural(count, zero: 'No free requests left this week', one: '${count} free request left this week', other: '${count} free requests left this week')}";

  static String m53(count, total) => "${count} of ${total} requests left";

  static String m54(link) =>
      "Explore Tarot and the lunar calendar with Asteria: ${link}";

  static String m55(title) => "${title} is locked";

  static String m56(title) => "Open the meaning of the future rune ${title}";

  static String m57(title) => "Open ${title}";

  static String m58(title) => "Open the meaning of the past rune ${title}";

  static String m59(title) => "Open the meaning of the present rune ${title}";

  static String m60(count) => "${count} pcs";

  static String m61(price) => "price per item = ${price}";

  static String m62(date) => "Your next payment\nwill be charged on\n${date}";

  static String m63(count) => "Purchases restored: ${count}";

  static String m64(title) => "${title} is locked";

  static String m65(title) => "Open ${title}";

  static String m66(position) => "Open card ${position} of 3";

  static String m67(position, card) => "Card ${position} of 3: ${card}";

  static String m68(price) =>
      "Your personal yearly horoscope\nfor ${price} Star Coins";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aboutTitle": MessageLookupByLibrary.simpleMessage("About Asteria"),
    "achievementHoroscope": MessageLookupByLibrary.simpleMessage(
      "Open your horoscope",
    ),
    "achievementLocked": m0,
    "achievementRemaining": m1,
    "achievementRunes": MessageLookupByLibrary.simpleMessage("Open the runes"),
    "achievementTarot": MessageLookupByLibrary.simpleMessage(
      "Get a Tarot reading",
    ),
    "achievementsTitle": MessageLookupByLibrary.simpleMessage(
      "My achievements",
    ),
    "adDecode": MessageLookupByLibrary.simpleMessage("Interpret"),
    "adDreamDescription": MessageLookupByLibrary.simpleMessage(
      "Tell her your dream — she will reveal its meaning.",
    ),
    "adDreamTitle": MessageLookupByLibrary.simpleMessage("Had a dream?"),
    "adLiviaName": MessageLookupByLibrary.simpleMessage("Livia"),
    "adLiviaSubtitle": MessageLookupByLibrary.simpleMessage(
      "guardian of dreams.",
    ),
    "affirmationCategoryAbundance": MessageLookupByLibrary.simpleMessage(
      "Abundance",
    ),
    "affirmationCategoryCalm": MessageLookupByLibrary.simpleMessage("Calm"),
    "affirmationCategoryCreativity": MessageLookupByLibrary.simpleMessage(
      "Creativity",
    ),
    "affirmationCategoryLocked": m2,
    "affirmationCategoryLove": MessageLookupByLibrary.simpleMessage("Love"),
    "affirmationCategoryLunar": MessageLookupByLibrary.simpleMessage("Lunar"),
    "affirmationCategoryStrength": MessageLookupByLibrary.simpleMessage(
      "Strength",
    ),
    "affirmationLoadError": MessageLookupByLibrary.simpleMessage(
      "Unable to load the affirmation. Check your connection.",
    ),
    "affirmationLoading": MessageLookupByLibrary.simpleMessage(
      "Loading affirmation…",
    ),
    "affirmationLoadingLabel": MessageLookupByLibrary.simpleMessage(
      "Loading affirmation of the day",
    ),
    "affirmationOfDay": MessageLookupByLibrary.simpleMessage(
      "Affirmation of the day",
    ),
    "affirmationOpenPlayer": MessageLookupByLibrary.simpleMessage(
      "Open the audio player",
    ),
    "affirmationRetryLabel": MessageLookupByLibrary.simpleMessage(
      "Reload affirmation",
    ),
    "affirmationSemantics": m3,
    "affirmationSubscriptionRequired": MessageLookupByLibrary.simpleMessage(
      "This affirmation is included with a subscription. Get access to every affirmation, including locked categories, and other exclusive features.",
    ),
    "affirmationSwipeHint": MessageLookupByLibrary.simpleMessage(
      "Swipe left or right to change the affirmation",
    ),
    "affirmationUnavailableLabel": MessageLookupByLibrary.simpleMessage(
      "Affirmation of the day unavailable",
    ),
    "affirmationsTitle": MessageLookupByLibrary.simpleMessage("Affirmations"),
    "agreementSummary": MessageLookupByLibrary.simpleMessage(
      "Terms governing access to Asteria, digital content, subscriptions, and store purchases.",
    ),
    "agreementText": MessageLookupByLibrary.simpleMessage("Terms of Use"),
    "allAffirmations": MessageLookupByLibrary.simpleMessage("All affirmations"),
    "anakraFreeAndPurchased": m4,
    "anakraGreetingMessage": MessageLookupByLibrary.simpleMessage(
      "Welcome. I\'m Anakra, guardian of the stars and your celestial path. Ask me a question or choose where to begin.",
    ),
    "anakraGreetingTitle": MessageLookupByLibrary.simpleMessage(
      "Welcome.\nI\'m Anakra—\nguardian of\nthe stars and\nyour path.",
    ),
    "anakraInputHint": MessageLookupByLibrary.simpleMessage(
      "Ask your question",
    ),
    "anakraName": MessageLookupByLibrary.simpleMessage("Anakra"),
    "anakraQuickCompatibility": MessageLookupByLibrary.simpleMessage(
      "Check compatibility",
    ),
    "anakraQuickDrawCard": MessageLookupByLibrary.simpleMessage("Draw a card"),
    "anakraQuickNatalChart": MessageLookupByLibrary.simpleMessage(
      "Show my birth chart",
    ),
    "anakraQuickPowerDay": MessageLookupByLibrary.simpleMessage(
      "When is my next power day?",
    ),
    "anakraReady": MessageLookupByLibrary.simpleMessage(
      "The stars are ready to answer.",
    ),
    "anakraRequestsLeftLabel": MessageLookupByLibrary.simpleMessage(
      "Anakra requests left",
    ),
    "anakraSendMessageLabel": MessageLookupByLibrary.simpleMessage(
      "Send message",
    ),
    "anakraServerError": MessageLookupByLibrary.simpleMessage(
      "The server couldn\'t answer. Try again.",
    ),
    "anakraTitle": MessageLookupByLibrary.simpleMessage("Anakra AI Astrologer"),
    "anakraTyping": MessageLookupByLibrary.simpleMessage("Anakra is typing…"),
    "anakraWelcomeMessage": MessageLookupByLibrary.simpleMessage(
      "Welcome. I am Anakra, keeper of the star signs and your celestial path. Ask your question or choose where to begin.",
    ),
    "applePurchaseAccount": MessageLookupByLibrary.simpleMessage(
      "This Apple purchase belongs to another Asteria account. Sign in to that account to use it.",
    ),
    "applePurchaseActive": MessageLookupByLibrary.simpleMessage(
      "Your subscription is already active. You can manage it in the App Store.",
    ),
    "applePurchaseApproval": MessageLookupByLibrary.simpleMessage(
      "Waiting for purchase approval. You can check the status here later.",
    ),
    "applePurchaseCheckStatus": MessageLookupByLibrary.simpleMessage(
      "Check status",
    ),
    "applePurchaseInvalid": MessageLookupByLibrary.simpleMessage(
      "This purchase could not be verified. Contact support.",
    ),
    "applePurchaseOffline": MessageLookupByLibrary.simpleMessage(
      "Purchase status could not be checked. Reconnect and check again.",
    ),
    "applePurchaseWaiting": MessageLookupByLibrary.simpleMessage(
      "Apple has not confirmed the purchase yet. Check its status before trying again.",
    ),
    "arcPaySubscriptionUnavailable": MessageLookupByLibrary.simpleMessage(
      "Arc Pay subscriptions are not available yet",
    ),
    "arcPaySubscriptionUnavailableDescription":
        MessageLookupByLibrary.simpleMessage(
          "Star Coins can be purchased through the Faster Payments System. Subscriptions will become available after saved-card testing is complete.",
        ),
    "arcSubscriptionCancelError": MessageLookupByLibrary.simpleMessage(
      "We couldn\'t cancel the subscription. Try again later.",
    ),
    "arcSubscriptionCreateError": MessageLookupByLibrary.simpleMessage(
      "We couldn\'t create the subscription. Try again later.",
    ),
    "arcSubscriptionNotFound": MessageLookupByLibrary.simpleMessage(
      "No Arc Pay subscription was found.",
    ),
    "arcSubscriptionProductsError": MessageLookupByLibrary.simpleMessage(
      "We couldn\'t load the available Arc Pay plans.",
    ),
    "arcSubscriptionRetryError": MessageLookupByLibrary.simpleMessage(
      "We couldn\'t retry the payment. Try again later.",
    ),
    "articleNotFound": MessageLookupByLibrary.simpleMessage(
      "Article not found",
    ),
    "articlesReadMore": MessageLookupByLibrary.simpleMessage("Read more"),
    "articlesScrollLabel": MessageLookupByLibrary.simpleMessage(
      "Scroll articles",
    ),
    "articlesTitle": MessageLookupByLibrary.simpleMessage("Articles"),
    "asteriaWebsite": MessageLookupByLibrary.simpleMessage("Asteria website"),
    "astrologyLoadingChart": MessageLookupByLibrary.simpleMessage(
      "Creating your destiny chart…",
    ),
    "astrologyLoadingPersonal": MessageLookupByLibrary.simpleMessage(
      "Preparing your personal horoscope…",
    ),
    "astrologyLoadingStars": MessageLookupByLibrary.simpleMessage(
      "Reading messages from the stars…",
    ),
    "astrologyLoadingSymbols": MessageLookupByLibrary.simpleMessage(
      "Interpreting astrological symbols…",
    ),
    "attemptsLeftCount": m5,
    "authBirthDetailsPrompt": MessageLookupByLibrary.simpleMessage(
      "Enter your birth date, time, and place—and let the Universe speak to you.",
    ),
    "authCosmicEssence": MessageLookupByLibrary.simpleMessage(
      "Discover your cosmic essence",
    ),
    "authMoonRhythms": MessageLookupByLibrary.simpleMessage(
      "Tune in to the Moon\'s rhythms and open your birth chart—it can guide your path.",
    ),
    "authSaveUserError": MessageLookupByLibrary.simpleMessage(
      "We couldn\'t save your profile. Check your connection and try again.",
    ),
    "authUserNotInitialized": MessageLookupByLibrary.simpleMessage(
      "Your profile isn\'t ready yet. Return to the previous step and try again.",
    ),
    "avatarAstrologer": MessageLookupByLibrary.simpleMessage("Astrologer"),
    "avatarAstrologerWoman": MessageLookupByLibrary.simpleMessage(
      "Astrologer, woman",
    ),
    "avatarChange": MessageLookupByLibrary.simpleMessage("Change avatar"),
    "avatarChooseTitle": MessageLookupByLibrary.simpleMessage(
      "Choose your avatar",
    ),
    "avatarDragon": MessageLookupByLibrary.simpleMessage("Dragon"),
    "avatarElfMan": MessageLookupByLibrary.simpleMessage("Elf man"),
    "avatarElfWoman": MessageLookupByLibrary.simpleMessage("Elf woman"),
    "avatarPhoenix": MessageLookupByLibrary.simpleMessage("Phoenix"),
    "avatarSave": MessageLookupByLibrary.simpleMessage("Choose avatar"),
    "avatarSaveError": MessageLookupByLibrary.simpleMessage(
      "Could not save your avatar. Please try again.",
    ),
    "avatarScreenTitle": MessageLookupByLibrary.simpleMessage("Avatar"),
    "avatarSorcerer": MessageLookupByLibrary.simpleMessage("Sorcerer"),
    "avatarSorceress": MessageLookupByLibrary.simpleMessage("Sorceress"),
    "avatarUnicorn": MessageLookupByLibrary.simpleMessage("Unicorn"),
    "balanceAllOperations": MessageLookupByLibrary.simpleMessage(
      "All activity",
    ),
    "balanceBuy": MessageLookupByLibrary.simpleMessage("Buy Star Coins"),
    "balanceChooseSubscription": MessageLookupByLibrary.simpleMessage(
      "Choose a subscription",
    ),
    "balanceCurrencyDescription": MessageLookupByLibrary.simpleMessage(
      " is the in-app currency for card readings, dream interpretations, and questions for Anakra.",
    ),
    "balanceDeposits": MessageLookupByLibrary.simpleMessage("Credits"),
    "balanceHistoryEmpty": MessageLookupByLibrary.simpleMessage(
      "Nothing here yet. Earn or spend star credits to see your history!",
    ),
    "balanceHistoryLoadError": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t load history",
    ),
    "balanceHistoryNoDeposits": MessageLookupByLibrary.simpleMessage(
      "No credits yet",
    ),
    "balanceHistoryNoWithdrawals": MessageLookupByLibrary.simpleMessage(
      "No charges yet",
    ),
    "balanceHistoryRefreshError": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t refresh history",
    ),
    "balanceHistoryTitle": MessageLookupByLibrary.simpleMessage(
      "Balance history",
    ),
    "balanceLabel": MessageLookupByLibrary.simpleMessage("Balance"),
    "balanceLegacyOperation": MessageLookupByLibrary.simpleMessage(
      "Balance transaction",
    ),
    "balanceRewardRetry": MessageLookupByLibrary.simpleMessage("Try again"),
    "balanceServiceAnakra": MessageLookupByLibrary.simpleMessage(
      "AI Astrologer chat — 1 question",
    ),
    "balanceServiceCompatibility": MessageLookupByLibrary.simpleMessage(
      "Additional compatibility report",
    ),
    "balanceServiceDream": MessageLookupByLibrary.simpleMessage(
      "Dream interpretation",
    ),
    "balanceServiceNatal": MessageLookupByLibrary.simpleMessage("Birth chart"),
    "balanceServiceTarot": MessageLookupByLibrary.simpleMessage(
      "Tarot reading: Love / Celtic Cross",
    ),
    "balanceServiceYearForecast": MessageLookupByLibrary.simpleMessage(
      "Personal yearly forecast",
    ),
    "balanceStarsLabel": m6,
    "balanceSubscriptionDescription": MessageLookupByLibrary.simpleMessage(
      "Subscribe for unlimited access to everything.",
    ),
    "balanceSubscriptionPrompt": MessageLookupByLibrary.simpleMessage(
      "Prefer unlimited access?",
    ),
    "balanceTitle": MessageLookupByLibrary.simpleMessage("Star Coins"),
    "balanceWhereToSpend": MessageLookupByLibrary.simpleMessage(
      "Where can I spend it?",
    ),
    "balanceWithdrawals": MessageLookupByLibrary.simpleMessage("Charges"),
    "birthDateLabel": MessageLookupByLibrary.simpleMessage("Date of birth"),
    "birthDatePickerTitle": MessageLookupByLibrary.simpleMessage(
      "Select your date of birth",
    ),
    "birthPlaceLabel": MessageLookupByLibrary.simpleMessage("Place of birth"),
    "birthTimeLabel": MessageLookupByLibrary.simpleMessage("Time of birth"),
    "birthTimePickerTitle": MessageLookupByLibrary.simpleMessage(
      "Select your time of birth",
    ),
    "buyAttempts": MessageLookupByLibrary.simpleMessage("Buy attempts"),
    "buyAttemptsLabel": MessageLookupByLibrary.simpleMessage("Buy attempts"),
    "buyAttemptsTitle": MessageLookupByLibrary.simpleMessage("Buy requests"),
    "buyForPrice": m7,
    "buyNatalCardLabel": m8,
    "buySpecialReadingLabel": m9,
    "buyYearHoroscopeLabel": m10,
    "calendarNextMonth": MessageLookupByLibrary.simpleMessage("Next month"),
    "calendarPreviousMonth": MessageLookupByLibrary.simpleMessage(
      "Previous month",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cardNumberLabel": MessageLookupByLibrary.simpleMessage("Card"),
    "celticCrossDescription": MessageLookupByLibrary.simpleMessage(
      "A deep, precise ten-card reading that reveals the heart of a situation and its hidden influences to help you make an important decision.",
    ),
    "choosePackageTitle": MessageLookupByLibrary.simpleMessage(
      "Choose a package",
    ),
    "cityConfirmationQuestion": MessageLookupByLibrary.simpleMessage(
      "is this your city?",
    ),
    "citySaveError": MessageLookupByLibrary.simpleMessage(
      "Could not save the city. Please try again.",
    ),
    "citySearchEmpty": MessageLookupByLibrary.simpleMessage("No cities found"),
    "citySearchError": MessageLookupByLibrary.simpleMessage(
      "We couldn\'t load cities. Check the city name or try again.",
    ),
    "citySelectionChange": MessageLookupByLibrary.simpleMessage("Change"),
    "citySelectionConfirm": MessageLookupByLibrary.simpleMessage("Correct"),
    "citySelectionTitle": MessageLookupByLibrary.simpleMessage("Choose a city"),
    "clearMessage": MessageLookupByLibrary.simpleMessage("Clear message"),
    "coinPackageDescription10": MessageLookupByLibrary.simpleMessage(
      "Enough for one request",
    ),
    "coinPackageDescription120": MessageLookupByLibrary.simpleMessage(
      "A lasting supply",
    ),
    "coinPackageDescription30": MessageLookupByLibrary.simpleMessage(
      "For your first card readings",
    ),
    "coinPackageDescription300": MessageLookupByLibrary.simpleMessage(
      "For every wish",
    ),
    "coinPackageDescription60": MessageLookupByLibrary.simpleMessage(
      "Most popular",
    ),
    "coinPackageFallback": m11,
    "coinPackageFirstMoon": MessageLookupByLibrary.simpleMessage("First Moon"),
    "coinPackageRetrogradePath": MessageLookupByLibrary.simpleMessage(
      "Retrograde Path",
    ),
    "coinPackageStarPath": MessageLookupByLibrary.simpleMessage("Star Path"),
    "coinPackageSunlight": MessageLookupByLibrary.simpleMessage("Sunlight"),
    "coinPackageUniverseSecret": MessageLookupByLibrary.simpleMessage(
      "Secret of the Universe",
    ),
    "coinPackagesLoad": MessageLookupByLibrary.simpleMessage("Load packages"),
    "coinPackagesUnavailable": MessageLookupByLibrary.simpleMessage(
      "Packages are currently unavailable",
    ),
    "coinPackagesUnavailableRetry": MessageLookupByLibrary.simpleMessage(
      "Packages are currently unavailable. Try again later.",
    ),
    "coinPurchasePending": MessageLookupByLibrary.simpleMessage(
      "Payment received. Your Star Coins will appear within a few minutes.",
    ),
    "commonBack": MessageLookupByLibrary.simpleMessage("Back"),
    "commonBirthDate": MessageLookupByLibrary.simpleMessage("Date of birth"),
    "commonBirthPlace": MessageLookupByLibrary.simpleMessage("Place of birth"),
    "commonBirthTime": MessageLookupByLibrary.simpleMessage("Time of birth"),
    "commonBuy": MessageLookupByLibrary.simpleMessage("Buy"),
    "commonCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "commonClear": MessageLookupByLibrary.simpleMessage("Clear"),
    "commonClose": MessageLookupByLibrary.simpleMessage("Close"),
    "commonContinue": MessageLookupByLibrary.simpleMessage("Continue"),
    "commonDescription": MessageLookupByLibrary.simpleMessage("Description:"),
    "commonError": MessageLookupByLibrary.simpleMessage("Error"),
    "commonHowItAffects": MessageLookupByLibrary.simpleMessage(
      "How it affects you:",
    ),
    "commonInReadings": MessageLookupByLibrary.simpleMessage("In readings:"),
    "commonKeywords": MessageLookupByLibrary.simpleMessage("Keywords:"),
    "commonMeaning": MessageLookupByLibrary.simpleMessage("Meaning:"),
    "commonMore": MessageLookupByLibrary.simpleMessage("More"),
    "commonName": MessageLookupByLibrary.simpleMessage("Name"),
    "commonNo": MessageLookupByLibrary.simpleMessage("No"),
    "commonOf": MessageLookupByLibrary.simpleMessage("of"),
    "commonOk": MessageLookupByLibrary.simpleMessage("OK"),
    "commonRetry": MessageLookupByLibrary.simpleMessage("Try again"),
    "commonSelect": MessageLookupByLibrary.simpleMessage("Select"),
    "commonUnavailable": MessageLookupByLibrary.simpleMessage(
      "Not available yet",
    ),
    "commonYes": MessageLookupByLibrary.simpleMessage("Yes"),
    "compatibilityAboutPair": MessageLookupByLibrary.simpleMessage(
      "Astrology for the two of you",
    ),
    "compatibilityAboutPairDescription": MessageLookupByLibrary.simpleMessage(
      "See how your elements, planets, and signs work together—not only in love, but also in energy, support, and growth.",
    ),
    "compatibilityCalculate": MessageLookupByLibrary.simpleMessage("Calculate"),
    "compatibilityCalculationError": MessageLookupByLibrary.simpleMessage(
      "Unable to calculate compatibility. Try again.",
    ),
    "compatibilityCheck": MessageLookupByLibrary.simpleMessage(
      "Check compatibility",
    ),
    "compatibilityConflicts": MessageLookupByLibrary.simpleMessage("Conflicts"),
    "compatibilityDetailsLabel": MessageLookupByLibrary.simpleMessage(
      "More about compatibility",
    ),
    "compatibilityFamily": MessageLookupByLibrary.simpleMessage("Family"),
    "compatibilityFillBirthDate": MessageLookupByLibrary.simpleMessage(
      "Add your date of birth in Profile",
    ),
    "compatibilityFillPartner": MessageLookupByLibrary.simpleMessage(
      "Add your partner\'s information",
    ),
    "compatibilityHistoryEmpty": MessageLookupByLibrary.simpleMessage(
      "Your compatibility history is empty",
    ),
    "compatibilityHistoryTitle": MessageLookupByLibrary.simpleMessage(
      "Compatibility\nhistory",
    ),
    "compatibilityLoadingConsulting": MessageLookupByLibrary.simpleMessage(
      "The stars are consulting…",
    ),
    "compatibilityLoadingDestinies": MessageLookupByLibrary.simpleMessage(
      "Comparing your paths…",
    ),
    "compatibilityLoadingSecrets": MessageLookupByLibrary.simpleMessage(
      "The Universe is revealing its secrets…",
    ),
    "compatibilityLoadingSigns": MessageLookupByLibrary.simpleMessage(
      "Reading the celestial signs…",
    ),
    "compatibilityLove": MessageLookupByLibrary.simpleMessage("Love"),
    "compatibilityNewPair": MessageLookupByLibrary.simpleMessage(
      "Check another couple",
    ),
    "compatibilityNoData": MessageLookupByLibrary.simpleMessage(
      "No compatibility data",
    ),
    "compatibilityPartnerBirthDate": MessageLookupByLibrary.simpleMessage(
      "Partner\'s date of birth",
    ),
    "compatibilityPartnerDetailsTitle": MessageLookupByLibrary.simpleMessage(
      "Enter your partner\'s\ndetails",
    ),
    "compatibilityReadMore": MessageLookupByLibrary.simpleMessage("Read more"),
    "compatibilityTitle": MessageLookupByLibrary.simpleMessage("Compatibility"),
    "compatibilityUnlockTitle": MessageLookupByLibrary.simpleMessage(
      "Check your compatibility",
    ),
    "compatibilityYou": MessageLookupByLibrary.simpleMessage("You"),
    "contactsDescription": MessageLookupByLibrary.simpleMessage(
      "For support, email us at:\nsupport@asteria-calendar.com",
    ),
    "contactsTitle": MessageLookupByLibrary.simpleMessage("Contact us"),
    "contentTranslationUnavailable": MessageLookupByLibrary.simpleMessage(
      "This content is not available in English yet. Please try again later.",
    ),
    "currentLocationAutoLabel": MessageLookupByLibrary.simpleMessage(
      "Detected automatically",
    ),
    "currentLocationManualLabel": MessageLookupByLibrary.simpleMessage(
      "Set manually",
    ),
    "dailyLimitTitle": MessageLookupByLibrary.simpleMessage("Today\'s limit"),
    "dailyRuneFlipLabel": MessageLookupByLibrary.simpleMessage(
      "Flip the rune of the day",
    ),
    "dailyRuneLoading": MessageLookupByLibrary.simpleMessage(
      "Loading your rune…",
    ),
    "dailyRuneOpenedLabel": m12,
    "dailyRuneReading": MessageLookupByLibrary.simpleMessage("Cast the runes"),
    "dailyRuneTab": MessageLookupByLibrary.simpleMessage("Rune"),
    "dailyRuneTap": MessageLookupByLibrary.simpleMessage(
      "Tap the rune to flip it",
    ),
    "dailyRuneTitle": MessageLookupByLibrary.simpleMessage("Rune of the day"),
    "dailySymbolTitle": MessageLookupByLibrary.simpleMessage(
      "Symbol of the day",
    ),
    "dailyTarotFlipLabel": MessageLookupByLibrary.simpleMessage(
      "Flip the Tarot card of the day",
    ),
    "dailyTarotLoading": MessageLookupByLibrary.simpleMessage(
      "Loading your Tarot card…",
    ),
    "dailyTarotOpenedLabel": m13,
    "dailyTarotReading": MessageLookupByLibrary.simpleMessage("Get a reading"),
    "dailyTarotTab": MessageLookupByLibrary.simpleMessage("Tarot"),
    "dailyTarotTap": MessageLookupByLibrary.simpleMessage(
      "Tap the card to flip it",
    ),
    "dailyTarotTitle": MessageLookupByLibrary.simpleMessage(
      "Tarot card of the day",
    ),
    "dayFavorable": MessageLookupByLibrary.simpleMessage("Favorable\nday"),
    "dayFavorableDescription": MessageLookupByLibrary.simpleMessage(
      "The Moon supports your plans today. Make important plans, act with confidence, and choose what helps you move forward.",
    ),
    "dayNeutral": MessageLookupByLibrary.simpleMessage("Neutral\nday"),
    "dayNeutralDescription": MessageLookupByLibrary.simpleMessage(
      "This is a pause between impulse and action. The Moon neither adds nor takes away energy. Don\'t wait for inspiration—take care of yourself and avoid overload. Inner quiet is a strength too.",
    ),
    "dayTimeOptionLabel": MessageLookupByLibrary.simpleMessage("Daytime"),
    "dayUnfavorable": MessageLookupByLibrary.simpleMessage("Unfavorable\nday"),
    "dayUnfavorableDescription": MessageLookupByLibrary.simpleMessage(
      "Ease your workload today and don\'t force events. Postpone abrupt decisions, conserve your energy, and choose a calmer pace.",
    ),
    "deckCardLabel": m14,
    "deckGetInsight": MessageLookupByLibrary.simpleMessage("Get insight"),
    "deckHowToUse": MessageLookupByLibrary.simpleMessage(
      "How to use the cards",
    ),
    "deckOpenedCardLabel": m15,
    "defaultLocationMoscow": MessageLookupByLibrary.simpleMessage("Moscow"),
    "defaultUserName": MessageLookupByLibrary.simpleMessage("User"),
    "demoTheme": MessageLookupByLibrary.simpleMessage("Theme demo"),
    "done": MessageLookupByLibrary.simpleMessage("Done"),
    "dreamCalculationError": MessageLookupByLibrary.simpleMessage(
      "Unable to interpret your dream. Try again.",
    ),
    "dreamDecode": MessageLookupByLibrary.simpleMessage("Interpret"),
    "dreamDecodeAgain": MessageLookupByLibrary.simpleMessage(
      "Interpret another dream",
    ),
    "dreamDictionaryTitle": MessageLookupByLibrary.simpleMessage(
      "Dream Dictionary",
    ),
    "dreamGreeting": MessageLookupByLibrary.simpleMessage(
      "Hello!\nThis is Livia,\nthe guardian of dreams.",
    ),
    "dreamHistoryEmpty": MessageLookupByLibrary.simpleMessage(
      "Your Dream Dictionary history is empty",
    ),
    "dreamHistoryTitle": MessageLookupByLibrary.simpleMessage(
      "Request history",
    ),
    "dreamInputHint": MessageLookupByLibrary.simpleMessage(
      "Tell us about your dream",
    ),
    "dreamNoData": MessageLookupByLibrary.simpleMessage(
      "No dream interpretation data",
    ),
    "dreamTellPrompt": MessageLookupByLibrary.simpleMessage(
      "Tell her your dream,\nand she\'ll reveal its meaning.",
    ),
    "elementAir": MessageLookupByLibrary.simpleMessage("Air"),
    "elementEarth": MessageLookupByLibrary.simpleMessage("Earth"),
    "elementFire": MessageLookupByLibrary.simpleMessage("Fire"),
    "elementWater": MessageLookupByLibrary.simpleMessage("Water"),
    "emailAccessIssueText": MessageLookupByLibrary.simpleMessage(
      "Use a different email address",
    ),
    "emailAuthConsentPrefix": MessageLookupByLibrary.simpleMessage(
      "By requesting a code, you accept the",
    ),
    "emailAuthMessage": MessageLookupByLibrary.simpleMessage(
      "Enter your email and we\'ll send you a six-digit verification code.",
    ),
    "emailAuthTitle": MessageLookupByLibrary.simpleMessage(
      "Sign in or create\nan account with email",
    ),
    "emailCodeSentText": MessageLookupByLibrary.simpleMessage(
      "We sent a code to your email",
    ),
    "emailDeliveryError": MessageLookupByLibrary.simpleMessage(
      "Unable to send the email. Try again later.",
    ),
    "emailHint": MessageLookupByLibrary.simpleMessage("Email address"),
    "emailInvalidError": MessageLookupByLibrary.simpleMessage(
      "Enter a valid email address",
    ),
    "emailInvalidOrExpiredCodeError": MessageLookupByLibrary.simpleMessage(
      "The code is incorrect or has expired.",
    ),
    "emailNetworkError": MessageLookupByLibrary.simpleMessage(
      "Unable to connect to the server.",
    ),
    "emailRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "Too many attempts. Try again later.",
    ),
    "emailSendCodeError": MessageLookupByLibrary.simpleMessage(
      "Unable to send the code. Try again.",
    ),
    "emailSignInError": MessageLookupByLibrary.simpleMessage(
      "Unable to sign in. Check your connection and try again.",
    ),
    "emailUnavailableError": MessageLookupByLibrary.simpleMessage(
      "Email sign-in is temporarily unavailable.",
    ),
    "emailUnknownError": MessageLookupByLibrary.simpleMessage(
      "Something went wrong. Try again.",
    ),
    "energyFocus": MessageLookupByLibrary.simpleMessage("Focus"),
    "energyOfDay": MessageLookupByLibrary.simpleMessage("Energy of the day"),
    "energyRisks": MessageLookupByLibrary.simpleMessage("Risks"),
    "errorWithDetails": m16,
    "exactTimeUnknown": MessageLookupByLibrary.simpleMessage(
      "Exact time is unknown",
    ),
    "exactTimeUnknownDescription": MessageLookupByLibrary.simpleMessage(
      "Your birth time affects calculation accuracy. If you don\'t know it, you can enter an approximate time. Some details may be less precise without an exact time.",
    ),
    "femaleGender": MessageLookupByLibrary.simpleMessage("Woman"),
    "freeLimitResetsIn": m17,
    "freeRequestsResetIn": m18,
    "genericCheckConnection": MessageLookupByLibrary.simpleMessage(
      "Check your internet connection and try again.",
    ),
    "genericRefreshError": MessageLookupByLibrary.simpleMessage(
      "Unable to refresh. Try again.",
    ),
    "genericSomethingWrong": MessageLookupByLibrary.simpleMessage(
      "Something went wrong",
    ),
    "getCodeText": MessageLookupByLibrary.simpleMessage("Get code"),
    "getStartedButton": MessageLookupByLibrary.simpleMessage("Get started"),
    "googleSubscriptionPerMonth": m19,
    "googleSubscriptionPerWeek": m20,
    "googleSubscriptionPerYear": m21,
    "googleSubscriptionRecurringTerms": m22,
    "googleSubscriptionTrialTerms": m23,
    "helloText": MessageLookupByLibrary.simpleMessage("Hello"),
    "homeLoadError": MessageLookupByLibrary.simpleMessage(
      "Unable to load data",
    ),
    "homeOpenCalendar": MessageLookupByLibrary.simpleMessage("Pick a day"),
    "homeProSubscriptionCta": MessageLookupByLibrary.simpleMessage(
      "Try 7 days free",
    ),
    "homeProSubscriptionDescription": MessageLookupByLibrary.simpleMessage(
      "Full access to Dream Dictionary, Tarot, AI Astrologer, and Lunar Calendar",
    ),
    "homeProSubscriptionTitle": MessageLookupByLibrary.simpleMessage(
      "More signs\nfrom the stars",
    ),
    "homeTitle": MessageLookupByLibrary.simpleMessage("Home"),
    "horoscopeAdvice": MessageLookupByLibrary.simpleMessage("Guidance"),
    "horoscopeCreateError": MessageLookupByLibrary.simpleMessage(
      "Unable to create your horoscope.",
    ),
    "horoscopeEmotions": MessageLookupByLibrary.simpleMessage(
      "Emotions\nand inner world",
    ),
    "horoscopeEssence": MessageLookupByLibrary.simpleMessage("Your essence"),
    "horoscopeEssenceDescription": MessageLookupByLibrary.simpleMessage(
      "— strengths and hidden talents.",
    ),
    "horoscopeEvolution": MessageLookupByLibrary.simpleMessage(
      "Your evolution",
    ),
    "horoscopeEvolutionDescription": MessageLookupByLibrary.simpleMessage(
      "— your path of growth and key changes.",
    ),
    "horoscopeExamples": MessageLookupByLibrary.simpleMessage("Examples"),
    "horoscopeFinances": MessageLookupByLibrary.simpleMessage(
      "Finances\nand the material\nworld",
    ),
    "horoscopeGeneral": MessageLookupByLibrary.simpleMessage(
      "General characteristics",
    ),
    "horoscopeLifeAreas": MessageLookupByLibrary.simpleMessage("Life areas"),
    "horoscopeLifeAreasDescription": MessageLookupByLibrary.simpleMessage(
      "— where good fortune awaits and what deserves your attention.",
    ),
    "horoscopeLifetimeDescription": MessageLookupByLibrary.simpleMessage(
      "Lifetime access—read whenever you like, return, and discover new meaning in every word.",
    ),
    "horoscopeLoadError": MessageLookupByLibrary.simpleMessage(
      "Unable to load your horoscope.",
    ),
    "horoscopeLove": MessageLookupByLibrary.simpleMessage(
      "Love\nand relationships",
    ),
    "horoscopeMetaphor": MessageLookupByLibrary.simpleMessage(
      "Astrological\nmetaphor",
    ),
    "horoscopePersonalAdvice": MessageLookupByLibrary.simpleMessage(
      "Personal guidance",
    ),
    "horoscopePowerPeriods": MessageLookupByLibrary.simpleMessage(
      "Periods of power\nand transformation",
    ),
    "horoscopeTitle": MessageLookupByLibrary.simpleMessage("Horoscope"),
    "horoscopeTransits": MessageLookupByLibrary.simpleMessage(
      "Current transits",
    ),
    "horoscopeWeakPoints": MessageLookupByLibrary.simpleMessage(
      "Weak points and cautions",
    ),
    "horoscopeWellbeing": MessageLookupByLibrary.simpleMessage("Well-being"),
    "horoscopeWork": MessageLookupByLibrary.simpleMessage("Work\nand purpose"),
    "initializationError": MessageLookupByLibrary.simpleMessage(
      "Unable to start Asteria",
    ),
    "insightLoadError": MessageLookupByLibrary.simpleMessage(
      "Unable to get your insight. Try again later.",
    ),
    "insightLoadingAngle": MessageLookupByLibrary.simpleMessage(
      "Looking for a fresh perspective…",
    ),
    "insightLoadingPerspective": MessageLookupByLibrary.simpleMessage(
      "Seeing the situation differently…",
    ),
    "insightLoadingSymbols": MessageLookupByLibrary.simpleMessage(
      "Listening to the symbols…",
    ),
    "insightLoadingTitle": MessageLookupByLibrary.simpleMessage("Your insight"),
    "insightLoadingTogether": MessageLookupByLibrary.simpleMessage(
      "Bringing your insight together…",
    ),
    "keltCardPositionTitle": m24,
    "keltDeckCompletedDescription": MessageLookupByLibrary.simpleMessage(
      "You\'ve opened all 10 cards of the Celtic Cross. This spread offers a complete view of the situation: from roots in the past to future trends, and from inner motives to outside influences.\n✨ Reflect on the question you brought. What resonates most now? Did one card stand out?\nTo explore the spread more deeply:\n• Return to key positions 1, 4, and 6\n• Notice what repeats\n• Consider the guidance in position 10",
    ),
    "keltDeckDescription": MessageLookupByLibrary.simpleMessage(
      "A Tarot spread answers a specific question. Open the cards in order—together they form one complete answer. First phrase your question, then reveal each card and choose the area it relates to.",
    ),
    "keltDeckHowToClosing": MessageLookupByLibrary.simpleMessage(
      "Read each card carefully. Don\'t rush: consider the position first, then the card. The interpretations can help you understand the situation and choose your path.",
    ),
    "keltDeckHowToIntroduction": MessageLookupByLibrary.simpleMessage(
      "The Celtic Cross is one of the most detailed Tarot spreads. It helps reveal hidden causes, outside influences, and a likely outcome. Each of its 10 cards represents a specific aspect; read the card and consider its position.",
    ),
    "keltDeckTitle": MessageLookupByLibrary.simpleMessage("Celtic Cross"),
    "keltPosition10Description": MessageLookupByLibrary.simpleMessage(
      "This position shows the outcome and direction of the situation.",
    ),
    "keltPosition10Item": MessageLookupByLibrary.simpleMessage(
      "Outcome—where the situation may lead",
    ),
    "keltPosition10Title": MessageLookupByLibrary.simpleMessage("Outcome"),
    "keltPosition1Description": MessageLookupByLibrary.simpleMessage(
      "This position shows what is happening at the time of your question.",
    ),
    "keltPosition1Item": MessageLookupByLibrary.simpleMessage(
      "The present situation—what is happening now",
    ),
    "keltPosition1Title": MessageLookupByLibrary.simpleMessage(
      "The present situation",
    ),
    "keltPosition2Description": MessageLookupByLibrary.simpleMessage(
      "This position shows what is blocking you or creating difficulty.",
    ),
    "keltPosition2Item": MessageLookupByLibrary.simpleMessage(
      "The challenge—what blocks you or creates difficulty",
    ),
    "keltPosition2Title": MessageLookupByLibrary.simpleMessage("The challenge"),
    "keltPosition3Description": MessageLookupByLibrary.simpleMessage(
      "This position points to the root and deeper cause of the situation.",
    ),
    "keltPosition3Item": MessageLookupByLibrary.simpleMessage(
      "The foundation—the root and deeper cause",
    ),
    "keltPosition3Title": MessageLookupByLibrary.simpleMessage(
      "The foundation",
    ),
    "keltPosition4Description": MessageLookupByLibrary.simpleMessage(
      "This position points to past events or influences that shaped the current situation.",
    ),
    "keltPosition4Item": MessageLookupByLibrary.simpleMessage(
      "The past—events that shaped the current situation",
    ),
    "keltPosition4Title": MessageLookupByLibrary.simpleMessage("The past"),
    "keltPosition5Description": MessageLookupByLibrary.simpleMessage(
      "This position shows the potential and likely development of events.",
    ),
    "keltPosition5Item": MessageLookupByLibrary.simpleMessage(
      "Potential—what may happen if the current path continues",
    ),
    "keltPosition5Title": MessageLookupByLibrary.simpleMessage("Potential"),
    "keltPosition6Description": MessageLookupByLibrary.simpleMessage(
      "This position shows the near future and what may emerge soon.",
    ),
    "keltPosition6Item": MessageLookupByLibrary.simpleMessage(
      "The near future—what may emerge soon",
    ),
    "keltPosition6Title": MessageLookupByLibrary.simpleMessage(
      "The near future",
    ),
    "keltPosition7Description": MessageLookupByLibrary.simpleMessage(
      "This position reveals your inner mindset and behavior.",
    ),
    "keltPosition7Item": MessageLookupByLibrary.simpleMessage(
      "Yourself—your mindset and behavior",
    ),
    "keltPosition7Title": MessageLookupByLibrary.simpleMessage("Yourself"),
    "keltPosition8Description": MessageLookupByLibrary.simpleMessage(
      "This position shows the influence of other people and outside factors.",
    ),
    "keltPosition8Item": MessageLookupByLibrary.simpleMessage(
      "Your environment—other people and outside factors",
    ),
    "keltPosition8Title": MessageLookupByLibrary.simpleMessage(
      "Your environment",
    ),
    "keltPosition9Description": MessageLookupByLibrary.simpleMessage(
      "This position offers advice or a caution worth considering.",
    ),
    "keltPosition9Item": MessageLookupByLibrary.simpleMessage(
      "Advice or caution—what you need to know or consider",
    ),
    "keltPosition9Title": MessageLookupByLibrary.simpleMessage(
      "Advice or caution",
    ),
    "legalDocumentUnavailable": MessageLookupByLibrary.simpleMessage(
      "The approved English legal document is not available in this build.",
    ),
    "legalTermsConnector": MessageLookupByLibrary.simpleMessage("and"),
    "licensesDescription": MessageLookupByLibrary.simpleMessage(
      "Icons by HadiSharifani from Figma Community, licensed under CC BY 4.0.",
    ),
    "licensesTitle": MessageLookupByLibrary.simpleMessage(
      "Materials and licenses",
    ),
    "limitResetsIn": m25,
    "loading": MessageLookupByLibrary.simpleMessage("Loading…"),
    "loadingDataError": MessageLookupByLibrary.simpleMessage(
      "Unable to load data",
    ),
    "locationAllowButton": MessageLookupByLibrary.simpleMessage(
      "Allow location",
    ),
    "locationManualButton": MessageLookupByLibrary.simpleMessage(
      "Choose city manually",
    ),
    "locationManualInputHint": MessageLookupByLibrary.simpleMessage("City"),
    "locationNotConfigured": MessageLookupByLibrary.simpleMessage(
      "Current location is not set",
    ),
    "locationPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "We couldn\'t detect your location. Allow access in device settings or enter a city manually.",
    ),
    "logoutButton": MessageLookupByLibrary.simpleMessage("Log out"),
    "logoutError": MessageLookupByLibrary.simpleMessage("Unable to log out"),
    "loveDeckDescription": MessageLookupByLibrary.simpleMessage(
      "Six cards reveal your relationship\'s past, present, and possible future.\nOpen them in order to understand what is happening between you.",
    ),
    "loveDeckHowToClosing": MessageLookupByLibrary.simpleMessage(
      "Open the cards one at a time and read each meaning in the context of your situation.",
    ),
    "loveDeckHowToIntroduction": MessageLookupByLibrary.simpleMessage(
      "The Love spread helps you understand yourself, your partner, and your connection. Its six cards each represent an important aspect of your relationship:",
    ),
    "loveDeckPositionFuture": MessageLookupByLibrary.simpleMessage(
      "The relationship\'s future—how the situation may develop",
    ),
    "loveDeckPositionObstacles": MessageLookupByLibrary.simpleMessage(
      "What gets in the way—obstacles or misunderstandings",
    ),
    "loveDeckPositionPartnerFeelings": MessageLookupByLibrary.simpleMessage(
      "Their feelings—what they feel toward you",
    ),
    "loveDeckPositionSharedEnergy": MessageLookupByLibrary.simpleMessage(
      "Shared energy—how your energies interact",
    ),
    "loveDeckPositionSupport": MessageLookupByLibrary.simpleMessage(
      "What helps—resources and support in the relationship",
    ),
    "loveDeckPositionYourFeelings": MessageLookupByLibrary.simpleMessage(
      "Your feelings—your emotions and wishes",
    ),
    "loveDeckTagline": MessageLookupByLibrary.simpleMessage(
      "Look into your partner\'s feelings and discover where your relationship is heading",
    ),
    "loveDeckTitle": MessageLookupByLibrary.simpleMessage("Love spread"),
    "loveReadingDescription": MessageLookupByLibrary.simpleMessage(
      "Explore what is happening in your love life. For relationships, doubts, being single, or attraction.",
    ),
    "lunarCalendarTitle": MessageLookupByLibrary.simpleMessage(
      "Lunar calendar",
    ),
    "lunarCareerGrowth": MessageLookupByLibrary.simpleMessage("Career growth"),
    "lunarCosmetology": MessageLookupByLibrary.simpleMessage("Cosmetology"),
    "lunarCouple": MessageLookupByLibrary.simpleMessage("Couple"),
    "lunarDailyDiet": MessageLookupByLibrary.simpleMessage("Daily diet"),
    "lunarDay": MessageLookupByLibrary.simpleMessage("lunar day"),
    "lunarEpilationDepilation": MessageLookupByLibrary.simpleMessage(
      "Hair removal",
    ),
    "lunarFamily": MessageLookupByLibrary.simpleMessage("Family"),
    "lunarForThoseAlone": MessageLookupByLibrary.simpleMessage("For singles"),
    "lunarFragrancesMagnetism": MessageLookupByLibrary.simpleMessage(
      "Fragrance and magnetism",
    ),
    "lunarFriends": MessageLookupByLibrary.simpleMessage("Friends"),
    "lunarGarden": MessageLookupByLibrary.simpleMessage("Garden"),
    "lunarHairColoring": MessageLookupByLibrary.simpleMessage("Hair coloring"),
    "lunarHaircut": MessageLookupByLibrary.simpleMessage("Haircuts"),
    "lunarHarvestingPreserving": MessageLookupByLibrary.simpleMessage(
      "Harvesting and preserving",
    ),
    "lunarHealthImmunity": MessageLookupByLibrary.simpleMessage(
      "Health and immunity",
    ),
    "lunarHouseplants": MessageLookupByLibrary.simpleMessage("Houseplants"),
    "lunarImportantDecisions": MessageLookupByLibrary.simpleMessage(
      "Important decisions",
    ),
    "lunarJobChange": MessageLookupByLibrary.simpleMessage("Changing jobs"),
    "lunarManicurePedicure": MessageLookupByLibrary.simpleMessage(
      "Manicure and pedicure",
    ),
    "lunarMedicalProcedures": MessageLookupByLibrary.simpleMessage(
      "Medical procedures",
    ),
    "lunarMeditations": MessageLookupByLibrary.simpleMessage("Meditation"),
    "lunarPestControl": MessageLookupByLibrary.simpleMessage("Pest control"),
    "lunarPhysicalActivitySports": MessageLookupByLibrary.simpleMessage(
      "Physical activity and sports",
    ),
    "lunarSex": MessageLookupByLibrary.simpleMessage("Sex"),
    "lunarSkinCare": MessageLookupByLibrary.simpleMessage("Skin care"),
    "lunarSleepRecovery": MessageLookupByLibrary.simpleMessage(
      "Sleep and recovery",
    ),
    "lunarSowingPlanting": MessageLookupByLibrary.simpleMessage(
      "Sowing and planting",
    ),
    "lunarSpaRelaxation": MessageLookupByLibrary.simpleMessage(
      "Spa and relaxation",
    ),
    "lunarTransplantingPricking": MessageLookupByLibrary.simpleMessage(
      "Transplanting and pricking out",
    ),
    "lunarTravel": MessageLookupByLibrary.simpleMessage("Travel"),
    "lunarWateringFertilizing": MessageLookupByLibrary.simpleMessage(
      "Watering and fertilizing",
    ),
    "lunarWeightLossFasting": MessageLookupByLibrary.simpleMessage(
      "Weight loss and fasting days",
    ),
    "lunarWork": MessageLookupByLibrary.simpleMessage("Work"),
    "maleGender": MessageLookupByLibrary.simpleMessage("Man"),
    "manage": MessageLookupByLibrary.simpleMessage("Manage"),
    "moonBackgroundTitle": m26,
    "moonCalendarLoadingDayDescription": MessageLookupByLibrary.simpleMessage(
      "Checking today\'s date, Moon phase, and recommendations.",
    ),
    "moonCalendarLoadingDayTitle": MessageLookupByLibrary.simpleMessage(
      "Loading lunar day",
    ),
    "moonDayDetailsUnavailable": MessageLookupByLibrary.simpleMessage(
      "The lunar note for this date is unavailable. Explore another day or plan an activity.",
    ),
    "moonDayNumber": m27,
    "moonDescriptionDefault": MessageLookupByLibrary.simpleMessage(
      "Slow down, check in with yourself, and choose what supports your energy.",
    ),
    "moonDescriptionFirstQuarter": MessageLookupByLibrary.simpleMessage(
      "Stay focused: choose what matters, move consistently, and protect your energy.",
    ),
    "moonDescriptionFullMoon": MessageLookupByLibrary.simpleMessage(
      "Emotions may feel brighter than usual. Keep your balance, finish what you started, and make room for rest.",
    ),
    "moonDescriptionLastQuarter": MessageLookupByLibrary.simpleMessage(
      "Energy is easing. Slow down, avoid overload, and postpone major new beginnings.",
    ),
    "moonDescriptionNewMoon": MessageLookupByLibrary.simpleMessage(
      "A gentle reset: listen inward, set intentions, and avoid rushed decisions.",
    ),
    "moonDescriptionWaningCrescent": MessageLookupByLibrary.simpleMessage(
      "A time for rest and quiet. Close loose ends and don\'t ask too much of yourself.",
    ),
    "moonDescriptionWaningGibbous": MessageLookupByLibrary.simpleMessage(
      "A good time to share experience, practice gratitude, and release excess tension.",
    ),
    "moonDescriptionWaxingCrescent": MessageLookupByLibrary.simpleMessage(
      "Energy is building. Take the first steps, strengthen your plans, and keep your focus.",
    ),
    "moonDescriptionWaxingGibbous": MessageLookupByLibrary.simpleMessage(
      "Refine important work, review the details, and move calmly toward the result.",
    ),
    "moonGenericFallbackNotice": MessageLookupByLibrary.simpleMessage(
      "Showing the general lunar calendar",
    ),
    "moonLocationNote": MessageLookupByLibrary.simpleMessage(
      "Based on your location and time",
    ),
    "moonLocationSetupDescription": MessageLookupByLibrary.simpleMessage(
      "The lunar day and moonrise time depend on where you are now. Allow location access or enter a city manually.",
    ),
    "moonLocationSetupTitle": MessageLookupByLibrary.simpleMessage(
      "Set your current location",
    ),
    "moonNextPhaseDate": m28,
    "moonPhaseChange": MessageLookupByLibrary.simpleMessage(
      "Moon phase change",
    ),
    "moonPhaseEventTime": m29,
    "moonPhaseFirstQuarter": MessageLookupByLibrary.simpleMessage(
      "First Quarter",
    ),
    "moonPhaseFullMoon": MessageLookupByLibrary.simpleMessage("Full Moon"),
    "moonPhaseLastQuarter": MessageLookupByLibrary.simpleMessage(
      "Last Quarter",
    ),
    "moonPhaseLoadingDescription": MessageLookupByLibrary.simpleMessage(
      "Checking your current location and recalculating lunar data.",
    ),
    "moonPhaseLoadingTitle": MessageLookupByLibrary.simpleMessage(
      "Loading moon phase",
    ),
    "moonPhaseNewMoon": MessageLookupByLibrary.simpleMessage("New Moon"),
    "moonPhaseTitle": MessageLookupByLibrary.simpleMessage("Moon phase"),
    "moonPhaseUnknown": MessageLookupByLibrary.simpleMessage("Moon phase"),
    "moonPhaseWaningCrescent": MessageLookupByLibrary.simpleMessage(
      "Waning Crescent",
    ),
    "moonPhaseWaningGibbous": MessageLookupByLibrary.simpleMessage(
      "Waning Gibbous",
    ),
    "moonPhaseWaxingCrescent": MessageLookupByLibrary.simpleMessage(
      "Waxing Crescent",
    ),
    "moonPhaseWaxingGibbous": MessageLookupByLibrary.simpleMessage(
      "Waxing Gibbous",
    ),
    "moonSphereStatusTitle": m30,
    "moonStatusFavorableShort": MessageLookupByLibrary.simpleMessage(
      "favorable",
    ),
    "moonStatusNeutralShort": MessageLookupByLibrary.simpleMessage("neutral"),
    "moonStatusUnfavorableShort": MessageLookupByLibrary.simpleMessage(
      "unfavorable",
    ),
    "nameLabel": MessageLookupByLibrary.simpleMessage("Name"),
    "natalAccentHouse": m31,
    "natalAccessUnavailable": MessageLookupByLibrary.simpleMessage(
      "Could not check your subscription. Please try again.",
    ),
    "natalBuy": MessageLookupByLibrary.simpleMessage("Unlock birth chart"),
    "natalCardPriceTitle": m32,
    "natalChartTitle": MessageLookupByLibrary.simpleMessage("Birth chart"),
    "natalCreateCard": MessageLookupByLibrary.simpleMessage(
      "Create your birth chart",
    ),
    "natalDestinyDepth": MessageLookupByLibrary.simpleMessage(
      "Destiny and depth",
    ),
    "natalElementsDescription": MessageLookupByLibrary.simpleMessage(
      "— your inner balance of energies.",
    ),
    "natalElementsModalities": MessageLookupByLibrary.simpleMessage(
      "Elements\nand modalities",
    ),
    "natalElementsTab": MessageLookupByLibrary.simpleMessage("Elements"),
    "natalForeverAccess": MessageLookupByLibrary.simpleMessage(
      "Lifetime access",
    ),
    "natalForeverDescription": MessageLookupByLibrary.simpleMessage(
      "A detailed interpretation that\'s yours to keep.",
    ),
    "natalGeneralData": MessageLookupByLibrary.simpleMessage(
      "General information",
    ),
    "natalGenerationFailed": MessageLookupByLibrary.simpleMessage(
      "Could not create your chart. Please try again.",
    ),
    "natalGetInterpretation": MessageLookupByLibrary.simpleMessage(
      "Get interpretation",
    ),
    "natalGrowthLife": MessageLookupByLibrary.simpleMessage("Growth and life"),
    "natalHousesDescription": MessageLookupByLibrary.simpleMessage(
      "— keys to life areas and your talents.",
    ),
    "natalHousesThemes": MessageLookupByLibrary.simpleMessage(
      "Houses and themes",
    ),
    "natalIncludedInPro": MessageLookupByLibrary.simpleMessage(
      "Included in PRO",
    ),
    "natalInsideTitle": MessageLookupByLibrary.simpleMessage(
      "What you\'ll discover",
    ),
    "natalInstantAccess": MessageLookupByLibrary.simpleMessage(
      "Access opens immediately after payment.",
    ),
    "natalLoadError": MessageLookupByLibrary.simpleMessage(
      "Unable to load your birth chart. Try again.",
    ),
    "natalLoadingCode": MessageLookupByLibrary.simpleMessage(
      "Revealing your celestial personality code…",
    ),
    "natalLoadingLanguage": MessageLookupByLibrary.simpleMessage(
      "Reading the secret language of the planets…",
    ),
    "natalLoadingPattern": MessageLookupByLibrary.simpleMessage(
      "Connecting the stars into your destiny pattern…",
    ),
    "natalLoadingPortrait": MessageLookupByLibrary.simpleMessage(
      "The Universe is creating your star portrait…",
    ),
    "natalMagicSummary": MessageLookupByLibrary.simpleMessage(
      "Magical summary",
    ),
    "natalMainPositions": MessageLookupByLibrary.simpleMessage("Key positions"),
    "natalPaywallIntro": MessageLookupByLibrary.simpleMessage(
      "A birth chart is your unique celestial passport, created at the moment you were born.",
    ),
    "natalPaywallTitle": MessageLookupByLibrary.simpleMessage(
      "Your birth chart",
    ),
    "natalPersonalityFoundation": MessageLookupByLibrary.simpleMessage(
      "Personality foundation",
    ),
    "natalPositionsTab": MessageLookupByLibrary.simpleMessage("Today"),
    "natalProAccessDescription": MessageLookupByLibrary.simpleMessage(
      "No Star Coins required. Your chart is yours to keep.",
    ),
    "natalRelationshipsExpression": MessageLookupByLibrary.simpleMessage(
      "Relationships and expression",
    ),
    "natalStrongHouse": m33,
    "natalSummaryDescription": MessageLookupByLibrary.simpleMessage(
      "— a personal message from the Universe.",
    ),
    "natalWeakHouse": m34,
    "navHome": MessageLookupByLibrary.simpleMessage("Home"),
    "navMoon": MessageLookupByLibrary.simpleMessage("Moon"),
    "navPersonal": MessageLookupByLibrary.simpleMessage("Personal"),
    "navPractices": MessageLookupByLibrary.simpleMessage("Practices"),
    "navProfile": MessageLookupByLibrary.simpleMessage("Profile"),
    "next": MessageLookupByLibrary.simpleMessage("Next"),
    "nightTimeOptionLabel": MessageLookupByLibrary.simpleMessage("Nighttime"),
    "noSubscriptionQuestion": MessageLookupByLibrary.simpleMessage(
      "No subscription?",
    ),
    "notEnoughStarsTitle": MessageLookupByLibrary.simpleMessage(
      "Not enough Star Coins",
    ),
    "offerIncludesTitle": MessageLookupByLibrary.simpleMessage("You\'ll get:"),
    "offerProTitle": MessageLookupByLibrary.simpleMessage(
      "Get a PRO subscription",
    ),
    "offerUnlimitedDescription": MessageLookupByLibrary.simpleMessage(
      "Unlimited Dream Dictionary, Tarot, AI Astrologer, and compatibility requests",
    ),
    "onboardPreviewAnakraQuestion": MessageLookupByLibrary.simpleMessage(
      "Hi, why am I feeling so tired?",
    ),
    "onboardPreviewAnakraReply": MessageLookupByLibrary.simpleMessage(
      "Welcome ✨ Today your energy asks you to slow down, restore your inner balance and give yourself more rest 🌙",
    ),
    "onboardPreviewCompatibilityScore": MessageLookupByLibrary.simpleMessage(
      "69%",
    ),
    "onboardPreviewGemini": MessageLookupByLibrary.simpleMessage("Gemini"),
    "onboardPreviewGeminiDates": MessageLookupByLibrary.simpleMessage(
      "22 May 1994",
    ),
    "onboardPreviewMagicDescription": MessageLookupByLibrary.simpleMessage(
      "You came into this world to care for yourself and others while keeping your boundaries. You carry Earth\'s strength and Water\'s sensitivity. The Moon guides your inner world — remember to listen to her whispers.",
    ),
    "onboardPreviewMagicTitle": MessageLookupByLibrary.simpleMessage(
      "Magical insight",
    ),
    "onboardPreviewPersonalState": MessageLookupByLibrary.simpleMessage(
      "You are learning to let go of expectations and trust the flow.",
    ),
    "onboardPreviewTaurus": MessageLookupByLibrary.simpleMessage("Taurus"),
    "onboardPreviewTaurusDates": MessageLookupByLibrary.simpleMessage(
      "13 May 1995",
    ),
    "onboardingEmptyPagesError": MessageLookupByLibrary.simpleMessage(
      "Onboarding content is unavailable.",
    ),
    "onboardingInvalidPageError": MessageLookupByLibrary.simpleMessage(
      "This onboarding page is unavailable.",
    ),
    "onboardingPage1Description": MessageLookupByLibrary.simpleMessage(
      "Moon phases, tarot, your birth chart,\nand personal guidance every day",
    ),
    "onboardingPage1Title": MessageLookupByLibrary.simpleMessage(
      "Asteria\nThe Moon and\nyour daily rhythm",
    ),
    "onboardingPage2Description": MessageLookupByLibrary.simpleMessage(
      "Moon phases, daily energy,\nfavorable periods, and guidance",
    ),
    "onboardingPage2Title": MessageLookupByLibrary.simpleMessage(
      "Discover\nwhat today holds\nfor you",
    ),
    "onboardingPage3Description": MessageLookupByLibrary.simpleMessage(
      "Readings, advice,\nand personal interpretations",
    ),
    "onboardingPage3Title": MessageLookupByLibrary.simpleMessage(
      "Find answers\nthrough tarot\nand an AI astrologer",
    ),
    "onboardingPage4Description": MessageLookupByLibrary.simpleMessage(
      "Your birth chart and compatibility\nwith the people in your life",
    ),
    "onboardingPage4Title": MessageLookupByLibrary.simpleMessage(
      "Learn more\nabout yourself and\nyour energy",
    ),
    "onboardingPreviewAffirmation": MessageLookupByLibrary.simpleMessage(
      "My inner strength grows with every breath, filling me with confidence and calm in every moment of life.",
    ),
    "onboardingPreviewFocusDescription": MessageLookupByLibrary.simpleMessage(
      "A day for breakthrough ideas. The planets support clarity and action. A good time to take the initiative.",
    ),
    "onboardingPreviewFocusPhrase": MessageLookupByLibrary.simpleMessage(
      "Strong focus and energy",
    ),
    "onboardingPreviewRiskDescription": MessageLookupByLibrary.simpleMessage(
      "Be careful with financial investments.",
    ),
    "onboardingPreviewRiskPhrase": MessageLookupByLibrary.simpleMessage(
      "Lower attention and focus",
    ),
    "openArticleLabel": m35,
    "openCompatibilityLabel": MessageLookupByLibrary.simpleMessage(
      "Open compatibility",
    ),
    "openLunarCalendarLabel": MessageLookupByLibrary.simpleMessage(
      "Pick a day in the lunar calendar",
    ),
    "openSubscription": MessageLookupByLibrary.simpleMessage(
      "View subscription options",
    ),
    "paidRequestsLeft": m36,
    "paymentAbandonedLocal": MessageLookupByLibrary.simpleMessage(
      "The attempt was closed on this device. The server will continue to process any bank confirmation safely.",
    ),
    "paymentAbandonedServerConfirmed": MessageLookupByLibrary.simpleMessage(
      "You can create a new payment. A later bank confirmation for the previous payment won\'t be lost.",
    ),
    "paymentAttemptLeft": MessageLookupByLibrary.simpleMessage(
      "Payment attempt saved",
    ),
    "paymentAuthenticationRequired": MessageLookupByLibrary.simpleMessage(
      "Sign in to continue with this payment.",
    ),
    "paymentCoinsCredited": m37,
    "paymentCoinsCreditedBalanceUpdated": m38,
    "paymentConfirming": MessageLookupByLibrary.simpleMessage(
      "Confirming payment",
    ),
    "paymentConfirmingMessage": MessageLookupByLibrary.simpleMessage(
      "Arc Pay accepted the payment. Your coins will appear after the server credits them.",
    ),
    "paymentContinue": MessageLookupByLibrary.simpleMessage("Continue payment"),
    "paymentCreateError": MessageLookupByLibrary.simpleMessage(
      "We couldn\'t create the payment. Try again.",
    ),
    "paymentCreateNew": MessageLookupByLibrary.simpleMessage(
      "Create a new payment",
    ),
    "paymentCreating": MessageLookupByLibrary.simpleMessage("Creating payment"),
    "paymentCreatingMessage": MessageLookupByLibrary.simpleMessage(
      "Getting a secure Arc Pay link…",
    ),
    "paymentDeclined": MessageLookupByLibrary.simpleMessage(
      "Your bank declined the payment.",
    ),
    "paymentDiagnostics": m39,
    "paymentExpired": MessageLookupByLibrary.simpleMessage(
      "The payment expired.",
    ),
    "paymentFailed": MessageLookupByLibrary.simpleMessage("Payment failed"),
    "paymentLeaveAttempt": MessageLookupByLibrary.simpleMessage(
      "Leave this attempt",
    ),
    "paymentLeaveDescription": MessageLookupByLibrary.simpleMessage(
      "You can create a new payment. If your bank has already confirmed this one, your Star Coins will still be credited after server verification.",
    ),
    "paymentLeaveQuestion": MessageLookupByLibrary.simpleMessage(
      "Leave this payment attempt?",
    ),
    "paymentManualReview": MessageLookupByLibrary.simpleMessage(
      "The payment was sent for manual review.",
    ),
    "paymentNoPendingPayment": MessageLookupByLibrary.simpleMessage(
      "There is no unfinished payment to restore.",
    ),
    "paymentNotCompleted": MessageLookupByLibrary.simpleMessage(
      "The payment was not completed.",
    ),
    "paymentOpenError": MessageLookupByLibrary.simpleMessage(
      "Unable to open the payment page",
    ),
    "paymentOpenPage": MessageLookupByLibrary.simpleMessage(
      "Open payment page",
    ),
    "paymentPackagesLoadError": MessageLookupByLibrary.simpleMessage(
      "We couldn\'t load the available packages. Try again later.",
    ),
    "paymentSettingsDescription": MessageLookupByLibrary.simpleMessage(
      "Choose your payment method on Arc Pay\'s secure page when buying Star Coins.",
    ),
    "paymentSuccess": MessageLookupByLibrary.simpleMessage(
      "Payment successful!",
    ),
    "paymentTitle": MessageLookupByLibrary.simpleMessage("Payment"),
    "paymentWaiting": MessageLookupByLibrary.simpleMessage(
      "Waiting for payment",
    ),
    "paymentWaitingMessage": MessageLookupByLibrary.simpleMessage(
      "Complete the payment in your external browser. The status updates automatically.",
    ),
    "personalAdviceDay": MessageLookupByLibrary.simpleMessage(
      "Advice for the day",
    ),
    "personalAdviceMonth": MessageLookupByLibrary.simpleMessage(
      "Advice for the month",
    ),
    "personalAdviceWeek": MessageLookupByLibrary.simpleMessage(
      "Advice for the week",
    ),
    "personalCharacter": MessageLookupByLibrary.simpleMessage("Character"),
    "personalDefaultDescription": MessageLookupByLibrary.simpleMessage(
      "You were born under a sign of stability and deep sensitivity. You have a strong connection to emotion and intuition.",
    ),
    "personalElement": MessageLookupByLibrary.simpleMessage("Element"),
    "personalEnergy": MessageLookupByLibrary.simpleMessage("Energy"),
    "personalFavorablePeriods": MessageLookupByLibrary.simpleMessage(
      "Favorable periods",
    ),
    "personalFinances": MessageLookupByLibrary.simpleMessage("Finances"),
    "personalFinancialStability": MessageLookupByLibrary.simpleMessage(
      "Financial stability",
    ),
    "personalForecastPrice": m40,
    "personalGreeting": m41,
    "personalGreetingGeneral": MessageLookupByLibrary.simpleMessage("Hello!"),
    "personalHarmony": MessageLookupByLibrary.simpleMessage(
      "Inner harmony balance",
    ),
    "personalImpactAreas": MessageLookupByLibrary.simpleMessage(
      "Impact on life areas",
    ),
    "personalInfoDescription": MessageLookupByLibrary.simpleMessage(
      "Enter your date, time, and place of birth, and let the Universe speak to you.",
    ),
    "personalInfoSubtitle": MessageLookupByLibrary.simpleMessage(
      "Tune in to the Moon and reveal your birth chart—it can illuminate your path.",
    ),
    "personalInfoTitle": MessageLookupByLibrary.simpleMessage(
      "Discover your cosmic self",
    ),
    "personalLove": MessageLookupByLibrary.simpleMessage("Love"),
    "personalLoveRelationships": MessageLookupByLibrary.simpleMessage(
      "Love\nand relationships",
    ),
    "personalMonthKeyThemes": MessageLookupByLibrary.simpleMessage(
      "Key themes\nthis month",
    ),
    "personalMonthPurchaseDescription": MessageLookupByLibrary.simpleMessage(
      "A detailed personal horoscope for the month is available as a one-time purchase.",
    ),
    "personalMonthTab": MessageLookupByLibrary.simpleMessage("Month"),
    "personalOpenChart": MessageLookupByLibrary.simpleMessage("Open chart"),
    "personalOpenForecast": MessageLookupByLibrary.simpleMessage(
      "Unlock your forecast",
    ),
    "personalOpenFree": MessageLookupByLibrary.simpleMessage("Unlock for free"),
    "personalPlanet": MessageLookupByLibrary.simpleMessage("Planet"),
    "personalTodayFree": MessageLookupByLibrary.simpleMessage(
      "Your detailed personal horoscope for today is available free of charge.",
    ),
    "personalTodayTab": MessageLookupByLibrary.simpleMessage("Today"),
    "personalUnlock": MessageLookupByLibrary.simpleMessage("Unlock"),
    "personalUnlockKeyTheme": MessageLookupByLibrary.simpleMessage(
      "Unlock key theme",
    ),
    "personalUnlockWeaknesses": MessageLookupByLibrary.simpleMessage(
      "Unlock weak points",
    ),
    "personalWeaknessesPrice": m42,
    "personalWeekPurchaseDescription": MessageLookupByLibrary.simpleMessage(
      "A detailed personal horoscope for the week is available as a one-time purchase.",
    ),
    "personalWeekTab": MessageLookupByLibrary.simpleMessage("Week"),
    "personalYearForecast": MessageLookupByLibrary.simpleMessage(
      "Personal yearly horoscope",
    ),
    "personalYourHoroscope": MessageLookupByLibrary.simpleMessage(
      "Your horoscope",
    ),
    "placeLabel": MessageLookupByLibrary.simpleMessage("Place of birth"),
    "planetChiron": MessageLookupByLibrary.simpleMessage("Chiron"),
    "planetJupiter": MessageLookupByLibrary.simpleMessage("Jupiter"),
    "planetLilith": MessageLookupByLibrary.simpleMessage("Lilith"),
    "planetMars": MessageLookupByLibrary.simpleMessage("Mars"),
    "planetMercury": MessageLookupByLibrary.simpleMessage("Mercury"),
    "planetMoon": MessageLookupByLibrary.simpleMessage("Moon"),
    "planetNeptune": MessageLookupByLibrary.simpleMessage("Neptune"),
    "planetNorthNode": MessageLookupByLibrary.simpleMessage("North Node"),
    "planetParsFortunae": MessageLookupByLibrary.simpleMessage(
      "Part of Fortune",
    ),
    "planetPluto": MessageLookupByLibrary.simpleMessage("Pluto"),
    "planetSaturn": MessageLookupByLibrary.simpleMessage("Saturn"),
    "planetSelena": MessageLookupByLibrary.simpleMessage("Selena"),
    "planetSouthNode": MessageLookupByLibrary.simpleMessage("South Node"),
    "planetSun": MessageLookupByLibrary.simpleMessage("Sun"),
    "planetUranus": MessageLookupByLibrary.simpleMessage("Uranus"),
    "planetVenus": MessageLookupByLibrary.simpleMessage("Venus"),
    "planetVertex": MessageLookupByLibrary.simpleMessage("Vertex"),
    "playerAddedFavorite": MessageLookupByLibrary.simpleMessage(
      "Added to favorites",
    ),
    "playerClose": MessageLookupByLibrary.simpleMessage("Close player"),
    "playerFavorite": MessageLookupByLibrary.simpleMessage("Favorite"),
    "playerFavoriteError": MessageLookupByLibrary.simpleMessage(
      "Unable to save favorites",
    ),
    "playerHideTranscript": MessageLookupByLibrary.simpleMessage(
      "Collapse transcript",
    ),
    "playerMetadata": MessageLookupByLibrary.simpleMessage(
      "Affirmation  ·  1 min 15 sec",
    ),
    "playerPause": MessageLookupByLibrary.simpleMessage("Pause"),
    "playerPlay": MessageLookupByLibrary.simpleMessage("Play"),
    "playerPlayError": MessageLookupByLibrary.simpleMessage(
      "Unable to play this recording",
    ),
    "playerPosition": MessageLookupByLibrary.simpleMessage("Playback position"),
    "playerRemovedFavorite": MessageLookupByLibrary.simpleMessage(
      "Removed from favorites",
    ),
    "playerRepeat": MessageLookupByLibrary.simpleMessage("Repeat recording"),
    "playerRepeatOff": MessageLookupByLibrary.simpleMessage("Repeat off"),
    "playerRepeatOn": MessageLookupByLibrary.simpleMessage("Repeat on"),
    "playerReplay": MessageLookupByLibrary.simpleMessage("Play again"),
    "playerShare": MessageLookupByLibrary.simpleMessage("Share affirmation"),
    "playerShareError": MessageLookupByLibrary.simpleMessage(
      "Could not open sharing options",
    ),
    "playerShowTranscript": MessageLookupByLibrary.simpleMessage(
      "Show full transcript",
    ),
    "policyText": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "privacySummary": MessageLookupByLibrary.simpleMessage(
      "How Asteria collects, uses, stores, and protects personal data.",
    ),
    "profileAbout": MessageLookupByLibrary.simpleMessage("About Asteria"),
    "profileAchievements": MessageLookupByLibrary.simpleMessage(
      "My achievements",
    ),
    "profileConfirmEmailDelete": MessageLookupByLibrary.simpleMessage(
      "Confirm your email before deleting your account",
    ),
    "profileDeleteAccount": MessageLookupByLibrary.simpleMessage(
      "Delete account",
    ),
    "profileDeleteAccountQuestion": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete your account?",
    ),
    "profileDeleteError": MessageLookupByLibrary.simpleMessage(
      "Unable to delete the account. Try again.",
    ),
    "profileLogoutQuestion": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to log out?",
    ),
    "profileLogoutTitle": MessageLookupByLibrary.simpleMessage("Log out"),
    "profileOpenWebsiteError": MessageLookupByLibrary.simpleMessage(
      "Unable to open the website",
    ),
    "profileShop": MessageLookupByLibrary.simpleMessage("Shop"),
    "profileTitle": MessageLookupByLibrary.simpleMessage("Profile"),
    "purchaseConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Confirm purchase",
    ),
    "purchaseDayHoroscope": MessageLookupByLibrary.simpleMessage(
      "Unlock today\'s horoscope",
    ),
    "purchaseErrorTryAgain": MessageLookupByLibrary.simpleMessage(
      "Something went wrong. Try again later.",
    ),
    "purchaseForCoinsLabel": m43,
    "purchaseForPrice": m44,
    "purchaseGoToChat": MessageLookupByLibrary.simpleMessage("Go to chat"),
    "purchaseMonthHoroscope": MessageLookupByLibrary.simpleMessage(
      "Unlock monthly horoscope",
    ),
    "purchaseNotEnoughGeneric": MessageLookupByLibrary.simpleMessage(
      "Not enough Star Coins for this purchase",
    ),
    "purchaseNotEnoughReading": MessageLookupByLibrary.simpleMessage(
      "Not enough to buy this reading",
    ),
    "purchaseNotEnoughRequests": MessageLookupByLibrary.simpleMessage(
      "Not enough to buy requests",
    ),
    "purchaseRequestsTitle": m45,
    "purchaseRequired": MessageLookupByLibrary.simpleMessage(
      "Required for purchase",
    ),
    "purchaseSuccess": MessageLookupByLibrary.simpleMessage(
      "Purchase complete",
    ),
    "purchaseTitle": MessageLookupByLibrary.simpleMessage("Purchase"),
    "purchaseWeekHoroscope": MessageLookupByLibrary.simpleMessage(
      "Unlock weekly horoscope",
    ),
    "purchaseYearHoroscope": MessageLookupByLibrary.simpleMessage(
      "Unlock yearly horoscope",
    ),
    "purchasedAttemptsAdd": MessageLookupByLibrary.simpleMessage(
      "Purchased attempts are added to your free attempts",
    ),
    "purchasedAttemptsCombine": MessageLookupByLibrary.simpleMessage(
      "Purchased requests are added to your free requests",
    ),
    "questionCoinPrice": m46,
    "readingComplete": MessageLookupByLibrary.simpleMessage(
      "Your reading is complete",
    ),
    "readingTimeMinutes": MessageLookupByLibrary.simpleMessage("min"),
    "refreshDailyRuneLabel": MessageLookupByLibrary.simpleMessage(
      "Refresh rune of the day",
    ),
    "refreshDailyTarotLabel": MessageLookupByLibrary.simpleMessage(
      "Refresh Tarot card of the day",
    ),
    "refreshReadingLabel": MessageLookupByLibrary.simpleMessage(
      "Refresh reading",
    ),
    "refreshRuneSpreadLabel": MessageLookupByLibrary.simpleMessage(
      "Refresh rune spread",
    ),
    "refreshTarotSpreadLabel": MessageLookupByLibrary.simpleMessage(
      "Refresh Tarot spread",
    ),
    "requestLimitResetIn": m47,
    "requestPackageCount": m48,
    "requestPackageForCoins": m49,
    "requestsExhausted": MessageLookupByLibrary.simpleMessage(
      "You\'ve used all your requests.\nWant to continue?",
    ),
    "requestsLeftCount": m50,
    "requestsLeftOfTotal": m51,
    "requestsLeftThisWeek": m52,
    "requestsRemaining": m53,
    "resendCodeButtonText": MessageLookupByLibrary.simpleMessage(
      "Send a new code",
    ),
    "resendCodeText": MessageLookupByLibrary.simpleMessage("Resend code in"),
    "retry": MessageLookupByLibrary.simpleMessage("Try again"),
    "rewardAvailableNextMonth": MessageLookupByLibrary.simpleMessage(
      "Available next month",
    ),
    "rewardCompleteOnboarding": MessageLookupByLibrary.simpleMessage(
      "Complete onboarding",
    ),
    "rewardCompleted": MessageLookupByLibrary.simpleMessage("Completed"),
    "rewardGranted": MessageLookupByLibrary.simpleMessage("Star Coins added"),
    "rewardLoadError": MessageLookupByLibrary.simpleMessage(
      "Unable to load rewards.",
    ),
    "rewardLoginStreak": MessageLookupByLibrary.simpleMessage(
      "Open Asteria 5 days in a row",
    ),
    "rewardMonthly": MessageLookupByLibrary.simpleMessage("Once a month"),
    "rewardOneTime": MessageLookupByLibrary.simpleMessage("One time"),
    "rewardReadArticles": MessageLookupByLibrary.simpleMessage(
      "Read 3 articles",
    ),
    "rewardShare": MessageLookupByLibrary.simpleMessage(
      "Share on social media",
    ),
    "rewardShareError": MessageLookupByLibrary.simpleMessage(
      "Unable to share Asteria.",
    ),
    "rewardShareSubject": MessageLookupByLibrary.simpleMessage(
      "Asteria—your personal astrology guide",
    ),
    "rewardShareText": m54,
    "rewardStartError": MessageLookupByLibrary.simpleMessage(
      "Unable to start rewards.",
    ),
    "rewardTarotReading": MessageLookupByLibrary.simpleMessage(
      "Get a Tarot reading",
    ),
    "rewardsHowEarn": MessageLookupByLibrary.simpleMessage(
      "How can I earn more?",
    ),
    "runeLockedLabel": m55,
    "runeOpenFuture": MessageLookupByLibrary.simpleMessage(
      "Open the future rune",
    ),
    "runeOpenFutureMeaning": m56,
    "runeOpenLabel": m57,
    "runeOpenPast": MessageLookupByLibrary.simpleMessage("Open the past rune"),
    "runeOpenPastMeaning": m58,
    "runeOpenPresent": MessageLookupByLibrary.simpleMessage(
      "Open the present rune",
    ),
    "runeOpenPresentMeaning": m59,
    "runeRefreshSubscriptionRequired": MessageLookupByLibrary.simpleMessage(
      "Refreshing the rune of the day is available with a subscription. Subscribe to receive a new rune every day.",
    ),
    "runesEmpty": MessageLookupByLibrary.simpleMessage("No runes found"),
    "runesFuture": MessageLookupByLibrary.simpleMessage("Future"),
    "runesFutureDescription": MessageLookupByLibrary.simpleMessage(
      "Where things are heading: a possible outcome, direction, or guidance for the path ahead.",
    ),
    "runesHowToIntroduction": MessageLookupByLibrary.simpleMessage(
      "Runes are not fortune-telling in the literal sense. They are symbols that reveal your inner knowledge, help you hear your intuition, and find answers already within you.",
    ),
    "runesHowToReminder": MessageLookupByLibrary.simpleMessage(
      "Runes are neither a verdict nor a prediction of fate. They are a mirror that can help you see yourself more clearly. Treat them with respect, and they can become wise companions on your path.",
    ),
    "runesHowToSteps": MessageLookupByLibrary.simpleMessage(
      "1. Set an intention. Ask yourself a question or choose an area where you want guidance.\n\n2. Settle into the moment. Quiet your thoughts. Runes work best in inner and outer stillness.\n\n3. Choose a rune. Don\'t overthink it. Trust yourself—your rune will find you.\n\n4. Read its meaning. Notice the symbol and its essence. Don\'t look for a simple yes or no; look deeper.\n\n5. Listen to yourself. Notice what resonates. Runes offer direction, but you walk the path.",
    ),
    "runesHowToUse": MessageLookupByLibrary.simpleMessage("How to use runes"),
    "runesInsightSubscriptionRequired": MessageLookupByLibrary.simpleMessage(
      "Spread insights are available with a subscription. Subscribe to discover the meaning of your spread.",
    ),
    "runesLoadError": MessageLookupByLibrary.simpleMessage(
      "Unable to load runes.",
    ),
    "runesPast": MessageLookupByLibrary.simpleMessage("Past"),
    "runesPastDescription": MessageLookupByLibrary.simpleMessage(
      "What brought you to this point: experience, lessons, and the root of the question.",
    ),
    "runesPresent": MessageLookupByLibrary.simpleMessage("Present"),
    "runesPresentDescription": MessageLookupByLibrary.simpleMessage(
      "Where you are now: your inner state and current influences.",
    ),
    "runesSpreadDailyLimit": MessageLookupByLibrary.simpleMessage(
      "You\'ve already changed your spread today. You can choose a new spread again tomorrow, or subscribe for unlimited changes.",
    ),
    "runesSpreadDescription": MessageLookupByLibrary.simpleMessage(
      "Each rune in this spread represents a different part of your situation:",
    ),
    "runesSpreadTitle": MessageLookupByLibrary.simpleMessage("Rune spread"),
    "runesTabAll": MessageLookupByLibrary.simpleMessage("All runes"),
    "runesTabDay": MessageLookupByLibrary.simpleMessage("Rune of the day"),
    "runesTabSpread": MessageLookupByLibrary.simpleMessage("Spread"),
    "runesTapToFlip": MessageLookupByLibrary.simpleMessage(
      "Tap a rune to flip it",
    ),
    "runesTitle": MessageLookupByLibrary.simpleMessage("Runes"),
    "saveButtonLoadingText": MessageLookupByLibrary.simpleMessage("Saving..."),
    "savings": MessageLookupByLibrary.simpleMessage("Save"),
    "scenarioCalendarActivityIntro": MessageLookupByLibrary.simpleMessage(
      "Choose an activity, then mark the dates that suit you and save your plan.",
    ),
    "scenarioCalendarActivityName": MessageLookupByLibrary.simpleMessage(
      "Activity name",
    ),
    "scenarioCalendarBackToCalendar": MessageLookupByLibrary.simpleMessage(
      "Back to calendar",
    ),
    "scenarioCalendarChangeDate": MessageLookupByLibrary.simpleMessage(
      "Change date",
    ),
    "scenarioCalendarChooseActivity": MessageLookupByLibrary.simpleMessage(
      "What are you planning?",
    ),
    "scenarioCalendarChooseDate": MessageLookupByLibrary.simpleMessage(
      "Choose a date",
    ),
    "scenarioCalendarChooseDates": MessageLookupByLibrary.simpleMessage(
      "Which dates work for you?",
    ),
    "scenarioCalendarCompareAction": MessageLookupByLibrary.simpleMessage(
      "Compare dates",
    ),
    "scenarioCalendarComparisonTitle": MessageLookupByLibrary.simpleMessage(
      "Compare dates",
    ),
    "scenarioCalendarEmptyPlans": MessageLookupByLibrary.simpleMessage(
      "Activities you schedule will appear here.",
    ),
    "scenarioCalendarEqualRating": MessageLookupByLibrary.simpleMessage(
      "Both dates have the same rating for this activity.",
    ),
    "scenarioCalendarFindDate": MessageLookupByLibrary.simpleMessage(
      "Find a day for an activity",
    ),
    "scenarioCalendarMonthError": MessageLookupByLibrary.simpleMessage(
      "Could not load this month.",
    ),
    "scenarioCalendarMyPlans": MessageLookupByLibrary.simpleMessage("My plans"),
    "scenarioCalendarNoActivities": MessageLookupByLibrary.simpleMessage(
      "No activity recommendations are available for this month yet.",
    ),
    "scenarioCalendarPlansError": MessageLookupByLibrary.simpleMessage(
      "Could not open your plans.",
    ),
    "scenarioCalendarRecommendationMissing":
        MessageLookupByLibrary.simpleMessage(
          "There is no recommendation for this activity on this date yet.",
        ),
    "scenarioCalendarRemoveDate": MessageLookupByLibrary.simpleMessage(
      "Deselect one date first.",
    ),
    "scenarioCalendarRepotPlants": MessageLookupByLibrary.simpleMessage(
      "Repotting plants",
    ),
    "scenarioCalendarSaveError": MessageLookupByLibrary.simpleMessage(
      "Could not save the plan. Try again.",
    ),
    "scenarioCalendarSavePlan": MessageLookupByLibrary.simpleMessage(
      "Save plan",
    ),
    "scenarioCalendarSaved": MessageLookupByLibrary.simpleMessage("Plan saved"),
    "scenarioCalendarSelectDay": MessageLookupByLibrary.simpleMessage(
      "Choose this day",
    ),
    "scenarioCalendarSingleDate": MessageLookupByLibrary.simpleMessage(
      "View this day",
    ),
    "scenarioCalendarSubtitle": MessageLookupByLibrary.simpleMessage(
      "Compare dates that work for you in the lunar calendar and save your plan.",
    ),
    "scenarioCalendarTitle": MessageLookupByLibrary.simpleMessage("Pick a day"),
    "scenarioCalendarUnratedDates": MessageLookupByLibrary.simpleMessage(
      "There are no lunar notes for this activity yet. You can still compare Moon phases and save a date.",
    ),
    "scenarioGoHome": MessageLookupByLibrary.simpleMessage("Go home"),
    "scenarioPracticeChooseMood": MessageLookupByLibrary.simpleMessage(
      "What do you need right now?",
    ),
    "scenarioPracticeFocus": MessageLookupByLibrary.simpleMessage(
      "Gather my thoughts",
    ),
    "scenarioPracticeSlowDown": MessageLookupByLibrary.simpleMessage(
      "Find calm",
    ),
    "scenarioPracticeSubtitle": MessageLookupByLibrary.simpleMessage(
      "Affirmations to match your mood.",
    ),
    "scenarioPracticeTitle": MessageLookupByLibrary.simpleMessage(
      "Take a minute for yourself",
    ),
    "scenarioPracticeUnavailable": MessageLookupByLibrary.simpleMessage(
      "No audio practices are available right now.",
    ),
    "scenarioPracticeUnwind": MessageLookupByLibrary.simpleMessage("Unwind"),
    "scenarioRelationshipCare": MessageLookupByLibrary.simpleMessage(
      "My relationship",
    ),
    "scenarioRelationshipCareOffer": MessageLookupByLibrary.simpleMessage(
      "Explore how you show care and find a question to discuss together.",
    ),
    "scenarioRelationshipCareQuestion": MessageLookupByLibrary.simpleMessage(
      "What little thing tells you that I care about you?",
    ),
    "scenarioRelationshipChooseSituation": MessageLookupByLibrary.simpleMessage(
      "What would you like to explore?",
    ),
    "scenarioRelationshipConversationLabel":
        MessageLookupByLibrary.simpleMessage("For your conversation"),
    "scenarioRelationshipDisagreement": MessageLookupByLibrary.simpleMessage(
      "Tension and disagreements",
    ),
    "scenarioRelationshipDisagreementOffer":
        MessageLookupByLibrary.simpleMessage(
          "Explore how you handle disagreements and find a way to start talking.",
        ),
    "scenarioRelationshipDisagreementQuestion":
        MessageLookupByLibrary.simpleMessage(
          "I would like to come back to our conversation. Would now or a little later work better for you?",
        ),
    "scenarioRelationshipFullReading": MessageLookupByLibrary.simpleMessage(
      "See full reading",
    ),
    "scenarioRelationshipOpenPair": MessageLookupByLibrary.simpleMessage(
      "Open pair reading",
    ),
    "scenarioRelationshipOpenSpread": MessageLookupByLibrary.simpleMessage(
      "Open love spread",
    ),
    "scenarioRelationshipOwnFeelings": MessageLookupByLibrary.simpleMessage(
      "My feelings and wishes",
    ),
    "scenarioRelationshipReflectionLabel": MessageLookupByLibrary.simpleMessage(
      "A question to reflect on",
    ),
    "scenarioRelationshipReflectionQuestion":
        MessageLookupByLibrary.simpleMessage(
          "What am I hoping the other person will do? Have we talked about it?",
        ),
    "scenarioRelationshipShareQuestion": MessageLookupByLibrary.simpleMessage(
      "Share question",
    ),
    "scenarioRelationshipSpreadOffer": MessageLookupByLibrary.simpleMessage(
      "Draw the cards and reflect on what you want.",
    ),
    "scenarioRelationshipsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Choose what is on your mind. Asteria will suggest a place to start.",
    ),
    "scenarioRelationshipsTitle": MessageLookupByLibrary.simpleMessage(
      "Understand our relationship",
    ),
    "scenarioSave": MessageLookupByLibrary.simpleMessage("Save"),
    "scenarioStartTitle": MessageLookupByLibrary.simpleMessage(
      "Where shall we start?",
    ),
    "scenarioStrengthChartSource": MessageLookupByLibrary.simpleMessage(
      "From your birth chart",
    ),
    "scenarioStrengthChooseArea": MessageLookupByLibrary.simpleMessage(
      "What’s on your mind?",
    ),
    "scenarioStrengthChooseSituation": MessageLookupByLibrary.simpleMessage(
      "What lies ahead?",
    ),
    "scenarioStrengthExplanation": MessageLookupByLibrary.simpleMessage(
      "Why this tip?",
    ),
    "scenarioStrengthForecastSource": MessageLookupByLibrary.simpleMessage(
      "From this day’s forecast",
    ),
    "scenarioStrengthFullReading": MessageLookupByLibrary.simpleMessage(
      "Open full reading",
    ),
    "scenarioStrengthNeedsReading": MessageLookupByLibrary.simpleMessage(
      "A personal tip uses your birth chart reading.",
    ),
    "scenarioStrengthNoPersonalMatch": MessageLookupByLibrary.simpleMessage(
      "Your reading has no specific guidance for this situation yet.",
    ),
    "scenarioStrengthOpenChart": MessageLookupByLibrary.simpleMessage(
      "Open birth chart reading",
    ),
    "scenarioStrengthSave": MessageLookupByLibrary.simpleMessage("Save tip"),
    "scenarioStrengthSaveError": MessageLookupByLibrary.simpleMessage(
      "Could not save this tip. Please try again.",
    ),
    "scenarioStrengthSaved": MessageLookupByLibrary.simpleMessage("Tip saved"),
    "scenarioStrengthSavedTips": MessageLookupByLibrary.simpleMessage(
      "My saved tips",
    ),
    "scenarioStrengthSubtitle": MessageLookupByLibrary.simpleMessage(
      "Get a suggestion from Anakra and reveal your daily card.",
    ),
    "scenarioStrengthTitle": MessageLookupByLibrary.simpleMessage(
      "Find a way forward",
    ),
    "scenarioStrengthTry": MessageLookupByLibrary.simpleMessage("Try this"),
    "scenarioStrengthTryToday": MessageLookupByLibrary.simpleMessage(
      "Try this today",
    ),
    "scenarioStrengthViewSaved": MessageLookupByLibrary.simpleMessage(
      "View saved tips",
    ),
    "settingsCurrentLocationDescription": MessageLookupByLibrary.simpleMessage(
      "We use your current city for the lunar calendar and moon phase. Birth place stays only for your natal chart.",
    ),
    "settingsDailyAffirmations": MessageLookupByLibrary.simpleMessage(
      "Daily affirmations",
    ),
    "settingsDailyHoroscope": MessageLookupByLibrary.simpleMessage(
      "Daily horoscope",
    ),
    "settingsGeolocation": MessageLookupByLibrary.simpleMessage("Geolocation"),
    "settingsLunarCalendar": MessageLookupByLibrary.simpleMessage(
      "Lunar Calendar",
    ),
    "settingsNotifications": MessageLookupByLibrary.simpleMessage(
      "Notifications",
    ),
    "settingsPushNotifications": MessageLookupByLibrary.simpleMessage(
      "Push notifications",
    ),
    "shopAfterPurchase": MessageLookupByLibrary.simpleMessage(
      "After purchase:",
    ),
    "shopBalance": MessageLookupByLibrary.simpleMessage("Balance:"),
    "shopDecreaseQuantity": MessageLookupByLibrary.simpleMessage(
      "Decrease quantity",
    ),
    "shopIncreaseQuantity": MessageLookupByLibrary.simpleMessage(
      "Increase quantity",
    ),
    "shopItemCount": m60,
    "shopItemSuffix": MessageLookupByLibrary.simpleMessage("items"),
    "shopItemsLeft": MessageLookupByLibrary.simpleMessage("Left"),
    "shopLoadError": MessageLookupByLibrary.simpleMessage(
      "Unable to load products",
    ),
    "shopNoProducts": MessageLookupByLibrary.simpleMessage("No products found"),
    "shopProceed": MessageLookupByLibrary.simpleMessage("Continue"),
    "shopPurchaseComplete": MessageLookupByLibrary.simpleMessage(
      "Purchase complete",
    ),
    "shopPurchaseError": MessageLookupByLibrary.simpleMessage(
      "Unable to complete the purchase",
    ),
    "shopQuantityQuestion": MessageLookupByLibrary.simpleMessage(
      "How many would you like?",
    ),
    "shopRequired": MessageLookupByLibrary.simpleMessage("Required"),
    "shopSubtitle": MessageLookupByLibrary.simpleMessage(
      "Spend Star Coins on useful features",
    ),
    "shopTitle": MessageLookupByLibrary.simpleMessage("Shop"),
    "shopUnitPrice": MessageLookupByLibrary.simpleMessage("price per item"),
    "shopUnitPriceValue": m61,
    "sonnikLoadingDetails": MessageLookupByLibrary.simpleMessage(
      "The details form a pattern…",
    ),
    "sonnikLoadingImages": MessageLookupByLibrary.simpleMessage(
      "Every image has a story…",
    ),
    "sonnikLoadingLiveya": MessageLookupByLibrary.simpleMessage(
      "Liveya steps into the world of dreams…",
    ),
    "sonnikLoadingMeaning": MessageLookupByLibrary.simpleMessage(
      "Looking for a clue in your dream…",
    ),
    "specialReadingsTitle": MessageLookupByLibrary.simpleMessage(
      "Special readings",
    ),
    "sphereBeauty": MessageLookupByLibrary.simpleMessage("Beauty"),
    "sphereGarden": MessageLookupByLibrary.simpleMessage("Gardening"),
    "sphereHealth": MessageLookupByLibrary.simpleMessage("Health"),
    "sphereRelationships": MessageLookupByLibrary.simpleMessage(
      "Relationships",
    ),
    "sphereSelect": MessageLookupByLibrary.simpleMessage("Choose an area"),
    "sphereSubscriptionRequired": MessageLookupByLibrary.simpleMessage(
      "Subscribe to discover how the Moon affects you",
    ),
    "sphereWorkRest": MessageLookupByLibrary.simpleMessage("Work and rest"),
    "step1Description": MessageLookupByLibrary.simpleMessage(
      "Explore every feature and start using Asteria today",
    ),
    "step1Title": MessageLookupByLibrary.simpleMessage(
      "Discover new possibilities",
    ),
    "step2Description": MessageLookupByLibrary.simpleMessage(
      "An intuitive interface helps you get started quickly",
    ),
    "step2Title": MessageLookupByLibrary.simpleMessage("Simple and convenient"),
    "step3Description": MessageLookupByLibrary.simpleMessage(
      "Join the community and unlock everything Asteria offers",
    ),
    "step3Title": MessageLookupByLibrary.simpleMessage("Ready to begin?"),
    "storeProductsLoadError": MessageLookupByLibrary.simpleMessage(
      "Store products could not be loaded. Try again.",
    ),
    "storePurchaseCanceled": MessageLookupByLibrary.simpleMessage(
      "Purchase canceled.",
    ),
    "storePurchaseFailedError": MessageLookupByLibrary.simpleMessage(
      "The purchase could not be completed. Try again.",
    ),
    "storePurchaseStartError": MessageLookupByLibrary.simpleMessage(
      "The purchase could not be started. Try again.",
    ),
    "storePurchaseSupportError": MessageLookupByLibrary.simpleMessage(
      "There was a purchase error. Please contact support.",
    ),
    "storePurchaseVerificationError": MessageLookupByLibrary.simpleMessage(
      "The purchase could not be verified. Contact support if you were charged.",
    ),
    "storeRestorePurchasesError": MessageLookupByLibrary.simpleMessage(
      "Purchases could not be restored. Try again.",
    ),
    "storeSignInRequiredError": MessageLookupByLibrary.simpleMessage(
      "Sign in to continue with your purchase.",
    ),
    "subscribeTitle": MessageLookupByLibrary.simpleMessage(
      "Get a subscription",
    ),
    "subscriptionAccessUntil": MessageLookupByLibrary.simpleMessage(
      "Access will remain available until\n",
    ),
    "subscriptionActivated": MessageLookupByLibrary.simpleMessage(
      "Subscription activated",
    ),
    "subscriptionActivationPending": MessageLookupByLibrary.simpleMessage(
      "Payment received. Your subscription will activate within a few minutes.",
    ),
    "subscriptionActive": MessageLookupByLibrary.simpleMessage(
      "PRO subscription\nis active",
    ),
    "subscriptionAvailableToYou": MessageLookupByLibrary.simpleMessage(
      "You have access to:",
    ),
    "subscriptionBenefitAffirmations": MessageLookupByLibrary.simpleMessage(
      "Unlimited affirmations in every category",
    ),
    "subscriptionBenefitCompatibility": MessageLookupByLibrary.simpleMessage(
      "Unlimited compatibility reports",
    ),
    "subscriptionBenefitHoroscope": MessageLookupByLibrary.simpleMessage(
      "Complete personal horoscope",
    ),
    "subscriptionBenefitMoon": MessageLookupByLibrary.simpleMessage(
      "All Lunar Calendar areas",
    ),
    "subscriptionBenefitUnlimited": MessageLookupByLibrary.simpleMessage(
      "Unlimited Dream Dictionary, Tarot, and AI Astrologer requests",
    ),
    "subscriptionBenefitsTitle": MessageLookupByLibrary.simpleMessage(
      "What your subscription includes",
    ),
    "subscriptionCancelDescription": MessageLookupByLibrary.simpleMessage(
      "All services will remain available\nuntil the end of the paid period",
    ),
    "subscriptionCancelQuestion": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to\ncancel your subscription?",
    ),
    "subscriptionChoosePlan": MessageLookupByLibrary.simpleMessage(
      "Choose a plan",
    ),
    "subscriptionConfirmingCard": MessageLookupByLibrary.simpleMessage(
      "Confirming your card and first payment…",
    ),
    "subscriptionConnect": MessageLookupByLibrary.simpleMessage("Get PRO"),
    "subscriptionDisable": MessageLookupByLibrary.simpleMessage(
      "Cancel subscription",
    ),
    "subscriptionInactive": MessageLookupByLibrary.simpleMessage(
      "PRO subscription\nis not active",
    ),
    "subscriptionInactiveDescription": MessageLookupByLibrary.simpleMessage(
      "Unlock advanced PRO\nfeatures and cancel\nany time.",
    ),
    "subscriptionInfoDescription": MessageLookupByLibrary.simpleMessage(
      "A subscription provides access to Asteria\'s advanced features:\n• Unlimited Dream Dictionary, Tarot, and AI Astrologer requests\n• Detailed Lunar Calendar insights\n• Full compatibility reports\n• Unlimited affirmations\nPayment is charged to your App Store or Google Play account after confirmation. The subscription renews automatically unless auto-renew is turned off at least 24 hours before the end of the current period. You can manage or cancel it in your store account settings. Payments are not refunded for unused time. See the Terms of Use for details.",
    ),
    "subscriptionInfoTitle": MessageLookupByLibrary.simpleMessage(
      "Subscription information",
    ),
    "subscriptionLoadPlans": MessageLookupByLibrary.simpleMessage("Load plans"),
    "subscriptionNextPayment": MessageLookupByLibrary.simpleMessage(
      "Your next payment\nwill be charged",
    ),
    "subscriptionNextPaymentInline": MessageLookupByLibrary.simpleMessage(
      "Your next payment will be\ncharged on ",
    ),
    "subscriptionNextPaymentOn": m62,
    "subscriptionNoPurchasesToRestore": MessageLookupByLibrary.simpleMessage(
      "No purchases were found to restore",
    ),
    "subscriptionOnlyTitle": MessageLookupByLibrary.simpleMessage(
      "Subscription only",
    ),
    "subscriptionOpenPaymentAgain": MessageLookupByLibrary.simpleMessage(
      "Open payment again",
    ),
    "subscriptionPlanMonth": MessageLookupByLibrary.simpleMessage("Month"),
    "subscriptionPlanWeek": MessageLookupByLibrary.simpleMessage("Week"),
    "subscriptionPlanYear": MessageLookupByLibrary.simpleMessage("Year"),
    "subscriptionPlansUnavailable": MessageLookupByLibrary.simpleMessage(
      "Subscriptions are currently unavailable. Try again later.",
    ),
    "subscriptionPurchasesRestored": m63,
    "subscriptionRestoreInProgress": MessageLookupByLibrary.simpleMessage(
      "Restoring purchases…",
    ),
    "subscriptionRestorePurchases": MessageLookupByLibrary.simpleMessage(
      "Restore purchases",
    ),
    "subscriptionTitle": MessageLookupByLibrary.simpleMessage("Subscription"),
    "subscriptionUnlimitedAccess": MessageLookupByLibrary.simpleMessage(
      "Subscribe for unlimited access to everything.",
    ),
    "tarotCardsEmpty": MessageLookupByLibrary.simpleMessage("No cards found"),
    "tarotCardsTitle": MessageLookupByLibrary.simpleMessage("Tarot cards"),
    "tarotChooseSphere": MessageLookupByLibrary.simpleMessage(
      "Choose an area\nto receive an insight",
    ),
    "tarotHowToReminder": MessageLookupByLibrary.simpleMessage(
      "Remember: an interpretation is guidance, not a verdict. You are always in charge of your life.",
    ),
    "tarotHowToSteps": MessageLookupByLibrary.simpleMessage(
      "1. Center yourself. Think about your question or situation.\n\n2. Choose a card or a spread—intuitively or by following the instructions.\n\n3. Read each card\'s meaning and relate it to current events.\n\n4. Trust your intuition. Tarot doesn\'t deliver rigid verdicts; it helps reveal what is hidden.\n\n5. Choose the area of life your question concerns for a more precise interpretation.",
    ),
    "tarotInsightSubscriptionRequired": MessageLookupByLibrary.simpleMessage(
      "Spread insights are available with a subscription. Subscribe to discover the meaning of your spread.",
    ),
    "tarotLoadError": MessageLookupByLibrary.simpleMessage(
      "Unable to load Tarot cards.",
    ),
    "tarotLockedCardLabel": m64,
    "tarotOpenCardLabel": m65,
    "tarotOpenSpreadCard": m66,
    "tarotOpenedSpreadCard": m67,
    "tarotRefreshSubscriptionRequired": MessageLookupByLibrary.simpleMessage(
      "Refreshing the Tarot card is available with a subscription. Subscribe to receive a new card every day.",
    ),
    "tarotSphereCareer": MessageLookupByLibrary.simpleMessage(
      "Career and money",
    ),
    "tarotSphereFamily": MessageLookupByLibrary.simpleMessage(
      "Family and home",
    ),
    "tarotSphereHealth": MessageLookupByLibrary.simpleMessage(
      "Health and energy",
    ),
    "tarotSphereLove": MessageLookupByLibrary.simpleMessage(
      "Love and relationships",
    ),
    "tarotSphereSelfRealization": MessageLookupByLibrary.simpleMessage(
      "Self-realization",
    ),
    "tarotSphereSpirituality": MessageLookupByLibrary.simpleMessage(
      "Spirituality",
    ),
    "tarotSpreadDailyLimit": MessageLookupByLibrary.simpleMessage(
      "You\'ve already changed your spread today. You can choose a new spread again tomorrow, or subscribe for unlimited changes.",
    ),
    "tarotSpreadDescription": MessageLookupByLibrary.simpleMessage(
      "A Tarot spread answers a specific question.\nOpen the cards in order—together they form one complete answer.\nFirst phrase your question, then reveal each card and choose the area it relates to.",
    ),
    "tarotSpreadTitle": MessageLookupByLibrary.simpleMessage("Tarot spread"),
    "tarotTabAllCards": MessageLookupByLibrary.simpleMessage("All cards"),
    "tarotTabDay": MessageLookupByLibrary.simpleMessage("Card of the day"),
    "tarotTabSpread": MessageLookupByLibrary.simpleMessage("Spread"),
    "tarotTapToFlip": MessageLookupByLibrary.simpleMessage(
      "Tap a card to flip it",
    ),
    "unknownTimeOptionLabel": MessageLookupByLibrary.simpleMessage(
      "Time unknown",
    ),
    "unlimited": MessageLookupByLibrary.simpleMessage("Unlimited"),
    "userNotFoundError": MessageLookupByLibrary.simpleMessage("User not found"),
    "viewHistory": MessageLookupByLibrary.simpleMessage("View history"),
    "yearHoroscopeChapters": MessageLookupByLibrary.simpleMessage(
      "Each chapter includes:",
    ),
    "yearHoroscopeIntro": MessageLookupByLibrary.simpleMessage(
      "Open your map of destiny and glimpse the future created just for you.",
    ),
    "yearHoroscopePriceTitle": m68,
  };
}

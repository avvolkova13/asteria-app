// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en_US locale. All the
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
  String get localeName => 'en_US';

  static String m19(price) => "${price} per month";

  static String m20(price) => "${price} per week";

  static String m21(price) => "${price} per year";

  static String m22(price) => "${price}. Renews automatically. Cancel anytime.";

  static String m23(price) =>
      "7 days free, then ${price}. Renews automatically. Cancel anytime.";

  static String m24(date) => "Upcoming days · from ${date}";

  static String m25(date) => "Chosen day: ${date}";

  static String m26(current, total) => "Page ${current} of ${total}";

  static String m46(time) => "Reminder at ${time}";

  static String m64(count) => "Plans: ${count}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
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
    "googleSubscriptionPerMonth": m19,
    "googleSubscriptionPerWeek": m20,
    "googleSubscriptionPerYear": m21,
    "googleSubscriptionRecurringTerms": m22,
    "googleSubscriptionTrialTerms": m23,
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
    "introAnakraMessage": MessageLookupByLibrary.simpleMessage(
      "Give one small step ten minutes. Just try it.",
    ),
    "introAudioError": MessageLookupByLibrary.simpleMessage(
      "Unable to play the recording.",
    ),
    "introCalendarCompare": MessageLookupByLibrary.simpleMessage(
      "Compare the next few days",
    ),
    "introCalendarCompleted": MessageLookupByLibrary.simpleMessage(
      "Everything is planned",
    ),
    "introCalendarCompletedBody": MessageLookupByLibrary.simpleMessage(
      "Your haircut is in the calendar. A reminder is set for the day before.",
    ),
    "introCalendarExample": MessageLookupByLibrary.simpleMessage(
      "Example: choosing a day",
    ),
    "introCalendarFrom": m24,
    "introCalendarInsight": MessageLookupByLibrary.simpleMessage(
      "A good day to freshen up your cut or try a new length.",
    ),
    "introCalendarReminderChoice": MessageLookupByLibrary.simpleMessage(
      "One day before",
    ),
    "introCalendarReminderEnabled": MessageLookupByLibrary.simpleMessage(
      "Reminder is on",
    ),
    "introCalendarReminderTitle": MessageLookupByLibrary.simpleMessage(
      "Remind me about this plan",
    ),
    "introCalendarRequest": MessageLookupByLibrary.simpleMessage(
      "I want a new haircut.\nWhen should I book it?",
    ),
    "introCalendarResult": m25,
    "introCalendarSavedText": MessageLookupByLibrary.simpleMessage(
      "Saved to My plans",
    ),
    "introCalendarSavedTitle": MessageLookupByLibrary.simpleMessage(
      "Haircut",
    ),
    "introDemoLabel": MessageLookupByLibrary.simpleMessage("Example reading"),
    "introFavorable": MessageLookupByLibrary.simpleMessage("Favorable day"),
    "introFavorableTip": MessageLookupByLibrary.simpleMessage(
      "A day to consider trying a new style.",
    ),
    "introMoodAffirmation": MessageLookupByLibrary.simpleMessage(
      "You can take this moment at your own pace.",
    ),
    "introMoodCalm": MessageLookupByLibrary.simpleMessage("Looking for calm"),
    "introMoodMatched": MessageLookupByLibrary.simpleMessage("Your own pace"),
    "introMoodPractice": MessageLookupByLibrary.simpleMessage(
      "Relax your shoulders. Breathe out slowly.",
    ),
    "introMoodPracticeTitle": MessageLookupByLibrary.simpleMessage(
      "A short practice",
    ),
    "introMoodRequest": MessageLookupByLibrary.simpleMessage(
      "I’m always rushing.\nI need a moment to breathe.",
    ),
    "introMoodRush": MessageLookupByLibrary.simpleMessage("Always rushing"),
    "introMoodTired": MessageLookupByLibrary.simpleMessage("Low on energy"),
    "introNatalDate": MessageLookupByLibrary.simpleMessage(
      "Example data · 13 May 1995",
    ),
    "introNatalPattern": MessageLookupByLibrary.simpleMessage(
      "Change may bring a need for more clarity and time.",
    ),
    "introNatalPatternTitle": MessageLookupByLibrary.simpleMessage(
      "A familiar reaction",
    ),
    "introNatalQuestion": MessageLookupByLibrary.simpleMessage(
      "What helps you feel grounded before a new step?",
    ),
    "introNatalQuestionTitle": MessageLookupByLibrary.simpleMessage(
      "A question to reflect on",
    ),
    "introNatalStrength": MessageLookupByLibrary.simpleMessage(
      "Following through and finishing what you start.",
    ),
    "introNatalStrengthTitle": MessageLookupByLibrary.simpleMessage(
      "A strength",
    ),
    "introNeutral": MessageLookupByLibrary.simpleMessage("Neutral day"),
    "introNeutralTip": MessageLookupByLibrary.simpleMessage(
      "Refresh your style or trim the ends.",
    ),
    "introPairExample": MessageLookupByLibrary.simpleMessage(
      "Example couple’s reading",
    ),
    "introPairFirst": MessageLookupByLibrary.simpleMessage("Taurus"),
    "introPairNeedTalk": MessageLookupByLibrary.simpleMessage(
      "“Talking about what happened helps me.”",
    ),
    "introPairNeedTime": MessageLookupByLibrary.simpleMessage(
      "“I need time to understand how I feel.”",
    ),
    "introPairPrompt": MessageLookupByLibrary.simpleMessage(
      "“This conversation matters to me. Is now a good time, or would later be better?”",
    ),
    "introPairQuestion": MessageLookupByLibrary.simpleMessage(
      "Try starting with this",
    ),
    "introPairRequest": MessageLookupByLibrary.simpleMessage(
      "I go quiet after an argument. My partner wants to talk.",
    ),
    "introPairSecond": MessageLookupByLibrary.simpleMessage("Gemini"),
    "introPairTip": MessageLookupByLibrary.simpleMessage(
      "A different pace doesn’t mean they don’t care.",
    ),
    "introPause": MessageLookupByLibrary.simpleMessage("Pause"),
    "introPlay": MessageLookupByLibrary.simpleMessage(
      "Listen to “I have time”",
    ),
    "introProgress": m26,
    "introReplay": MessageLookupByLibrary.simpleMessage(
      "Replay the card reveal",
    ),
    "introSkip": MessageLookupByLibrary.simpleMessage("Skip"),
    "introStart": MessageLookupByLibrary.simpleMessage("Get started"),
    "introStoryExample": MessageLookupByLibrary.simpleMessage("Example story"),
    "introStoryPause": MessageLookupByLibrary.simpleMessage("Pause story"),
    "introStoryReplay": MessageLookupByLibrary.simpleMessage("Replay"),
    "introStoryResume": MessageLookupByLibrary.simpleMessage("Resume story"),
    "introTarotFollowup": MessageLookupByLibrary.simpleMessage(
      "What if it does not work out?",
    ),
    "introTarotHint": MessageLookupByLibrary.simpleMessage(
      "One question. Three new perspectives.",
    ),
    "introTarotInsight": MessageLookupByLibrary.simpleMessage(
      "Anakra’s advice",
    ),
    "introTarotMeaning": MessageLookupByLibrary.simpleMessage(
      "Start with the part that interests you.",
    ),
    "introTarotMeaningTitle": MessageLookupByLibrary.simpleMessage(
      "A way to read these cards",
    ),
    "introTarotReflection": MessageLookupByLibrary.simpleMessage(
      "What if you followed your curiosity?",
    ),
    "introTarotRequest": MessageLookupByLibrary.simpleMessage(
      "I want to start something new,\nbut I keep putting it off.",
    ),
    "natalHousesNeedTime": MessageLookupByLibrary.simpleMessage(
      "An exact birth time is needed to calculate the houses.",
    ),
    "natalTimeUnknown": MessageLookupByLibrary.simpleMessage("Not provided"),
    "natalWheelApproximate": MessageLookupByLibrary.simpleMessage(
      "Without an exact birth time, the planet positions on the chart are approximate.",
    ),
    "natalWheelSelectPlanet": MessageLookupByLibrary.simpleMessage(
      "Tap a planet to see its connections",
    ),
    "natalWheelUnavailable": MessageLookupByLibrary.simpleMessage(
      "Planet positions are currently unavailable. Your saved reading is below.",
    ),
    "onboardingPage1Description": MessageLookupByLibrary.simpleMessage(
      "Let’s check the lunar calendar.",
    ),
    "onboardingPage1Title": MessageLookupByLibrary.simpleMessage(
      "When should I get a haircut?",
    ),
    "onboardingPage2Description": MessageLookupByLibrary.simpleMessage(
      "Strengths, familiar reactions and new questions to ask yourself.",
    ),
    "onboardingPage2Title": MessageLookupByLibrary.simpleMessage(
      "Your character",
    ),
    "onboardingPage3Description": MessageLookupByLibrary.simpleMessage(
      "Understand different reactions and find a way to talk.",
    ),
    "onboardingPage3Title": MessageLookupByLibrary.simpleMessage(
      "Your relationship",
    ),
    "onboardingPage4Description": MessageLookupByLibrary.simpleMessage(
      "From a Tarot reading to reflection and a conversation with Anakra.",
    ),
    "onboardingPage4Title": MessageLookupByLibrary.simpleMessage(
      "Your question",
    ),
    "onboardingPage5Description": MessageLookupByLibrary.simpleMessage(
      "Affirmations and short practices for a pause in your day.",
    ),
    "onboardingPage5Title": MessageLookupByLibrary.simpleMessage(
      "Time for yourself",
    ),
    "planReminderAdd": MessageLookupByLibrary.simpleMessage(
      "Remind me on the day",
    ),
    "planReminderAt": m46,
    "planReminderDenied": MessageLookupByLibrary.simpleMessage(
      "To get reminders, allow notifications for Asteria in iPhone Settings.",
    ),
    "planReminderEdit": MessageLookupByLibrary.simpleMessage("Change time"),
    "planReminderNotificationTitle": MessageLookupByLibrary.simpleMessage(
      "Your plan for today",
    ),
    "planReminderPast": MessageLookupByLibrary.simpleMessage(
      "This time has passed. Choose a later time.",
    ),
    "planReminderRemove": MessageLookupByLibrary.simpleMessage(
      "Remove reminder",
    ),
    "planReminderTime": MessageLookupByLibrary.simpleMessage("Reminder time"),
    "planReminderUnavailable": MessageLookupByLibrary.simpleMessage(
      "Couldn’t update the reminder. Please try again.",
    ),
    "scenarioPlansAllDay": MessageLookupByLibrary.simpleMessage("No time set"),
    "scenarioPlansCount": m64,
    "scenarioPlansDay": MessageLookupByLibrary.simpleMessage("Day"),
    "scenarioPlansEmptyDay": MessageLookupByLibrary.simpleMessage(
      "No plans for this day yet.",
    ),
    "scenarioPlansEmptyWeek": MessageLookupByLibrary.simpleMessage(
      "No plans for this week yet.",
    ),
    "scenarioPlansMonth": MessageLookupByLibrary.simpleMessage("Month"),
    "scenarioPlansNext": MessageLookupByLibrary.simpleMessage("Next period"),
    "scenarioPlansPrevious": MessageLookupByLibrary.simpleMessage(
      "Previous period",
    ),
    "scenarioPlansToday": MessageLookupByLibrary.simpleMessage("Today"),
    "scenarioPlansWeek": MessageLookupByLibrary.simpleMessage("Week"),
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
    "subscriptionPlanMonth": MessageLookupByLibrary.simpleMessage("Month"),
    "subscriptionPlanWeek": MessageLookupByLibrary.simpleMessage("Week"),
    "subscriptionPlanYear": MessageLookupByLibrary.simpleMessage("Year"),
  };
}

// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en_CA locale. All the
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
  String get localeName => 'en_CA';

  static String m19(price) => "${price} per month";

  static String m20(price) => "${price} per week";

  static String m21(price) => "${price} per year";

  static String m22(price) => "${price}. Renews automatically. Cancel anytime.";

  static String m23(price) =>
      "7 days free, then ${price}. Renews automatically. Cancel anytime.";

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
    "dayFavorable": MessageLookupByLibrary.simpleMessage("Favourable\nday"),
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
    "onboardingPage2Description": MessageLookupByLibrary.simpleMessage(
      "Moon phases, daily energy,\nfavourable periods, and guidance",
    ),
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

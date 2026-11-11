// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en_AU locale. All the
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
  String get localeName => 'en_AU';

  static String m19(price) => "${price} per month";

  static String m20(price) => "${price} per week";

  static String m21(price) => "${price} per year";

  static String m22(price) => "${price}. Renews automatically. Cancel anytime.";

  static String m23(price) =>
      "7 days free, then ${price}. Renews automatically. Cancel anytime.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "avatarChange": MessageLookupByLibrary.simpleMessage("Change avatar"),
    "avatarChooseTitle": MessageLookupByLibrary.simpleMessage(
      "Choose your avatar",
    ),
    "avatarDragon": MessageLookupByLibrary.simpleMessage("Dragon"),
    "avatarElfMan": MessageLookupByLibrary.simpleMessage("Elf man"),
    "avatarElfWoman": MessageLookupByLibrary.simpleMessage("Elf woman"),
    "avatarPhoenix": MessageLookupByLibrary.simpleMessage("Phoenix"),
    "avatarRaven": MessageLookupByLibrary.simpleMessage("Raven"),
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
    "onboardingPage2Description": MessageLookupByLibrary.simpleMessage(
      "Moon phases, daily energy,\nfavourable periods, and guidance",
    ),
  };
}

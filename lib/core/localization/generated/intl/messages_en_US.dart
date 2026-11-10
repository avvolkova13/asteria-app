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

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "googleSubscriptionPerMonth": m19,
    "googleSubscriptionPerWeek": m20,
    "googleSubscriptionPerYear": m21,
    "googleSubscriptionRecurringTerms": m22,
    "googleSubscriptionTrialTerms": m23,
  };
}

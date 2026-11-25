import 'package:asteria_app/app/data/models/anakra_chat/anakra_chat_message_model.dart';
import 'package:asteria_app/core/localization/generated/intl/messages_en.dart'
    as english;
import 'package:asteria_app/core/localization/generated/intl/messages_ru.dart'
    as russian;
import 'package:asteria_app/core/localization/generated/l10n.dart';

enum AnakraSystemMessage {
  welcome('anakraWelcomeMessage'),
  serverError('anakraServerError');

  const AnakraSystemMessage(this._key);

  final String _key;

  String localized(AppLocalizations strings) => switch (this) {
    welcome => strings.anakraWelcomeMessage,
    serverError => strings.anakraServerError,
  };
}

// Older profiles store rendered system copy instead of an event identifier.
// Match those exact strings without changing the persisted message contract.
final _legacySystemMessages = <String, AnakraSystemMessage>{
  for (final kind in AnakraSystemMessage.values)
    for (final library in [english.messages, russian.messages])
      (library.messages[kind._key] as String Function())(): kind,
};

extension AnakraSystemMessageLocalization on AnakraChatMessageModel {
  AnakraSystemMessage? get systemKind =>
      isUser ? null : _legacySystemMessages[text];

  String displayText(AppLocalizations strings) =>
      systemKind?.localized(strings) ?? text;
}

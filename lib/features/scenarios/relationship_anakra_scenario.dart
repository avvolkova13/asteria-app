import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/features/anakra_chat/presentation/screens/anakra_chat_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class RelationshipAnakraScenario extends StatelessWidget {
  const RelationshipAnakraScenario({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.select<UserProvider, String?>(
      (user) => user.currentUser?.id,
    );
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    return AnakraChatScreen.freeQuestion(
      key: ValueKey(uid),
      draft: ru
          ? 'Как сказать партнёру, что меня задело, и начать разговор без ссоры?'
          : 'How can I tell my partner what hurt me without starting an argument?',
    );
  }
}

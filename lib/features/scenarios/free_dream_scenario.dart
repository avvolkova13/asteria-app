import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/sonnik/presentation/screens/create_sonnik_initial_screen.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/dream_journal_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'free_attempt.dart';

class FreeDreamScenario extends StatelessWidget {
  const FreeDreamScenario({super.key, required this.onOpenRunes});

  final VoidCallback onOpenRunes;

  Future<bool> _checkAccess(BuildContext context) async {
    final users = context.read<UserProvider>();
    final owner = users.currentUser?.id;
    final access = context.read<MonetizationProvider>();
    var offline = false;
    try {
      await access.refreshForAccess();
    } catch (_) {
      offline = true;
    }
    if (!context.mounted ||
        users.currentUser?.id != owner ||
        ModalRoute.isCurrentOf(context) != true) {
      return false;
    }
    if (!offline &&
        owner != null &&
        access.isCurrentUser(owner) &&
        canUseScenarioRequest(access, 'sonnik')) {
      return true;
    }

    final ru = Localizations.localeOf(context).languageCode == 'ru';
    final showRunes = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialog) => dreamJournalDialog(
        CupertinoAlertDialog(
          title: Text(
            offline
                ? (ru ? 'Не удалось проверить доступ' : 'Couldn’t check access')
                : (ru
                      ? 'Бесплатное толкование сейчас недоступно'
                      : 'Free interpretation is unavailable'),
          ),
          content: Text(
            ru
                ? 'Можно сохранить сон в дневнике или выбрать расклад на трёх рунах.'
                : 'You can save your dream in the journal or explore a three-rune reading.',
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(dialog, false),
              child: Text(ru ? 'Вернуться к сну' : 'Back to my dream'),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(dialog, true),
              child: Text(ru ? 'Открыть три руны' : 'Open three runes'),
            ),
          ],
        ),
      ),
    );
    if (showRunes == true &&
        context.mounted &&
        users.currentUser?.id == owner) {
      onOpenRunes();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) =>
      CreateSonnikInitialScreen(checkScenarioAccess: _checkAccess);
}

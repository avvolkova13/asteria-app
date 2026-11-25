import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dream_journal_screen.dart';

/// Existing links to interpretation history open the account's dream journal.
class CreateSonnikHistoryScreen extends StatelessWidget {
  const CreateSonnikHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final owner = user.currentUser?.id;
    if (owner == null || owner.isEmpty) {
      return SonnikPageScaffold(
        title: Localizations.localeOf(context).languageCode == 'ru'
            ? 'Дневник снов'
            : 'Dream journal',
        child: Center(child: Text(context.l10n.dreamNoData)),
      );
    }
    return DreamJournalScreen(key: ValueKey(owner), owner: owner, user: user);
  }
}

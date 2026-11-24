import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/features/practices/data/practice_notes_store.dart';
import 'package:asteria_app/features/practices/practice_catalog_screen.dart';
import 'package:asteria_app/features/scenarios/scenario_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'practice_notes_screen.dart';

const _personal = 'journal:personal';

class NotesJournalLink extends StatelessWidget {
  const NotesJournalLink({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider?>();
    final owner = user?.currentUser?.id;
    if (user == null || owner == null || owner.isEmpty) {
      return const SizedBox.shrink();
    }
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    return LotusButtons.textIcon(
      style: TextButton.styleFrom(
        foregroundColor: AppColorsDark.linkGold,
        minimumSize: const Size(44, 44),
      ),
      onPressed: () => Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => ListenableBuilder(
            listenable: user,
            builder: (_, __) => user.currentUser?.id == owner
                ? _NotesJournal(owner: owner, user: user)
                : const SizedBox.shrink(),
          ),
        ),
      ),
      icon: const Icon(Icons.edit_note_rounded),
      label: Text(ru ? 'Мои заметки' : 'My notes'),
    );
  }
}

class _NotesJournal extends StatefulWidget {
  const _NotesJournal({required this.owner, required this.user});
  final String owner;
  final UserProvider user;
  @override
  State<_NotesJournal> createState() => _NotesJournalState();
}

class _NotesJournalState extends State<_NotesJournal> {
  late var _entries = const PracticeNotesStore().readJournal(widget.owner);
  bool get _ru => Localizations.localeOf(context).languageCode == 'ru';
  String _source(String id) {
    if (id == _personal) return _ru ? 'Личная заметка' : 'Personal note';
    if (id.startsWith('affirmation:')) {
      final content = di.isRegistered<ContentProvider>()
          ? di.get<ContentProvider>()
          : null;
      final matched = content?.affirmations
          .where((item) => 'affirmation:${item.id}' == id)
          .firstOrNull;
      return matched?.text ?? (_ru ? 'Аффирмация' : 'Affirmation');
    }
    return practiceTitleById(id, _ru) ?? (_ru ? 'Практика' : 'Practice');
  }

  void _refresh() {
    final entries = const PracticeNotesStore().readJournal(widget.owner);
    setState(() {
      _entries = entries;
    });
  }

  Future<void> _open([JournalNote? selected]) async {
    if (widget.user.currentUser?.id != widget.owner) return;
    final source = selected?.practiceId ?? _personal;
    await openPracticeNotes(
      context,
      practiceId: source,
      practiceTitle: _source(source),
      returnToCaller: true,
      initialNoteId: selected?.note.id,
      startNew: selected == null,
    );
    if (mounted && widget.user.currentUser?.id == widget.owner) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return ScenarioPage(
      title: _ru ? 'Мои заметки' : 'My notes',
      scrollable: false,
      footer: AsteriaActionButton(
        text: _ru ? 'Написать заметку' : 'Write a note',
        width: double.infinity,
        onPressed: () => _open(),
      ),
      child: FutureBuilder<List<JournalNote>>(
        future: _entries,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: LotusButtons.text(
                onPressed: _refresh,
                child: Text(context.l10n.retry),
              ),
            );
          }
          final entries = snapshot.data;
          if (entries == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (entries.isEmpty) {
            return Center(
              child: Text(
                _ru
                    ? 'Здесь будут ваши мысли и заметки к практикам.'
                    : 'Keep your thoughts and practice notes here.',
                textAlign: TextAlign.center,
                style: context.textTheme.inverseUrbanistRegular16,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 2,
                ),
                onTap: () => _open(entry),
                title: Text(
                  entry.note.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.inverseUrbanistRegular16,
                ),
                subtitle: Text(
                  '${DateFormat.MMMd(locale).format(entry.note.recordedAt)} · ${_source(entry.practiceId)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.inverseUrbanistRegular14.copyWith(
                    color: AppColorsDark.textSecondary,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColorsDark.textSecondary,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

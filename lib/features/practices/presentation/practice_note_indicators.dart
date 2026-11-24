import 'practice_notes_screen.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/features/practices/data/practice_notes_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

String practiceNoteCountLabel(BuildContext context, int count) {
  if (Localizations.localeOf(context).languageCode != 'ru') {
    return '$count ${count == 1 ? 'note' : 'notes'}';
  }
  final last = count % 10;
  final teens = count % 100 >= 11 && count % 100 <= 14;
  final word = !teens && last == 1
      ? 'заметка'
      : !teens && last >= 2 && last <= 4
      ? 'заметки'
      : 'заметок';
  return '$count $word';
}

/// Counts subscribe only to the current account and reset before an account switch paints.
class PracticeNotesCountBuilder extends StatefulWidget {
  const PracticeNotesCountBuilder({
    super.key,
    required this.practiceId,
    required this.builder,
  });
  final String practiceId;
  final Widget Function(BuildContext context, int count) builder;

  @override
  State<PracticeNotesCountBuilder> createState() =>
      _PracticeNotesCountBuilderState();
}

class _PracticeNotesCountBuilderState extends State<PracticeNotesCountBuilder> {
  String? _owner, _practice;
  Stream<int>? _counts;

  @override
  Widget build(BuildContext context) {
    final owner = context.watch<UserProvider?>()?.currentUser?.id;
    if (owner == null || owner.isEmpty) {
      _owner = null;
      _practice = null;
      _counts = null;
      return widget.builder(context, 0);
    }
    if (_owner != owner || _practice != widget.practiceId) {
      _owner = owner;
      _practice = widget.practiceId;
      _counts = const PracticeNotesStore().watchCount(owner, widget.practiceId);
    }
    return StreamBuilder<int>(
      key: ValueKey((owner, widget.practiceId)),
      stream: _counts,
      builder: (context, snapshot) =>
          widget.builder(context, snapshot.hasError ? 0 : snapshot.data ?? 0),
    );
  }
}

class PracticeNotesMarker extends StatelessWidget {
  const PracticeNotesMarker({super.key, required this.practiceId});
  final String practiceId;

  @override
  Widget build(BuildContext context) => PracticeNotesCountBuilder(
    practiceId: practiceId,
    builder: (context, count) => count == 0
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ClayIcon(
                  Icons.notes_rounded,
                  size: 15,
                  color: AppColorsDark.linkGold,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    practiceNoteCountLabel(context, count),
                    style: context.textTheme.inverseUrbanistRegular14.copyWith(
                      color: AppColorsDark.linkGold,
                    ),
                  ),
                ),
              ],
            ),
          ),
  );
}

/// A separate accessible action for the currently visible card in a swipe deck.
class PracticeDeckNotesAction extends StatelessWidget {
  const PracticeDeckNotesAction({
    super.key,
    required this.practiceId,
    required this.practiceTitle,
  });
  final String practiceId, practiceTitle;
  @override
  Widget build(BuildContext context) {
    if (context.watch<UserProvider?>()?.currentUser?.id.isNotEmpty != true) {
      return const SizedBox.shrink();
    }
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    return Align(
      alignment: Alignment.centerLeft,
      child: PracticeNotesCountBuilder(
        practiceId: practiceId,
        builder: (context, count) => LotusButtons.text(
          onPressed: () => openPracticeNotes(
            context,
            practiceId: practiceId,
            practiceTitle: practiceTitle,
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppColorsDark.linkGold,
            minimumSize: const Size(48, 48),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ClayIcon(
                Icons.edit_note_rounded,
                size: 21,
                color: AppColorsDark.linkGold,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  count == 0
                      ? (ru ? 'Оставить заметку' : 'Write a note')
                      : practiceNoteCountLabel(context, count),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

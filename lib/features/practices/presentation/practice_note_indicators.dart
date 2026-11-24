import 'package:asteria_app/app/providers/user_provider.dart';
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

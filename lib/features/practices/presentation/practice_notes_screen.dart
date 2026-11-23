import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';
import 'package:asteria_app/core/ui_kit/widgets/input_bubble_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/features/practices/data/practice_notes_store.dart';
import 'package:asteria_app/features/scenarios/scenario_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> openPracticeNotes(
  BuildContext context, {
  required String practiceId,
  required String practiceTitle,
}) async {
  final user = context.read<UserProvider?>();
  final owner = user?.currentUser?.id;
  if (user == null || owner == null || owner.isEmpty) return;

  await Navigator.of(context).push<void>(
    CupertinoPageRoute(
      builder: (context) => ListenableBuilder(
        listenable: user,
        builder: (context, _) {
          if (user.currentUser?.id != owner) {
            final ru = Localizations.localeOf(context).languageCode == 'ru';
            return ScenarioPage(
              title: ru ? 'Мои заметки' : 'My notes',
              child: Text(
                ru
                    ? 'Откройте практику из\u00a0текущего аккаунта.'
                    : 'Open the practice from your current account.',
              ),
            );
          }
          return _PracticeNotesScreen(
            user: user,
            ownerId: owner,
            practiceId: practiceId,
            practiceTitle: practiceTitle,
          );
        },
      ),
    ),
  );
}

class _PracticeNotesScreen extends StatefulWidget {
  const _PracticeNotesScreen({
    required this.user,
    required this.ownerId,
    required this.practiceId,
    required this.practiceTitle,
  });

  final UserProvider user;
  final String ownerId;
  final String practiceId;
  final String practiceTitle;

  @override
  State<_PracticeNotesScreen> createState() => _PracticeNotesScreenState();
}

enum _NoteStatus { ready, saved, deleted, writeFailed }

class _PracticeNotesScreenState extends State<_PracticeNotesScreen> {
  static const _store = PracticeNotesStore();
  final _editorKey = GlobalKey();
  final _text = TextEditingController();
  List<PracticeNote> _notes = [];
  PracticeNote? _selected;
  _NoteStatus _status = _NoteStatus.ready;
  bool _loading = true;
  bool _loadFailed = false;
  bool _writing = false;
  bool _showingDialog = false;

  bool get _ru => Localizations.localeOf(context).languageCode == 'ru';
  bool get _ownsNotes => widget.user.currentUser?.id == widget.ownerId;
  bool get _changed => _text.text.trim() != (_selected?.text ?? '');

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final notes = await _store.read(widget.ownerId, widget.practiceId);
      if (!mounted || !_ownsNotes) return;
      setState(() {
        _notes = notes;
        _loadFailed = false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || !_ownsNotes) return;
      setState(() {
        _loadFailed = true;
        _loading = false;
      });
    }
  }

  Future<bool> _confirm(String title, String action) async {
    if (_showingDialog) return false;
    _showingDialog = true;
    try {
      final confirmed = await showCupertinoDialog<bool>(
        context: context,
        useRootNavigator: false,
        builder: (dialog) => CupertinoAlertDialog(
          title: Text(title),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(dialog, false),
              child: Text(dialog.l10n.commonCancel),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(dialog, true),
              child: Text(action),
            ),
          ],
        ),
      );
      return mounted && _ownsNotes && confirmed == true;
    } finally {
      _showingDialog = false;
    }
  }

  Future<bool> _discardChanges() => _confirm(
    _ru ? 'Сбросить изменения?' : 'Discard changes?',
    _ru ? 'Сбросить' : 'Discard',
  );

  Future<void> _select(PracticeNote? note) async {
    if (_writing || note?.id == _selected?.id) return;
    if (_changed && !await _discardChanges()) return;
    if (!mounted || !_ownsNotes) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _selected = note;
      _text.text = note?.text ?? '';
      _status = _NoteStatus.ready;
    });
    final editor = _editorKey.currentContext;
    if (editor != null && editor.mounted) {
      await Scrollable.ensureVisible(
        editor,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 220),
        alignment: .15,
      );
    }
  }

  Future<void> _save() async {
    final text = _text.text.trim();
    if (_writing || !_ownsNotes || !_changed || text.isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _writing = true;
      _status = _NoteStatus.ready;
    });
    try {
      final note = await _store.save(
        ownerId: widget.ownerId,
        practiceId: widget.practiceId,
        text: text,
        noteId: _selected?.id,
      );
      if (!mounted || !_ownsNotes) return;
      setState(() {
        _notes = [..._notes.where((entry) => entry.id != note.id), note]
          ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
        _selected = null;
        _text.clear();
        _status = _NoteStatus.saved;
      });
    } catch (_) {
      if (mounted && _ownsNotes) {
        setState(() => _status = _NoteStatus.writeFailed);
      }
    } finally {
      if (mounted) setState(() => _writing = false);
    }
  }

  Future<void> _delete(PracticeNote note) async {
    if (_writing ||
        !await _confirm(
          _ru ? 'Удалить заметку?' : 'Delete this note?',
          _ru ? 'Удалить' : 'Delete',
        )) {
      return;
    }
    if (!mounted || !_ownsNotes) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _writing = true;
      _status = _NoteStatus.ready;
    });
    try {
      await _store.delete(widget.ownerId, widget.practiceId, note.id);
      if (!mounted || !_ownsNotes) return;
      setState(() {
        _notes = _notes.where((entry) => entry.id != note.id).toList();
        _selected = null;
        _text.clear();
        _status = _NoteStatus.deleted;
      });
    } catch (_) {
      if (mounted && _ownsNotes) {
        setState(() => _status = _NoteStatus.writeFailed);
      }
    } finally {
      if (mounted) setState(() => _writing = false);
    }
  }

  String _date(DateTime date) =>
      MaterialLocalizations.of(context).formatFullDate(date);

  @override
  Widget build(BuildContext context) {
    final ru = _ru;
    final selected = _selected;
    final changed = _changed;
    final status = switch (_status) {
      _NoteStatus.ready => null,
      _NoteStatus.saved => ru ? 'Заметка сохранена.' : 'Note saved.',
      _NoteStatus.deleted => ru ? 'Заметка удалена.' : 'Note deleted.',
      _NoteStatus.writeFailed =>
        ru
            ? 'Не удалось обновить заметку. Попробуйте ещё раз.'
            : 'Could not update the note. Please try again.',
    };
    return PopScope<void>(
      canPop: !_writing && !changed,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _writing || !changed) return;
        if (await _discardChanges() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: ScenarioPage(
        title: ru ? 'Мои заметки' : 'My notes',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.practiceTitle,
              style: context.textTheme.inversePlayfairSemiBold20,
            ),
            const SizedBox(height: 6),
            Text(
              ru
                  ? 'Заметки хранятся на\u00a0этом устройстве.'
                  : 'Notes are stored on this device.',
              style: context.textTheme.inverseUrbanistRegular14,
            ),
            const SizedBox(height: 18),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_loadFailed) ...[
              Text(
                ru
                    ? 'Не удалось открыть заметки.'
                    : 'Could not open your notes.',
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: LotusButtons.text(
                  onPressed: () {
                    setState(() => _loading = true);
                    _load();
                  },
                  child: Text(context.l10n.retry),
                ),
              ),
            ] else ...[
              if (selected != null) ...[
                Text(
                  _date(selected.recordedAt),
                  style: context.textTheme.inverseUrbanistRegular14,
                ),
                const SizedBox(height: 8),
              ],
              InputBubbleSurface(
                key: _editorKey,
                surfaceBrightness: Brightness.dark,
                child: TextField(
                  controller: _text,
                  readOnly: _writing,
                  onChanged: (_) => setState(() => _status = _NoteStatus.ready),
                  minLines: 4,
                  maxLines: 7,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  style: context.textTheme.inverseUrbanistRegular16,
                  decoration: InputDecoration(
                    hintText: ru
                        ? 'Что хочется запомнить?'
                        : 'What would you like to remember?',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AsteriaActionButton(
                text: ru ? 'Сохранить заметку' : 'Save note',
                onPressed: !_writing && changed && _text.text.trim().isNotEmpty
                    ? _save
                    : null,
                width: double.infinity,
              ),
              if (status != null) ...[
                const SizedBox(height: 8),
                Semantics(liveRegion: true, child: Text(status)),
              ],
              if (selected != null)
                Wrap(
                  spacing: 8,
                  children: [
                    LotusButtons.text(
                      onPressed: _writing ? null : () => _select(null),
                      child: Text(ru ? 'Новая заметка' : 'New note'),
                    ),
                    LotusButtons.text(
                      onPressed: _writing ? null : () => _delete(selected),
                      child: Text(ru ? 'Удалить заметку' : 'Delete note'),
                    ),
                  ],
                ),
              if (_notes.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  ru ? 'Сохранённые заметки' : 'Saved notes',
                  style: context.textTheme.inversePlayfairSemiBold20,
                ),
                const SizedBox(height: 8),
                for (final note in _notes)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    selected: note.id == selected?.id,
                    textColor: AppColors.textInverse,
                    selectedColor: AppColors.cardTinted,
                    title: Text(
                      note.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(_date(note.recordedAt)),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.cardTinted,
                    ),
                    onTap: _writing ? null : () => _select(note),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

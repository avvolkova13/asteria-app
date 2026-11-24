import 'package:asteria_app/core/ui_kit/widgets/journal_actions.dart';
import 'package:asteria_app/core/ui_kit/widgets/dictation_button.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:provider/provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/features/sonnik/data/dream_journal.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<DreamEntry?> openDreamJournal(
  BuildContext context,
  UserProvider user,
) async {
  final owner = user.currentUser?.id;
  if (owner == null || owner.isEmpty) return null;
  FocusManager.instance.primaryFocus?.unfocus();
  final page = InheritedTheme.captureAll(
    context,
    ListenableBuilder(
      listenable: user,
      builder: (context, _) => user.currentUser?.id == owner
          ? DreamJournalScreen(owner: owner)
          : const SizedBox.shrink(),
    ),
  );
  final text = await Navigator.of(
    context,
  ).push<DreamEntry>(MaterialPageRoute(builder: (_) => page));
  return user.currentUser?.id == owner ? text : null;
}

class DreamCaptureButton extends StatelessWidget {
  const DreamCaptureButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AsteriaActionButton(
      text: context.l10n.adDecode,
      gold: true,
      width: double.infinity,
      onPressed: () async {
        final user = context.read<UserProvider?>();
        if (user == null || user.currentUser?.id.isNotEmpty != true) {
          CreateSonnikInitialRoute.push(context);
          return;
        }
        final draft = await openDreamJournal(context, user);
        if (!context.mounted || draft == null) return;
        CreateSonnikInitialRoute.push(
          context,
          params: CreateSonnikInitialRouteParams(initialEntry: draft),
        );
      },
    );
  }
}

class DreamJournalScreen extends StatefulWidget {
  const DreamJournalScreen({super.key, required this.owner});

  final String owner;

  @override
  State<DreamJournalScreen> createState() => _DreamJournalScreenState();
}

class _DreamJournalScreenState extends State<DreamJournalScreen> {
  final _scroll = ScrollController();
  late final _journal = DreamJournal(widget.owner);
  final _text = TextEditingController();
  final _focus = FocusNode();
  List<DreamEntry> _entries = [];
  DreamEntry? _selected;
  bool _loading = true;
  bool _busy = false;
  bool _dictating = false;
  bool _loadFailed = false;
  bool _writeFailed = false;

  bool get _russian => Localizations.localeOf(context).languageCode == 'ru';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _focus.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final entries = await _journal.read();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _loadFailed = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _changed => _text.text.trim() != (_selected?.text ?? '');

  Future<bool> _discardChanges() async =>
      await showCupertinoDialog<bool>(
        context: context,
        builder: (dialog) => CupertinoAlertDialog(
          title: Text(_russian ? 'Сбросить изменения?' : 'Discard changes?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(dialog, false),
              child: Text(dialog.l10n.commonCancel),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(dialog, true),
              child: Text(_russian ? 'Сбросить' : 'Discard'),
            ),
          ],
        ),
      ) ==
      true;

  Future<void> _select(DreamEntry? entry) async {
    if (_busy || _dictating || (entry != null && entry.id == _selected?.id)) {
      return;
    }
    if (_changed && !await _discardChanges()) return;
    if (!mounted) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _selected = entry;
      _text.text = entry?.text ?? '';
      _writeFailed = false;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
    if (entry == null) _focus.requestFocus();
  }

  Future<void> _save() async {
    if (_busy || _text.text.trim().isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _busy = true;
      _writeFailed = false;
    });
    try {
      final entry = await _journal.save(_text.text, entry: _selected);
      if (!mounted) return;
      setState(() {
        _entries = [..._entries.where((saved) => saved.id != entry.id), entry]
          ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
        _selected = entry;
        _text.text = entry.text;
      });
    } catch (_) {
      if (mounted) setState(() => _writeFailed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(DreamEntry entry) async {
    final ru = _russian;
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialog) => CupertinoAlertDialog(
        title: Text(ru ? 'Удалить запись о сне?' : 'Delete this dream entry?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(dialog.l10n.commonCancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(ru ? 'Удалить' : 'Delete'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() {
      _busy = true;
      _writeFailed = false;
    });
    try {
      await _journal.delete(entry.id);
      if (!mounted) return;
      setState(() {
        _entries = _entries.where((saved) => saved.id != entry.id).toList();
        if (_selected?.id == entry.id) {
          _selected = null;
          _text.clear();
        }
      });
    } catch (_) {
      if (mounted) setState(() => _writeFailed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ru = _russian;
    final saved = _selected;
    final text = _text.text.trim();
    final canEdit = !_busy && !_loading && !_loadFailed;
    final date = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return PopScope<DreamEntry>(
      canPop: !_busy && !_dictating && !_changed,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _busy || _dictating || !_changed) return;
        if (await _discardChanges() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: SonnikPageScaffold(
        title: ru ? 'Дневник снов' : 'Dream journal',
        resizeToAvoidBottomInset: true,
        child: ListView(
          controller: _scroll,
          padding: EdgeInsets.fromLTRB(
            16,
            6,
            16,
            28 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_loadFailed) ...[
              Text(
                ru
                    ? 'Не удалось открыть дневник.'
                    : 'Could not open the journal.',
              ),
              LotusButtons.text(
                onPressed: () {
                  setState(() => _loading = true);
                  _load();
                },
                child: Text(context.l10n.retry),
              ),
            ] else ...[
              Text(
                ru
                    ? 'Записи хранятся на\u00a0этом устройстве.'
                    : 'Entries are stored on this device.',
                style: context.textTheme.inverseUrbanistRegular14,
              ),
              const SizedBox(height: 8),
              JournalAddButton(
                label: ru ? 'Добавить сон' : 'Add dream',
                onPressed: canEdit && !_dictating ? () => _select(null) : null,
              ),
              const SizedBox(height: 8),
              if (saved != null) ...[
                Text(
                  date.format(saved.recordedAt),
                  style: context.textTheme.inverseUrbanistRegular14,
                ),
                const SizedBox(height: 8),
              ],
              SonnikTextArea(
                controller: _text,
                focusNode: _focus,
                readOnly: _busy,
                onChanged: (_) => setState(() => _writeFailed = false),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: DictationButton(
                  controller: _text,
                  enabled: canEdit,
                  showLabel: true,
                  onActiveChanged: (active) =>
                      setState(() => _dictating = active),
                ),
              ),
              if (_writeFailed) ...[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    ru
                        ? 'Не удалось обновить запись. Попробуйте ещё раз.'
                        : 'Could not update the entry. Please try again.',
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (saved != null && saved.text == text)
                SonnikGradientButton(
                  text: ru ? 'Спросить Ливею' : 'Ask Liveya',
                  onPressed: canEdit && !_dictating
                      ? () => Navigator.pop(context, saved)
                      : null,
                )
              else
                SonnikGradientButton(
                  text: ru ? 'Сохранить сон' : 'Save dream',
                  onPressed: canEdit && !_dictating && text.isNotEmpty
                      ? _save
                      : null,
                ),
              if (_entries.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  ru ? 'Мои сны' : 'My dreams',
                  style: context.textTheme.inversePlayfairSemiBold20,
                ),
                const SizedBox(height: 8),
                for (final entry in _entries)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      entry.text,
                      style: context.textTheme.inverseUrbanistRegular16,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      date.format(entry.recordedAt),
                      style: context.textTheme.inverseUrbanistRegular14
                          .copyWith(color: AppColors.cardTinted),
                    ),
                    trailing: JournalEntryMenu(
                      label: ru ? 'Действия с записью' : 'Entry actions',
                      deleteLabel: ru ? 'Удалить запись' : 'Delete entry',
                      onDelete: !canEdit || _dictating
                          ? null
                          : () => _delete(entry),
                    ),
                    onTap: !canEdit || _dictating ? null : () => _select(entry),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

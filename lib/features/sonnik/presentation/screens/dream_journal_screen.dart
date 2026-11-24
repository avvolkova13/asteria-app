import 'package:asteria_app/core/ui_kit/widgets/journal_actions.dart';
import 'dream_entry_screen.dart';
import '../widgets/dream_journal_layout.dart';
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
  UserProvider user, {
  bool startNew = false,
}) async {
  final owner = user.currentUser?.id;
  if (owner == null || owner.isEmpty) return null;
  if (startNew) return openDreamEntry(context, user, owner: owner);
  FocusManager.instance.primaryFocus?.unfocus();
  final page = InheritedTheme.captureAll(
    context,
    ListenableBuilder(
      listenable: user,
      builder: (context, _) => user.currentUser?.id == owner
          ? DreamJournalScreen(owner: owner, user: user)
          : const SizedBox.shrink(),
    ),
  );
  final text = await Navigator.of(
    context,
  ).push<DreamEntry>(MaterialPageRoute(builder: (_) => page));
  return user.currentUser?.id == owner ? text : null;
}

Future<void> _showDreams(BuildContext context, {required bool write}) async {
  final user = context.read<UserProvider?>();
  final owner = user?.currentUser?.id;
  if (user == null || owner == null || owner.isEmpty) {
    CreateSonnikInitialRoute.push(context);
    return;
  }
  final entry = await openDreamJournal(context, user, startNew: write);
  if (!context.mounted || user.currentUser?.id != owner || entry == null) {
    return;
  }
  CreateSonnikInitialRoute.push(
    context,
    params: CreateSonnikInitialRouteParams(initialEntry: entry, ownerId: owner),
  );
}

class DreamJournalLink extends StatelessWidget {
  const DreamJournalLink({super.key});

  @override
  Widget build(BuildContext context) {
    final owner = context.watch<UserProvider?>()?.currentUser?.id;
    if (owner == null || owner.isEmpty) return const SizedBox.shrink();
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    return LotusButtons.textIcon(
      style: TextButton.styleFrom(
        foregroundColor: AppColorsDark.linkGold,
        minimumSize: const Size(44, 44),
      ),
      onPressed: () => _showDreams(context, write: false),
      icon: const Icon(Icons.menu_book_rounded, size: 19),
      label: Text(ru ? 'Дневник снов' : 'Dream journal'),
    );
  }
}

class DreamCaptureButton extends StatelessWidget {
  const DreamCaptureButton({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      AsteriaActionButton(
        text: context.l10n.adDecode,
        gold: true,
        width: double.infinity,
        onPressed: () => _showDreams(context, write: true),
      ),
      const DreamJournalLink(),
    ],
  );
}

class DreamJournalScreen extends StatefulWidget {
  const DreamJournalScreen({
    super.key,
    required this.owner,
    required this.user,
  });
  final String owner;
  final UserProvider user;
  @override
  State<DreamJournalScreen> createState() => _DreamJournalScreenState();
}

class _DreamJournalScreenState extends State<DreamJournalScreen> {
  late final _journal = DreamJournal(widget.owner);
  List<DreamEntry> _entries = [];
  bool _loading = true, _failed = false, _busy = false, _opening = false;
  bool get _owns => widget.user.currentUser?.id == widget.owner;
  bool get _ru => Localizations.localeOf(context).languageCode == 'ru';
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final entries = await _journal.read();
      if (mounted && _owns) {
        setState(() {
          _entries = entries;
          _failed = false;
        });
      }
    } catch (_) {
      if (mounted && _owns) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open([DreamEntry? entry]) async {
    if (_busy || _opening || !_owns) return;
    _opening = true;
    final chosen = await openDreamEntry(
      context,
      widget.user,
      owner: widget.owner,
      entry: entry,
    );
    _opening = false;
    if (!mounted || !_owns) return;
    if (chosen != null) {
      Navigator.pop(context, chosen);
    } else {
      await _load();
    }
  }

  Future<void> _delete(DreamEntry entry) async {
    if (_busy || !_owns) return;
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialog) => dreamJournalDialog(
        CupertinoAlertDialog(
          title: Text(
            _ru ? 'Удалить запись о сне?' : 'Delete this dream entry?',
          ),
          content: Text(
            _ru ? 'Восстановить её не получится.' : 'This cannot be undone.',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(dialog, false),
              child: Text(dialog.l10n.commonCancel),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(dialog, true),
              child: Text(_ru ? 'Удалить' : 'Delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || !_owns || confirmed != true) return;
    setState(() => _busy = true);
    try {
      await _journal.delete(entry.id);
      if (mounted && _owns) await _load();
    } catch (_) {
      if (mounted && _owns) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ru = _ru;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DreamJournalScaffold(
      title: ru ? 'Дневник снов' : 'Dream journal',
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AsteriaActionButton(
            text: ru ? 'Записать сон' : 'Write a dream',
            width: double.infinity,
            onPressed: _busy ? null : () => _open(),
          ),
          const SizedBox(height: 10),
          Text(
            ru
                ? 'Записи хранятся на этом устройстве'
                : 'Entries stay on this device',
            style: context.textTheme.inverseUrbanistRegular14.copyWith(
              color: AppColorsDark.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              children: [
                if (_failed) ...[
                  Text(
                    ru
                        ? 'Не удалось обновить дневник.'
                        : 'Could not update the journal.',
                  ),
                  LotusButtons.text(
                    onPressed: _load,
                    child: Text(context.l10n.retry),
                  ),
                ],
                if (_entries.isEmpty && !_failed)
                  Padding(
                    padding: const EdgeInsets.only(top: 56),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.nights_stay_outlined,
                          size: 42,
                          color: AppColorsDark.linkGold,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          ru
                              ? 'Сохраните свой первый сон'
                              : 'Keep your first dream',
                          style: context.textTheme.inversePlayfairSemiBold20,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          ru
                              ? 'Запишите образы и чувства, пока они свежи в памяти. К расшифровке можно вернуться позже.'
                              : 'Capture the images and feelings while they are fresh. You can explore their meaning later.',
                          style: context.textTheme.inverseUrbanistRegular16
                              .copyWith(color: AppColorsDark.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                for (final (index, entry) in _entries.indexed) ...[
                  if (index == 0 ||
                      !DateUtils.isSameDay(
                        entry.recordedAt,
                        _entries[index - 1].recordedAt,
                      ))
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 8),
                      child: Text(
                        DateFormat.yMMMd(locale).format(entry.recordedAt),
                        style: context.textTheme.inverseUrbanistMedium16
                            .copyWith(color: AppColorsDark.linkGold),
                      ),
                    ),
                  SonnikGlassPanel(
                    padding: EdgeInsets.zero,
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _busy ? null : () => _open(entry),
                            borderRadius: BorderRadius.circular(24),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 18, 0, 18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.text.replaceAll(RegExp(r'\s+'), ' '),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: context
                                        .textTheme
                                        .inverseUrbanistRegular16,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Text(
                                        DateFormat.Hm(
                                          locale,
                                        ).format(entry.recordedAt),
                                        style: context
                                            .textTheme
                                            .inverseUrbanistRegular14
                                            .copyWith(
                                              color:
                                                  AppColorsDark.textSecondary,
                                            ),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.chevron_right,
                                        size: 20,
                                        color: AppColorsDark.textSecondary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        JournalEntryMenu(
                          label: ru ? 'Действия с записью' : 'Entry actions',
                          deleteLabel: ru ? 'Удалить запись' : 'Delete entry',
                          onDelete: _busy ? null : () => _delete(entry),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }
}

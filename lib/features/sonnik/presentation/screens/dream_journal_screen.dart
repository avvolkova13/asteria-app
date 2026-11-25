import 'create_sonnik_initial_screen.dart';
import 'create_sonnik_loaded_screen.dart';

import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';

import '../widgets/dream_journal_layout.dart';

import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';
import 'package:provider/provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/features/sonnik/data/dream_journal.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';

Future<void> _openOwnedPage(
  BuildContext context,
  UserProvider user,
  String owner,
  Widget child,
) async {
  if (user.currentUser?.id != owner) return;
  FocusManager.instance.primaryFocus?.unfocus();
  final page = InheritedTheme.captureAll(
    context,
    ChangeNotifierProvider<UserProvider>.value(
      value: user,
      child: Consumer<UserProvider>(
        builder: (context, account, _) =>
            account.currentUser?.id == owner ? child : const SizedBox.shrink(),
      ),
    ),
  );
  await Navigator.of(
    context,
  ).push<void>(MaterialPageRoute(builder: (_) => page));
}

Future<void> openDreamJournal(
  BuildContext context,
  UserProvider user, {
  Future<bool> Function(BuildContext)? checkScenarioAccess,
}) async {
  final owner = user.currentUser?.id;
  if (owner == null || owner.isEmpty) return;
  await _openOwnedPage(
    context,
    user,
    owner,
    DreamJournalScreen(
      owner: owner,
      user: user,
      checkScenarioAccess: checkScenarioAccess,
    ),
  );
}

class DreamJournalLink extends StatelessWidget {
  const DreamJournalLink({super.key});
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider?>();
    if (user == null || user.currentUser?.id.isNotEmpty != true) {
      return const SizedBox.shrink();
    }
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    return LotusButtons.textIcon(
      style: TextButton.styleFrom(
        foregroundColor: AppColorsDark.linkGold,
        minimumSize: const Size(44, 44),
      ),
      onPressed: () => openDreamJournal(context, user),
      icon: const Icon(Icons.menu_book_rounded, size: 19),
      label: Text(ru ? 'Дневник снов' : 'Dream journal'),
    );
  }
}

class DreamJournalScreen extends StatefulWidget {
  const DreamJournalScreen({
    super.key,
    required this.owner,
    required this.user,
    this.checkScenarioAccess,
  });
  final Future<bool> Function(BuildContext)? checkScenarioAccess;
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
  int _loadVersion = 0;
  String? _revealedEntryId;
  List<SonnikModel>? _history;
  @override
  void initState() {
    super.initState();
    widget.user.addListener(_onAccountChanged);
    _load();
  }

  @override
  void dispose() {
    widget.user.removeListener(_onAccountChanged);
    super.dispose();
  }

  void _onAccountChanged() {
    if (!_owns) {
      _loadVersion++;
      _history = null;
      setState(() => _entries = []);
    } else if (!identical(_history, widget.user.currentUser?.sonnikHistory)) {
      _load();
    }
  }

  Future<void> _load() async {
    final version = ++_loadVersion;
    if (!_owns) return;
    _history = widget.user.currentUser?.sonnikHistory;
    try {
      final entries = await _journal.read(history: _history ?? const []);
      if (mounted && _owns && version == _loadVersion) {
        setState(() {
          _entries = entries;
          _failed = false;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted && _owns && version == _loadVersion) {
        setState(() {
          _failed = true;
          _loading = false;
        });
      }
    }
  }

  Future<void> _open([DreamEntry? entry, SonnikModel? reading]) async {
    if (_busy || _opening || !_owns) return;
    if (_revealedEntryId != null) setState(() => _revealedEntryId = null);
    _opening = true;
    try {
      final result =
          reading ??
          (entry?.historyOnly == true ? entry!.interpretations.first : null);
      await _openOwnedPage(
        context,
        widget.user,
        widget.owner,
        result == null
            ? CreateSonnikInitialScreen(
                initialEntry: entry,
                entryOwnerId: widget.owner,
                checkScenarioAccess: widget.checkScenarioAccess,
                fromJournal: true,
                journalRoute: ModalRoute.of(context),
              )
            : CreateSonnikLoadedScreen(
                sonnik: result,
                ownerId: widget.owner,
                fromJournal: true,
                journalRoute: ModalRoute.of(context),
                checkScenarioAccess: widget.checkScenarioAccess,
              ),
      );
      if (mounted && _owns) await _load();
    } finally {
      _opening = false;
    }
  }

  Future<void> _delete(DreamEntry entry) async {
    if (_busy || !_owns) return;
    setState(() => _revealedEntryId = null);
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialog) => dreamJournalDialog(
        CupertinoAlertDialog(
          title: Text(
            _ru ? 'Удалить запись о сне?' : 'Delete this dream entry?',
          ),
          content: Text(
            entry.interpretations.isEmpty
                ? (_ru
                      ? 'Восстановить её не получится.'
                      : 'This cannot be undone.')
                : (_ru
                      ? 'Запись и расшифровка исчезнут из дневника на этом устройстве.'
                      : 'The entry and its interpretation will be removed from the journal on this device.'),
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
    final tablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    final empty = tablet && !_loading && !_failed && _entries.isEmpty;
    final write = AsteriaActionButton(
      text: ru ? 'Записать сон' : 'Write a dream',
      width: double.infinity,
      onPressed: _busy ? null : () => _open(),
    );
    return DreamJournalScaffold(
      title: ru ? 'Дневник снов' : 'Dream journal',
      footer: empty ? null : write,
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
                    padding: EdgeInsets.only(
                      top: empty ? MediaQuery.sizeOf(context).height * .13 : 56,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Column(
                          children: [
                            if (empty)
                              const SonnikLiveyaAvatar(size: 180)
                            else
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
                              style:
                                  context.textTheme.inversePlayfairSemiBold20,
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
                            if (empty) ...[const SizedBox(height: 24), write],
                          ],
                        ),
                      ),
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
                  _DreamEntrySwipe(
                    key: ValueKey(entry.id),
                    revealed: _revealedEntryId == entry.id,
                    onReveal: (revealed) => setState(() {
                      _revealedEntryId = revealed ? entry.id : null;
                    }),
                    deleteLabel: ru ? 'Удалить запись' : 'Delete entry',
                    onDelete: _busy ? null : () => _delete(entry),
                    child: SonnikGlassPanel(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            button: true,
                            child: InkWell(
                              onTap: _busy ? null : () => _open(entry),
                              borderRadius: BorderRadius.circular(24),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  14,
                                  16,
                                  12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            entry.text.replaceAll(
                                              RegExp(r'\s+'),
                                              ' ',
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: context
                                                .textTheme
                                                .inverseUrbanistRegular16,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            [
                                              DateFormat.Hm(
                                                locale,
                                              ).format(entry.recordedAt),
                                              if (entry.historyOnly)
                                                ru
                                                    ? 'Расшифровка Ливеи'
                                                    : 'Liveya’s interpretation',
                                            ].join(' · '),
                                            style: context
                                                .textTheme
                                                .inverseUrbanistRegular14
                                                .copyWith(
                                                  color: AppColorsDark
                                                      .textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.chevron_right,
                                      size: 22,
                                      color: AppColorsDark.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (!entry.historyOnly)
                            for (final reading in entry.interpretations)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  bottom: 4,
                                ),
                                child: LotusButtons.text(
                                  onPressed: _busy
                                      ? null
                                      : () => _open(entry, reading),
                                  child: Text(
                                    entry.interpretations.length == 1
                                        ? (ru
                                              ? 'Открыть расшифровку'
                                              : 'Read interpretation')
                                        : reading.title,
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }
}

class _DreamEntrySwipe extends StatefulWidget {
  const _DreamEntrySwipe({
    super.key,
    required this.revealed,
    required this.onReveal,
    required this.deleteLabel,
    required this.onDelete,
    required this.child,
  });

  final bool revealed;
  final ValueChanged<bool> onReveal;
  final String deleteLabel;
  final VoidCallback? onDelete;
  final Widget child;

  @override
  State<_DreamEntrySwipe> createState() => _DreamEntrySwipeState();
}

class _DreamEntrySwipeState extends State<_DreamEntrySwipe> {
  static const _actionWidth = 72.0;
  double? _dragOffset;

  void _settle(bool revealed) {
    setState(() => _dragOffset = null);
    widget.onReveal(revealed);
  }

  @override
  Widget build(BuildContext context) {
    final canDelete = widget.onDelete != null;
    final offset = _dragOffset ?? (widget.revealed ? _actionWidth : 0.0);
    return Semantics(
      customSemanticsActions: !canDelete || widget.revealed
          ? null
          : {
              CustomSemanticsAction(label: widget.deleteLabel):
                  widget.onDelete!,
            },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: canDelete
            ? (_) {
                setState(
                  () => _dragOffset = widget.revealed ? _actionWidth : 0,
                );
              }
            : null,
        onHorizontalDragUpdate: canDelete
            ? (details) {
                setState(
                  () =>
                      _dragOffset = ((_dragOffset ?? offset) - details.delta.dx)
                          .clamp(0.0, _actionWidth),
                );
              }
            : null,
        onHorizontalDragEnd: canDelete
            ? (details) {
                final velocity = details.primaryVelocity ?? 0;
                _settle(
                  velocity.abs() > 250
                      ? velocity < 0
                      : (_dragOffset ?? offset) >= _actionWidth / 2,
                );
              }
            : null,
        onHorizontalDragCancel: canDelete
            ? () => _settle(widget.revealed)
            : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              if (offset > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  width: _actionWidth,
                  child: ExcludeSemantics(
                    excluding: !widget.revealed,
                    child: ColoredBox(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Center(
                        child: IconButton(
                          tooltip: widget.deleteLabel,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          onPressed: widget.revealed ? widget.onDelete : null,
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ),
                    ),
                  ),
                ),
              TweenAnimationBuilder<double>(
                tween: Tween(end: offset),
                duration:
                    _dragOffset != null ||
                        MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Transform.translate(
                  offset: Offset(-value, 0),
                  child: child,
                ),
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

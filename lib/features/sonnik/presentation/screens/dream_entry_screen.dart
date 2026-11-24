import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';
import 'package:asteria_app/core/ui_kit/widgets/dictation_button.dart';
import 'package:asteria_app/core/ui_kit/widgets/input_bubble_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/features/sonnik/data/dream_journal.dart';
import '../widgets/dream_journal_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<DreamEntry?> openDreamEntry(
  BuildContext context,
  UserProvider user, {
  required String owner,
  DreamEntry? entry,
}) async {
  if (user.currentUser?.id != owner) return null;
  FocusManager.instance.primaryFocus?.unfocus();
  final page = InheritedTheme.captureAll(
    context,
    ListenableBuilder(
      listenable: user,
      builder: (_, __) => user.currentUser?.id == owner
          ? DreamEntryScreen(owner: owner, user: user, entry: entry)
          : const SizedBox.shrink(),
    ),
  );
  final result = await Navigator.of(
    context,
  ).push<DreamEntry>(MaterialPageRoute(builder: (_) => page));
  return user.currentUser?.id == owner ? result : null;
}

class DreamEntryScreen extends StatefulWidget {
  const DreamEntryScreen({
    super.key,
    required this.owner,
    required this.user,
    this.entry,
  });
  final String owner;
  final UserProvider user;
  final DreamEntry? entry;
  @override
  State<DreamEntryScreen> createState() => _DreamEntryScreenState();
}

class _DreamEntryScreenState extends State<DreamEntryScreen> {
  late final _journal = DreamJournal(widget.owner);
  late final _text = TextEditingController(text: widget.entry?.text ?? '');
  final _focus = FocusNode();
  late DreamEntry? _entry = widget.entry;
  late bool _editing = widget.entry == null;
  bool _busy = false, _dictating = false, _failed = false, _asking = false;
  bool get _owns => widget.user.currentUser?.id == widget.owner;
  bool get _changed => _text.text.trim() != (_entry?.text ?? '');
  bool get _ru => Localizations.localeOf(context).languageCode == 'ru';
  @override
  void initState() {
    super.initState();
    _text.addListener(_update);
  }

  void _update() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _text.removeListener(_update);
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<bool> _save() async {
    if (_busy || _dictating || !_owns || _text.text.trim().isEmpty) {
      return false;
    }
    _focus.unfocus();
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final entry = await _journal.save(_text.text, entry: _entry);
      if (!mounted || !_owns) return false;
      setState(() {
        _entry = entry;
        _text.text = entry.text;
        _editing = false;
      });
      return true;
    } catch (_) {
      if (mounted && _owns) setState(() => _failed = true);
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _interpret() async {
    if (_busy || _dictating || !_owns || _text.text.trim().isEmpty) return;
    if (_changed && !await _save()) return;
    if (mounted && _owns && _entry != null) Navigator.pop(context, _entry);
  }

  Future<void> _exit() async {
    if (_asking || _busy || _dictating || !_owns) return;
    _asking = true;
    final choice = await showCupertinoDialog<String>(
      context: context,
      builder: (dialog) => dreamJournalDialog(
        CupertinoAlertDialog(
          title: Text(_ru ? 'Сохранить изменения?' : 'Save your changes?'),
          content: Text(
            _ru
                ? 'Ваш сон ещё не сохранён.'
                : 'Your dream has not been saved yet.',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(dialog, 'stay'),
              child: Text(_ru ? 'Продолжить редактирование' : 'Keep editing'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(dialog, 'discard'),
              child: Text(_ru ? 'Сбросить' : 'Discard'),
            ),
            if (_text.text.trim().isNotEmpty)
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(dialog, 'save'),
                child: Text(_ru ? 'Сохранить' : 'Save'),
              ),
          ],
        ),
      ),
    );
    _asking = false;
    if (!mounted || !_owns) return;
    if (choice == 'discard' || (choice == 'save' && await _save())) {
      if (mounted && _owns) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ru = _ru;
    final entry = _entry;
    final date = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return PopScope<DreamEntry>(
      canPop: !_busy && !_dictating && !_changed,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_dictating) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _ru
                    ? 'Завершите диктовку, чтобы выйти.'
                    : 'Finish dictation before leaving.',
              ),
            ),
          );
        } else if (_changed) {
          _exit();
        }
      },
      child: DreamJournalScaffold(
        title: _editing
            ? (entry == null
                  ? (ru ? 'Новый сон' : 'New dream')
                  : (ru ? 'Редактирование' : 'Edit dream'))
            : (ru ? 'Мой сон' : 'My dream'),
        footer: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_failed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    ru
                        ? 'Не удалось сохранить. Текст остался здесь — попробуйте ещё раз.'
                        : 'Could not save. Your text is still here; please try again.',
                  ),
                ),
              ),
            AsteriaActionButton(
              text: _editing
                  ? (entry == null
                        ? (ru ? 'Сохранить сон' : 'Save dream')
                        : (ru ? 'Сохранить изменения' : 'Save changes'))
                  : (ru ? 'Расшифровать сон' : 'Interpret dream'),
              width: double.infinity,
              isLoading: _busy,
              onPressed:
                  _busy ||
                      _dictating ||
                      (_editing && (!_changed || _text.text.trim().isEmpty))
                  ? null
                  : () {
                      if (_editing) {
                        _save();
                      } else {
                        _interpret();
                      }
                    },
            ),
            if (_editing && _text.text.trim().isNotEmpty)
              LotusButtons.textIcon(
                icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                label: Text(
                  _changed
                      ? (ru ? 'Сохранить и расшифровать' : 'Save and interpret')
                      : (ru ? 'Расшифровать сон' : 'Interpret dream'),
                ),
                onPressed: _busy || _dictating ? null : _interpret,
              ),
          ],
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    date.format(entry?.recordedAt ?? DateTime.now()),
                    style: context.textTheme.inverseUrbanistMedium16.copyWith(
                      color: AppColorsDark.linkGold,
                    ),
                  ),
                ),
                if (!_editing)
                  LotusButtons.text(
                    onPressed: () {
                      setState(() => _editing = true);
                      _focus.requestFocus();
                    },
                    child: Text(ru ? 'Изменить' : 'Edit'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_editing) ...[
              Text(
                ru ? 'Что вам приснилось?' : 'What did you dream?',
                style: context.textTheme.inversePlayfairSemiBold20,
              ),
              const SizedBox(height: 16),
              InputBubbleSurface(
                surfaceBrightness: Brightness.dark,
                child: TextField(
                  controller: _text,
                  focusNode: _focus,
                  autofocus: entry == null,
                  readOnly: _busy || _dictating,
                  minLines: MediaQuery.viewInsetsOf(context).bottom > 0 ? 3 : 5,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: context.textTheme.inverseUrbanistRegular16.copyWith(
                    height: 1.55,
                  ),
                  cursorColor: AppColorsDark.linkGold,
                  decoration: InputDecoration(
                    hintText: ru
                        ? 'Место, люди, образы… Что вы чувствовали?'
                        : 'Places, people, images… How did you feel?',
                    hintStyle: context.textTheme.inverseUrbanistRegular16
                        .copyWith(color: AppColorsDark.textSecondary),
                    contentPadding: const EdgeInsets.all(18),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: DictationButton(
                  controller: _text,
                  enabled: !_busy,
                  showLabel: true,
                  onActiveChanged: (active) {
                    if (mounted) setState(() => _dictating = active);
                  },
                ),
              ),
            ] else ...[
              Semantics(
                liveRegion: true,
                child: Text(
                  ru ? 'Сохранено на этом устройстве' : 'Saved on this device',
                  style: context.textTheme.inverseUrbanistRegular14.copyWith(
                    color: AppColorsDark.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SelectableText(
                entry!.text,
                style: context.textTheme.inverseUrbanistRegular16.copyWith(
                  height: 1.7,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

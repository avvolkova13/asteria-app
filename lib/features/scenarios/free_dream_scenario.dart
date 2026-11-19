import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'free_attempt.dart';
import 'scenario_text_field.dart';
import 'scenario_ui.dart';

class FreeDreamScenario extends StatelessWidget {
  const FreeDreamScenario({super.key, required this.onOpenRunes});

  final VoidCallback onOpenRunes;

  @override
  Widget build(BuildContext context) {
    final uid = context.select<UserProvider, String?>((p) => p.currentUser?.id);
    return _DreamPage(key: ValueKey(uid), uid: uid, onOpenRunes: onOpenRunes);
  }
}

class _DreamPage extends StatefulWidget {
  const _DreamPage({super.key, required this.uid, required this.onOpenRunes});

  final String? uid;
  final VoidCallback onOpenRunes;

  @override
  State<_DreamPage> createState() => _DreamPageState();
}

class _DreamPageState extends State<_DreamPage> {
  final _draft = TextEditingController();
  bool _checking = true;
  bool _checkFailed = false;
  bool _submitting = false;
  bool _calculationFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refresh();
    });
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  bool _available(MonetizationProvider access) =>
      widget.uid != null &&
      access.isCurrentUser(widget.uid!) &&
      access.isFeatureEnabled('sonnik') &&
      canUseFreeAttempt(access.requestQuotas['sonnik']);

  Future<bool> _refresh() async {
    final access = context.read<MonetizationProvider>();
    setState(() {
      _checking = true;
      _checkFailed = false;
    });
    try {
      await access.refreshForAccess();
      return mounted && _available(access);
    } catch (_) {
      if (mounted) setState(() => _checkFailed = true);
      return false;
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  void _openResult(SonnikModel item) {
    final owner = widget.uid;
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) {
          final currentUid = context.watch<UserProvider>().currentUser?.id;
          if (owner == null || owner != currentUid) {
            return ScenarioPage(
              title: context.l10n.dreamDictionaryTitle,
              child: Text(
                context.l10n.dreamNoData,
                style: context.textTheme.inverseUrbanistRegular16,
              ),
            );
          }
          return ScenarioPage(
            title: item.title,
            child: SonnikGlassPanel(
              child: SelectableText(
                item.interpretation,
                style: context.textTheme.inverseUrbanistRegular16.copyWith(
                  height: 1.42,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    final dream = _draft.text.trim();
    if (_submitting || dream.isEmpty) return;
    setState(() {
      _submitting = true;
      _calculationFailed = false;
    });
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      if (!await _refresh() ||
          !mounted ||
          ModalRoute.of(context)?.isCurrent != true) {
        return;
      }
      final item = await context.read<ContentProvider>().createSonnik(dream);
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      _draft.clear();
      _openResult(item);
    } catch (_) {
      if (mounted) setState(() => _calculationFailed = true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    final access = context.watch<MonetizationProvider>();
    final history =
        context.watch<UserProvider>().currentUser?.sonnikHistory ??
        const <SonnikModel>[];
    final available = !_checking && !_checkFailed && _available(access);
    final textStyle = context.textTheme.inverseUrbanistRegular16;
    return ScenarioPage(
      title: context.l10n.dreamDictionaryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          if (_submitting || _checking)
            Semantics(
              liveRegion: true,
              child: Text(
                _submitting
                    ? (ru
                          ? 'Готовим толкование…'
                          : 'Preparing your interpretation…')
                    : (ru
                          ? 'Проверяем бесплатные толкования…'
                          : 'Checking free interpretations…'),
                style: textStyle,
              ),
            )
          else if (available) ...[
            Text(
              ru
                  ? 'Бесплатных толкований осталось: ${access.requestQuota('sonnik').freeRemaining}'
                  : 'Free interpretations left: ${access.requestQuota('sonnik').freeRemaining}',
              style: textStyle,
            ),
            ScenarioTextField(
              controller: _draft,
              label: ru ? 'Что вам приснилось?' : 'What did you dream about?',
              hint: ru
                  ? 'Какая деталь сна вам запомнилась?'
                  : 'Which detail do you remember?',
              minLines: 3,
              onChanged: (_) => setState(() {}),
            ),
            if (_calculationFailed)
              Text(context.l10n.dreamCalculationError, style: textStyle),
            CustomButton(
              isFullWidth: true,
              text: context.l10n.dreamDecode,
              onPressed: _draft.text.trim().isEmpty ? null : _submit,
            ),
          ] else ...[
            Text(
              _checkFailed
                  ? (ru
                        ? 'Не удалось проверить бесплатные попытки.'
                        : 'Couldn’t check your free attempts.')
                  : (ru
                        ? 'Сейчас новое бесплатное толкование недоступно.'
                        : 'A new free interpretation is currently unavailable.'),
              style: textStyle,
            ),
            if (_checkFailed)
              TextButton(onPressed: _refresh, child: Text(context.l10n.retry)),
          ],
          if (!_checking &&
              !_submitting &&
              (_calculationFailed || (!available && history.isEmpty)))
            ScenarioTile(
              title: ru ? 'Открыть три руны' : 'Open three runes',
              subtitle: ru
                  ? 'Рассмотрите свою ситуацию с помощью трёх рун.'
                  : 'Explore your situation with a free three-rune reading.',
              onTap: widget.onOpenRunes,
            ),
          if (history.isNotEmpty && !_submitting) ...[
            Text(
              context.l10n.dreamHistoryTitle,
              style: context.textTheme.inversePlayfairSemiBold20,
            ),
            for (final entry in history.reversed)
              ScenarioTile(title: entry.title, onTap: () => _openResult(entry)),
          ],
        ],
      ),
    );
  }
}

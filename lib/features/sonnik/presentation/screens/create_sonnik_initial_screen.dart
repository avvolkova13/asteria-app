import 'package:asteria_app/core/ui_kit/widgets/dictation_button.dart';
import 'package:asteria_app/core/ui_kit/widgets/responsive_heading.dart';
import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/dream_journal_layout.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoAlertDialog, CupertinoDialogAction, showCupertinoDialog;
import 'package:asteria_app/features/sonnik/data/dream_journal.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/features/sonnik/presentation/screens/dream_journal_screen.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/dictionaries/entry_surface.dart';
import 'package:asteria_app/core/analytics/dictionaries/generation_status.dart';
import 'package:asteria_app/core/analytics/dictionaries/length_band.dart';
import 'package:asteria_app/core/analytics/dictionaries/limit_period.dart';
import 'package:asteria_app/core/analytics/dictionaries/limit_type.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'create_sonnik_loaded_screen.dart';

import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';

class CreateSonnikInitialScreen extends StatefulWidget {
  const CreateSonnikInitialScreen({
    super.key,
    this.initialEntry,
    this.entryOwnerId,
    this.autoInterpret = false,
    this.fromJournal = false,
    this.journalRoute,
    this.checkScenarioAccess,
  });
  final DreamEntry? initialEntry;
  final String? entryOwnerId;
  final bool autoInterpret;
  final bool fromJournal;
  final Route<dynamic>? journalRoute;
  final Future<bool> Function(BuildContext)? checkScenarioAccess;

  @override
  State<CreateSonnikInitialScreen> createState() =>
      _CreateSonnikInitialScreenState();
}

class _CreateSonnikInitialScreenState extends State<CreateSonnikInitialScreen> {
  late DreamEntry? _routeEntry = widget.initialEntry;
  String? _owner;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _owner = Provider.of<UserProvider?>(context)?.currentUser?.id;
    // Once the account changes, returning to it must not replay a request.
    if (_owner == null || _owner != widget.entryOwnerId) _routeEntry = null;
  }

  @override
  Widget build(BuildContext context) => _DreamForm(
    key: ValueKey(_owner),
    owner: _owner,
    initialEntry: _routeEntry,
    autoInterpret: widget.autoInterpret && _routeEntry != null,
    fromJournal: widget.fromJournal,
    journalRoute: widget.journalRoute,
    checkScenarioAccess: widget.checkScenarioAccess,
  );
}

class _DreamForm extends StatefulWidget {
  const _DreamForm({
    super.key,
    required this.owner,
    required this.autoInterpret,
    required this.fromJournal,
    this.journalRoute,
    this.checkScenarioAccess,
    this.initialEntry,
  });
  final bool autoInterpret;
  final bool fromJournal;
  final Route<dynamic>? journalRoute;
  final Future<bool> Function(BuildContext)? checkScenarioAccess;
  final String? owner;
  final DreamEntry? initialEntry;
  @override
  State<_DreamForm> createState() => _DreamFormState();
}

class _DreamFormState extends State<_DreamForm> {
  late final _textController = TextEditingController(
    text: widget.initialEntry?.text,
  );
  late DreamEntry? _savedEntry = widget.initialEntry;
  bool _submitting = false;
  bool get _current =>
      mounted && context.read<UserProvider?>()?.currentUser?.id == widget.owner;
  bool get _canShowResult =>
      _current && ModalRoute.of(context)?.isCurrent == true;
  bool _savingDream = false;
  bool _dictating = false;
  bool _asking = false;
  bool _interpretationFailed = false;
  SonnikModel? _unlinkedResult;
  String? _unlinkedText;
  bool get _ru => Localizations.localeOf(context).languageCode == 'ru';
  bool get _changed => _textController.text.trim() != (_savedEntry?.text ?? '');
  final ContentProvider _contentProvider = di.get<ContentProvider>();
  final GlobalLoaderService _loaderService = di.get<GlobalLoaderService>();

  static const _featureParam = {EventParams.featureName: 'sonnik'};

  @override
  void initState() {
    super.initState();
    if (widget.autoInterpret) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_canShowResult) _onCreateSonnikTap();
      });
    }
    final facade = di.get<AnalyticsFacade>();
    facade.trackEvent(AnalyticsEvents.sonnikFunnelStart, params: _featureParam);
    facade.trackEvent(
      AnalyticsEvents.sonnikInputStarted,
      params: _featureParam,
    );
    di.get<ProductAnalyticsService>().trackSonnikStart(
      entrySurface: EntrySurface.home,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    setState(() => _interpretationFailed = false);
  }

  Future<void> _openJournal(UserProvider user) async {
    final owner = user.currentUser?.id;
    if (owner == null || owner.isEmpty) return;
    await openDreamJournal(
      context,
      user,
      checkScenarioAccess: widget.checkScenarioAccess,
    );
    if (!_current || user.currentUser?.id != owner) return;
    final previous = _savedEntry;
    if (previous == null) return;
    final List<DreamEntry> entries;
    try {
      entries = await DreamJournal(owner).read();
    } catch (_) {
      return;
    }
    if (!mounted || user.currentUser?.id != owner || _savedEntry != previous) {
      return;
    }
    final updated = entries.where((item) => item.id == previous.id).firstOrNull;
    setState(() {
      _savedEntry = updated;
      if (updated != null && _textController.text.trim() == previous.text) {
        _textController.text = updated.text;
      }
    });
  }

  Future<DreamEntry?> _persist({SonnikModel? interpretation}) async {
    final owner = widget.owner;
    if (!_current || owner == null || owner.isEmpty) return null;
    final text = _textController.text.trim();
    if (text.isEmpty) return null;
    if (interpretation == null && text == _savedEntry?.text) return _savedEntry;
    try {
      final saved = await DreamJournal(
        owner,
      ).save(text, entry: _savedEntry, interpretation: interpretation);
      if (!_current) return null;
      setState(() => _savedEntry = saved);
      return saved;
    } catch (_) {
      if (mounted && _current) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _ru
                  ? 'Не удалось сохранить сон. Попробуйте ещё раз.'
                  : 'Could not save the dream. Please try again.',
            ),
          ),
        );
      }
      return null;
    }
  }

  Future<void> _saveAndExit() async {
    if (_savingDream || _submitting || _dictating || !_canShowResult) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _savingDream = true);
    final saved = await _persist(interpretation: _pendingForCurrentText);
    if (!_current) return;
    setState(() => _savingDream = false);
    if (saved != null && mounted && _canShowResult) {
      if (!widget.fromJournal) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _ru ? 'Сон сохранён в дневнике' : 'Dream saved to your journal',
            ),
          ),
        );
      }
      Navigator.of(context).pop();
    }
  }

  SonnikModel? get _pendingForCurrentText =>
      _unlinkedText == _textController.text.trim() ? _unlinkedResult : null;

  Future<void> _confirmExit() async {
    if (_asking || _submitting || _savingDream || _dictating || !_current) {
      return;
    }
    _asking = true;
    final choice = await showCupertinoDialog<String>(
      context: context,
      builder: (dialog) => dreamJournalDialog(
        CupertinoAlertDialog(
          title: Text(_ru ? 'Сохранить изменения?' : 'Save your changes?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(dialog),
              child: Text(_ru ? 'Продолжить редактирование' : 'Keep editing'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(dialog, 'discard'),
              child: Text(_ru ? 'Выйти без сохранения' : 'Discard changes'),
            ),
            if (_textController.text.trim().isNotEmpty)
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(dialog, 'save'),
                child: Text(_ru ? 'Сохранить и выйти' : 'Save and exit'),
              ),
          ],
        ),
      ),
    );
    _asking = false;
    if (!_canShowResult) return;
    if (choice == 'save') await _saveAndExit();
    if (choice == 'discard' && mounted) Navigator.of(context).pop();
  }

  Future<void> _viewResult(SonnikModel result) async {
    final owner = widget.owner;
    if (owner == null || !_canShowResult) return;
    final nextDream = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CreateSonnikLoadedScreen(
          sonnik: result,
          ownerId: owner,
          returnToComposer: true,
          journalRoute: widget.journalRoute,
          checkScenarioAccess: widget.checkScenarioAccess,
        ),
      ),
    );
    if (nextDream == true && _current) {
      setState(() {
        _savedEntry = null;
        _unlinkedResult = null;
        _unlinkedText = null;
        _textController.clear();
      });
    }
  }

  Future<void> _onCreateSonnikTap() async {
    final text = _textController.text.trim();
    if (!_canShowResult ||
        _submitting ||
        _savingDream ||
        _dictating ||
        text.isEmpty) {
      return;
    }
    setState(() {
      _submitting = true;
      _interpretationFailed = false;
    });
    try {
      final pending = _pendingForCurrentText;
      if (pending != null) {
        if (await _persist(interpretation: pending) == null ||
            !_canShowResult) {
          return;
        }
        _unlinkedResult = null;
        _unlinkedText = null;
        await _viewResult(pending);
      } else if (!_changed && _savedEntry?.currentInterpretation != null) {
        await _viewResult(_savedEntry!.currentInterpretation!);
      } else {
        await _interpret(text);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _interpret(String text) async {
    final facade = di.get<AnalyticsFacade>();
    final productAnalytics = di.get<ProductAnalyticsService>();
    // Bucket the dream length BEFORE the text leaves this method — the raw
    // text must never be logged. See spec §2.5 R36.
    final dreamLengthBand = LengthBand.fromText(text);
    facade.trackEvent(
      AnalyticsEvents.sonnikInputCompleted,
      params: _featureParam,
    );
    productAnalytics.trackSonnikDreamSubmit(dreamLengthBand: dreamLengthBand);

    if (await _persist() == null || !mounted || !_canShowResult) return;
    final scenarioAccess = widget.checkScenarioAccess;
    final bool? canMakeRequest;
    try {
      canMakeRequest = scenarioAccess == null
          ? await checkRequestAccess(context, 'sonnik', showError: false)
          : await scenarioAccess(context);
    } catch (_) {
      if (mounted && _canShowResult) {
        setState(() => _interpretationFailed = true);
      }
      return;
    }
    if (!mounted || !_canShowResult) return;
    if (canMakeRequest == null) {
      setState(() => _interpretationFailed = true);
      return;
    }
    if (!canMakeRequest) {
      productAnalytics.trackSonnikLimitReached(
        limitType: LimitType.requests,
        requestsLeft: 0,
        limitPeriod: LimitPeriod.unknown,
      );
      if (scenarioAccess == null) CreateSonnikRequestsLeftRoute.push(context);
      return;
    }

    facade.trackEvent(
      AnalyticsEvents.calculationStarted,
      params: _featureParam,
    );
    FocusManager.instance.primaryFocus?.unfocus();
    _loaderService.showWithSpheres(GlobalLoaderType.sonnik);
    final stopwatch = Stopwatch()..start();
    final SonnikModel sonnik;
    try {
      sonnik = await _contentProvider.createSonnik(text);
      stopwatch.stop();
      facade.trackEvent(
        AnalyticsEvents.calculationCompleted,
        params: {..._featureParam, EventParams.resultStatus: 'success'},
      );
      productAnalytics.trackSonnikGenerationComplete(
        generationStatus: GenerationStatus.success,
        generationSeconds: stopwatch.elapsed.inSeconds,
      );
    } catch (e) {
      stopwatch.stop();
      facade.trackEvent(
        AnalyticsEvents.calculationCompleted,
        params: {
          ..._featureParam,
          EventParams.resultStatus: 'failed',
          EventParams.failureReason: e.runtimeType.toString(),
        },
      );
      productAnalytics.trackSonnikGenerationComplete(
        generationStatus: GenerationStatus.failed,
        generationSeconds: stopwatch.elapsed.inSeconds,
      );
      if (!mounted || !_canShowResult) return;
      setState(() => _interpretationFailed = true);
      return;
    } finally {
      _loaderService.hide();
    }
    if (!_current) return;
    _unlinkedText = text;
    _unlinkedResult = sonnik;
    if (await _persist(interpretation: sonnik) == null || !_canShowResult) {
      return;
    }
    _unlinkedResult = null;
    _unlinkedText = null;
    await _viewResult(sonnik);
  }

  @override
  Widget build(BuildContext context) {
    final text = _textController.text.trim();
    final hasText = text.isNotEmpty;
    final canSubmit = !_savingDream && !_dictating && !_submitting;
    final hasResult = !_changed && _savedEntry?.currentInterpretation != null;
    final signedIn = widget.owner?.isNotEmpty == true;
    final user = context.watch<UserProvider?>();
    final ru = Localizations.localeOf(context).languageCode == 'ru';

    return PopScope(
      canPop: !_changed && _pendingForCurrentText == null && canSubmit,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && (_changed || _pendingForCurrentText != null)) {
          _confirmExit();
        }
      },
      child: SonnikPageScaffold(
        title: context.l10n.dreamDictionaryTitle,
        resizeToAvoidBottomInset: true,
        child: ListView(
          physics: const ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            16,
            6,
            16,
            32 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            Consumer<MonetizationProvider>(
              builder: (context, monetizationProvider, child) {
                final requestsLeft = widget.checkScenarioAccess == null
                    ? monetizationProvider.requestsLeft('sonnik')
                    : monetizationProvider
                              .requestQuotas['sonnik']
                              ?.freeRemaining ??
                          0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: AsteriaEntrance.sections([
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final tablet = constraints.maxWidth >= 600;
                        final avatarSize = (constraints.maxWidth * .435).clamp(
                          120.0,
                          tablet ? 228.0 : 156.0,
                        );
                        final largeText =
                            constraints.maxWidth < 360 &&
                            MediaQuery.textScalerOf(context).scale(16) > 20;
                        Widget introduction() => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ResponsiveHeading(
                              largeText || tablet
                                  ? context.l10n.dreamGreeting.replaceAll(
                                      '\n',
                                      ' ',
                                    )
                                  : context.l10n.dreamGreeting,
                              style: context.textTheme.inversePlayfairSemiBold24
                                  .copyWith(
                                    height: 1.1,
                                    fontSize: tablet ? 34 : null,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              largeText || tablet
                                  ? context.l10n.dreamTellPrompt.replaceAll(
                                      '\n',
                                      ' ',
                                    )
                                  : context.l10n.dreamTellPrompt,
                              style: context.textTheme.inverseUrbanistRegular16
                                  .copyWith(
                                    color: SonnikPalette.white.withValues(
                                      alpha: 0.78,
                                    ),
                                    height: 1.2,
                                  ),
                            ),
                            if (!monetizationProvider.effectivePro) ...[
                              const SizedBox(height: 8),
                              SonnikQuotaBadge(requestsLeft: requestsLeft),
                            ],
                          ],
                        );
                        if (largeText) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox.square(
                                dimension: 80,
                                child: SonnikLiveyaAvatar(),
                              ),
                              const SizedBox(height: 12),
                              introduction(),
                            ],
                          );
                        }
                        return ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 176),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: introduction()),
                              const SizedBox(width: 12),
                              SizedBox.square(
                                dimension: avatarSize,
                                child: const SonnikLiveyaAvatar(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    SonnikTextArea(
                      controller: _textController,
                      onChanged: _onTextChanged,
                      readOnly: _savingDream || _submitting,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: DictationButton(
                        controller: _textController,
                        enabled: !_savingDream && !_submitting,
                        showLabel: true,
                        onActiveChanged: (active) {
                          setState(() => _dictating = active);
                        },
                      ),
                    ),
                    SonnikGradientButton(
                      text: ru ? 'Сохранить и выйти' : 'Save and exit',
                      onPressed: signedIn && hasText && canSubmit
                          ? _saveAndExit
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: LotusButtons.text(
                        onPressed: signedIn && hasText && canSubmit
                            ? _onCreateSonnikTap
                            : null,
                        child: Text(
                          hasResult || _pendingForCurrentText != null
                              ? (ru
                                    ? 'Открыть расшифровку'
                                    : 'View interpretation')
                              : context.l10n.dreamDecode,
                        ),
                      ),
                    ),
                    if (_interpretationFailed) ...[
                      const SizedBox(height: 8),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          ru
                              ? 'Сон сохранён. Расшифровка не удалась. Можно попробовать снова или вернуться к записи позже.'
                              : 'Your dream is saved. The interpretation failed. Try again now or return to the entry later.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    if (signedIn && user != null && !widget.fromJournal)
                      Center(
                        child: LotusButtons.textIcon(
                          icon: const Icon(Icons.menu_book_rounded, size: 18),
                          onPressed: canSubmit
                              ? () => _openJournal(user)
                              : null,
                          label: Text(ru ? 'Дневник снов' : 'Dream journal'),
                        ),
                      ),
                  ]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

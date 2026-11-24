import 'package:asteria_app/core/ui_kit/widgets/dictation_button.dart';
import 'package:asteria_app/core/ui_kit/widgets/responsive_heading.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';
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

import 'package:asteria_app/features/sonnik/presentation/provider/sonnik_provider.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';

class CreateSonnikInitialScreen extends StatefulWidget {
  const CreateSonnikInitialScreen({
    super.key,
    this.initialEntry,
    this.entryOwnerId,
  });
  final DreamEntry? initialEntry;
  final String? entryOwnerId;

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
  );
}

class _DreamForm extends StatefulWidget {
  const _DreamForm({super.key, required this.owner, this.initialEntry});
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
  final ContentProvider _contentProvider = di.get<ContentProvider>();
  final GlobalLoaderService _loaderService = di.get<GlobalLoaderService>();

  static const _featureParam = {EventParams.featureName: 'sonnik'};

  @override
  void initState() {
    super.initState();
    if (widget.initialEntry != null) {
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
    setState(() {});
  }

  Future<void> _openJournal(UserProvider user) async {
    final owner = user.currentUser?.id;
    if (owner == null || owner.isEmpty) return;
    final entry = await openDreamJournal(context, user);
    if (!mounted || user.currentUser?.id != owner) return;
    if (entry != null) {
      final draft = _textController.text.trim();
      if (draft.isNotEmpty &&
          draft != _savedEntry?.text &&
          draft != entry.text) {
        // Keep the unfinished form on the stack when interpreting another entry.
        CreateSonnikInitialRoute.push(
          context,
          params: CreateSonnikInitialRouteParams(
            initialEntry: entry,
            ownerId: owner,
          ),
        );
        return;
      }
      setState(() {
        _savedEntry = entry;
        _textController.text = entry.text;
      });
      await _onCreateSonnikTap();
      return;
    }

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

  Future<void> _saveDream(UserProvider user) async {
    final owner = user.currentUser?.id;
    final text = _textController.text.trim();
    if (!_current ||
        _submitting ||
        _savingDream ||
        owner == null ||
        owner.isEmpty ||
        text.isEmpty) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _savingDream = true);
    try {
      final saved = await DreamJournal(owner).save(text, entry: _savedEntry);
      if (!mounted || user.currentUser?.id != owner) return;
      setState(() => _savedEntry = saved);
    } catch (_) {
      if (!mounted || user.currentUser?.id != owner) return;
      final ru = Localizations.localeOf(context).languageCode == 'ru';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ru
                ? 'Не удалось сохранить сон. Попробуйте ещё раз.'
                : 'Could not save the dream. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _savingDream = false);
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
    setState(() => _submitting = true);
    try {
      await _interpret(text);
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

    final canMakeRequest = await checkRequestAccess(context, 'sonnik');
    if (!mounted || canMakeRequest == null || !_canShowResult) return;
    if (!canMakeRequest) {
      productAnalytics.trackSonnikLimitReached(
        limitType: LimitType.requests,
        requestsLeft: 0,
        limitPeriod: LimitPeriod.unknown,
      );
      CreateSonnikRequestsLeftRoute.push(context);
      return;
    }

    facade.trackEvent(
      AnalyticsEvents.calculationStarted,
      params: _featureParam,
    );
    FocusManager.instance.primaryFocus?.unfocus();
    _loaderService.showWithSpheres(GlobalLoaderType.sonnik);
    final stopwatch = Stopwatch()..start();
    try {
      final sonnik = await _contentProvider.createSonnik(text);
      stopwatch.stop();
      facade.trackEvent(
        AnalyticsEvents.calculationCompleted,
        params: {..._featureParam, EventParams.resultStatus: 'success'},
      );
      productAnalytics.trackSonnikGenerationComplete(
        generationStatus: GenerationStatus.success,
        generationSeconds: stopwatch.elapsed.inSeconds,
      );
      if (!mounted || !_canShowResult) return;
      di.get<SonnikProvider>().selectSonnik(sonnik);
      CreateSonnikLoadedRoute.pushReplacement(context);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.dreamCalculationError)),
      );
    } finally {
      _loaderService.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = _textController.text.trim();
    final hasText = text.isNotEmpty;
    final canSubmit = !_savingDream && !_dictating && !_submitting;
    final saved = _savedEntry?.text == text && hasText;
    final user = context.watch<UserProvider?>();
    final ru = Localizations.localeOf(context).languageCode == 'ru';

    return SonnikPageScaffold(
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
              final requestsLeft = monetizationProvider.requestsLeft('sonnik');

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AsteriaEntrance.sections([
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final avatarSize = (constraints.maxWidth * .435).clamp(
                        120.0,
                        156.0,
                      );
                      final largeText =
                          constraints.maxWidth < 360 &&
                          MediaQuery.textScalerOf(context).scale(16) > 20;
                      Widget introduction() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ResponsiveHeading(
                            largeText
                                ? context.l10n.dreamGreeting.replaceAll(
                                    '\n',
                                    ' ',
                                  )
                                : context.l10n.dreamGreeting,
                            style: context.textTheme.inversePlayfairSemiBold24
                                .copyWith(height: 1.0),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            largeText
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
                  const SizedBox(height: 32),
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
                    text: context.l10n.dreamDecode,
                    onPressed: hasText && canSubmit ? _onCreateSonnikTap : null,
                  ),
                  if (user != null &&
                      user.currentUser?.id.isNotEmpty == true &&
                      hasText)
                    if (saved)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            ru
                                ? 'Сохранено в дневнике'
                                : 'Saved to your journal',
                            style: context.textTheme.inverseUrbanistRegular14,
                          ),
                        ),
                      )
                    else
                      LotusButtons.text(
                        onPressed: canSubmit ? () => _saveDream(user) : null,
                        child: Text(
                          ru ? 'Сохранить на потом' : 'Save for later',
                        ),
                      ),
                  if (user != null &&
                      user.currentUser?.id.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    AsteriaActionButton(
                      text: ru ? 'Открыть дневник снов' : 'Open dream journal',
                      width: double.infinity,
                      gold: true,
                      onPressed: canSubmit ? () => _openJournal(user) : null,
                    ),
                  ],
                  Align(
                    alignment: Alignment.centerLeft,
                    child: LotusButtons.text(
                      onPressed: () =>
                          CreateSonnikHistoryRoute.pushReplacement(context),
                      style: TextButton.styleFrom(
                        foregroundColor: SonnikPalette.white,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        context.l10n.viewHistory,
                        style: context.textTheme.inverseUrbanistSemiBold17
                            .copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: SonnikPalette.white,
                            ),
                      ),
                    ),
                  ),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }
}

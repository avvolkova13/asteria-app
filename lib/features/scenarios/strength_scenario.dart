import 'package:asteria_app/core/ui_kit/widgets/card_turn.dart';
import 'dart:convert';
import 'dart:async';
import 'package:asteria_app/app/data/models/anakra_chat/anakra_chat_message_model.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/features/home/presentation/widgets/daily_symbol_of_the_day_widget.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_chat_message.dart';
import 'package:asteria_app/features/auth/presentation/widgets/auth_flow_widgets.dart';
import 'package:asteria_app/features/home/presentation/widgets/bottom_tab_bar_widget.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'guidance_situation.dart';
import 'daily_guidance_store.dart';
import 'scenario_sky.dart';
import 'scenario_ui.dart';
import 'scenario_completion.dart';
import 'strength_guidance.dart';
import 'free_dream_scenario.dart';
import 'free_rune_scenario.dart';

class StrengthTipStore {
  const StrengthTipStore(this.box, this.owner);
  final Box<Map> box;
  final String owner;

  String get _prefix => 'strength-tip/${base64Url.encode(utf8.encode(owner))}/';
  List<StrengthTip> read() {
    if (owner.isEmpty) return [];
    final results = <StrengthTip>[];
    for (final key in box.keys.whereType<String>().where(
      (k) => k.startsWith(_prefix),
    )) {
      final data = box.get(key);
      if (data != null) results.add(StrengthTip.fromJson(data));
    }
    return results..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> save(StrengthTip tip) async {
    if (owner.isEmpty) throw StateError('Missing account');
    final key = '$_prefix${tip.id}';
    if (!box.containsKey(key)) await box.put(key, tip.toJson());
  }

  bool contains(StrengthTip tip) => box.containsKey('$_prefix${tip.id}');
}

class StrengthScenarioScreen extends StatelessWidget {
  const StrengthScenarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    void open(Widget child) {
      Navigator.of(context).push<void>(
        CupertinoPageRoute(builder: (_) => ScenarioSkyScope(child: child)),
      );
    }

    return ScenarioPage(
      title: context.l10n.scenarioStrengthTitle,
      child: ScenarioChoiceGrid(
        children: [
          ScenarioChoiceCard(
            title: context.l10n.scenarioRelationshipOpenSpread,
            art: 'assets/images/year_animals/horse.webp',
            onTap: () => open(const _DailyGuidancePicker()),
          ),
          ScenarioChoiceCard(
            title: ru ? 'Вытянуть три руны' : 'Draw three runes',
            art: 'assets/images/home/practice_runes_clay.webp',
            onTap: () => open(const FreeRuneScenario()),
          ),
          ScenarioChoiceCard(
            wide: true,
            title: ru ? 'Растолковать сон' : 'Interpret a dream',
            art: 'assets/images/practices/time-for-sleep.webp',
            onTap: () => open(
              FreeDreamScenario(
                onOpenRunes: () => open(const FreeRuneScenario()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyGuidancePicker extends StatefulWidget {
  const _DailyGuidancePicker();

  @override
  State<_DailyGuidancePicker> createState() => _DailyGuidancePickerState();
}

class _DailyGuidancePickerState extends State<_DailyGuidancePicker>
    with WidgetsBindingObserver {
  late final _users = di.get<UserProvider>();
  Timer? _midnight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _users.addListener(_refresh);
    _scheduleMidnight();
  }

  void _scheduleMidnight() {
    _midnight?.cancel();
    final now = DateTime.now();
    _midnight = Timer(
      DateTime(now.year, now.month, now.day + 1).difference(now),
      () {
        _refresh();
        _scheduleMidnight();
      },
    );
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
      _scheduleMidnight();
    }
  }

  @override
  void dispose() {
    _midnight?.cancel();
    _users.removeListener(_refresh);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    final opened = DailyGuidanceStore(_users.currentUser?.id ?? '').read();
    return ScenarioPage(
      title: ru ? 'Подсказка Анакры' : 'Anakra’s guidance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: AsteriaEntrance.sections([
          ScenarioChoiceHero(
            description: opened != null
                ? (ru
                      ? 'Сегодняшняя карта открыта. Выберите отмеченную тему, чтобы перечитать подсказку.'
                      : 'Your daily card is open. Pick the marked topic to revisit its reading.')
                : (ru
                      ? 'Какой вопрос возьмём к карте дня? Сегодня можно выбрать одну тему.'
                      : 'What would you like to ask your daily card? Choose one theme for today.'),
            art: 'assets/images/year_animals/horse.webp',
          ),
          const SizedBox(height: 20),
          ScenarioChoiceGrid(
            children: [
              for (final situation in GuidanceSituation.values)
                _choice(situation, ru, opened?.situation),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _choice(
    GuidanceSituation situation,
    bool ru,
    GuidanceSituation? opened,
  ) {
    final locked = opened != null && opened != situation;
    Future<void> open() async {
      final current = DailyGuidanceStore(_users.currentUser?.id ?? '').read();
      if (current != null && current.situation != situation) return;
      await Navigator.of(context).push<void>(
        CupertinoPageRoute<void>(
          builder: (_) => ScenarioSkyScope(
            child: _GuidanceConversation(situation: situation),
          ),
        ),
      );
      _refresh();
    }

    final card = ScenarioChoiceCard(
      title: situation.title(ru),
      art: situation.art,
      selected: opened == situation,
      subtitle: opened == null
          ? null
          : (locked
                ? (ru ? 'Доступно завтра' : 'Available tomorrow')
                : (ru ? 'Ваш инсайт' : 'Your insight')),
      onTap: open,
    );
    if (!locked) return card;
    return ExcludeFocus(
      child: Semantics(
        label:
            '${situation.title(ru)}. ${ru ? 'Доступно завтра' : 'Available tomorrow'}',
        button: true,
        enabled: false,
        child: ExcludeSemantics(
          child: IgnorePointer(
            child: Stack(
              children: [
                Opacity(opacity: .48, child: card),
                const Positioned(
                  top: 12,
                  right: 12,
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 20,
                    color: AppColors.cardTinted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuidanceConversation extends StatefulWidget {
  const _GuidanceConversation({required this.situation});
  final GuidanceSituation situation;
  @override
  State<_GuidanceConversation> createState() => _GuidanceConversationState();
}

class _GuidanceConversationState extends State<_GuidanceConversation>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final ContentProvider _content = di.get<ContentProvider>();
  late final UserProvider _users = di.get<UserProvider>();
  late final String? _owner;
  late final DailyGuidanceStore _store;
  bool _locked = false;
  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: CardTurn.duration,
  );
  final _answer = GlobalKey();
  bool _accountChanged = false;
  bool? _tryToday;

  void _checkOwner() {
    if (_users.currentUser?.id != _owner && !_accountChanged) {
      setState(() {
        _accountChanged = true;
        _card = null;
        _tryToday = null;
      });
    }
  }

  final DateTime _started = DateTime.now();
  TarotCardModel? _card;
  bool _busy = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _owner = _users.currentUser?.id;
    _store = DailyGuidanceStore(_owner ?? '');
    _users.addListener(_checkOwner);
    _restore();
  }

  void _restore() {
    if (_accountChanged) return;
    final saved = _store.read();
    _locked = saved != null && saved.situation != widget.situation;
    if (!_locked && saved != null && _card?.id == saved.cardId) return;
    _card = null;
    _tryToday = null;
    _flip.value = 0;
    if (_locked) return;
    if (saved != null || _content.isTodayTarotCardOpened()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_accountChanged) _reveal(restore: true);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_busy && mounted) {
      setState(_restore);
    }
  }

  @override
  void dispose() {
    _users.removeListener(_checkOwner);
    _flip.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _reveal({bool restore = false}) async {
    if (_busy || _accountChanged || _locked) return;
    final drawnDay = _store.day;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      if (_content.tarotCards.isEmpty) await _content.loadContent();
      if (!mounted || _accountChanged) return;
      final saved = _store.read();
      if (saved != null && saved.situation != widget.situation) {
        setState(() => _locked = true);
        return;
      }
      final isRestoring =
          restore || saved != null || _content.isTodayTarotCardOpened();
      final today = saved == null
          ? _content.getTodayTarotCard()
          : _content.tarotCards.firstWhere((card) => card.id == saved.cardId);
      if (saved == null) {
        if (!_content.isTodayTarotCardOpened()) {
          await _content.setTodayTarotCardOpened();
        }
        if (!mounted || _accountChanged) return;
        await _store.save(widget.situation, today.id, drawnDay);
        if (!mounted || _accountChanged) return;
        _content.setDailySymbolTarotOpened();
      }
      setState(() => _card = today);
      final reduced = MediaQuery.disableAnimationsOf(context);
      if (reduced || isRestoring) {
        _flip.value = 1;
      } else {
        await _flip.forward(from: 0).orCancel;
      }
      if (!mounted || _accountChanged || isRestoring) return;
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || _accountChanged) return;
      final answer = _answer.currentContext;
      if (answer != null && answer.mounted) {
        await Scrollable.ensureVisible(
          answer,
          alignment: .75,
          duration: reduced ? Duration.zero : const Duration(milliseconds: 270),
          curve: Curves.easeOutCubic,
        );
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _reply(String text, bool ru) => AnakraChatMessage(
    message: AnakraChatMessageModel(
      text: text,
      isUser: false,
      timestamp: _started,
      locale: ru ? 'ru' : 'en',
    ),
  );

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    final ru = language == 'ru';
    final card = _card;
    if (_accountChanged) {
      return ScenarioPage(
        title: widget.situation.title(ru),
        child: Text(
          ru
              ? 'Вы вошли в другой аккаунт. Вернитесь к выбору ситуации.'
              : 'Your account has changed. Go back to choose a situation.',
        ),
      );
    }
    if (_locked) {
      return ScenarioPage(
        title: widget.situation.title(ru),
        child: Text(
          ru
              ? 'Ваш инсайт на сегодня уже открыт в другой карточке. Приходите завтра за новым.'
              : 'Today’s insight is already open in another card. Come back tomorrow for a new insight.',
        ),
      );
    }
    final revealLabel = ru ? 'Вытянуть карту' : 'Draw a card';
    return ScenarioPage(
      title: widget.situation.title(ru),
      footer: card == null
          ? AuthGradientButton(
              text: _failed ? context.l10n.commonRetry : revealLabel,
              onPressed: _busy ? null : _reveal,
              isLoading: _busy,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: AsteriaEntrance.sections([
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox.square(
              dimension: 112,
              child: FittedBox(
                child: const AnakraIdleBadge(
                  assetPath: 'assets/images/year_animals/horse.webp',
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _reply(widget.situation.opening(ru), ru),
          AsteriaEntrance(
            animateInitially: false,
            child: Center(
              child: LotusFeedback(
                animateEntrance: false,
                keyboard: true,
                onActivate: card == null && !_busy ? _reveal : null,
                builder: (activate) => Semantics(
                  label: card?.title ?? revealLabel,
                  button: card == null,
                  onTap: activate,
                  child: ExcludeSemantics(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: activate,
                      child: DailySymbolFlip(
                        animation: _flip,

                        back: const DailyTarotCardFace(width: 140, height: 208),
                        front: DailyTarotCardFace(
                          card: card,
                          width: 140,
                          height: 208,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (card == null && _failed)
            Text(
              ru
                  ? 'Карты пока не загрузились. Попробуем ещё раз?'
                  : 'The cards haven’t loaded yet. Try again?',
              textAlign: TextAlign.center,
              style: AppTypography.text2.copyWith(color: AppColors.cardTinted),
            ),
          if (card != null) ...[
            Text(
              card.title,
              textAlign: TextAlign.center,
              style: context.textTheme.inversePlayfairSemiBold24,
            ),
            const SizedBox(height: 14),
            KeyedSubtree(key: _answer, child: _reply(_advice(card, ru), ru)),
            const SizedBox(height: 20),
            if (_tryToday == null) ...[
              Text(
                ru
                    ? 'Как хотите продолжить?'
                    : 'How would you like to continue?',
                style: context.textTheme.inversePlayfairSemiBold20,
              ),
              const SizedBox(height: 12),
              CustomButton(
                isFullWidth: true,
                height: 50,
                text: ru
                    ? 'Попробую этот шаг сегодня'
                    : 'I’ll try this step today',
                onPressed: () => setState(() => _tryToday = true),
              ),
              const SizedBox(height: 8),
              CustomButton(
                isFullWidth: true,
                height: 50,
                type: CustomButtonType.outline,
                textColor: AppColors.textInverse,
                text: ru
                    ? 'Сначала хочу обдумать'
                    : 'I’d like to think it over first',
                onPressed: () => setState(() => _tryToday = false),
              ),
            ] else ...[
              Text(
                _tryToday!
                    ? (ru
                          ? 'Начните с одного шага — этого достаточно на сегодня.'
                          : 'One step is enough for today.')
                    : (ru
                          ? 'Дайте себе время. Вернитесь к карте дня, когда будете готовы.'
                          : 'Give yourself time. Revisit your daily card when you feel ready.'),
                style: context.textTheme.inverseUrbanistRegular16,
              ),
              const SizedBox(height: 16),
              ScenarioCompletion(
                message: ru
                    ? 'Карта дня доступна на главной. Там можно посмотреть лунный календарь или включить короткую аффирмацию.'
                    : 'Your daily card is on Home. You can explore the lunar calendar or play a short affirmation there.',
              ),
            ],
          ],
        ]),
      ),
    );
  }

  String _advice(TarotCardModel card, bool ru) {
    final description = [
      card.cardOfDayDescription,
      card.shortDescription,
      card.generalDescription,
    ].map((s) => s.trim()).firstWhere((s) => s.isNotEmpty, orElse: () => '');
    final firstSentence = RegExp(
      r'^[^.!?\n]+[.!?…]?',
    ).firstMatch(description)?.group(0)?.trim();
    return [
      if (firstSentence != null && firstSentence.isNotEmpty) firstSentence,
      widget.situation.nextStep(card, ru),
    ].join('\n\n');
  }
}

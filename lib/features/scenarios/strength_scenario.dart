import 'dart:convert';
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
import 'scenario_sky.dart';
import 'scenario_ui.dart';
import 'scenario_completion.dart';
import 'strength_guidance.dart';

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
    return ScenarioPage(
      title: context.l10n.scenarioStrengthChooseArea,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: AsteriaEntrance.sections([
          ScenarioChoiceHero(
            description: ru
                ? 'Выберите ситуацию. Анакра предложит первый шаг, а карта дня поможет взглянуть на него иначе.'
                : 'Choose a situation. Anakra will suggest a first step, and your daily card will offer another perspective.',
            art: 'assets/images/year_animals/horse.webp',
          ),
          const SizedBox(height: 20),
          ScenarioChoiceGrid(
            children: [
              for (final situation in GuidanceSituation.values)
                ScenarioChoiceCard(
                  title: situation.title(ru),
                  art: situation.art,
                  onTap: () => Navigator.of(context).push<void>(
                    CupertinoPageRoute<void>(
                      builder: (_) => ScenarioSkyScope(
                        child: _GuidanceConversation(situation: situation),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ]),
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
  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 540),
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
    _users.addListener(_checkOwner);
    _restore();
  }

  void _restore() {
    if (_accountChanged) return;
    try {
      if (!_content.isTodayTarotCardOpened()) {
        _card = null;
        _tryToday = null;
        _flip.value = 0;
      } else if (_content.tarotCards.isNotEmpty) {
        _card = _content.getTodayTarotCard();
        _flip.value = 1;
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_accountChanged) _reveal();
        });
      }
    } catch (_) {
      _card = null;
      _failed = true;
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

  Future<void> _reveal() async {
    if (_busy || _accountChanged) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      if (_content.tarotCards.isEmpty) await _content.loadContent();
      if (!mounted || _accountChanged) return;
      final today = _content.getTodayTarotCard();
      if (!_content.isTodayTarotCardOpened()) {
        await _content.setTodayTarotCardOpened();
      }
      if (!mounted || _accountChanged) return;
      _content.setDailySymbolTarotOpened();
      setState(() => _card = today);
      final reduced = MediaQuery.disableAnimationsOf(context);
      if (reduced) {
        _flip.value = 1;
      } else {
        await _flip.forward(from: 0).orCancel;
      }
      if (!mounted || _accountChanged) return;
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
    final revealLabel = ru ? 'Вытянуть карту дня' : 'Draw my daily card';
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
          Center(
            child: LotusFeedback(
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
                      startsFaceDown: true,
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
          const SizedBox(height: 12),
          if (card == null)
            Text(
              _failed
                  ? (ru
                        ? 'Карты пока не загрузились. Попробуем ещё раз?'
                        : 'The cards haven’t loaded yet. Try again?')
                  : (ru
                        ? 'Одна карта на сегодня. Её можно снова открыть на главной.'
                        : 'One card for today. You can find it again on Home.'),
              textAlign: TextAlign.center,
              style: AppTypography.text2.copyWith(color: AppColors.cardTinted),
            )
          else ...[
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

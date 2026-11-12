import 'package:asteria_app/features/scenarios/scenario_sky.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/extensions/datetime_extensions.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/compatibility/presentation/screens/compatibility_history_screen.dart';
import 'package:asteria_app/features/compatibility/presentation/screens/create_compatibility_initial_screen.dart';
import 'package:asteria_app/features/compatibility/presentation/widgets/compatibility_layout.dart';
import 'package:asteria_app/features/compatibility/presentation/widgets/compability_results.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/features/home/presentation/widgets/tarot_card_of_the_day_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'scenario_ui.dart';
import 'scenario_completion.dart';
import 'relationship_question.dart';

enum RelationshipSituation {
  care,
  disagreement,
  ownFeelings;

  String get art => switch (this) {
    care => 'assets/images/scenarios/conversation.webp',
    disagreement => 'assets/images/home/personal_week_balance_harmony.webp',
    ownFeelings => 'assets/images/home/hand_with_star.webp',
  };

  bool get forPair => this != ownFeelings;

  String title(BuildContext context) => switch (this) {
    care => context.l10n.scenarioRelationshipCare,
    disagreement => context.l10n.scenarioRelationshipDisagreement,
    ownFeelings => context.l10n.scenarioRelationshipOwnFeelings,
  };

  String recommendation(BuildContext context) => switch (this) {
    care => context.l10n.scenarioRelationshipCareOffer,
    disagreement => context.l10n.scenarioRelationshipDisagreementOffer,
    ownFeelings => context.l10n.scenarioRelationshipSpreadOffer,
  };

  String question(BuildContext context) => switch (this) {
    care => context.l10n.scenarioRelationshipCareQuestion,
    disagreement => context.l10n.scenarioRelationshipDisagreementQuestion,
    ownFeelings => context.l10n.scenarioRelationshipReflectionQuestion,
  };

  String reading(SavedCompatibilityModel pair) => switch (this) {
    care => pair.compatibilityData.loveCompatibility.trim(),
    disagreement => pair.compatibilityData.conflicts.trim(),
    ownFeelings => '',
  };
}

Future<T?> _open<T>(BuildContext context, Widget screen) =>
    Navigator.of(context).push<T>(
      CupertinoPageRoute<T>(builder: (_) => ScenarioSkyScope(child: screen)),
    );

class RelationshipsScenarioScreen extends StatefulWidget {
  const RelationshipsScenarioScreen({super.key});

  @override
  State<RelationshipsScenarioScreen> createState() =>
      _RelationshipsScenarioScreenState();
}

class _RelationshipsScenarioScreenState
    extends State<RelationshipsScenarioScreen> {
  RelationshipSituation? _selected;
  bool _opening = false;

  Future<void> _start(RelationshipSituation situation) async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      if (!situation.forPair) {
        final content = di.get<ContentProvider>();
        if (content.tarotCards.isEmpty) await content.loadContent();
        if (!mounted) return;
        await _open<void>(context, const _RelationshipDailyCard());
        return;
      }
      final users = di.get<UserProvider>();
      if (users.currentUser == null) {
        showAccessError(context);
        return;
      }
      if (users.currentUser!.compatibilityHistory.isEmpty) {
        await _createPair(context, situation);
      } else {
        await _open<void>(context, _Pairs(situation: situation));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.genericRefreshError)),
        );
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Widget _choice(RelationshipSituation situation, {bool wide = false}) =>
      ScenarioChoiceCard(
        art: situation.art,
        title: situation.title(context),
        selected: _selected == situation,
        wide: wide,
        onTap: () {
          if (!_opening) setState(() => _selected = situation);
        },
      );

  @override
  Widget build(BuildContext context) {
    final choice = _selected;
    return ScenarioPage(
      title: context.l10n.scenarioRelationshipChooseSituation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: AsteriaEntrance.sections([
          _choice(RelationshipSituation.care, wide: true),
          const SizedBox(height: 12),
          ScenarioChoiceGrid(
            children: [
              _choice(RelationshipSituation.disagreement),
              _choice(RelationshipSituation.ownFeelings),
            ],
          ),
          if (choice != null) ...[
            const SizedBox(height: 20),
            Semantics(
              liveRegion: true,
              child: Text(
                choice.recommendation(context),
                style: context.textTheme.inverseUrbanistRegular16,
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              isFullWidth: true,
              height: 50,
              isLoading: _opening,
              text: choice.forPair
                  ? context.l10n.scenarioRelationshipOpenPair
                  : context.l10n.scenarioRelationshipOpenSpread,
              onPressed: _opening ? null : () => _start(choice),
            ),
          ],
        ]),
      ),
    );
  }
}

Future<void> _createPair(
  BuildContext context,
  RelationshipSituation situation,
) async {
  final userProvider = di.get<UserProvider>();
  final uid = userProvider.currentUser?.id;
  final pair = await _open<SavedCompatibilityModel>(
    context,
    const CreateCompatibilityInitialScreen(returnCreatedPair: true),
  );
  if (!context.mounted || pair == null || userProvider.currentUser?.id != uid) {
    return;
  }
  await _open<void>(
    context,
    RelationshipPairResult(situation: situation, pair: pair),
  );
}

class _Pairs extends StatelessWidget {
  const _Pairs({required this.situation});
  final RelationshipSituation situation;

  @override
  Widget build(BuildContext context) {
    final users = di.get<UserProvider>();
    return CompatibilityLayout(
      child: ListenableBuilder(
        listenable: users,
        builder: (context, _) => CompatibilityHistoryScreen(
          user: users.currentUser,
          onNewPairPressed: () => _createPair(context, situation),
          onItemTap: (pair) => _open<void>(
            context,
            RelationshipPairResult(situation: situation, pair: pair),
          ),
        ),
      ),
    );
  }
}

class RelationshipPairResult extends StatelessWidget {
  const RelationshipPairResult({
    super.key,
    required this.situation,
    required this.pair,
  });
  final RelationshipSituation situation;
  final SavedCompatibilityModel pair;

  Future<void> _share(BuildContext context, String question) async {
    try {
      final box = context.findRenderObject() as RenderBox;
      await SharePlus.instance.share(
        ShareParams(
          text: question,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.playerShareError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    final locale = Localizations.localeOf(context);
    final overview = pair.compatibilityData.generalCompatibility.trim();
    final questions = situation == RelationshipSituation.disagreement
        ? [RelationshipQuestion.deescalate, RelationshipQuestion.beHeard]
        : [RelationshipQuestion.closeness, RelationshipQuestion.support];
    return CompatibilityLayout(
      showRequestsBadge: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: AsteriaEntrance.sections([
          Text(
            '${pair.firstBirthdate.getZodiacSignName(languageCode: locale.languageCode)} + ${pair.secondBirthdate.getZodiacSignName(languageCode: locale.languageCode)}',
            style: context.textTheme.inverseUrbanistRegular16,
          ),
          const SizedBox(height: 8),
          Text(
            situation.title(context),
            style: context.textTheme.inversePlayfairSemiBold32,
          ),
          const SizedBox(height: 20),
          if (overview.isNotEmpty) ...[
            Text(overview, style: context.textTheme.inverseUrbanistRegular16),
            const SizedBox(height: 24),
          ],
          Text(
            ru ? 'На чём сосредоточимся?' : 'What would you like to focus on?',
            style: context.textTheme.inversePlayfairSemiBold24,
          ),
          const SizedBox(height: 10),
          Text(
            ru
                ? 'Выберите вопрос. Посмотрим на вашу пару через эту тему и подберём первые слова для разговора.'
                : 'Choose a question. We’ll look at your pair through this theme and suggest a way to start the conversation.',
            style: context.textTheme.inverseUrbanistRegular16,
          ),
          const SizedBox(height: 16),
          for (final question in questions)
            ScenarioTile(
              title: question.title(ru),
              onTap: () => _open<void>(
                context,
                _RelationshipAnswer(
                  pair: pair,
                  question: question,
                  onShare: _share,
                ),
              ),
            ),
          LotusButtons.text(
            onPressed: () => _open<void>(
              context,
              CompatibilityLayout(
                child: CompabilityResults(
                  compatibilityData: pair.compatibilityData,
                  hisBirthdate: pair.firstBirthdate.toShortDate(),
                  herBirthdate: pair.secondBirthdate.toShortDate(),
                  onHistoryPressed: () =>
                      CreateCompatibilityHistoryRoute.push(context),
                ),
              ),
            ),
            child: Text(context.l10n.scenarioRelationshipFullReading),
          ),
        ]),
      ),
    );
  }
}

class _RelationshipAnswer extends StatelessWidget {
  const _RelationshipAnswer({
    required this.pair,
    required this.question,
    required this.onShare,
  });
  final SavedCompatibilityModel pair;
  final RelationshipQuestion question;
  final Future<void> Function(BuildContext, String) onShare;
  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    final reading = question.reading(pair.compatibilityData);
    return ScenarioPage(
      title: question.title(ru),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: AsteriaEntrance.sections([
          if (reading.isNotEmpty) ...[
            Text(
              ru ? 'В вашем разборе' : 'From your pair reading',
              style: context.textTheme.inversePlayfairSemiBold20,
            ),
            const SizedBox(height: 10),
            Text(reading, style: context.textTheme.inverseUrbanistRegular16),
            const SizedBox(height: 24),
          ],
          Text(
            ru ? 'Что можно попробовать' : 'Something to try',
            style: context.textTheme.inversePlayfairSemiBold24,
          ),
          const SizedBox(height: 10),
          Text(
            question.suggestion(ru),
            style: context.textTheme.inverseUrbanistRegular16,
          ),
          const SizedBox(height: 24),
          CompatibilityGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.scenarioRelationshipConversationLabel,
                  style: context.textTheme.inversePlayfairSemiBold20,
                ),
                const SizedBox(height: 10),
                Text(
                  question.opener(ru),
                  style: context.textTheme.inverseUrbanistRegular16,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (buttonContext) => CustomButton(
              isFullWidth: true,
              height: 50,
              type: CustomButtonType.outline,
              textColor: AppColors.textInverse,
              text: context.l10n.scenarioRelationshipShareQuestion,
              onPressed: () => onShare(buttonContext, question.opener(ru)),
            ),
          ),
          const SizedBox(height: 24),
          ScenarioCompletion(
            message: ru
                ? 'Разбор пары останется в «Разборах». На главной можно посмотреть лунный календарь или взять минуту для себя с аффирмацией.'
                : 'Your pair reading stays in Readings. On Home, you can explore the lunar calendar or take a minute with an affirmation.',
          ),
        ]),
      ),
    );
  }
}

class _Reflection extends StatelessWidget {
  const _Reflection();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: AsteriaEntrance.sections([
      CompatibilityGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.scenarioRelationshipReflectionLabel,
              style: context.textTheme.playfairSemiBold20.copyWith(
                color: AppColors.textInverse,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              RelationshipSituation.ownFeelings.question(context),
              style: context.textTheme.inverseUrbanistRegular16,
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      ScenarioCompletion(
        message: Localizations.localeOf(context).languageCode == 'ru'
            ? 'Карта дня останется на главной. Там же можно послушать аффирмацию или заглянуть в лунный календарь.'
            : 'Your daily card stays on Home. You can also listen to an affirmation or explore the lunar calendar.',
      ),
    ]),
  );
}

class _RelationshipDailyCard extends StatelessWidget {
  const _RelationshipDailyCard();

  Future<void> _reveal(BuildContext context, ContentProvider content) async {
    try {
      await content.setTodayTarotCardOpened();
      content.setDailySymbolTarotOpened();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.genericRefreshError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = di.get<ContentProvider>();
    return ScenarioPage(
      title: context.l10n.scenarioRelationshipOwnFeelings,
      child: ListenableBuilder(
        listenable: content,
        builder: (context, _) {
          if (content.tarotCards.isEmpty) {
            return ErrorScreenWidget(
              error: context.l10n.tarotLoadError,
              onRetry: () => content.loadContent(),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.scenarioRelationshipSpreadOffer,
                style: context.textTheme.inverseUrbanistRegular16,
              ),
              const SizedBox(height: 20),
              TarotCardOfTheDayWidget(
                tarotCard: content.getTodayTarotCard(),
                isOpened: content.isTodayTarotCardOpened(),
                isDarkLayout: true,
                margin: EdgeInsets.zero,
                showMoreButton: false,
                onCardTap: () => _reveal(context, content),
              ),
              if (content.isTodayTarotCardOpened()) ...[
                const SizedBox(height: 24),
                const _Reflection(),
              ],
            ],
          );
        },
      ),
    );
  }
}

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
import 'package:asteria_app/features/love_deck/love_deck_access.dart';
import 'package:asteria_app/features/love_deck/love_deck_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'scenario_ui.dart';

enum RelationshipSituation {
  care,
  disagreement,
  ownFeelings;

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

Future<T?> _open<T>(BuildContext context, Widget screen) => Navigator.of(
  context,
).push<T>(CupertinoPageRoute<T>(builder: (_) => screen));

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
        await openLoveDeck(
          context,
          onOpen: () {
            _open<void>(
              context,
              const LoveDeckScreen(afterReading: _Reflection()),
            );
          },
        );
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

  @override
  Widget build(BuildContext context) {
    final choice = _selected;
    return ScenarioPage(
      title: context.l10n.scenarioRelationshipChooseSituation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in RelationshipSituation.values) ...[
            Semantics(
              selected: choice == item,
              child: ScenarioTile(
                title: item.title(context),
                subtitle: choice == item ? item.recommendation(context) : null,
                onTap: () {
                  if (!_opening) setState(() => _selected = item);
                },
              ),
            ),
            if (choice == item) ...[
              const SizedBox(height: 8),
              CustomButton(
                text: item.forPair
                    ? context.l10n.scenarioRelationshipOpenPair
                    : context.l10n.scenarioRelationshipOpenSpread,
                onPressed: _opening ? null : () => _start(item),
              ),
            ],
            const SizedBox(height: 12),
          ],
        ],
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
    final interpretation = situation.reading(pair);
    final question = situation.question(context);
    final locale = Localizations.localeOf(context);
    return CompatibilityLayout(
      showRequestsBadge: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${pair.firstBirthdate.getZodiacSignName(languageCode: locale.languageCode)} + ${pair.secondBirthdate.getZodiacSignName(languageCode: locale.languageCode)}',
            style: context.textTheme.tertiaryUrbanistRegular16,
          ),
          const SizedBox(height: 8),
          Text(
            situation.title(context),
            style: context.textTheme.inversePlayfairSemiBold32,
          ),
          const SizedBox(height: 20),
          if (interpretation.isNotEmpty) ...[
            Text(
              interpretation,
              style: context.textTheme.inverseUrbanistRegular16,
            ),
            const SizedBox(height: 24),
          ],
          CompatibilityGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.scenarioRelationshipConversationLabel,
                  style: context.textTheme.playfairSemiBold20,
                ),
                const SizedBox(height: 8),
                Text(
                  question,
                  style: context.textTheme.inverseUrbanistRegular16,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (buttonContext) => CompatibilityGradientButton(
              text: context.l10n.scenarioRelationshipShareQuestion,
              onPressed: () => _share(buttonContext, question),
            ),
          ),
          TextButton(
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
          TextButton(
            onPressed: () => scenarioHome(context),
            child: Text(context.l10n.scenarioGoHome),
          ),
        ],
      ),
    );
  }
}

class _Reflection extends StatelessWidget {
  const _Reflection();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      CompatibilityGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.scenarioRelationshipReflectionLabel,
              style: context.textTheme.playfairSemiBold20,
            ),
            const SizedBox(height: 8),
            Text(
              RelationshipSituation.ownFeelings.question(context),
              style: context.textTheme.inverseUrbanistRegular16,
            ),
          ],
        ),
      ),
      TextButton(
        onPressed: () => scenarioHome(context),
        child: Text(context.l10n.scenarioGoHome),
      ),
    ],
  );
}

import 'dream_journal_screen.dart';
import 'create_sonnik_initial_screen.dart';
import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:provider/provider.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/feature_names.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/sonnik/presentation/provider/sonnik_provider.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_results.dart';
import 'package:flutter/material.dart';

class CreateSonnikLoadedScreen extends StatefulWidget {
  const CreateSonnikLoadedScreen({
    super.key,
    this.sonnik,
    this.ownerId,
    this.fromJournal = false,
    this.journalRoute,
    this.returnToComposer = false,
    this.checkScenarioAccess,
  });
  final SonnikModel? sonnik;
  final String? ownerId;
  final bool fromJournal;
  final Route<dynamic>? journalRoute;
  final bool returnToComposer;
  final Future<bool> Function(BuildContext)? checkScenarioAccess;

  @override
  State<CreateSonnikLoadedScreen> createState() =>
      _CreateSonnikLoadedScreenState();
}

class _CreateSonnikLoadedScreenState extends State<CreateSonnikLoadedScreen> {
  late final String? _owner;
  late final SonnikModel? _result;
  bool _accountChanged = false;
  @override
  void initState() {
    super.initState();
    _owner = widget.ownerId ?? context.read<UserProvider?>()?.currentUser?.id;
    _result =
        widget.sonnik ?? di.get<SonnikProvider>().selectedSonnikFor(_owner);
    if (widget.sonnik case final result?) {
      if (context.read<UserProvider?>()?.currentUser?.id == _owner &&
          di.isRegistered<SonnikProvider>()) {
        di.get<SonnikProvider>().selectSonnik(result, ownerId: _owner);
      }
    }
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.sonnikResultView,
      params: {EventParams.featureName: FeatureName.sonnik.eventValue},
    );
    di.get<ProductAnalyticsService>().trackSonnikResultView();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider?>();
    if (user?.currentUser?.id != _owner) _accountChanged = true;
    final sonnik = _accountChanged || _owner == null ? null : _result;
    final ru = Localizations.localeOf(context).languageCode == 'ru';

    if (sonnik == null) {
      return SonnikPageScaffold(
        title: context.l10n.dreamDictionaryTitle,
        child: Center(
          child: Text(
            context.l10n.dreamNoData,
            style: context.textTheme.inverseUrbanistRegular16,
          ).withEntrance(),
        ),
      );
    }

    return SonnikPageScaffold(
      title: context.l10n.dreamDictionaryTitle,
      child: ListView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        children: [
          SonnikResults(
            sonnik: sonnik,
            onDecodeAgainPressed: () {
              if (widget.returnToComposer) {
                Navigator.pop(context, true);
              } else {
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => CreateSonnikInitialScreen(
                      checkScenarioAccess: widget.checkScenarioAccess,
                      fromJournal: widget.fromJournal,
                      journalRoute: widget.journalRoute,
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 8),
          Center(
            child: LotusButtons.textIcon(
              icon: const Icon(Icons.menu_book_rounded, size: 18),
              label: Text(ru ? 'Дневник снов' : 'Dream journal'),
              onPressed: user == null
                  ? null
                  : () {
                      final journal = widget.journalRoute;
                      if (journal != null && journal.isActive) {
                        Navigator.of(
                          context,
                        ).popUntil((route) => identical(route, journal));
                      } else if (widget.fromJournal) {
                        Navigator.of(context).pop();
                      } else {
                        openDreamJournal(
                          context,
                          user,
                          checkScenarioAccess: widget.checkScenarioAccess,
                        );
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}

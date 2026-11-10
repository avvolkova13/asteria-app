import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/feature_names.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/sonnik/presentation/provider/sonnik_provider.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_results.dart';
import 'package:flutter/material.dart';

class CreateSonnikLoadedScreen extends StatefulWidget {
  const CreateSonnikLoadedScreen({Key? key}) : super(key: key);

  @override
  State<CreateSonnikLoadedScreen> createState() =>
      _CreateSonnikLoadedScreenState();
}

class _CreateSonnikLoadedScreenState extends State<CreateSonnikLoadedScreen> {
  @override
  void initState() {
    super.initState();
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.sonnikResultView,
      params: {EventParams.featureName: FeatureName.sonnik.eventValue},
    );
    di.get<ProductAnalyticsService>().trackSonnikResultView();
  }

  @override
  Widget build(BuildContext context) {
    final sonnik = di.get<SonnikProvider>().selectedSonnik;

    if (sonnik == null) {
      return SonnikPageScaffold(
        title: context.l10n.dreamDictionaryTitle,
        child: Center(
          child: Text(
            context.l10n.dreamNoData,
            style: context.textTheme.inverseUrbanistRegular16,
          ),
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
            onDecodeAgainPressed: () =>
                CreateSonnikInitialRoute.pushReplacement(context),
          ),
        ],
      ),
    );
  }
}

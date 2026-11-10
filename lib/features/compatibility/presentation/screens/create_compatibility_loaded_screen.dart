import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/feature_names.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/extensions/datetime_extensions.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/compatibility/presentation/provider/compatibility_provider.dart';
import 'package:asteria_app/features/compatibility/presentation/widgets/compatibility_layout.dart';
import 'package:asteria_app/features/compatibility/presentation/widgets/compability_results.dart';
import 'package:flutter/material.dart';

class CreateCompatibilityLoadedScreen extends StatefulWidget {
  const CreateCompatibilityLoadedScreen({Key? key}) : super(key: key);

  @override
  State<CreateCompatibilityLoadedScreen> createState() =>
      _CreateCompatibilityLoadedScreenState();
}

class _CreateCompatibilityLoadedScreenState
    extends State<CreateCompatibilityLoadedScreen> {
  @override
  void initState() {
    super.initState();
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.compatibilityResultView,
      params: {EventParams.featureName: FeatureName.compatibility.eventValue},
    );
    di.get<ProductAnalyticsService>().trackCompatibilityResultView();
  }

  @override
  Widget build(BuildContext context) {
    final compatibility = di.get<CompatibilityProvider>().selectedCompatibility;

    if (compatibility == null) {
      return BaseScaffold(
        child: Center(
          child: Text(
            context.l10n.compatibilityNoData,
            style: context.textTheme.urbanistRegular16,
          ),
        ),
      );
    }

    return CompatibilityLayout(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
      child: CompabilityResults(
        compatibilityData: compatibility.compatibilityData,
        hisBirthdate: compatibility.firstBirthdate.toShortDate(),
        herBirthdate: compatibility.secondBirthdate.toShortDate(),
        onHistoryPressed: () {
          CreateCompatibilityHistoryRoute.push(context);
        },
      ),
    );
  }
}

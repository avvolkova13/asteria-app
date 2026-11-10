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
  const CreateSonnikInitialScreen({super.key});

  @override
  State<CreateSonnikInitialScreen> createState() =>
      _CreateSonnikInitialScreenState();
}

class _CreateSonnikInitialScreenState extends State<CreateSonnikInitialScreen> {
  final TextEditingController _textController = TextEditingController();
  final ContentProvider _contentProvider = di.get<ContentProvider>();
  final GlobalLoaderService _loaderService = di.get<GlobalLoaderService>();

  static const _featureParam = {EventParams.featureName: 'sonnik'};

  @override
  void initState() {
    super.initState();
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

  Future<void> _onCreateSonnikTap() async {
    if (_textController.text.isEmpty) return;

    final facade = di.get<AnalyticsFacade>();
    final productAnalytics = di.get<ProductAnalyticsService>();
    // Bucket the dream length BEFORE the text leaves this method — the raw
    // text must never be logged. See spec §2.5 R36.
    final dreamLengthBand = LengthBand.fromText(_textController.text);
    facade.trackEvent(
      AnalyticsEvents.sonnikInputCompleted,
      params: _featureParam,
    );
    productAnalytics.trackSonnikDreamSubmit(dreamLengthBand: dreamLengthBand);

    final canMakeRequest = await checkRequestAccess(context, 'sonnik');
    if (canMakeRequest == null) return;
    if (!mounted) return;
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
    _loaderService.show();
    final stopwatch = Stopwatch()..start();
    try {
      final sonnik = await _contentProvider.createSonnik(_textController.text);
      stopwatch.stop();
      facade.trackEvent(
        AnalyticsEvents.calculationCompleted,
        params: {..._featureParam, EventParams.resultStatus: 'success'},
      );
      productAnalytics.trackSonnikGenerationComplete(
        generationStatus: GenerationStatus.success,
        generationSeconds: stopwatch.elapsed.inSeconds,
      );
      if (!mounted) return;
      di.get<SonnikProvider>().selectSonnik(sonnik);
      CreateSonnikLoadedRoute.pushReplacement(context);
    } catch (e) {
      stopwatch.stop();
      facade.trackEvent(
        AnalyticsEvents.calculationCompleted,
        params: {
          ..._featureParam,
          EventParams.resultStatus: 'failed',
          EventParams.failureReason: e.toString(),
        },
      );
      productAnalytics.trackSonnikGenerationComplete(
        generationStatus: GenerationStatus.failed,
        generationSeconds: stopwatch.elapsed.inSeconds,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.dreamCalculationError)),
      );
    } finally {
      _loaderService.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _textController.text.isNotEmpty;

    return SonnikPageScaffold(
      title: context.l10n.dreamDictionaryTitle,
      resizeToAvoidBottomInset: true,
      child: ListView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16,
          18,
          16,
          32 + MediaQuery.of(context).viewInsets.bottom,
        ),
        children: [
          Consumer<MonetizationProvider>(
            builder: (context, monetizationProvider, child) {
              final requestsLeft = monetizationProvider.requestsLeft('sonnik');

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.dreamGreeting,
                          style: context.textTheme.inversePlayfairSemiBold24
                              .copyWith(height: 1.0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const SonnikLiveyaAvatar(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    context.l10n.dreamTellPrompt,
                    style: context.textTheme.inverseUrbanistRegular16.copyWith(
                      color: SonnikPalette.white.withValues(alpha: 0.78),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!monetizationProvider.effectivePro)
                    SonnikQuotaBadge(requestsLeft: requestsLeft),
                  const SizedBox(height: 24),
                  SonnikTextArea(
                    controller: _textController,
                    onChanged: _onTextChanged,
                  ),
                  const SizedBox(height: 18),
                  SonnikGradientButton(
                    text: context.l10n.dreamDecode,
                    onPressed: hasText ? _onCreateSonnikTap : null,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      LotusButtons.text(
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
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

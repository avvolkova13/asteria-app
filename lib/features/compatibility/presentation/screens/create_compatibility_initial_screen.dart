import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/dictionaries/entry_surface.dart';
import 'package:asteria_app/core/analytics/dictionaries/generation_status.dart';
import 'package:asteria_app/core/analytics/dictionaries/limit_period.dart';
import 'package:asteria_app/core/analytics/dictionaries/limit_type.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/feature_names.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/extensions/datetime_extensions.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/utils/utils.dart';
import 'package:asteria_app/features/auth/presentation/widgets/date_picker_bottom_sheet.dart';
import 'package:asteria_app/features/compatibility/presentation/provider/compatibility_provider.dart';
import 'package:asteria_app/features/compatibility/presentation/widgets/compatibility_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateCompatibilityInitialScreen extends StatefulWidget {
  const CreateCompatibilityInitialScreen({
    super.key,
    this.returnCreatedPair = false,
  });

  final bool returnCreatedPair;

  @override
  State<CreateCompatibilityInitialScreen> createState() =>
      _CreateCompatibilityInitialScreenState();
}

class _CreateCompatibilityInitialScreenState
    extends State<CreateCompatibilityInitialScreen> {
  final TextEditingController _partnerNameController = TextEditingController();
  final UserProvider _userProvider = di.get<UserProvider>();
  final ContentProvider _contentProvider = di.get<ContentProvider>();
  final GlobalLoaderService _loaderService = di.get<GlobalLoaderService>();
  DateTime? _partnerSelectedDate;
  bool _submitting = false;

  bool get _canSubmit =>
      _partnerNameController.text.trim().isNotEmpty &&
      _partnerSelectedDate != null;

  @override
  void initState() {
    super.initState();
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.compatibilityInputStarted,
      params: {EventParams.featureName: FeatureName.compatibility.eventValue},
    );
    // ast_compatibility_start — funnel funnel_start event for compatibility.
    di.get<ProductAnalyticsService>().trackCompatibilityStart(
      entrySurface: EntrySurface.home,
    );
  }

  @override
  void dispose() {
    _partnerNameController.dispose();
    super.dispose();
  }

  void _showDatePicker(String title, Function(DateTime) onDateChanged) {
    showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DateTimePickerBottomSheet(
          key: ObjectKey('date_picker'),
          mode: CupertinoDatePickerMode.date,
          initialDate: DateTime(2000, 1, 1),
          minimumDate: DateTime(1900, 1, 1),
          maximumDate: DateTime.now(),
          title: title,
          onDateChanged: (DateTime newDate) {
            onDateChanged(newDate);
          },
        );
      },
    );
  }

  Future<void> _onCreateCompatibilityTap() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await _submitPair();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submitPair() async {
    final user = _userProvider.currentUser;
    final userBirthDate = user?.personalInfo?.birthDate?.birthDate;

    if (userBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.compatibilityFillBirthDate)),
      );
      return;
    }

    if (_partnerSelectedDate == null || _partnerNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.compatibilityFillPartner)),
      );
      return;
    }

    final facade = di.get<AnalyticsFacade>();
    final productAnalytics = di.get<ProductAnalyticsService>();
    final featureParam = {
      EventParams.featureName: FeatureName.compatibility.eventValue,
    };

    facade.trackEvent(
      AnalyticsEvents.compatibilityInputCompleted,
      params: featureParam,
    );
    productAnalytics.trackCompatibilityInputComplete();

    final canMakeRequest = await checkRequestAccess(context, 'compatibility');
    if (canMakeRequest == null) return;
    if (!mounted) return;
    if (!canMakeRequest) {
      productAnalytics.trackCompatibilityLimitReached(
        limitType: LimitType.requests,
        requestsLeft: 0,
        limitPeriod: LimitPeriod.unknown,
      );
      CreateCompatibilityRequestsLeftRoute.push(context);
      return;
    }

    facade.trackEvent(AnalyticsEvents.calculationStarted, params: featureParam);
    _loaderService.showWithSpheres(GlobalLoaderType.compatibility);
    final stopwatch = Stopwatch()..start();
    try {
      final compatibility = await _contentProvider.createCompatibility(
        firstName: user?.name ?? context.l10n.compatibilityYou,
        firstDate: userBirthDate.toIsoDate(),
        secondName: _partnerNameController.text,
        secondDate: _partnerSelectedDate!.toIsoDate(),
      );
      stopwatch.stop();
      facade.trackEvent(
        AnalyticsEvents.compatibilityCalculationCompleted,
        params: {...featureParam, EventParams.resultStatus: 'success'},
      );
      productAnalytics.trackCompatibilityGenerationComplete(
        generationStatus: GenerationStatus.success,
        generationSeconds: stopwatch.elapsed.inSeconds,
      );
      if (!mounted) return;
      try {
        await di.get<CompatibilityProvider>().selectCompatibility(
          compatibility,
        );
      } catch (_) {
        // The calculation is already saved on the server and remains in history.
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.genericRefreshError)),
        );
        return;
      }
      if (!mounted) return;
      if (widget.returnCreatedPair) {
        Navigator.of(context).pop(compatibility);
      } else {
        CreateCompatibilityLoadedRoute.pushReplacement(context);
      }
    } catch (e) {
      stopwatch.stop();
      facade.trackEvent(
        AnalyticsEvents.compatibilityCalculationCompleted,
        params: {
          ...featureParam,
          EventParams.resultStatus: 'failed',
          EventParams.failureReason: e.toString(),
        },
      );
      productAnalytics.trackCompatibilityGenerationComplete(
        generationStatus: GenerationStatus.failed,
        generationSeconds: stopwatch.elapsed.inSeconds,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.compatibilityCalculationError)),
      );
    } finally {
      _loaderService.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompatibilityLayout(
      resizeToAvoidBottomInset: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.compatibilityPartnerDetailsTitle,
            style: context.textTheme.inversePlayfairSemiBold32.copyWith(
              height: 1.18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 26),
          _CompatibilityInputField(
            hintText: context.l10n.commonName,
            controller: _partnerNameController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          _CompatibilityDateField(
            text: _partnerSelectedDate != null
                ? formatDate(context, _partnerSelectedDate, null)
                : null,
            hintText: context.l10n.commonBirthDate,
            onTap: () => _showDatePicker(
              context.l10n.compatibilityPartnerBirthDate,
              (DateTime newDate) {
                setState(() {
                  _partnerSelectedDate = newDate;
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          CompatibilityGradientButton(
            text: context.l10n.compatibilityCalculate,
            onPressed: _canSubmit && !_submitting
                ? _onCreateCompatibilityTap
                : null,
          ),
          const SizedBox(height: 14),
          if (!widget.returnCreatedPair)
            LotusButtons.text(
              onPressed: () => CreateCompatibilityHistoryRoute.push(context),
              child: Text(
                context.l10n.viewHistory,
                style: context.textTheme.tertiaryUrbanistSemiBold14.copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.textTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CompatibilityInputField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _CompatibilityInputField({
    required this.hintText,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF3D2F54).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.28)),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textCapitalization: TextCapitalization.words,
        cursorColor: AppColors.white,
        style: context.textTheme.inverseUrbanistRegular16,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: context.textTheme.tertiaryUrbanistRegular16,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: true,
          fillColor: Colors.transparent,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}

class _CompatibilityDateField extends StatelessWidget {
  final String? text;
  final String hintText;
  final VoidCallback onTap;

  const _CompatibilityDateField({
    required this.text,
    required this.hintText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: text ?? hintText,
      child: LotusTap(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF3D2F54).withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.28),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              text ?? hintText,
              style: text != null
                  ? context.textTheme.inverseUrbanistRegular16
                  : context.textTheme.tertiaryUrbanistRegular16,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/location/city_search_service.dart';
import 'package:asteria_app/core/location/device_location_service.dart';
import 'package:asteria_app/core/location/widgets/city_selection_screen.dart';
import 'package:asteria_app/core/location/suggested_cities.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CurrentLocationControls extends StatefulWidget {
  const CurrentLocationControls({
    super.key,
    this.compact = false,
    this.onLocationUpdateStarted,
    this.onLocationUpdated,
    this.citySearchService,
  }) : city = null,
       cityLabel = null;

  const CurrentLocationControls.city({
    super.key,
    required CurrentLocationModel location,
    required Widget label,
    required this.onLocationUpdateStarted,
    required this.onLocationUpdated,
  }) : city = location,
       cityLabel = label,
       compact = true,
       citySearchService = null;

  final CurrentLocationModel? city;
  final Widget? cityLabel;
  final bool compact;
  final VoidCallback? onLocationUpdateStarted;
  final VoidCallback? onLocationUpdated;
  final CitySearchService? citySearchService;

  @override
  State<CurrentLocationControls> createState() =>
      _CurrentLocationControlsState();
}

class _CurrentLocationControlsState extends State<CurrentLocationControls> {
  bool _isDetecting = false;
  bool _isSavingManual = false;
  List<CitySuggestion> _lastCitySuggestions = const [];
  String? _lastCitySelectedPlaceId;

  Future<void> _detectLocation() async {
    if (_isDetecting) return;
    setState(() => _isDetecting = true);

    try {
      final result = await di
          .get<DeviceLocationService>()
          .detectCurrentLocation(requestPermission: true);
      final location = result.location;
      if (result.status != DeviceLocationStatus.available || location == null) {
        _showLocationError();
        return;
      }

      widget.onLocationUpdateStarted?.call();
      await _saveLocation(location, preserveManualLocation: false);
    } finally {
      if (mounted) setState(() => _isDetecting = false);
    }
  }

  bool _choosing = false;

  Future<void> _openCitySelection() async {
    if (_choosing || _isSavingManual) return;
    _choosing = true;
    try {
      final city = widget.city;
      if (city != null) {
        final decision = await _showCityConfirmation(city);
        if (!mounted || decision != false) return;
      }
      var initial = city == null
          ? _lastCitySuggestions
          : suggestedCities(city, Localizations.localeOf(context).languageCode);
      var selected = city == null ? _lastCitySelectedPlaceId : 'current';
      final view = View.of(context);
      final topInset = view.padding.top / view.devicePixelRatio + 44;
      while (true) {
        if (!mounted) return;
        final pageTheme = Theme.of(context);
        final picker = CitySelectionScreen(
          citySearchService: widget.citySearchService,
          initialSuggestions: initial,
          initialSelectedPlaceId: selected,
          asSheet: city != null,
        );
        final result = city != null
            ? await showModalBottomSheet<CitySelectionResult>(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                backgroundColor: Colors.transparent,
                barrierColor: ModalGlassTokens.barrier,
                builder: (sheetContext) => FractionallySizedBox(
                  heightFactor:
                      (1 - topInset / MediaQuery.sizeOf(sheetContext).height)
                          .clamp(0.25, 1.0)
                          .toDouble(),
                  child: picker,
                ),
              )
            : await Navigator.of(context).push<CitySelectionResult>(
                MaterialPageRoute(
                  builder: (_) => Theme(data: pageTheme, child: picker),
                ),
              );
        if (!mounted || result == null) return;
        selected = result.suggestion.placeId;
        initial = city == null
            ? result.suggestions
            : [
                result.suggestion,
                ...initial.where((s) => s.placeId != selected),
              ];
        _lastCitySuggestions = initial;
        _lastCitySelectedPlaceId = selected;
        final confirmed = await _showCityConfirmation(result.location);
        if (!mounted || confirmed == null) return;
        if (!confirmed) continue;
        if (result.suggestion.placeId == 'current') return;
        setState(() => _isSavingManual = true);
        widget.onLocationUpdateStarted?.call();
        final onUpdated = widget.onLocationUpdated;
        try {
          await _saveLocation(result.location, preserveManualLocation: false);
        } catch (_) {
          onUpdated?.call();
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(context.l10n.citySaveError)));
          }
        }
        return;
      }
    } finally {
      _choosing = false;
      if (mounted && _isSavingManual) setState(() => _isSavingManual = false);
    }
  }

  Future<bool?> _showCityConfirmation(CurrentLocationModel location) {
    return showDialog<bool>(
      context: context,
      barrierColor: ModalGlassTokens.barrier,
      useSafeArea: false,
      builder: (dialogContext) => SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: EdgeInsets.only(
            top: (103 - MediaQuery.paddingOf(dialogContext).top)
                .clamp(0, 103)
                .toDouble(),
          ),
          child: Align(
            alignment: Alignment.topRight,
            child: SingleChildScrollView(
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: 300,
                  child: _CityConfirmationSheet(
                    location: location,
                    onConfirm: () => Navigator.of(dialogContext).pop(true),
                    onChange: () => Navigator.of(dialogContext).pop(false),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveLocation(
    CurrentLocationModel location, {
    required bool preserveManualLocation,
  }) async {
    final onUpdated = widget.onLocationUpdated;
    await di.get<UserProvider>().updateCurrentLocation(
      location,
      preserveManualLocation: preserveManualLocation,
    );
    try {
      await di.get<ContentProvider>().loadMoonPhase();
    } catch (_) {
      // The selected location is still saved. A later content refresh can retry.
    }
    onUpdated?.call();
  }

  void _showLocationError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.locationPermissionDenied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cityLabel case final label?) {
      return Semantics(
        button: true,
        child: LotusInkTap(
          onTap: _isSavingManual ? null : _openCitySelection,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(height: 44, child: label),
        ),
      );
    }
    final currentLocation = di.get<UserProvider>().currentUser?.currentLocation;
    final sourceLabel = currentLocation?.source == CurrentLocationSource.manual
        ? context.l10n.currentLocationManualLabel
        : context.l10n.currentLocationAutoLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: AsteriaEntrance.sections([
        if (currentLocation != null) ...[
          Text(
            currentLocation.location,
            style: context.textTheme.inverseUrbanistRegular17.copyWith(
              color: AppColors.textInverse,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sourceLabel,
            style: context.textTheme.inverseUrbanistRegular14.copyWith(
              color: AppColors.textInverse.withValues(alpha: 0.62),
            ),
          ),
          const SizedBox(height: 14),
        ],
        _LocationPrimaryButton(
          isLoading: _isDetecting,
          title: context.l10n.locationAllowButton,
          icon: CupertinoIcons.location_fill,
          onPressed: _detectLocation,
        ),
        const SizedBox(height: 12),
        _LocationSecondaryButton(
          isLoading: _isSavingManual,
          title: context.l10n.locationManualButton,
          icon: CupertinoIcons.search,
          onPressed: _openCitySelection,
        ),
      ]),
    );
  }
}

class _CityConfirmationSheet extends StatelessWidget {
  const _CityConfirmationSheet({
    required this.location,
    required this.onConfirm,
    required this.onChange,
  });

  final CurrentLocationModel location;
  final VoidCallback onConfirm;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.text1.copyWith(color: AppColors.textInverse);
    return ModalGlassSurface(
      key: const ValueKey('city-confirmation-sheet'),
      color: ModalGlassTokens.surface,
      sheet: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: AsteriaEntrance.sections([
            Text.rich(
              TextSpan(
                style: style,
                children: [
                  TextSpan(
                    text: location.location.split(',').first.trim(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: ',\n${context.l10n.cityConfirmationQuestion}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _CityConfirmationButton(
              text: context.l10n.citySelectionConfirm,
              filled: true,
              onPressed: onConfirm,
            ),
            const SizedBox(height: 8),
            _CityConfirmationButton(
              text: context.l10n.citySelectionChange,
              filled: false,
              onPressed: onChange,
            ),
          ]),
        ),
      ),
    );
  }
}

class _CityConfirmationButton extends StatelessWidget {
  const _CityConfirmationButton({
    required this.text,
    required this.filled,
    required this.onPressed,
  });

  final String text;
  final bool filled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return LotusButtons.text(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.standard,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        backgroundColor: filled ? const Color(0xFF6E4BFF) : Colors.transparent,
        foregroundColor: AppColors.textInverse,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: filled ? null : const BorderSide(color: Color(0xFFE9E9EA)),
        textStyle: AppTypography.text1SemiBold,
      ),
      child: Text(text),
    );
  }
}

class _LocationSecondaryButton extends StatelessWidget {
  const _LocationSecondaryButton({
    required this.isLoading,
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  final bool isLoading;
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: CardLensDecoration.button(
          enabled: !isLoading,
          color: const Color(0xFF171122),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE6994D).withValues(alpha: 0.78),
          ),
        ),
        child: LotusButtons.textIcon(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : ClayIcon(icon, color: const Color(0xFFE6994D)),
          label: Text(
            title,
            style: AppTypography.text1SemiBold.copyWith(color: const Color(0xFFE6994D)),
          ),
        ),
      ),
    );
  }
}

class _LocationPrimaryButton extends StatelessWidget {
  const _LocationPrimaryButton({
    required this.isLoading,
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  final bool isLoading;
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: CardLensDecoration.button(
          enabled: !isLoading,
          gradient: const LinearGradient(
            colors: [Color(0xFF6E4BFF), Color(0xFF5A3FD1)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: LotusButtons.textIcon(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : ClayIcon(icon, color: AppColors.white),
          label: Text(
            title,
            style: AppTypography.text1SemiBold.copyWith(color: AppColors.white),
          ),
        ),
      ),
    );
  }
}

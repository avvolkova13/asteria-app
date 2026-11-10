import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/location/city_search_service.dart';
import 'package:asteria_app/core/location/device_location_service.dart';
import 'package:asteria_app/core/location/widgets/city_selection_screen.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CurrentLocationControls extends StatefulWidget {
  const CurrentLocationControls({
    super.key,
    this.compact = false,
    this.onLocationUpdateStarted,
    this.onLocationUpdated,
    this.citySearchService,
  });

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

  Future<void> _openCitySelection() async {
    if (_isSavingManual) return;
    final currentTheme = Theme.of(context);
    final result = await Navigator.of(context).push<CitySelectionResult>(
      MaterialPageRoute(
        builder: (_) => Theme(
          data: currentTheme,
          child: CitySelectionScreen(
            citySearchService: widget.citySearchService,
            initialSuggestions: _lastCitySuggestions,
            initialSelectedPlaceId: _lastCitySelectedPlaceId,
          ),
        ),
      ),
    );
    if (!mounted || result == null) return;

    _lastCitySuggestions = result.suggestions;
    _lastCitySelectedPlaceId = result.suggestion.placeId;

    final confirmed = await _showCityConfirmation(result.location);
    if (!mounted) return;
    if (confirmed == false) {
      await _openCitySelection();
      return;
    }
    if (confirmed != true) return;

    setState(() => _isSavingManual = true);
    widget.onLocationUpdateStarted?.call();
    try {
      await _saveLocation(result.location, preserveManualLocation: false);
    } finally {
      if (mounted) setState(() => _isSavingManual = false);
    }
  }

  Future<bool?> _showCityConfirmation(CurrentLocationModel location) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      useSafeArea: false,
      builder: (dialogContext) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 103),
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
        );
      },
    );
  }

  Future<void> _saveLocation(
    CurrentLocationModel location, {
    required bool preserveManualLocation,
  }) async {
    await di.get<UserProvider>().updateCurrentLocation(
      location,
      preserveManualLocation: preserveManualLocation,
    );
    try {
      await di.get<ContentProvider>().loadMoonPhase();
    } catch (_) {
      // The selected location is still saved. A later content refresh can retry.
    }
    widget.onLocationUpdated?.call();
  }

  void _showLocationError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.locationPermissionDenied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = di.get<UserProvider>().currentUser?.currentLocation;
    final sourceLabel = currentLocation?.source == CurrentLocationSource.manual
        ? context.l10n.currentLocationManualLabel
        : context.l10n.currentLocationAutoLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
      ],
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
    return Container(
      key: const ValueKey('city-confirmation-sheet'),
      height: 192,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1328),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.26)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E4BFF).withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            location.location,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.inverseUrbanistRegular14.copyWith(
              color: AppColors.textInverse,
              height: 1.15,
            ),
          ),
          const Spacer(),
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
        ],
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
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: filled
              ? const LinearGradient(
                  colors: [Color(0xFF6E4BFF), Color(0xFF5A3FD1)],
                )
              : null,
          color: filled ? null : AppColors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: filled
              ? null
              : Border.all(color: AppColors.white.withValues(alpha: 0.22)),
        ),
        child: TextButton(
          onPressed: onPressed,
          child: Text(
            text,
            style: context.textTheme.inverseUrbanistRegular14.copyWith(
              color: AppColors.textInverse,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
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
        decoration: BoxDecoration(
          color: const Color(0xFF171122),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE6994D).withValues(alpha: 0.78),
          ),
        ),
        child: TextButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon, color: const Color(0xFFE6994D)),
          label: Text(
            title,
            style: context.textTheme.inverseUrbanistRegular17.copyWith(
              color: const Color(0xFFE6994D),
              fontWeight: FontWeight.w700,
            ),
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
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6E4BFF), Color(0xFF5A3FD1)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon, color: AppColors.white),
          label: Text(
            title,
            style: context.textTheme.inverseUrbanistRegular17.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

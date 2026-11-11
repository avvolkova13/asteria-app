import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/personalized_lunar_month_model.dart';
import 'package:asteria_app/app/data/models/moon_phase/moon_phase_day_image.dart';
import 'package:asteria_app/app/data/models/moon_phase/moon_phase_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/extensions/string_extensions.dart';
import 'package:asteria_app/core/localization/locale_formatters.dart';
import 'package:asteria_app/core/location/current_location_resolver.dart';
import 'package:asteria_app/core/location/device_location_service.dart';
import 'package:asteria_app/core/location/widgets/current_location_controls.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/features/home/home.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/models/day_status_advice.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_section_heading.dart';
import 'package:asteria_app/features/home/presentation/widgets/day_status_icon.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

int _moonAgeDayIndexFromLunarDay(int lunarDay) {
  return ((lunarDay - 1) % 30 + 30) % 30;
}

int _moonAgeImageIndex({required int lunarDay, required int? moonAgeDayIndex}) {
  if (moonAgeDayIndex != null &&
      moonAgeDayIndex >= 0 &&
      moonAgeDayIndex <= 29) {
    return moonAgeDayIndex;
  }
  return _moonAgeDayIndexFromLunarDay(lunarDay);
}

// Use the same five spheres as the calendar's aggregate category status.
// A missing recommendation is unknown, not a neutral forecast.
DayStatus? _dayStatus(PersonalizedLunarDayModel? day) {
  if (day == null) return null;
  var score = 0;
  for (final sphere in const [
    'beauty',
    'gardening',
    'health',
    'work_and_rest',
    'relationships',
  ]) {
    final recommendation = day.spheres[sphere];
    if (recommendation == null) return null;
    score += switch (recommendation.status) {
      RecommendationStatus.favorable => 1,
      RecommendationStatus.neutral => 0,
      RecommendationStatus.unfavorable => -1,
    };
  }
  return DayStatus.fromValue(score);
}

class MoonPhaseWidget extends StatefulWidget {
  const MoonPhaseWidget({super.key});

  @override
  State<MoonPhaseWidget> createState() => _MoonPhaseWidgetState();
}

class _MoonPhaseWidgetState extends State<MoonPhaseWidget> {
  static const _minSwipeVelocity = 100.0;
  static const _dayStripWidth = 418.0;
  static const _dayTileWidth = 46.0;
  static const _dayTileHeight = 102.0;
  static const _dayTileGap = 16.0;
  static const _accentOrange = Color(0xFFE6994D);
  static const _accentOrangeLight = Color(0xFFF3B76A);
  static const _buttonPurple = Color(0xFF6E4BFF);
  static const _buttonPurpleDark = Color(0xFF5A3FD1);
  static const _dayCardBackground = Color(0x1A9A7DB8);

  static const _orangeGradient = LinearGradient(
    colors: [_accentOrange, _accentOrangeLight, _accentOrange],
  );

  static const _purpleGradient = LinearGradient(
    colors: [_buttonPurple, _buttonPurpleDark],
  );

  bool _isLoading = false;
  bool _isLocationUpdateInProgress = false;
  bool _isMoonPhaseLoadCheckInFlight = false;
  MoonPhaseModel? _displayedMoonPhase;
  bool _slideDirectionIsNext = true;
  bool _loadFailed = false;
  String? _lastLocationKey;
  String? _lastPersonalizedMonthKey;
  bool _isPersonalizedMonthLoadInFlight = false;
  bool _didAttemptAutoLocationRefresh = false;
  final Map<DateTime, MoonPhaseModel> _moonPhasesByDate = {};
  final Set<DateTime> _prefetchingDates = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoadMoonPhase();
    });
  }

  Future<void> _checkAndLoadMoonPhase() async {
    if (!mounted) return;
    if (_isLocationUpdateInProgress) return;
    if (_isMoonPhaseLoadCheckInFlight) return;

    _isMoonPhaseLoadCheckInFlight = true;
    try {
      final userProvider = di.get<UserProvider>();
      final user = userProvider.currentUser;
      final locationResolution = const CurrentLocationResolver().resolve(user);

      if (locationResolution.status ==
          CurrentLocationResolutionStatus.needsSetup) {
        await _tryLoadAutoLocationIfAlreadyAllowed();
        if (!mounted) return;
      } else {
        await _tryRefreshAutoLocationIfAlreadyAllowed(locationResolution);
        if (!mounted) return;
        setState(() {});
      }

      final freshUser = userProvider.currentUser;
      final freshLocationResolution = const CurrentLocationResolver().resolve(
        freshUser,
      );
      if (freshLocationResolution.status ==
          CurrentLocationResolutionStatus.needsSetup) {
        return;
      }

      if (freshUser?.moonPhase == null ||
          freshUser?.moonPhase?.isToday() == false) {
        setState(() {
          _isLoading = true;
        });

        try {
          final contentProvider = di.get<ContentProvider>();
          await contentProvider.loadMoonPhase();
        } catch (e) {
          debugPrint('[ERROR] Ошибка загрузки фазы луны: $e');
        } finally {
          if (mounted) {
            setState(() {
              _loadFailed = userProvider.currentUser?.moonPhase == null;
              _isLoading = false;
            });
          }
        }
      }
      await _loadPersonalizedMonthForDate(DateTime.now());
    } finally {
      _isMoonPhaseLoadCheckInFlight = false;
    }
  }

  Future<void> _tryLoadAutoLocationIfAlreadyAllowed() async {
    if (!di.isRegistered<DeviceLocationService>()) return;
    final result = await di.get<DeviceLocationService>().detectCurrentLocation(
      requestPermission: false,
    );
    final location = result.location;
    if (result.status != DeviceLocationStatus.available || location == null) {
      return;
    }
    _didAttemptAutoLocationRefresh = true;
    await di.get<UserProvider>().updateCurrentLocation(
      location,
      preserveManualLocation: true,
    );
  }

  Future<void> _tryRefreshAutoLocationIfAlreadyAllowed(
    CurrentLocationResolution locationResolution,
  ) async {
    final currentLocation = locationResolution.location;
    if (_didAttemptAutoLocationRefresh ||
        currentLocation == null ||
        currentLocation.source != CurrentLocationSource.auto ||
        !di.isRegistered<DeviceLocationService>()) {
      return;
    }

    _didAttemptAutoLocationRefresh = true;
    final result = await di.get<DeviceLocationService>().detectCurrentLocation(
      requestPermission: false,
    );
    final refreshedLocation = result.location;
    if (result.status != DeviceLocationStatus.available ||
        refreshedLocation == null ||
        _isSameLocation(currentLocation, refreshedLocation)) {
      return;
    }

    await di.get<UserProvider>().updateCurrentLocation(
      refreshedLocation,
      preserveManualLocation: true,
    );
  }

  bool _isSameLocation(
    CurrentLocationModel currentLocation,
    CurrentLocationModel nextLocation,
  ) {
    return (currentLocation.latitude - nextLocation.latitude).abs() < 0.0001 &&
        (currentLocation.longitude - nextLocation.longitude).abs() < 0.0001 &&
        currentLocation.location.trim() == nextLocation.location.trim();
  }

  Future<void> _changeDate(
    MoonPhaseModel currentMoonPhase, {
    required bool isNextDay,
  }) {
    return _changeDateByOffset(currentMoonPhase, isNextDay ? 1 : -1);
  }

  Future<void> _changeDateByOffset(
    MoonPhaseModel currentMoonPhase,
    int dayOffset,
  ) async {
    if (_isLoading || dayOffset == 0) return;

    _slideDirectionIsNext = dayOffset > 0;
    final currentDate = currentMoonPhase.date.fromRussianShortDate();
    final targetDate = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day + dayOffset,
    );
    final locationKey = _lastLocationKey;

    setState(() => _isLoading = true);
    try {
      final contentProvider = di.get<ContentProvider>();
      final moonPhase =
          _moonPhasesByDate[targetDate] ??
          await contentProvider.getMoonPhaseForDate(targetDate);
      if (!mounted || locationKey != _lastLocationKey) return;
      await _loadPersonalizedMonthForDate(targetDate);
      if (mounted && locationKey == _lastLocationKey) {
        setState(() {
          _displayedMoonPhase = moonPhase;
          _moonPhasesByDate[_normalizeDate(targetDate)] = moonPhase;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[ERROR] Ошибка загрузки фазы луны: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(SnackBar(content: Text(context.l10n.loadingDataError)));
      }
    }
  }

  void _handleHorizontalDragEnd(
    DragEndDetails details,
    MoonPhaseModel moonPhase,
  ) {
    final velocity = details.primaryVelocity ?? 0;
    if (_isLoading || velocity.abs() <= _minSwipeVelocity) return;
    LotusFeedback.selection();
    if (velocity < -_minSwipeVelocity) {
      _changeDate(moonPhase, isNextDay: true);
    } else if (velocity > _minSwipeVelocity) {
      _changeDate(moonPhase, isNextDay: false);
    }
  }

  Widget _buildLoadingContent() {
    return Container(
      key: ValueKey(_loadFailed ? 'error' : 'loading'),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            decoration: CardLensDecoration(
              color: const Color(0xFF1D1429),
              borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
              border: Border.all(color: const Color(0x40FFFFFF)),
            ),
            child: Column(
              children: [
                if (!_loadFailed)
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                const SizedBox(height: 18),
                Text(
                  _loadFailed
                      ? context.l10n.loadingDataError
                      : context.l10n.moonPhaseLoadingTitle,
                  textAlign: TextAlign.center,
                  style: context.textTheme.playfairSemiBold24.copyWith(
                    color: const Color(0xFFE6994D),
                  ),
                ),
                const SizedBox(height: 8),
                if (_loadFailed)
                  LotusButtons.text(
                    onPressed: () {
                      setState(() {
                        _loadFailed = false;
                        _lastPersonalizedMonthKey = null;
                      });
                      _checkAndLoadMoonPhase();
                    },
                    child: Text(context.l10n.retry),
                  )
                else
                  Text(
                    context.l10n.moonPhaseLoadingDescription,
                    textAlign: TextAlign.center,
                    style: context.textTheme.inverseUrbanistRegular17.copyWith(
                      color: AppColors.textInverse.withValues(alpha: 0.82),
                      height: 1.25,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(MoonPhaseModel moonPhase) {
    final displayedMoonPhase = _displayedMoonPhase ?? moonPhase;
    final selectedDate = displayedMoonPhase.date.fromRussianShortDate();
    _moonPhasesByDate[_normalizeDate(selectedDate)] = displayedMoonPhase;
    _schedulePersonalizedMonthLoad(selectedDate);
    final personalizedDay = di
        .get<ContentProvider>()
        .getPersonalizedLunarDayByDate(selectedDate);
    if (personalizedDay == null) {
      return _buildLoadingContent();
    }
    _scheduleNeighborPhasePrefetch(displayedMoonPhase);
    final location = const CurrentLocationResolver()
        .resolve(di.get<UserProvider>().currentUser)
        .location;

    const inset = EdgeInsets.symmetric(horizontal: 16);
    return Column(
      key: const ValueKey('phase-content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: AsteriaEntrance.sections([
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: (details) =>
              _handleHorizontalDragEnd(details, displayedMoonPhase),
          child: _buildDayStrip(displayedMoonPhase, selectedDate),
        ),
        const SizedBox(height: 1),
        Padding(
          padding: inset,
          child: _LocationBlock(
            location: location,
            onLocationUpdateStarted: _startLocationUpdate,
            onLocationUpdated: _finishLocationUpdate,
          ),
        ),
        const SizedBox(height: 1),
        Padding(
          padding: inset,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragEnd: (details) =>
                _handleHorizontalDragEnd(details, displayedMoonPhase),
            child: _MoonPhaseCard(
              moonPhase: displayedMoonPhase,
              personalizedDay: personalizedDay,
              slideDirectionIsNext: _slideDirectionIsNext,
            ),
          ),
        ),
      ]),
    );
  }

  void _startLocationUpdate() {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _isLocationUpdateInProgress = true;
    });
  }

  void _finishLocationUpdate() {
    if (!mounted) return;
    setState(() {
      _displayedMoonPhase = null;
      _moonPhasesByDate.clear();
      final location = const CurrentLocationResolver()
          .resolve(di.get<UserProvider>().currentUser)
          .location;
      if (location?.source == CurrentLocationSource.auto) {
        _didAttemptAutoLocationRefresh = true;
      }
      _isLoading = false;
      _isLocationUpdateInProgress = false;
      _lastPersonalizedMonthKey = null;
    });
  }

  Widget _buildLocationSetup() {
    return Container(
      key: const ValueKey('location-setup'),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
            decoration: CardLensDecoration(
              color: const Color(0xFF1D1429),
              borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
              border: Border.all(color: const Color(0x40FFFFFF)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6E4BFF).withValues(alpha: 0.16),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AsteriaEntrance.sections([
                Text(
                  context.l10n.moonLocationSetupTitle,
                  style: context.textTheme.playfairSemiBold24.copyWith(
                    color: const Color(0xFFE6994D),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.moonLocationSetupDescription,
                  style: context.textTheme.inverseUrbanistRegular17.copyWith(
                    color: AppColors.textInverse.withValues(alpha: 0.88),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 18),
                CurrentLocationControls(
                  onLocationUpdateStarted: _startLocationUpdate,
                  onLocationUpdated: _finishLocationUpdate,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayStrip(MoonPhaseModel moonPhase, DateTime selectedDate) {
    Widget tileForOffset(int offset) {
      final date = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day + offset,
      );
      return _MoonDayTile(
        date: date,
        phaseImagePath: _moonImageForDate(moonPhase, date),
        hasPrimaryPhase: _hasPrimaryPhaseForDate(date),
        status: _dayStatus(
          di.get<ContentProvider>().getPersonalizedLunarDayByDate(date),
        ),
        isSelected: offset == 0,
        onTap: _isLoading || offset == 0
            ? null
            : () => _changeDateByOffset(moonPhase, offset),
      );
    }

    // Civil-day coordinates keep neighboring tiles on a single moving rail,
    // including across month and daylight-saving boundaries.
    final day =
        DateTime.utc(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        ).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 410);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _dayStripWidth),
        child: SizedBox(
          height: _dayTileHeight,
          child: LayoutBuilder(
            builder: (context, bounds) {
              const stride = _dayTileWidth + _dayTileGap;
              return TweenAnimationBuilder<double>(
                tween: Tween(end: day.toDouble()),
                duration: duration,
                curve: Curves.easeInOutCubic,
                builder: (context, position, _) {
                  final halfCount =
                      (bounds.maxWidth + _dayTileWidth) / (2 * stride);
                  return Stack(
                    children: [
                      for (
                        var i = (position - halfCount).ceil();
                        i <= (position + halfCount).floor();
                        i++
                      )
                        Positioned(
                          key: ValueKey(i),
                          left:
                              (bounds.maxWidth - _dayTileWidth) / 2 +
                              (i - position) * stride,
                          top: 0,
                          child: tileForOffset(i - day),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _moonImageForDate(MoonPhaseModel selectedMoonPhase, DateTime date) {
    final moonPhase = _moonPhasesByDate[_normalizeDate(date)];
    final personalizedDay = di
        .get<ContentProvider>()
        .getPersonalizedLunarDayByDate(date);
    final moonAgeDayIndex = personalizedDay != null
        ? _moonAgeImageIndex(
            lunarDay: personalizedDay.lunarContext.lunarDay,
            moonAgeDayIndex: personalizedDay.lunarContext.moonAgeDayIndex,
          )
        : (moonPhase == null
              ? _moonAgeDayIndexForDate(selectedMoonPhase, date)
              : _moonAgeDayIndexFromLunarDay(moonPhase.lunarDay));

    return MoonPhaseDayImage.resolve(moonAgeDayIndex);
  }

  int _moonAgeDayIndexForDate(MoonPhaseModel selectedMoonPhase, DateTime date) {
    final selectedDate = _normalizeDate(
      selectedMoonPhase.date.fromRussianShortDate(),
    );
    final offset = _normalizeDate(date).difference(selectedDate).inDays;
    final imageDay = _moonAgeDayIndexFromLunarDay(selectedMoonPhase.lunarDay);
    return (imageDay + offset) % 30;
  }

  bool _hasPrimaryPhaseForDate(DateTime date) {
    final personalizedDay = di
        .get<ContentProvider>()
        .getPersonalizedLunarDayByDate(date);
    return personalizedDay?.lunarContext.phaseEvent != null ||
        (_moonPhasesByDate[_normalizeDate(date)]?.hasPrimaryPhase ?? false);
  }

  void _scheduleNeighborPhasePrefetch(MoonPhaseModel selectedMoonPhase) {
    final selectedDate = selectedMoonPhase.date.fromRussianShortDate();
    final datesToLoad = <DateTime>[];

    for (var offset = -3; offset <= 3; offset++) {
      final date = _normalizeDate(selectedDate.add(Duration(days: offset)));
      if (_moonPhasesByDate.containsKey(date) ||
          _prefetchingDates.contains(date)) {
        continue;
      }
      datesToLoad.add(date);
      _prefetchingDates.add(date);
    }

    if (datesToLoad.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _prefetchMoonPhases(datesToLoad);
    });
  }

  Future<void> _prefetchMoonPhases(List<DateTime> dates) async {
    final contentProvider = di.get<ContentProvider>();
    final locationKey = _lastLocationKey;
    var hasUpdates = false;

    for (final date in dates) {
      if (!mounted || locationKey != _lastLocationKey) return;
      try {
        final moonPhase = await contentProvider.getMoonPhaseForDate(date);
        if (!mounted || locationKey != _lastLocationKey) return;
        _moonPhasesByDate[_normalizeDate(date)] = moonPhase;
        hasUpdates = true;
      } catch (e) {
        debugPrint('[ERROR] Ошибка предзагрузки фазы луны: $e');
      } finally {
        if (locationKey == _lastLocationKey) {
          _prefetchingDates.remove(_normalizeDate(date));
        }
      }
    }

    if (mounted && hasUpdates) {
      setState(() {});
    }
  }

  void _schedulePersonalizedMonthLoad(DateTime date) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadPersonalizedMonthForDate(date);
    });
  }

  Future<void> _loadPersonalizedMonthForDate(DateTime date) async {
    if (_isPersonalizedMonthLoadInFlight || _loadFailed) return;
    final monthKey = '${date.year}-${date.month}';
    if (_lastPersonalizedMonthKey == monthKey) return;

    final locationKey = _lastLocationKey;
    _isPersonalizedMonthLoadInFlight = true;
    try {
      await di.get<ContentProvider>().loadPersonalizedLunarMonth(date);
      if (!mounted || locationKey != _lastLocationKey) return;
      setState(() {
        _lastPersonalizedMonthKey = monthKey;
      });
    } catch (e) {
      debugPrint('[ERROR] Ошибка загрузки персонального лунного календаря: $e');
      if (mounted && locationKey == _lastLocationKey) {
        setState(() => _loadFailed = true);
      }
    } finally {
      _isPersonalizedMonthLoadInFlight = false;
    }
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String? _locationKey(CurrentLocationResolution resolution) {
    final location = resolution.location;
    if (location == null) return null;
    return '${location.latitude.toStringAsFixed(4)}:${location.longitude.toStringAsFixed(4)}:${location.source.name}';
  }

  bool _shouldWaitForAutoLocationRefresh(
    CurrentLocationResolution locationResolution,
  ) {
    final location = locationResolution.location;
    return locationResolution.status !=
            CurrentLocationResolutionStatus.needsSetup &&
        location?.source == CurrentLocationSource.auto &&
        !_didAttemptAutoLocationRefresh &&
        di.isRegistered<DeviceLocationService>();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _MoonPhaseHeader(),
        ).withEntrance(),
        const SizedBox(height: 16),
        Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            final user = userProvider.currentUser;
            final locationResolution = const CurrentLocationResolver().resolve(
              user,
            );
            final locationKey = _locationKey(locationResolution);
            if (locationKey != _lastLocationKey) {
              _lastLocationKey = locationKey;
              if (!_isLocationUpdateInProgress) _isLoading = false;
              _loadFailed = false;
              _displayedMoonPhase = null;
              _moonPhasesByDate.clear();
              _prefetchingDates.clear();
              _lastPersonalizedMonthKey = null;
            }
            final duration = reduced
                ? Duration.zero
                : const Duration(milliseconds: 360);
            Widget surface(Widget child) => AnimatedSize(
              alignment: Alignment.topCenter,
              duration: duration,
              curve: Curves.easeInOutCubic,
              child: AnimatedSwitcher(
                duration: duration,
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                layoutBuilder: _overlayPrevious,
                child: child,
              ),
            );

            if (locationResolution.status ==
                CurrentLocationResolutionStatus.needsSetup) {
              return surface(_buildLocationSetup());
            }

            if (_shouldWaitForAutoLocationRefresh(locationResolution)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _checkAndLoadMoonPhase();
              });
              return surface(_buildLoadingContent());
            }

            final moonPhase = user?.moonPhase;
            final hasContent = _displayedMoonPhase != null || moonPhase != null;

            if (!hasContent) {
              if (!_isLoading && !_isLocationUpdateInProgress && !_loadFailed) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _checkAndLoadMoonPhase();
                });
              }
              return surface(_buildLoadingContent());
            }

            return surface(_buildContent(_displayedMoonPhase ?? moonPhase!));
          },
        ),
      ],
    );
  }
}

// Outgoing surfaces fade in place without taking input or holding the old height.
Widget _overlayPrevious(Widget? current, List<Widget> previous) => Stack(
  alignment: Alignment.topCenter,
  children: [
    for (final old in previous)
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: ExcludeSemantics(child: IgnorePointer(child: old)),
      ),
    ?current,
  ],
);

class _MoonDayTile extends StatelessWidget {
  const _MoonDayTile({
    required this.date,
    required this.phaseImagePath,
    required this.hasPrimaryPhase,
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final String phaseImagePath;
  final bool hasPrimaryPhase;
  final DayStatus? status;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected
        ? AppColors.textPrimary
        : AppColors.textInverse;
    final weekdayOpacity = isSelected ? 0.8 : 0.5;
    final locale = Localizations.localeOf(context);

    return LotusFeedback(
      onActivate: onTap,
      keyboard: true,
      builder: (activate) => Semantics(
        button: true,
        selected: isSelected,
        label: [
          _formatWeekday(date, locale),
          _formatDayMonth(date, locale),
          if (status != null) status!.title(context).replaceAll('\n', ' '),
          if (hasPrimaryPhase) context.l10n.moonPhaseChange,
        ].join(', '),
        onTap: activate,
        child: ExcludeSemantics(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: activate,
            child: AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 310),
              curve: Curves.easeInOut,
              width: _MoonPhaseWidgetState._dayTileWidth,
              height: _MoonPhaseWidgetState._dayTileHeight,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? const [
                          Color(0xFFFFD59F),
                          Color(0xFFF3B76A),
                          Color(0xFFDB8E4F),
                        ]
                      : const [
                          Color(0xFF41354F),
                          Color(0xFF241B30),
                          Color(0xFF171120),
                        ],
                  stops: const [0, .40, 1],
                ),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFFDDB0)
                      : const Color(0xFF5A4967),
                  width: .8,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 14,
                    child: Center(
                      child: status != null
                          ? DayStatusIcon(
                              status: status!,
                              size: 14,
                              excludeFromSemantics: true,
                            )
                          : hasPrimaryPhase
                          ? Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.textPrimary
                                    : _MoonPhaseWidgetState._accentOrangeLight,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                    ),
                  ),
                  SizedBox(
                    height: 14,
                    child: Center(
                      child: Text(
                        _formatWeekday(date, locale),
                        style: context.textTheme.urbanistRegular12.copyWith(
                          color: textColor.withValues(alpha: weekdayOpacity),
                          fontFamily: 'Onest',
                          height: 1,
                          letterSpacing: -0.41,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 14,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _formatDayMonth(date, locale),
                          maxLines: 1,
                          style:
                              (isSelected
                                      ? context.textTheme.urbanistSemiBold12
                                      : context.textTheme.urbanistRegular12)
                                  .copyWith(
                                    color: textColor,
                                    fontFamily: 'Onest',
                                    height: 1,
                                    letterSpacing: -0.41,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  _TintedMoonImage(
                    imagePath: phaseImagePath,
                    size: 37,
                    shadowBlur: 4,
                    shadowColor: const Color(0x40000000),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _formatWeekday(DateTime date, Locale locale) {
    return DateFormat(
      'EE',
      locale.toLanguageTag(),
    ).format(date).replaceAll('.', '').toUpperCase();
  }

  static String _formatDayMonth(DateTime date, Locale locale) {
    return LocaleFormatters.dayMonth(date, locale).replaceAll('.', '');
  }
}

class _MoonPhaseCard extends StatelessWidget {
  const _MoonPhaseCard({
    required this.moonPhase,
    required this.personalizedDay,
    required this.slideDirectionIsNext,
  });

  final MoonPhaseModel moonPhase;
  final PersonalizedLunarDayModel personalizedDay;
  final bool slideDirectionIsNext;

  @override
  Widget build(BuildContext context) {
    final lunarDay = personalizedDay.lunarContext.lunarDay;
    final status = _dayStatus(personalizedDay);
    final phase =
        moonPhase.phaseEvent?.phase ??
        personalizedDay.lunarContext.phaseEvent?.phase ??
        personalizedDay.lunarContext.moonPhase;
    final description = personalizedDay.dailyBackground.summary;
    final eventTime = moonPhase.phaseEvent?.localTimeLabel;

    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 410);
    final dateKey = ValueKey(moonPhase.date);
    return ClipRect(
      child: AnimatedSize(
        duration: duration,
        alignment: Alignment.topCenter,
        curve: Curves.easeInOutCubic,
        child: AnimatedSwitcher(
          duration: duration,
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          layoutBuilder: _overlayPrevious,
          transitionBuilder: (child, animation) {
            final incoming = child.key == dateKey;
            final direction = slideDirectionIsNext ? 1.0 : -1.0;
            final offset = Offset(direction * (incoming ? .63 : -.63), 0);
            return SlideTransition(
              position: Tween<Offset>(
                begin: offset,
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: HomeGlassSurface(
            key: dateKey,
            radius: AsteriaCardRadii.card,
            tint: _MoonPhaseWidgetState._dayCardBackground,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MoonPhaseBadgeRow(lunarDay: lunarDay, status: status),
                  const SizedBox(height: 8),
                  _GradientText(
                    text: _phaseTitle(context, phase),
                    gradient: _MoonPhaseWidgetState._orangeGradient,
                    style: context.textTheme.playfairMedium20.copyWith(
                      fontFamily: 'Lora',
                      height: 1.1,
                    ),
                  ),
                  if (eventTime != null && eventTime.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.moonPhaseEventTime(eventTime),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.urbanistRegular14.copyWith(
                        color: AppColors.textInverse.withValues(alpha: 0.8),
                        height: 1.2,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: context.textTheme.urbanistRegular16.copyWith(
                      fontFamily: 'Onest',
                      color: AppColors.textInverse,
                      height: 1.2,
                      letterSpacing: -0.408,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _phaseTitle(BuildContext context, String phase) =>
      switch (phase) {
        'new_moon' => context.l10n.moonPhaseNewMoon,
        'waxing_crescent' => context.l10n.moonPhaseWaxingCrescent,
        'first_quarter' => context.l10n.moonPhaseFirstQuarter,
        'waxing_gibbous' => context.l10n.moonPhaseWaxingGibbous,
        'full_moon' => context.l10n.moonPhaseFullMoon,
        'waning_gibbous' => context.l10n.moonPhaseWaningGibbous,
        'last_quarter' => context.l10n.moonPhaseLastQuarter,
        'waning_crescent' => context.l10n.moonPhaseWaningCrescent,
        _ => context.l10n.moonPhaseUnknown,
      };
}

class _MoonPhaseBadgeRow extends StatelessWidget {
  const _MoonPhaseBadgeRow({required this.lunarDay, required this.status});

  final int lunarDay;
  final DayStatus? status;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        _LunarDayChip(
          gradient: _MoonPhaseWidgetState._orangeGradient,
          lunarDay: lunarDay,
          textColor: AppColors.textPrimary,
        ),
        if (status != null)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: _MoonPhaseWidgetState._purpleGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      status!.title(context).replaceAll('\n', ' '),
                      style: context.textTheme.urbanistMedium12.copyWith(
                        fontFamily: 'Onest',
                        color: AppColors.textInverse,
                        height: 1.1,
                        letterSpacing: -0.41,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  DayStatusIcon(
                    status: status!,
                    size: 16,
                    excludeFromSemantics: true,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _LunarDayChip extends StatelessWidget {
  const _LunarDayChip({
    required this.gradient,
    required this.lunarDay,
    required this.textColor,
  });

  final Gradient gradient;
  final int lunarDay;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: const ValueKey('moon-phase-lunar-day-chip'),
      constraints: const BoxConstraints(minHeight: 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$lunarDay',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: ' ${context.l10n.lunarDay}'),
                ],
              ),
              key: const ValueKey('moon-phase-lunar-day-label'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.urbanistMedium12.copyWith(
                fontFamily: 'Onest',
                color: textColor,
                height: 0.9,
                letterSpacing: -0.41,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText({
    required this.text,
    required this.gradient,
    required this.style,
  });

  final String text;
  final Gradient gradient;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}

class _TintedMoonImage extends StatelessWidget {
  const _TintedMoonImage({
    required this.imagePath,
    required this.size,
    required this.shadowBlur,
    required this.shadowColor,
  });

  final String imagePath;
  final double size;
  final double shadowBlur;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: shadowBlur,
            offset: Offset.zero,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(imagePath, fit: BoxFit.cover),
    );
  }
}

class _LocationBlock extends StatelessWidget {
  const _LocationBlock({
    required this.location,
    required this.onLocationUpdateStarted,
    required this.onLocationUpdated,
  });
  final VoidCallback onLocationUpdateStarted;
  final VoidCallback onLocationUpdated;

  final CurrentLocationModel? location;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          Expanded(
            child: location == null
                ? Text(context.l10n.locationNotConfigured)
                : CurrentLocationControls.city(
                    location: location!,
                    onLocationUpdateStarted: onLocationUpdateStarted,
                    onLocationUpdated: onLocationUpdated,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox.square(
                          dimension: 14,
                          child: Center(
                            child: ClayAssetIcon(
                              'assets/icons/home_moon_location.svg',
                              width: 9.38,
                              height: 12,
                              excludeFromSemantics: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            location!.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.urbanistRegular12.copyWith(
                              fontFamily: 'Onest',
                              color: AppColors.textInverse,
                              letterSpacing: -0.08,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.75),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                context.l10n.moonLocationNote,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.end,
                style: context.textTheme.tertiaryUrbanistRegular12.copyWith(
                  fontFamily: 'Onest',
                  fontSize: 10,
                  height: 1.2,
                  letterSpacing: -0.41,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoonPhaseHeader extends StatelessWidget {
  const _MoonPhaseHeader();

  @override
  Widget build(BuildContext context) {
    return OverflowBar(
      alignment: MainAxisAlignment.spaceBetween,
      overflowAlignment: OverflowBarAlignment.start,
      spacing: 8,
      children: [
        HomeSectionHeading(context.l10n.moonPhaseTitle),
        _MoonCalendarButton(
          onPressed: () => context.read<HomeCubit>().changeTab(2),
        ),
      ],
    );
  }
}

class _MoonCalendarButton extends StatelessWidget {
  const _MoonCalendarButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return LotusFeedback(
      onActivate: onPressed,
      builder: (activate) => Semantics(
        button: true,
        label: context.l10n.openLunarCalendarLabel,
        onTap: activate,
        child: ExcludeSemantics(
          child: TextButton.icon(
            onPressed: activate,
            icon: const LotusRasterIcon(
              'assets/images/scenarios/calendar.webp',
              width: 26,
              height: 26,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 6),
              minimumSize: const Size(44, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            label: _GradientText(
              text: context.l10n.homeOpenCalendar,
              gradient: _MoonPhaseWidgetState._orangeGradient,
              style: context.textTheme.urbanistSemiBold16.copyWith(
                fontFamily: 'Onest',
                height: 1.2,
                letterSpacing: -0.41,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

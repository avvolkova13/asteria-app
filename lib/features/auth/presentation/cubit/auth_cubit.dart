import 'package:asteria_app/features/scenarios/first_session.dart';
import 'dart:async';

import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/attribution/attribution_service.dart';
import 'package:asteria_app/core/analytics/dictionaries/birth_time_precision.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/services/apps_flyer_service.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/features/auth/data/repositories/auth_repository.dart';
import 'package:asteria_app/features/auth/domain/models/auth_identity.dart';
import 'package:asteria_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:asteria_app/features/balance/presentation/provider/rewards_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final UserProvider _userProvider;
  final GlobalLoaderService _globalLoaderService;

  UserModel? _currentUser;
  bool _isTimeUnknown = false;
  TimeOfDayEnum? _lastSelectedTimeOption;

  /// Guards `ast_birth_data_complete` from firing more than once per cubit
  /// lifetime — birth data fields are updated through several setters and
  /// `_emitUserUpdated` runs on each one.
  bool _birthDataCompleteSent = false;

  AuthCubit({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required UserProvider userProvider,
    required GlobalLoaderService globalLoaderService,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _userProvider = userProvider,
       _globalLoaderService = globalLoaderService,
       super(AuthInitial());

  void initializeUser(AuthIdentity identity) {
    _currentUser = UserModel(
      id: identity.userId,
      email: identity.email,
      authMethod: AuthMethod.email,
      balance: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      personalInfo: PersonalInfoModel(gender: Gender.female),
      userGroup: UserGroup.user,
      subscriptionType: SubscriptionType.free,
      sonnikHistory: const [],
      solarData: SolarDataModel(data: ''),
      planetsHousesData: PlanetsHousesDataModel(
        data: '',
        elements: Elements(fire: '', earth: '', air: '', water: ''),
      ),
    );
    emit(UserInitialized(_currentUser!, isTimeUnknown: _isTimeUnknown));
  }

  void updateUserName(String name) {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      name: name,
      updatedAt: DateTime.now(),
    );
    _emitUserUpdated();
  }

  void updateUserGender(Gender gender) {
    if (_currentUser == null) return;

    final personalInfo =
        _currentUser!.personalInfo?.copyWith(gender: gender) ??
        PersonalInfoModel(gender: gender);
    _currentUser = _currentUser!.copyWith(
      personalInfo: personalInfo,
      updatedAt: DateTime.now(),
    );
    _emitUserUpdated();
  }

  void updateUserBirthPlace(
    String placeOfBirth, {
    double? latitude,
    double? longitude,
  }) {
    if (_currentUser == null) return;

    final birthPlace = BirthPlaceModel(
      location: placeOfBirth,
      latitude: latitude ?? 0.0,
      longitude: longitude ?? 0.0,
    );

    final personalInfo =
        _currentUser!.personalInfo?.copyWith(birthPlace: birthPlace) ??
        PersonalInfoModel(birthPlace: birthPlace);

    _currentUser = _currentUser!.copyWith(
      personalInfo: personalInfo,
      updatedAt: DateTime.now(),
    );
    _emitUserUpdated();
  }

  void updateUserBirthDate(DateTime birthDate) {
    if (_currentUser == null) return;

    final birthDateModel =
        _currentUser!.personalInfo?.birthDate?.copyWith(birthDate: birthDate) ??
        BirthDateModel(birthDate: birthDate);

    final personalInfo =
        _currentUser!.personalInfo?.copyWith(birthDate: birthDateModel) ??
        PersonalInfoModel(birthDate: birthDateModel);

    _currentUser = _currentUser!.copyWith(
      personalInfo: personalInfo,
      updatedAt: DateTime.now(),
    );
    _emitUserUpdated();
  }

  void updateUserBirthTime({
    DateTime? birthTime,
    required bool isTimeUnknown,
    TimeOfDayEnum? timeOption,
  }) {
    if (_currentUser == null) return;

    final actualBirthTime = birthTime;

    final birthDateModel =
        _currentUser!.personalInfo?.birthDate?.copyWith(
          birthTime: actualBirthTime,
        ) ??
        BirthDateModel(
          birthDate:
              _currentUser!.personalInfo?.birthDate?.birthDate ??
              DateTime.now(),
          birthTime: actualBirthTime,
        );

    final personalInfo =
        _currentUser!.personalInfo?.copyWith(birthDate: birthDateModel) ??
        PersonalInfoModel(birthDate: birthDateModel);

    _currentUser = _currentUser!.copyWith(
      personalInfo: personalInfo,
      updatedAt: DateTime.now(),
    );
    _isTimeUnknown = isTimeUnknown;
    if (timeOption != null) {
      _lastSelectedTimeOption = timeOption;
    } else if (!isTimeUnknown) {
      _lastSelectedTimeOption = null;
    }
    _emitUserUpdated();
  }

  TimeOfDayEnum? get lastSelectedTimeOption => _lastSelectedTimeOption;

  Future<void> saveUser() async {
    if (_currentUser == null) {
      emit(const UserSaveError(AuthErrorCode.userNotInitialized));
      return;
    }

    _globalLoaderService.show();

    try {
      // Stamp the attribution snapshot onto the new user before backend
      // create — gives backend user_id <-> source binding.
      final attributionService = di.get<AttributionService>();
      final attributionSnapshot = attributionService.currentSnapshot;
      final userToCreate = attributionSnapshot != null
          ? _currentUser!.copyWith(attribution: attributionSnapshot.toJson())
          : _currentUser!;

      await FirstSession.begin(userToCreate.id);
      final savedUser = await _authRepository.createUser(userToCreate);
      debugPrint('savedUser: ${savedUser.id}');
      _currentUser = savedUser;
      await _userRepository.setCurrentUser(savedUser);
      await _userProvider.setUser(savedUser);
      await attributionService.attachCustomerUserId(savedUser.id);
      unawaited(_initializeRewardsForNewUser(savedUser.id));

      _globalLoaderService.hide();
      final appsFlyer = di.get<AppsFlyerService>();
      appsFlyer.setCustomerUserId(savedUser.id);
      final facade = di.get<AnalyticsFacade>();
      facade.trackEvent(
        AnalyticsEvents.signupCompleted,
        params: {EventParams.authMethod: _currentUser!.authMethod.name},
      );
      facade.trackEvent(AnalyticsEvents.profileCompleted);
      // ast_activation_complete — auth + required profile/birth data done.
      di.get<ProductAnalyticsService>().trackActivationComplete();
      emit(UserSaved(savedUser));
    } catch (e) {
      _globalLoaderService.hide();
      debugPrint('Error saving user: $e');
      emit(const UserSaveError(AuthErrorCode.saveUser));
    }
  }

  Future<void> _initializeRewardsForNewUser(String userId) async {
    try {
      final rewardsProvider = di.get<RewardsProvider>();
      await rewardsProvider.recordOnboarding(userId: userId);
      await rewardsProvider.initializeForUser(userId);
    } catch (error) {
      // Account creation must not fail because the retry queue is
      // temporarily unavailable. Authenticated startup submits the same
      // idempotent onboarding event again.
      debugPrint('[AuthCubit] rewards initialization failed: $error');
    }
  }

  void _emitUserUpdated() {
    final isFormValid = _isUserFormValid();
    if (isFormValid && !_birthDataCompleteSent) {
      _birthDataCompleteSent = true;
      final personalInfo = _currentUser?.personalInfo;
      final hasBirthTime = personalInfo?.birthDate?.birthTime != null;
      final hasBirthPlace =
          personalInfo?.birthPlace?.location.isNotEmpty == true;
      di.get<ProductAnalyticsService>().trackBirthDataComplete(
        hasBirthTime: hasBirthTime,
        hasBirthPlace: hasBirthPlace,
        // No reliable signal for `approx_day`/`approx_night` here — we
        // know exact-vs-unknown only. Map accordingly.
        birthTimePrecision: hasBirthTime
            ? BirthTimePrecision.exact
            : BirthTimePrecision.unknown,
      );
    }
    emit(
      UserUpdated(
        _currentUser!,
        isFormValid: isFormValid,
        isTimeUnknown: _isTimeUnknown,
      ),
    );
  }

  bool _isUserFormValid() {
    if (_currentUser == null) return false;

    final personalInfo = _currentUser!.personalInfo;
    if (personalInfo == null) return false;

    final hasName = _currentUser!.name?.isNotEmpty == true;
    final hasPlace = personalInfo.birthPlace?.location.isNotEmpty == true;
    final hasDate = personalInfo.birthDate?.birthDate != null;
    final hasTime = personalInfo.birthDate?.birthTime != null || _isTimeUnknown;

    return hasName && hasPlace && hasDate && hasTime;
  }
}

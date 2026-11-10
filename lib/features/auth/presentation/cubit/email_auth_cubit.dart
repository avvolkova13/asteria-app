import 'dart:async';

import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/attribution/attribution_service.dart';
import 'package:asteria_app/core/analytics/dictionaries/failure_reason.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/services/apps_flyer_service.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/features/auth/data/email_auth_api.dart';
import 'package:asteria_app/features/auth/data/email_auth_repository.dart';
import 'package:asteria_app/features/auth/domain/models/auth_identity.dart';
import 'package:asteria_app/features/auth/presentation/cubit/email_auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmailAuthCubit extends Cubit<EmailAuthState> {
  final EmailAuthRepository _repository;
  final AuthSessionService _sessionService;
  final UserRepository _userRepository;
  final UserProvider _userProvider;
  final AnalyticsFacade? _analytics;
  final ProductAnalyticsService? _productAnalytics;
  final AppsFlyerService? _appsFlyer;
  final AttributionService? _attribution;

  Timer? _timer;
  String? _challengeId;
  String? _email;
  int _remainingSeconds = 0;
  int _challengeVersion = 0;
  bool _requestInFlight = false;

  EmailAuthCubit({
    required EmailAuthRepository repository,
    required AuthSessionService sessionService,
    required UserRepository userRepository,
    required UserProvider userProvider,
    AnalyticsFacade? analytics,
    ProductAnalyticsService? productAnalytics,
    AppsFlyerService? appsFlyer,
    AttributionService? attribution,
  }) : _repository = repository,
       _sessionService = sessionService,
       _userRepository = userRepository,
       _userProvider = userProvider,
       _analytics = analytics,
       _productAnalytics = productAnalytics,
       _appsFlyer = appsFlyer,
       _attribution = attribution,
       super(const EmailAuthInitial());

  String? get currentEmail => _email;
  int get remainingSeconds => _remainingSeconds;
  bool get canResend => _remainingSeconds == 0;
  int get challengeVersion => _challengeVersion;

  static String normalizeEmail(String email) => email.trim().toLowerCase();

  static bool isValidEmail(String email) {
    final normalized = normalizeEmail(email);
    return RegExp(
      r"^[a-z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?(?:\.[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?)+$",
    ).hasMatch(normalized);
  }

  Future<void> requestCode(String email, {String? expectedEmail}) async {
    if (_requestInFlight) return;
    final normalized = normalizeEmail(email);
    final normalizedExpected = expectedEmail == null
        ? null
        : normalizeEmail(expectedEmail);
    if (!isValidEmail(normalized) ||
        (normalizedExpected != null && normalized != normalizedExpected)) {
      emit(const EmailAuthFailure(EmailAuthFailureCode.invalidInput));
      return;
    }

    _requestInFlight = true;
    emit(const EmailAuthRequesting());
    try {
      final challenge = await _repository.requestCode(normalized);
      _email = normalized;
      _challengeId = challenge.challengeId;
      _challengeVersion++;
      _startTimer(challenge.resendAfter);
      final analytics = _analytics;
      if (analytics != null) {
        unawaited(
          analytics.trackEvent(
            AnalyticsEvents.authCodeRequested,
            params: {EventParams.authMethod: 'email'},
          ),
        );
      }
    } on EmailAuthException catch (error) {
      _trackFailure('send_code', error.type.name);
      emit(EmailAuthFailure(_codeFor(error)));
    } catch (_) {
      _trackFailure('send_code', 'unknown');
      emit(const EmailAuthFailure(EmailAuthFailureCode.sendCode));
    } finally {
      _requestInFlight = false;
    }
  }

  Future<void> resendCode() async {
    final email = _email;
    if (email == null || !canResend) return;
    await requestCode(email);
  }

  Future<void> verifyCode(String code, {String? expectedUid}) async {
    final challengeId = _challengeId;
    final email = _email;
    if (challengeId == null || email == null || code.length != 6) return;

    emit(EmailAuthVerifying(email, _remainingSeconds));
    try {
      final verification = await _repository.verifyCode(
        challengeId: challengeId,
        code: code,
      );
      if (expectedUid != null && verification.uid != expectedUid) {
        _trackVerifyFailure(FailureReasons.unknown);
        emit(
          EmailAuthFailure(
            EmailAuthFailureCode.signIn,
            remainingSeconds: _remainingSeconds,
          ),
        );
        return;
      }
      await _sessionService.saveSession(
        uid: verification.uid,
        email: email,
        accessToken: verification.accessToken,
        refreshToken: verification.refreshToken,
        expiresIn: verification.expiresIn,
      );

      final profile = await _userRepository.getUserById(verification.uid);
      final profileExists = profile != null;
      if (profile != null) {
        var effectiveProfile = profile;
        final attribution = _attribution;
        if (attribution != null) {
          try {
            await attribution.attachCustomerUserId(effectiveProfile.id);
            await attribution.markTouch();
            effectiveProfile = effectiveProfile.copyWith(
              attribution:
                  attribution.currentSnapshot?.toJson() ??
                  effectiveProfile.attribution,
            );
          } catch (_) {
            // Attribution is best-effort and must never block a valid login.
          }
        }
        await _userRepository.setCurrentUser(effectiveProfile);
        _userProvider.applyServerUserSnapshot(effectiveProfile);
        _appsFlyer?.setCustomerUserId(effectiveProfile.id);
      }

      _timer?.cancel();
      final analytics = _analytics;
      if (analytics != null) {
        unawaited(
          analytics.trackEvent(
            AnalyticsEvents.authCodeVerified,
            params: {EventParams.authMethod: 'email'},
          ),
        );
      }
      if (profileExists) {
        if (analytics != null) {
          unawaited(
            analytics.trackEvent(
              AnalyticsEvents.loginCompleted,
              params: {EventParams.authMethod: 'email'},
            ),
          );
        }
      }
      unawaited(
        _productAnalytics?.trackAuthCodeVerifySuccess(isSignup: !profileExists),
      );
      emit(
        EmailAuthVerified(
          profileExists: profileExists,
          identity: AuthIdentity.email(userId: verification.uid, email: email),
        ),
      );
    } on EmailAuthException catch (error) {
      _trackFailure('verify_code', error.type.name);
      _trackVerifyFailure(switch (error.type) {
        EmailAuthErrorType.invalidOrExpiredCode => FailureReasons.invalidCode,
        EmailAuthErrorType.network => FailureReasons.networkError,
        _ => FailureReasons.serverError,
      });
      emit(
        EmailAuthFailure(
          _codeFor(error),
          invalidCode: error.type == EmailAuthErrorType.invalidOrExpiredCode,
          remainingSeconds: _remainingSeconds,
        ),
      );
    } catch (_) {
      _trackFailure('verify_code', 'unknown');
      _trackVerifyFailure(FailureReasons.unknown);
      emit(
        EmailAuthFailure(
          EmailAuthFailureCode.signIn,
          remainingSeconds: _remainingSeconds,
        ),
      );
    }
  }

  void clearError() {
    final email = _email;
    if (email != null) {
      emit(EmailAuthCodeSent(email, _remainingSeconds));
    } else {
      emit(const EmailAuthInitial());
    }
  }

  void _startTimer(int seconds) {
    _timer?.cancel();
    _remainingSeconds = seconds;
    final email = _email;
    if (email == null) return;
    emit(EmailAuthCodeSent(email, _remainingSeconds));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
      }
      emit(EmailAuthCodeSent(email, _remainingSeconds));
      if (_remainingSeconds == 0) {
        timer.cancel();
      }
    });
  }

  EmailAuthFailureCode _codeFor(EmailAuthException error) {
    return switch (error.type) {
      EmailAuthErrorType.invalidInput => EmailAuthFailureCode.invalidInput,
      EmailAuthErrorType.invalidOrExpiredCode =>
        EmailAuthFailureCode.invalidOrExpiredCode,
      EmailAuthErrorType.rateLimited => EmailAuthFailureCode.rateLimited,
      EmailAuthErrorType.deliveryFailed => EmailAuthFailureCode.deliveryFailed,
      EmailAuthErrorType.unavailable => EmailAuthFailureCode.unavailable,
      EmailAuthErrorType.network => EmailAuthFailureCode.network,
      EmailAuthErrorType.unknown => EmailAuthFailureCode.unknown,
    };
  }

  void _trackFailure(String stage, String reason) {
    final analytics = _analytics;
    if (analytics == null) return;
    unawaited(
      analytics.trackEvent(
        AnalyticsEvents.authFailed,
        params: {
          EventParams.authMethod: 'email',
          EventParams.failureStage: stage,
          EventParams.failureReason: reason,
        },
      ),
    );
  }

  void _trackVerifyFailure(String reason) {
    unawaited(
      _productAnalytics?.trackAuthCodeVerifyFailed(failureReason: reason),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

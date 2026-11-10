import 'package:asteria_app/app/data/repositories/app_settings/app_settings_repository.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final UserRepository _userRepository;
  final AppSettingsRepository _appSettingsRepository;
  final AuthSessionService _authSessionService;

  SplashBloc({
    required UserRepository userRepository,
    required AppSettingsRepository appSettingsRepository,
    required AuthSessionService authSessionService,
  }) : _userRepository = userRepository,
       _appSettingsRepository = appSettingsRepository,
       _authSessionService = authSessionService,
       super(SplashInitial()) {
    on<InitializeApp>(_onInitializeApp);
  }

  Future<void> _onInitializeApp(
    InitializeApp event,
    Emitter<SplashState> emit,
  ) async {
    emit(SplashLoading());

    try {
      // Проверяем, прошел ли пользователь onboarding
      final showOnboarding = _appSettingsRepository.getShowOnboarding();

      if (showOnboarding) {
        emit(const SplashSuccess(initialRoute: '/onboarding'));
        return;
      }

      final currentUser = await _userRepository.getCurrentUser();

      if (currentUser != null) {
        emit(const SplashSuccess(initialRoute: '/home'));
      } else if (_authSessionService.hasSession) {
        emit(const SplashSuccess(initialRoute: '/auth/personal-info'));
      } else {
        emit(const SplashSuccess(initialRoute: '/auth/login'));
      }
    } catch (e) {
      emit(SplashError(message: 'Initialization error: $e'));
    }
  }
}

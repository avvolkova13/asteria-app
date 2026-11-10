import 'package:asteria_app/features/scenarios/first_session.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final UserRepository _userRepository;
  final AuthSessionService _authSessionService;

  SplashBloc({
    required UserRepository userRepository,
    required AuthSessionService authSessionService,
  }) : _userRepository = userRepository,
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
      final currentUser = await _userRepository.getCurrentUser();

      if (currentUser != null) {
        emit(
          SplashSuccess(
            initialRoute: FirstSession.pending(currentUser.id)
                ? FirstSession.path
                : '/home',
          ),
        );
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

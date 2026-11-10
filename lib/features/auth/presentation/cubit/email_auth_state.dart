import 'package:asteria_app/features/auth/domain/models/auth_identity.dart';
import 'package:equatable/equatable.dart';

sealed class EmailAuthState extends Equatable {
  const EmailAuthState();

  @override
  List<Object?> get props => [];
}

enum EmailAuthFailureCode {
  invalidInput,
  sendCode,
  invalidOrExpiredCode,
  rateLimited,
  deliveryFailed,
  unavailable,
  network,
  signIn,
  unknown,
}

class EmailAuthInitial extends EmailAuthState {
  const EmailAuthInitial();
}

class EmailAuthRequesting extends EmailAuthState {
  const EmailAuthRequesting();
}

class EmailAuthCodeSent extends EmailAuthState {
  final String email;
  final int remainingSeconds;

  const EmailAuthCodeSent(this.email, this.remainingSeconds);

  @override
  List<Object?> get props => [email, remainingSeconds];
}

class EmailAuthVerifying extends EmailAuthState {
  final String email;
  final int remainingSeconds;

  const EmailAuthVerifying(this.email, this.remainingSeconds);

  @override
  List<Object?> get props => [email, remainingSeconds];
}

class EmailAuthFailure extends EmailAuthState {
  final EmailAuthFailureCode code;
  final bool invalidCode;
  final int remainingSeconds;

  const EmailAuthFailure(
    this.code, {
    this.invalidCode = false,
    this.remainingSeconds = 0,
  });

  @override
  List<Object?> get props => [code, invalidCode, remainingSeconds];
}

class EmailAuthVerified extends EmailAuthState {
  final bool profileExists;
  final AuthIdentity identity;

  const EmailAuthVerified({
    required this.profileExists,
    required this.identity,
  });

  @override
  List<Object?> get props => [profileExists, identity.userId, identity.email];
}

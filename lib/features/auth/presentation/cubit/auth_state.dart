import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

enum AuthErrorCode { userNotInitialized, saveUser }

class AuthInitial extends AuthState {}

class UserInitialized extends AuthState {
  final UserModel user;
  final bool isFormValid;
  final bool isTimeUnknown;

  const UserInitialized(
    this.user, {
    this.isFormValid = false,
    this.isTimeUnknown = false,
  });

  @override
  List<Object?> get props => [user, isFormValid, isTimeUnknown];
}

class UserUpdated extends AuthState {
  final UserModel user;
  final bool isFormValid;
  final bool isTimeUnknown;

  const UserUpdated(
    this.user, {
    this.isFormValid = false,
    this.isTimeUnknown = false,
  });

  @override
  List<Object?> get props => [user, isFormValid, isTimeUnknown];
}

class UserSaved extends AuthState {
  final UserModel user;

  const UserSaved(this.user);

  @override
  List<Object?> get props => [user];
}

class UserSaveError extends AuthState {
  final AuthErrorCode code;

  const UserSaveError(this.code);

  @override
  List<Object?> get props => [code];
}

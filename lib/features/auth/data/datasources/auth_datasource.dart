import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_profile_api.dart';
import 'package:flutter/foundation.dart';

abstract class AuthDataSource {
  Future<UserModel> createUser(UserModel user);
}

class AuthDataSourceImpl implements AuthDataSource {
  final UserProfileApi _userProfileApi;

  AuthDataSourceImpl({required UserProfileApi userProfileApi})
    : _userProfileApi = userProfileApi;

  @override
  Future<UserModel> createUser(UserModel user) async {
    try {
      final emailUser = user.copyWith(
        clearPhoneNumber: true,
        authMethod: AuthMethod.email,
      );
      final userData = emailUser.toJson();

      debugPrint('Creating user with data: $userData');

      final created = await _userProfileApi.createUser(emailUser);
      debugPrint('User created successfully with ID: ${created.id}');
      return created;
    } catch (e) {
      debugPrint('Error creating user: $e');
      throw Exception('Ошибка создания документа: $e');
    }
  }
}

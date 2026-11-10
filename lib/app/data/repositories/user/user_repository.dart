import 'dart:async';
import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';
import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_profile_api.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/services/hive/hive_service.dart';
import 'package:flutter/foundation.dart';

abstract class UserRepository {
  Stream<UserModel?> getMe();
  Future<UserModel?> getCurrentUser();
  Future<void> updateCurrentUser(UserModel user);
  Future<void> clearCurrentUser();
  Future<void> setCurrentUser(UserModel user);
  Future<UserModel?> getUserById(String userId);
  Future<void> deleteUser(String userId);
  Future<void> updateUserShopItems(
    String userId,
    List<ShopItemModel> shopItems,
  );
  Future<void> addCompatibilityToHistory(SavedCompatibilityModel compatibility);
}

class UserRepositoryImpl implements UserRepository {
  final UserProfileApi _profileApi;
  final AuthSessionService _authSessionService;

  UserRepositoryImpl({
    required UserProfileApi profileApi,
    required AuthSessionService authSessionService,
  }) : _profileApi = profileApi,
       _authSessionService = authSessionService;

  // Кеш текущего пользователя
  UserModel? _currentUser;

  // StreamController для реактивных обновлений
  final StreamController<UserModel?> _userStreamController =
      StreamController<UserModel?>.broadcast();

  @override
  Stream<UserModel?> getMe() {
    debugPrint('getMe called, current user: ${_currentUser?.id}');

    // Создаем Stream который сразу эмитит текущее значение
    return Stream<UserModel?>.multi((controller) {
      debugPrint('Stream listener attached');

      // Если пользователь уже есть в кеше, сразу добавляем
      if (_currentUser != null) {
        debugPrint('Adding cached user to stream: ${_currentUser?.id}');
        controller.add(_currentUser);
      } else {
        // Если пользователь еще не загружен, запрашиваем его
        debugPrint('Loading current user...');
        _loadCurrentUser()
            .then((user) {
              debugPrint('User loaded, adding to stream: ${user?.id}');
              controller.add(user);
            })
            .catchError((e) {
              debugPrint('Error in _loadCurrentUser: $e');
              controller.add(null);
            });
      }

      // Подписываемся на обновления
      late StreamSubscription subscription;
      subscription = _userStreamController.stream.listen(
        (user) {
          debugPrint('Stream emitting user update: ${user?.id}');
          controller.add(user);
        },
        onError: (error) {
          debugPrint('Stream error: $error');
          controller.addError(error);
        },
      );

      // Очистка при отписке
      controller.onCancel = () {
        debugPrint('Stream cancelled');
        subscription.cancel();
      };
    }).distinct();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) {
      if (_currentUser!.id != _authSessionService.currentUid) {
        _currentUser = null;
        return null;
      }
      return _currentUser;
    }
    return await _loadCurrentUser();
  }

  @override
  Future<void> updateCurrentUser(UserModel user) async {
    try {
      debugPrint('Updating current user through backend: ${user.id}');
      final targetUserId = user.id;
      final updatedUser = await _profileApi.updateCurrentUser(user);
      if (_authSessionService.currentUid != targetUserId ||
          updatedUser.id != targetUserId) {
        debugPrint('Ignoring stale user update for: $targetUserId');
        return;
      }

      // Обновляем кеш
      _currentUser = updatedUser;

      // Уведомляем подписчиков
      _userStreamController.add(_currentUser);
      debugPrint('User updated successfully');
    } catch (e) {
      debugPrint('Error updating user: $e');
      throw Exception('Ошибка обновления пользователя: $e');
    }
  }

  @override
  Future<void> updateUserShopItems(
    String userId,
    List<ShopItemModel> shopItems,
  ) async {
    try {
      final current = _currentUser ?? await getUserById(userId);
      if (current == null) {
        throw Exception('Пользователь не найден');
      }
      await updateCurrentUser(current.copyWith(shopItems: shopItems));
    } catch (e) {
      throw Exception('Ошибка обновления товаров пользователя: $e');
    }
  }

  @override
  Future<void> clearCurrentUser() async {
    _currentUser = null;
    await _clearCurrentUserId();
    _userStreamController.add(null);
  }

  @override
  Future<void> setCurrentUser(UserModel user) async {
    _currentUser = user;

    // Сохраняем ID пользователя в локальное хранилище для последующей загрузки
    await _saveCurrentUserId(user.id);

    // Уведомляем подписчиков
    _userStreamController.add(_currentUser);
  }

  @override
  Future<UserModel?> getUserById(String userId) async {
    try {
      if (_authSessionService.currentUid == userId) {
        final user = await _profileApi.getCurrentUser();
        if (_authSessionService.currentUid != userId || user?.id != userId) {
          debugPrint('Ignoring stale user read for: $userId');
          return null;
        }
        if (user != null) {
          _currentUser = user;
          await _saveCurrentUserId(user.id);
          _userStreamController.add(user);
        }
        return user;
      }
      throw Exception('Arbitrary user profile access is disabled');
    } catch (e) {
      throw Exception('Ошибка получения пользователя по ID: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _profileApi.deleteUserById(userId);
      if (_currentUser?.id == userId) {
        await clearCurrentUser();
      }
    } catch (e) {
      debugPrint('Error deleting user: $e');
      throw Exception('Ошибка удаления аккаунта: $e');
    }
  }

  // Загрузка текущего пользователя из backend/Mongo.
  Future<UserModel?> _loadCurrentUser() async {
    debugPrint('_loadCurrentUser started');
    try {
      final sessionUid = _authSessionService.currentUid;
      if (sessionUid != null) {
        final backendUser = await _profileApi.getCurrentUser();
        if (_authSessionService.currentUid != sessionUid ||
            backendUser?.id != sessionUid) {
          debugPrint('Ignoring stale current user load for: $sessionUid');
          return null;
        }
        if (backendUser != null) {
          _currentUser = backendUser;
          await _saveCurrentUserId(sessionUid);
          _userStreamController.add(backendUser);
          return backendUser;
        }
        _userStreamController.add(null);
        return null;
      }

      // Получаем ID текущего пользователя из локального хранилища
      final userId = await _getCurrentUserId();
      debugPrint('Got user ID from storage: $userId');

      if (userId != null) {
        debugPrint('Loading user by ID: $userId');
        final user = await getUserById(userId);
        if (user != null) {
          debugPrint('User loaded successfully: ${user.name}');
          _currentUser = user;
          _userStreamController.add(_currentUser);
          return user;
        } else {
          debugPrint('User not found in backend for ID: $userId');
        }
      }

      debugPrint('No user found - adding null to stream');

      // Важно! Добавляем null в стрим, если пользователь не найден
      _userStreamController.add(null);
      return null;
    } catch (e) {
      debugPrint('Error loading user: $e');
      // При ошибке также добавляем null в стрим
      _userStreamController.add(null);
      return null; // Возвращаем null вместо throw
    }
  }

  // Получение ID текущего пользователя из локального хранилища
  Future<String?> _getCurrentUserId() async {
    try {
      final box = HiveService.appSettingsBox;
      return box.get('current_user_id')?.cast<String, dynamic>()['id']
          as String?;
    } catch (e) {
      return null;
    }
  }

  // Сохранение ID текущего пользователя в локальное хранилище
  Future<void> _saveCurrentUserId(String userId) async {
    try {
      final box = HiveService.appSettingsBox;
      await box.put('current_user_id', {'id': userId});
      debugPrint('Saved user id: $userId');
    } catch (e) {
      // handle errors
    }
  }

  // Очистка ID пользователя из локального хранилища
  Future<void> _clearCurrentUserId() async {
    try {
      final box = HiveService.appSettingsBox;
      await box.delete('current_user_id');
    } catch (e) {
      // handle errors
    }
  }

  @override
  Future<void> addCompatibilityToHistory(
    SavedCompatibilityModel compatibility,
  ) async {
    try {
      debugPrint('🔄 Starting addCompatibilityToHistory');
      final user = await getCurrentUser();
      if (user == null) {
        throw Exception('Пользователь не найден');
      }

      debugPrint('👤 Current user: ${user.id}');
      debugPrint(
        '📚 Current history length: ${user.compatibilityHistory.length}',
      );
      debugPrint('➕ Adding new compatibility with id: ${compatibility.id}');

      // Добавляем новую совместимость в начало истории
      final updatedHistory = [compatibility, ...user.compatibilityHistory];

      debugPrint('📚 Updated history length: ${updatedHistory.length}');

      // Обновляем пользователя с новой историей
      final updatedUser = user.copyWith(compatibilityHistory: updatedHistory);

      await updateCurrentUser(updatedUser);
      debugPrint('✅ Compatibility added to history successfully');
    } catch (e) {
      debugPrint('❌ Error adding compatibility to history: $e');
      throw Exception('Ошибка добавления совместимости в историю: $e');
    }
  }

  // Закрытие ресурсов
  void dispose() {
    _userStreamController.close();
  }
}

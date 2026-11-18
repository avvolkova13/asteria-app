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
       _authSessionService = authSessionService {
    if (authSessionService is Listenable) {
      (authSessionService as Listenable).addListener(_onSessionChanged);
    }
  }

  void _onSessionChanged() {
    if (_currentUser?.id != _authSessionService.currentUid) {
      _currentUser = null;
    }
  }

  // Кеш текущего пользователя
  UserModel? _currentUser;

  // StreamController для реактивных обновлений
  final StreamController<UserModel?> _userStreamController =
      StreamController<UserModel?>.broadcast();

  @override
  Stream<UserModel?> getMe() {
    debugPrint('user_profile_stream_requested');

    // Создаем Stream который сразу эмитит текущее значение
    return Stream<UserModel?>.multi((controller) {
      debugPrint('user_profile_stream_attached');
      final initialUid = _authSessionService.currentUid;
      final session = _authSessionService;
      final initialVersion = session is SessionIdentityVersion
          ? (session as SessionIdentityVersion).identityVersion
          : null;
      bool isInitialSessionCurrent() =>
          initialUid == _authSessionService.currentUid &&
          (initialVersion == null ||
              initialVersion ==
                  (session as SessionIdentityVersion).identityVersion);

      // Если пользователь уже есть в кеше, сразу добавляем
      if (_currentUser != null) {
        debugPrint('user_profile_cache_emitted');
        controller.add(_currentUser);
      } else {
        // Если пользователь еще не загружен, запрашиваем его
        debugPrint('user_profile_load_started');
        _loadCurrentUser()
            .then((user) {
              if (!isInitialSessionCurrent()) return;
              debugPrint('user_profile_loaded');
              controller.add(user);
            })
            .catchError((e) {
              if (!isInitialSessionCurrent()) return;
              debugPrint('user_profile_initial_load_failed');
              controller.addError(e);
            });
      }

      // Подписываемся на обновления
      late StreamSubscription subscription;
      subscription = _userStreamController.stream.listen(
        (user) {
          debugPrint('user_profile_update_emitted');
          controller.add(user);
        },
        onError: (error) {
          debugPrint('user_profile_stream_failed');
          controller.addError(error);
        },
      );

      // Очистка при отписке
      controller.onCancel = () {
        debugPrint('user_profile_stream_cancelled');
        subscription.cancel();
      };
    }).distinct();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) {
      if (_currentUser!.id != _authSessionService.currentUid) {
        _currentUser = null;
      } else {
        return _currentUser;
      }
    }
    return await _loadCurrentUser();
  }

  @override
  Future<void> updateCurrentUser(UserModel user) async {
    try {
      debugPrint('user_profile_update_started');
      final targetUserId = user.id;
      final updatedUser = await _profileApi.updateCurrentUser(user);
      if (_authSessionService.currentUid != targetUserId ||
          updatedUser.id != targetUserId) {
        debugPrint('user_profile_stale_update_ignored');
        return;
      }

      // Обновляем кеш
      _currentUser = updatedUser;

      // Уведомляем подписчиков
      _userStreamController.add(_currentUser);
      debugPrint('user_profile_update_completed');
    } catch (e) {
      debugPrint('user_profile_update_failed');
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
          debugPrint('user_profile_stale_read_ignored');
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
      debugPrint('user_profile_delete_failed');
      throw Exception('Ошибка удаления аккаунта: $e');
    }
  }

  // Загрузка текущего пользователя из backend/Mongo.
  Future<UserModel?> _loadCurrentUser() async {
    debugPrint('user_profile_load_started');
    final sessionUid = _authSessionService.currentUid;
    try {
      if (sessionUid != null) {
        final backendUser = await _profileApi.getCurrentUser();
        if (_authSessionService.currentUid != sessionUid ||
            (backendUser != null && backendUser.id != sessionUid)) {
          debugPrint('user_profile_stale_load_ignored');
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
      debugPrint('user_profile_saved_identity_read');

      if (userId != null) {
        debugPrint('user_profile_saved_identity_load_started');
        final user = await getUserById(userId);
        if (user != null) {
          debugPrint('user_profile_load_completed');
          _currentUser = user;
          _userStreamController.add(_currentUser);
          return user;
        } else {
          debugPrint('user_profile_not_found');
        }
      }

      debugPrint('user_profile_empty_emitted');

      // Важно! Добавляем null в стрим, если пользователь не найден
      _userStreamController.add(null);
      return null;
    } catch (e) {
      debugPrint('user_profile_load_failed');
      if (_authSessionService.currentUid != sessionUid) return null;
      rethrow;
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
      debugPrint('user_profile_identity_saved');
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
      debugPrint('compatibility_history_update_started');
      final user = await getCurrentUser();
      if (user == null) {
        throw Exception('Пользователь не найден');
      }

      debugPrint('compatibility_history_profile_loaded');
      debugPrint('compatibility_history_loaded');
      debugPrint('compatibility_history_item_added');

      // Добавляем новую совместимость в начало истории
      final updatedHistory = [compatibility, ...user.compatibilityHistory];

      debugPrint('compatibility_history_prepared');

      // Обновляем пользователя с новой историей
      final updatedUser = user.copyWith(compatibilityHistory: updatedHistory);

      await updateCurrentUser(updatedUser);
      debugPrint('compatibility_history_update_completed');
    } catch (e) {
      debugPrint('compatibility_history_update_failed');
      throw Exception('Ошибка добавления совместимости в историю: $e');
    }
  }

  // Закрытие ресурсов
  void dispose() {
    final session = _authSessionService;
    if (session is Listenable) {
      (session as Listenable).removeListener(_onSessionChanged);
    }
    _userStreamController.close();
  }
}

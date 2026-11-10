import 'package:asteria_app/core/services/api/backend_api.dart';
import 'package:asteria_app/core/services/hive/hive_service.dart';
import 'package:asteria_app/core/localization/app_locale_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class ContentVersionService {
  ContentVersionService({
    required BackendApi api,
    Box<Map>? contentBox,
    Duration refreshTimeout = const Duration(seconds: 10),
    AppLocaleService? localeService,
  }) : _api = api,
       _contentBox = contentBox,
       _refreshTimeout = refreshTimeout,
       _localeService = localeService;

  final BackendApi _api;
  final Box<Map>? _contentBox;
  final Duration _refreshTimeout;
  final AppLocaleService? _localeService;
  Map<String, int>? _remoteVersions;

  Box<Map> get _box => _contentBox ?? HiveService.contentBox;
  String get _localVersionsKey =>
      _localeService == null || _localeService.isRussian
      ? _localVersionsKeyBase
      : '${_localVersionsKeyBase}_${_localeService.contentLanguage}';

  static const _localVersionsKeyBase = 'content_collection_versions';

  Future<bool> refresh() async {
    try {
      final response = await _api.getContentVersions().timeout(_refreshTimeout);
      final raw = Map<String, dynamic>.from(response.data as Map);
      _remoteVersions = raw.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      );
      return true;
    } catch (error) {
      _remoteVersions = null;
      debugPrint('[ContentVersions] Не удалось получить версии: $error');
      return false;
    }
  }

  bool isStale(String collection) {
    final remoteVersion = _remoteVersions?[collection];
    if (remoteVersion == null) {
      return false;
    }
    final stored = _box.get(_localVersionsKey);
    final localVersion = (stored?[collection] as num?)?.toInt() ?? 0;
    return localVersion < remoteVersion;
  }

  Future<void> markCurrent(String collection) async {
    final remoteVersion = _remoteVersions?[collection];
    if (remoteVersion == null) {
      return;
    }
    final stored = _box.get(_localVersionsKey);
    await _box.put(_localVersionsKey, {
      if (stored != null) ...stored,
      collection: remoteVersion,
    });
  }
}

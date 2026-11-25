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
  final _remoteVersionsByLocale = <String, Map<String, int>>{};

  Box<Map> get _box => _contentBox ?? HiveService.contentBox;
  String get _currentLocale => _localeService?.languageTag ?? 'ru';
  String _localVersionsKey(String localeTag) => localeTag == 'ru'
      ? _localVersionsKeyBase
      : '${_localVersionsKeyBase}_$localeTag';

  static const _localVersionsKeyBase = 'content_collection_versions';

  Future<bool> refresh({String? localeTag}) async {
    final locale = localeTag ?? _currentLocale;
    try {
      final response = await _api.getContentVersions().timeout(_refreshTimeout);
      final raw = Map<String, dynamic>.from(response.data as Map);
      _remoteVersionsByLocale[locale] = raw.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      );
      return true;
    } catch (error) {
      _remoteVersionsByLocale.remove(locale);
      debugPrint('[ContentVersions] Не удалось получить версии: $error');
      return false;
    }
  }

  bool isStale(String collection, {String? localeTag}) {
    final locale = localeTag ?? _currentLocale;
    final remoteVersion = _remoteVersionsByLocale[locale]?[collection];
    if (remoteVersion == null) {
      return false;
    }
    final stored = _box.get(_localVersionsKey(locale));
    final localVersion = (stored?[collection] as num?)?.toInt() ?? 0;
    return localVersion < remoteVersion;
  }

  Future<void> markCurrent(String collection, {String? localeTag}) async {
    final locale = localeTag ?? _currentLocale;
    final remoteVersion = _remoteVersionsByLocale[locale]?[collection];
    if (remoteVersion == null) {
      return;
    }
    final stored = _box.get(_localVersionsKey(locale));
    await _box.put(_localVersionsKey(locale), {
      if (stored != null) ...stored,
      collection: remoteVersion,
    });
  }
}

import 'package:hive/hive.dart';

/// Normal runtime state in the existing settings box, separate from receipts.
/// A pending marker is never expired by a UI or server intent timer.
class ApplePendingAttempt {
  final String id, uid, productId, token;
  final bool approval;
  final Map<String, Object?>? analyticsContext;
  const ApplePendingAttempt({
    required this.id,
    required this.uid,
    required this.productId,
    required this.token,
    this.approval = false,
    this.analyticsContext,
  });
  Map<String, Object?> toMap() => {
    'id': id,
    'uid': uid,
    'product': productId,
    'token': token,
    'approval': approval,
    if (analyticsContext != null) 'analytics': analyticsContext,
  };
  factory ApplePendingAttempt.fromMap(Map raw) => ApplePendingAttempt(
    id: raw['id'] as String,
    uid: raw['uid'] as String,
    productId: raw['product'] as String,
    token: raw['token'] as String,
    approval: raw['approval'] == true,
    analyticsContext: raw['analytics'] is Map
        ? Map<String, Object?>.from(raw['analytics'] as Map)
        : null,
  );
  ApplePendingAttempt withApproval() => ApplePendingAttempt(
    id: id,
    uid: uid,
    productId: productId,
    token: token,
    approval: true,
    analyticsContext: analyticsContext,
  );
}

class AppleAttemptStore {
  final Box<Map> _settings;
  static const _prefix = 'apple_purchase_attempt:';
  AppleAttemptStore(this._settings);
  List<ApplePendingAttempt> readAll() => [
    for (final key in _settings.keys)
      if (key is String && key.startsWith(_prefix))
        ApplePendingAttempt.fromMap(_settings.get(key)!),
  ];
  Future<void> save(ApplePendingAttempt attempt) =>
      _settings.put('$_prefix${attempt.id}', attempt.toMap());
  Future<void> clear(ApplePendingAttempt attempt) async {
    final key = '$_prefix${attempt.id}';
    final current = _settings.get(key);
    if (current?['id'] == attempt.id && current?['token'] == attempt.token) {
      await _settings.delete(key);
    }
  }
}

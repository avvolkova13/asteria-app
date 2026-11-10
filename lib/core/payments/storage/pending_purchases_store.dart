import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:asteria_app/core/payments/models/purchase_result.dart';

/// Pending purchase persisted between app sessions.
///
/// Saved as `Map<String, dynamic>` to reuse the existing Hive setup
/// (boxes are typed `Box<Map>`). Avoids registering a TypeAdapter.
class PendingPurchase {
  final String originalTransactionId;
  final String productId;
  final String signedTransactionJws;
  final String userId;
  final DateTime createdAt;
  final StoreProvider storeProvider;
  final Map<String, Object?>? analyticsContext;

  /// When `true`, this entry has been marked as failed (e.g. backend returned
  /// 401 invalid JWS). Generic Google replay excludes failed entries. Apple
  /// recovery reads every entry: this historical flag is not owner/finish proof.
  final bool failed;

  const PendingPurchase({
    required this.originalTransactionId,
    required this.productId,
    required this.signedTransactionJws,
    required this.userId,
    required this.createdAt,
    this.storeProvider = StoreProvider.apple,
    this.failed = false,
    this.analyticsContext,
  });

  Map<String, dynamic> toMap() => {
    'original_transaction_id': originalTransactionId,
    'product_id': productId,
    'signed_transaction_jws': signedTransactionJws,
    'user_id': userId,
    'created_at': createdAt.toIso8601String(),
    'store_provider': storeProvider.name,
    'failed': failed,
    if (analyticsContext != null) 'analytics_context': analyticsContext,
  };

  factory PendingPurchase.fromMap(Map<dynamic, dynamic> map) {
    return PendingPurchase(
      originalTransactionId: map['original_transaction_id'] as String,
      productId: map['product_id'] as String,
      signedTransactionJws: map['signed_transaction_jws'] as String,
      userId: map['user_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      storeProvider: StoreProvider.values.firstWhere(
        (value) => value.name == map['store_provider'],
        orElse: () => StoreProvider.apple,
      ),
      failed: (map['failed'] as bool?) ?? false,
      analyticsContext: map['analytics_context'] is Map
          ? Map<String, Object?>.from(map['analytics_context'] as Map)
          : null,
    );
  }

  PendingPurchase copyWith({bool? failed}) => PendingPurchase(
    originalTransactionId: originalTransactionId,
    productId: productId,
    signedTransactionJws: signedTransactionJws,
    userId: userId,
    createdAt: createdAt,
    storeProvider: storeProvider,
    failed: failed ?? this.failed,
    analyticsContext: analyticsContext,
  );
}

class PendingPurchaseEntry {
  final Object key;
  final PendingPurchase purchase;
  final String observedPayload;
  const PendingPurchaseEntry(this.key, this.purchase, this.observedPayload);
}

class PendingPurchasesStore {
  static const String _boxName = 'pending_purchases';

  Box<Map>? _box;

  Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox<Map>(_boxName);
  }

  Future<void> save(PendingPurchase purchase) async {
    final box = await _ensureBox();
    await box.put(purchase.originalTransactionId, purchase.toMap());
  }

  /// New Apple keys identify exact events; existing keys and payloads stay intact.
  Future<PendingPurchaseEntry> saveApple(
    PendingPurchase purchase, {
    required String environment,
    required String transactionId,
  }) async {
    final box = await _ensureBox();
    final key = '$environment:$transactionId';
    final raw = purchase.toMap();
    await box.put(key, raw);
    return PendingPurchaseEntry(key, purchase, jsonEncode(raw));
  }

  List<PendingPurchaseEntry> get entries {
    final box = _box;
    if (box == null) return const [];
    return [
      for (final key in box.keys)
        if (box.get(key) case final Map raw)
          PendingPurchaseEntry(
            key as Object,
            PendingPurchase.fromMap(raw),
            jsonEncode(raw),
          ),
    ];
  }

  Future<bool> deleteObserved(PendingPurchaseEntry entry) async {
    final box = await _ensureBox();
    // No await between compare and Hive's synchronous cache mutation. A late
    // completion can never remove a replacement written at this actual key.
    if (jsonEncode(box.get(entry.key)) != entry.observedPayload) return false;
    await box.delete(entry.key);
    return true;
  }

  Future<void> markFailed(String originalTransactionId) async {
    final box = await _ensureBox();
    final raw = box.get(originalTransactionId);
    if (raw == null) return;
    final updated = PendingPurchase.fromMap(raw).copyWith(failed: true);
    await box.put(originalTransactionId, updated.toMap());
  }

  List<PendingPurchase> getAll() {
    final box = _box;
    if (box == null) return const [];
    return box.values
        .map((raw) {
          try {
            return PendingPurchase.fromMap(raw);
          } catch (e) {
            debugPrint('[PendingPurchasesStore] failed to decode entry: $e');
            return null;
          }
        })
        .whereType<PendingPurchase>()
        .toList(growable: false);
  }

  /// Returns only entries eligible for auto-retry (not previously marked failed).
  List<PendingPurchase> getPending() =>
      getAll().where((p) => !p.failed).toList(growable: false);

  Future<void> delete(String originalTransactionId) async {
    final box = await _ensureBox();
    await box.delete(originalTransactionId);
  }

  Future<Box<Map>> _ensureBox() async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
    return _box!;
  }
}

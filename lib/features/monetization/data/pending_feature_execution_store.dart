import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class PendingFeatureExecution {
  final String operationId;
  final String userId;
  final String featureKey;
  final String payloadKey;
  final String idempotencyKey;
  final Map<String, dynamic>? result;
  final DateTime createdAt;

  const PendingFeatureExecution({
    required this.operationId,
    required this.userId,
    required this.featureKey,
    required this.payloadKey,
    required this.idempotencyKey,
    required this.createdAt,
    this.result,
  });

  Map<String, dynamic> toMap() => {
    'operation_id': operationId,
    'user_id': userId,
    'feature_key': featureKey,
    'payload_key': payloadKey,
    'idempotency_key': idempotencyKey,
    if (result != null) 'result': result,
    'created_at': createdAt.toIso8601String(),
  };

  factory PendingFeatureExecution.fromMap(Map<dynamic, dynamic> map) {
    return PendingFeatureExecution(
      operationId: map['operation_id'] as String,
      userId: map['user_id'] as String,
      featureKey: map['feature_key'] as String,
      payloadKey: map['payload_key'] as String,
      idempotencyKey: map['idempotency_key'] as String,
      result: map['result'] == null
          ? null
          : Map<String, dynamic>.from(map['result'] as Map),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class PendingFeatureExecutionStore {
  static const String _boxName = 'pending_feature_executions';

  final Uuid _uuid;
  Box<Map>? _box;

  PendingFeatureExecutionStore({Uuid uuid = const Uuid()}) : _uuid = uuid;

  Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox<Map>(_boxName);
  }

  Future<PendingFeatureExecution> findOrCreate({
    required String userId,
    required String featureKey,
    required String payloadKey,
    String? idempotencyKey,
    Map<String, dynamic>? result,
  }) async {
    final operationId = _operationId(
      userId: userId,
      featureKey: featureKey,
      payloadKey: payloadKey,
    );
    final box = await _ensureBox();
    final existing = box.get(operationId);
    if (existing != null) {
      return PendingFeatureExecution.fromMap(existing);
    }
    final pending = PendingFeatureExecution(
      operationId: operationId,
      userId: userId,
      featureKey: featureKey,
      payloadKey: payloadKey,
      idempotencyKey: idempotencyKey ?? _uuid.v4(),
      result: result,
      createdAt: DateTime.now().toUtc(),
    );
    await box.put(operationId, pending.toMap());
    return pending;
  }

  Future<PendingFeatureExecution?> find({
    required String userId,
    required String featureKey,
    required String payloadKey,
  }) async {
    final box = await _ensureBox();
    final existing = box.get(
      _operationId(
        userId: userId,
        featureKey: featureKey,
        payloadKey: payloadKey,
      ),
    );
    if (existing == null) return null;
    return PendingFeatureExecution.fromMap(existing);
  }

  Future<void> delete({
    required String userId,
    required String featureKey,
    required String payloadKey,
  }) async {
    final box = await _ensureBox();
    await box.delete(
      _operationId(
        userId: userId,
        featureKey: featureKey,
        payloadKey: payloadKey,
      ),
    );
  }

  Future<Box<Map>> _ensureBox() async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
    return _box!;
  }

  static String _operationId({
    required String userId,
    required String featureKey,
    required String payloadKey,
  }) {
    return '$userId:$featureKey:$payloadKey';
  }
}

import 'dart:convert';

enum SyncOperation {
  create,
  update,
  delete;

  static SyncOperation fromString(String value) {
    return SyncOperation.values.firstWhere(
      (op) => op.name == value,
      orElse: () => SyncOperation.create,
    );
  }
}

class SyncQueueModel {
  final String id;
  final SyncOperation operation;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  SyncQueueModel({
    required this.id,
    required this.operation,
    required this.entityType,
    required this.entityId,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  factory SyncQueueModel.fromDatabase(Map<String, dynamic> map) {
    return SyncQueueModel(
      id: map['id'] as String,
      operation: SyncOperation.fromString(map['operation'] as String),
      entityType: map['entity_type'] as String,
      entityId: map['entity_id'] as String,
      data: jsonDecode(map['data'] as String) as Map<String, dynamic>,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      retryCount: map['retry_count'] as int,
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'operation': operation.name,
      'entity_type': entityType,
      'entity_id': entityId,
      'data': jsonEncode(data),
      'created_at': createdAt.millisecondsSinceEpoch,
      'retry_count': retryCount,
    };
  }

  SyncQueueModel copyWith({
    String? id,
    SyncOperation? operation,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    int? retryCount,
  }) {
    return SyncQueueModel(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/todo.dart';
part 'todo_model.g.dart';

@JsonSerializable()
class TodoModel {
  final String id;
  final String title;
  final String? description;
  final bool completed;
  @JsonKey(name: 'created_at')
  final int createdAt;
  @JsonKey(name: 'updated_at')
  final int updatedAt;
  final bool synced;

  TodoModel({
    required this.id,
    required this.title,
    this.description,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
    this.synced = false,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);

  Map<String, dynamic> toJson() => _$TodoModelToJson(this);

  factory TodoModel.fromEntity(Todo entity) {
    return TodoModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      completed: entity.completed,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
      updatedAt: entity.updatedAt.millisecondsSinceEpoch,
      synced: entity.synced,
    );
  }

  Todo toEntity() {
    return Todo(
      id: id,
      title: title,
      description: description,
      completed: completed,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      synced: synced,
    );
  }

  factory TodoModel.fromDatabase(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      completed: (map['completed'] as int) == 1,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
      synced: (map['synced'] as int) == 1,
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'synced': synced ? 1 : 0,
    };
  }

  // API response might have userId field
  factory TodoModel.fromApiResponse(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'].toString(),
      title: json['title'] as String,
      description: null,
      completed: json['completed'] as bool? ?? false,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      synced: true,
    );
  }

  Map<String, dynamic> toApiRequest() {
    return {
      'title': title,
      'completed': completed,
      'userId': 1, // JSONPlaceholder requires userId
    };
  }

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    int? createdAt,
    int? updatedAt,
    bool? synced,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }
}

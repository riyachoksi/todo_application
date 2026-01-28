import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final String id;
  final String title;
  final String? description;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;

  const Todo({
    required this.id,
    required this.title,
    this.description,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
    this.synced = false,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        completed,
        createdAt,
        updatedAt,
        synced,
      ];

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, completed: $completed, synced: $synced)';
  }
}

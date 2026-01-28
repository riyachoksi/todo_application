// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodoModel _$TodoModelFromJson(Map<String, dynamic> json) => TodoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      completed: json['completed'] as bool,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
      synced: json['synced'] as bool? ?? false,
    );

Map<String, dynamic> _$TodoModelToJson(TodoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'completed': instance.completed,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'synced': instance.synced,
    };

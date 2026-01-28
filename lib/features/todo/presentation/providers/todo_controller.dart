import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import 'todo_providers.dart';

class TodoController extends StateNotifier<AsyncValue<List<Todo>>> {
  final TodoRepository _repository;

  TodoController(this._repository) : super(const AsyncValue.loading()) {
    loadTodos();
  }

  Future<void> loadTodos() async {
    state = const AsyncValue.loading();
    try {
      final todos = await _repository.getTodos();
      state = AsyncValue.data(todos);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addTodo({
    required String title,
    String? description,
  }) async {
    try {
      final newTodo = Todo(
        id: const Uuid().v4(),
        title: title,
        description: description,
        completed: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        synced: false,
      );

      await _repository.createTodo(newTodo);
      await loadTodos();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      final updatedTodo = todo.copyWith(
        updatedAt: DateTime.now(),
        synced: false,
      );
      await _repository.updateTodo(updatedTodo);
      await loadTodos();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleTodoComplete(Todo todo) async {
    try {
      final updatedTodo = todo.copyWith(
        completed: !todo.completed,
        updatedAt: DateTime.now(),
        synced: false,
      );
      await _repository.updateTodo(updatedTodo);
      await loadTodos();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _repository.deleteTodo(id);
      await loadTodos();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> syncTodos() async {
    try {
      await _repository.syncTodos();
      await loadTodos();
    } catch (error) {
      // Don't update state on sync errors
      if (kDebugMode) {
        print('Sync error: $error');
      }
    }
  }
}

final todoControllerProvider =
    StateNotifierProvider<TodoController, AsyncValue<List<Todo>>>((ref) {
  final repository = ref.watch(todoRepositoryProvider);
  return TodoController(repository);
});

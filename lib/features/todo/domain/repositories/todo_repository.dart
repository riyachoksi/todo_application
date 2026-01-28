import '../entities/todo.dart';

abstract class TodoRepository {
  Future<List<Todo>> getTodos();
  Future<Todo?> getTodoById(String id);
  Future<void> createTodo(Todo todo);
  Future<void> updateTodo(Todo todo);
  Future<void> deleteTodo(String id);
  Future<void> syncTodos();
  Stream<bool> get syncStatus;
}

import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/todo_model.dart';

class TodoRemoteDataSource {
  final ApiClient apiClient;

  TodoRemoteDataSource(this.apiClient);

  Future<List<TodoModel>> getAllTodos() async {
    try {
      final response = await apiClient.get('/todos');
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => TodoModel.fromApiResponse(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Failed to fetch todos from server: $e');
    }
  }

  Future<TodoModel> getTodoById(String id) async {
    try {
      final response = await apiClient.get('/todos/$id');
      return TodoModel.fromApiResponse(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Failed to fetch todo from server: $e');
    }
  }

  Future<TodoModel> createTodo(TodoModel todo) async {
    try {
      final response = await apiClient.post(
        '/todos',
        data: todo.toApiRequest(),
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return TodoModel.fromApiResponse(responseData);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Failed to create todo on server: $e');
    }
  }

  Future<TodoModel> updateTodo(TodoModel todo) async {
    try {
      final response = await apiClient.put(
        '/todos/${todo.id}',
        data: todo.toApiRequest(),
      );
      
      final responseData = response.data as Map<String, dynamic>;
      return TodoModel.fromApiResponse(responseData);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Failed to update todo on server: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await apiClient.delete('/todos/$id');
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Failed to delete todo from server: $e');
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../config/app_config.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/network_checker.dart';
import '../../data/datasources/todo_local_datasource.dart';
import '../../data/datasources/todo_remote_datasource.dart';
import '../../data/repositories/todo_repository_impl.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';

// Core providers
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('appConfigProvider must be overridden');
});

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final networkCheckerProvider = Provider<NetworkChecker>((ref) {
  return NetworkChecker();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  return ApiClient(config);
});

// Data source providers
final todoLocalDataSourceProvider = Provider<TodoLocalDataSource>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return TodoLocalDataSource(databaseHelper);
});

final todoRemoteDataSourceProvider = Provider<TodoRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TodoRemoteDataSource(apiClient);
});

// Repository provider
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final localDataSource = ref.watch(todoLocalDataSourceProvider);
  final remoteDataSource = ref.watch(todoRemoteDataSourceProvider);
  final networkChecker = ref.watch(networkCheckerProvider);

  return TodoRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    networkChecker: networkChecker,
  );
});

// Todo list provider
final todoListProvider = FutureProvider<List<Todo>>((ref) async {
  final repository = ref.watch(todoRepositoryProvider);
  return await repository.getTodos();
});

// Network status provider
final networkStatusProvider = StreamProvider<bool>((ref) {
  final networkChecker = ref.watch(networkCheckerProvider);
  return networkChecker.onConnectivityChanged;
});

// Sync status provider
final syncStatusProvider = StreamProvider<bool>((ref) {
  final repository = ref.watch(todoRepositoryProvider);
  return repository.syncStatus;
});

// Selected todo provider
final selectedTodoProvider = StateProvider<Todo?>((ref) => null);

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../../config/constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/network_checker.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';
import '../datasources/todo_remote_datasource.dart';
import '../models/todo_model.dart';
import '../models/sync_queue_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;
  final TodoRemoteDataSource remoteDataSource;
  final NetworkChecker networkChecker;

  final _syncStatusController = StreamController<bool>.broadcast();
  Timer? _syncTimer;

  TodoRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkChecker,
  }) {
    _startPeriodicSync();
    _listenToConnectivityChanges();
  }

  @override
  Stream<bool> get syncStatus => _syncStatusController.stream;

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(
      const Duration(seconds: AppConstants.syncIntervalSeconds),
      (_) => syncTodos(),
    );
  }

  void _listenToConnectivityChanges() {
    networkChecker.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        syncTodos();
      }
    });
  }

  @override
  Future<List<Todo>> getTodos() async {
    try {
      final localTodos = await localDataSource.getAllTodos();
      
      if (await networkChecker.isConnected) {
        try {
          final remoteTodos = await remoteDataSource.getAllTodos();
          await _updateLocalWithRemote(remoteTodos);
          
          final updatedTodos = await localDataSource.getAllTodos();
          return updatedTodos.map((model) => model.toEntity()).toList();
        } catch (e) {
          if (kDebugMode) {
            print('Failed to fetch remote todos: $e');
          }
        }
      }
      
      return localTodos.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw DatabaseException('Failed to get todos: $e');
    }
  }

  Future<void> _updateLocalWithRemote(List<TodoModel> remoteTodos) async {
    for (final remoteTodo in remoteTodos) {
      final localTodo = await localDataSource.getTodoById(remoteTodo.id);
      if (localTodo == null) {
        await localDataSource.insertTodo(
          remoteTodo.copyWith(synced: true),
        );
      } else if (!localTodo.synced) {
        continue;
      } else {
        await localDataSource.updateTodo(
          remoteTodo.copyWith(synced: true),
        );
      }
    }
  }

  @override
  Future<Todo?> getTodoById(String id) async {
    try {
      final localTodo = await localDataSource.getTodoById(id);
      if (localTodo != null) {
        return localTodo.toEntity();
      }
      if (await networkChecker.isConnected) {
        try {
          final remoteTodo = await remoteDataSource.getTodoById(id);
          await localDataSource.insertTodo(remoteTodo.copyWith(synced: true));
          return remoteTodo.toEntity();
        } catch (e) {
          if (kDebugMode) {
            print('Failed to fetch remote todo: $e');
          }
        }
      }

      return null;
    } catch (e) {
      throw DatabaseException('Failed to get todo by id: $e');
    }
  }

  @override
  Future<void> createTodo(Todo todo) async {
    try {
      final model = TodoModel.fromEntity(todo);
      await localDataSource.insertTodo(model.copyWith(synced: false));

      if (await networkChecker.isConnected) {
        try {
          await remoteDataSource.createTodo(model);
          await localDataSource.markAsSynced(todo.id);
        } catch (e) {
          await _addToSyncQueue(
            SyncOperation.create,
            todo.id,
            model.toDatabase(),
          );
          if (kDebugMode) {
            print('Failed to create todo remotely, added to sync queue: $e');
          }
        }
      } else {
        await _addToSyncQueue(
          SyncOperation.create,
          todo.id,
          model.toDatabase(),
        );
      }
    } catch (e) {
      throw DatabaseException('Failed to create todo: $e');
    }
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    try {
      final model = TodoModel.fromEntity(todo);
      await localDataSource.updateTodo(model.copyWith(synced: false));

      if (await networkChecker.isConnected) {
        try {
          await remoteDataSource.updateTodo(model);
          await localDataSource.markAsSynced(todo.id);
        } catch (e) {
          await _addToSyncQueue(
            SyncOperation.update,
            todo.id,
            model.toDatabase(),
          );
          if (kDebugMode) {
            print('Failed to update todo remotely, added to sync queue: $e');
          }
        }
      } else {
        await _addToSyncQueue(
          SyncOperation.update,
          todo.id,
          model.toDatabase(),
        );
      }
    } catch (e) {
      throw DatabaseException('Failed to update todo: $e');
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      await localDataSource.deleteTodo(id);

      if (await networkChecker.isConnected) {
        try {
          await remoteDataSource.deleteTodo(id);
        } catch (e) {
          await _addToSyncQueue(
            SyncOperation.delete,
            id,
            {'id': id},
          );
          if (kDebugMode) {
            print('Failed to delete todo remotely, added to sync queue: $e');
          }
        }
      } else {
        await _addToSyncQueue(
          SyncOperation.delete,
          id,
          {'id': id},
        );
      }
    } catch (e) {
      throw DatabaseException('Failed to delete todo: $e');
    }
  }

  Future<void> _addToSyncQueue(
    SyncOperation operation,
    String entityId,
    Map<String, dynamic> data,
  ) async {
    final queueItem = SyncQueueModel(
      id: const Uuid().v4(),
      operation: operation,
      entityType: 'todo',
      entityId: entityId,
      data: data,
      createdAt: DateTime.now(),
    );
    await localDataSource.addToSyncQueue(queueItem);
  }

  @override
  Future<void> syncTodos() async {
    if (!await networkChecker.isConnected) {
      return;
    }

    try {
      _syncStatusController.add(true);

      final syncQueue = await localDataSource.getSyncQueue();
      
      for (final item in syncQueue) {
        if (item.retryCount >= AppConstants.maxRetryAttempts) {
          await localDataSource.removeFromSyncQueue(item.id);
          continue;
        }

        try {
          await _processSyncItem(item);
          await localDataSource.removeFromSyncQueue(item.id);
        } catch (e) {
          await localDataSource.updateSyncQueueRetryCount(
            item.id,
            item.retryCount + 1,
          );
          if (kDebugMode) {
            print('Failed to sync item ${item.id}: $e');
          }
        }
      }

      _syncStatusController.add(false);
    } catch (e) {
      _syncStatusController.add(false);
      if (kDebugMode) {
        print('Sync failed: $e');
      }
    }
  }

  Future<void> _processSyncItem(SyncQueueModel item) async {
    final model = TodoModel.fromDatabase(item.data);

    switch (item.operation) {
      case SyncOperation.create:
        await remoteDataSource.createTodo(model);
        await localDataSource.markAsSynced(item.entityId);
        break;
      case SyncOperation.update:
        await remoteDataSource.updateTodo(model);
        await localDataSource.markAsSynced(item.entityId);
        break;
      case SyncOperation.delete:
        await remoteDataSource.deleteTodo(item.entityId);
        break;
    }
  }

  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
  }
}

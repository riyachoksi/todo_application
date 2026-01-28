import 'package:sqflite/sqflite.dart' hide DatabaseException;
import '../../../../config/constants.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/error/exceptions.dart';
import '../models/todo_model.dart';
import '../models/sync_queue_model.dart';

class TodoLocalDataSource {
  final DatabaseHelper databaseHelper;

  TodoLocalDataSource(this.databaseHelper);

  Future<List<TodoModel>> getAllTodos() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.todosTable,
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => TodoModel.fromDatabase(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch todos: $e');
    }
  }

  Future<TodoModel?> getTodoById(String id) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.todosTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) return null;
      return TodoModel.fromDatabase(maps.first);
    } catch (e) {
      throw DatabaseException('Failed to fetch todo: $e');
    }
  }

  Future<void> insertTodo(TodoModel todo) async {
    try {
      final db = await databaseHelper.database;
      await db.insert(
        AppConstants.todosTable,
        todo.toDatabase(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException('Failed to insert todo: $e');
    }
  }

  Future<void> updateTodo(TodoModel todo) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        AppConstants.todosTable,
        todo.toDatabase(),
        where: 'id = ?',
        whereArgs: [todo.id],
      );
    } catch (e) {
      throw DatabaseException('Failed to update todo: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        AppConstants.todosTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete todo: $e');
    }
  }

  Future<List<TodoModel>> getUnsyncedTodos() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.todosTable,
        where: 'synced = ?',
        whereArgs: [0],
      );
      return maps.map((map) => TodoModel.fromDatabase(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch unsynced todos: $e');
    }
  }

  Future<void> markAsSynced(String id) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        AppConstants.todosTable,
        {'synced': 1, 'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to mark todo as synced: $e');
    }
  }

  // Sync Queue operations
  Future<void> addToSyncQueue(SyncQueueModel item) async {
    try {
      final db = await databaseHelper.database;
      await db.insert(
        AppConstants.syncQueueTable,
        item.toDatabase(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException('Failed to add to sync queue: $e');
    }
  }

  Future<List<SyncQueueModel>> getSyncQueue() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.syncQueueTable,
        orderBy: 'created_at ASC',
      );
      return maps.map((map) => SyncQueueModel.fromDatabase(map)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch sync queue: $e');
    }
  }

  Future<void> removeFromSyncQueue(String id) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        AppConstants.syncQueueTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to remove from sync queue: $e');
    }
  }

  Future<void> updateSyncQueueRetryCount(String id, int retryCount) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        AppConstants.syncQueueTable,
        {'retry_count': retryCount},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to update retry count: $e');
    }
  }

  Future<void> clearSyncQueue() async {
    try {
      final db = await databaseHelper.database;
      await db.delete(AppConstants.syncQueueTable);
    } catch (e) {
      throw DatabaseException('Failed to clear sync queue: $e');
    }
  }

  Future<void> clearAllTodos() async {
    try {
      final db = await databaseHelper.database;
      await db.delete(AppConstants.todosTable);
    } catch (e) {
      throw DatabaseException('Failed to clear todos: $e');
    }
  }
}

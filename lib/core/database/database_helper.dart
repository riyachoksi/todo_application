import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../config/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.todosTable} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        completed INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.syncQueueTable} (
        id TEXT PRIMARY KEY,
        operation TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX idx_todos_synced ON ${AppConstants.todosTable} (synced)
    ''');

    await db.execute('''
      CREATE INDEX idx_sync_queue_created ON ${AppConstants.syncQueueTable} (created_at)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration for version 2
      // await db.execute('ALTER TABLE todos ADD COLUMN new_field TEXT');
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}

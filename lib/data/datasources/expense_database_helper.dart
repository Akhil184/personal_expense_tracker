import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = 'expenses.db';
  static const _databaseVersion = 1;

  static const _tableName = 'expenses';

  static Database? _database;

  // Singleton pattern for initializing the database
  static Future<Database> initDatabase() async {
    if (_database != null) return _database!;

    // If database is not initialized, open it
    _database = await _openDatabase();
    return _database!;
  }

  // Open the database
  static Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            description TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      },
    );
  }
}

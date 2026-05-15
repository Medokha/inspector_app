import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'inspector_offline.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE offline_reports (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            taskId TEXT NOT NULL,
            generalCondition TEXT,
            qualityScore INTEGER,
            hasViolations INTEGER,
            reportNotes TEXT,
            photoPaths TEXT,
            createdAt TEXT,
            isSynced INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<int> saveReport(Map<String, dynamic> report) async {
    final db = await database;
    return await db.insert('offline_reports', report);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedReports() async {
    final db = await database;
    return await db.query('offline_reports', where: 'isSynced = 0');
  }

  Future<int> markAsSynced(int id) async {
    final db = await database;
    return await db.update(
      'offline_reports',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

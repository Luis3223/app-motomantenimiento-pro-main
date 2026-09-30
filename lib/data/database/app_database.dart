import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static Database? _db;

  static Future<Database> instance() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'casaracing_maint_database.db'),
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            email TEXT NOT NULL,
            password TEXT NOT NULL,
            name TEXT NOT NULL,
            bikeModel TEXT NOT NULL,
            bikePlate TEXT NOT NULL,
            bikeYear TEXT NOT NULL,
            bikeVin TEXT NOT NULL,
            profileImage TEXT NOT NULL,
            isAdmin INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE services (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId TEXT NOT NULL,
            type TEXT NOT NULL,
            date TEXT NOT NULL,
            mileage INTEGER NOT NULL,
            notes TEXT NOT NULL,
            category TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS services');
        await db.execute('DROP TABLE IF EXISTS users');
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            email TEXT NOT NULL,
            password TEXT NOT NULL,
            name TEXT NOT NULL,
            bikeModel TEXT NOT NULL,
            bikePlate TEXT NOT NULL,
            bikeYear TEXT NOT NULL,
            bikeVin TEXT NOT NULL,
            profileImage TEXT NOT NULL,
            isAdmin INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE services (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId TEXT NOT NULL,
            type TEXT NOT NULL,
            date TEXT NOT NULL,
            mileage INTEGER NOT NULL,
            notes TEXT NOT NULL,
            category TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }
}

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static const schemaVersion = 2;

  static Database? _db;

  static Future<Database> instance() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'casaracing_maint_database.db'),
      version: schemaVersion,
      onCreate: (db, version) => _createTables(db),
      onUpgrade: _migrate,
    );
    return _db!;
  }

  static Future<void> _createTables(Database db) async {
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
  }

  /// Migraciones incrementales: cada paso transforma el esquema conservando
  /// los datos. Las versiones nuevas deben usar `ALTER TABLE`, nunca
  /// `DROP TABLE`.
  static Future<void> _migrate(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // v1 era un esquema de prototipo sin datos reales: se reconstruye.
      await db.execute('DROP TABLE IF EXISTS services');
      await db.execute('DROP TABLE IF EXISTS users');
      await _createTables(db);
    }
    // Siguiente versión, por ejemplo:
    // if (oldVersion < 3) {
    //   await db.execute('ALTER TABLE services ADD COLUMN ...');
    // }
  }
}

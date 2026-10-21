import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../security/password_hasher.dart';

class AppDatabase {
  AppDatabase._();

  static const schemaVersion = 4;

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
        isAdmin INTEGER NOT NULL DEFAULT 0,
        remote_updated_at TEXT
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
        category TEXT NOT NULL,
        sync_id TEXT,
        remote_updated_at TEXT,
        deleted_at TEXT
      )
    ''');
    await _createSessionTable(db);
    await _createPendingTable(db);
  }

  /// Una sola fila (`id = 1`) con el usuario que tiene la sesión abierta.
  static Future<void> _createSessionTable(Database db) => db.execute('''
      CREATE TABLE IF NOT EXISTS session (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        userId TEXT NOT NULL
      )
    ''');

  static Future<void> _createPendingTable(Database db) => db.execute('''
      CREATE TABLE IF NOT EXISTS pending_changes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id TEXT NOT NULL,
        entity TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload TEXT NOT NULL,
        base_updated_at TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  static Future<void> _hashPlaintextPasswords(Database db) async {
    const hasher = PasswordHasher();
    final rows = await db.query('users', columns: ['id', 'password']);
    for (final row in rows) {
      final stored = row['password']! as String;
      if (PasswordHasher.isHashed(stored)) continue;
      await db.update(
        'users',
        {'password': hasher.hash(stored)},
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
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
      return;
    }
    if (oldVersion < 3) {
      await _createSessionTable(db);
      await _hashPlaintextPasswords(db);
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE users ADD COLUMN remote_updated_at TEXT');
      await db.execute('ALTER TABLE services ADD COLUMN sync_id TEXT');
      await db.execute(
        'ALTER TABLE services ADD COLUMN remote_updated_at TEXT',
      );
      await db.execute('ALTER TABLE services ADD COLUMN deleted_at TEXT');
      await _createPendingTable(db);
    }
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import 'database/app_database.dart';
import 'models/oil_status.dart';
import 'models/service_record.dart';
import 'models/user.dart';
import 'security/password_hasher.dart';

class Repository {
  /// [seedDemoData] siembra las cuentas demo; por defecto solo en debug, para
  /// que las credenciales de prueba no lleguen a un build de release.
  Repository({PasswordHasher? hasher, this.seedDemoData = kDebugMode})
    : _hasher = hasher ?? const PasswordHasher();

  final PasswordHasher _hasher;
  final bool seedDemoData;

  Database? _db;
  AppUser? currentUser;
  List<InAppNotification> notifications = [];

  final _usersController = StreamController<List<AppUser>>.broadcast();
  final _servicesController = StreamController<List<ServiceRecord>>.broadcast();
  final _userServicesControllers =
      <String, StreamController<List<ServiceRecord>>>{};

  Stream<List<AppUser>> get allUsers async* {
    yield await getAllUsers();
    yield* _usersController.stream;
  }

  Stream<List<ServiceRecord>> get allServices async* {
    yield await getAllServices();
    yield* _servicesController.stream;
  }

  Future<void> init() async {
    _db = await AppDatabase.instance();
    await _db!.execute(
      'CREATE TABLE IF NOT EXISTS service_types (name TEXT PRIMARY KEY, isDefault INTEGER DEFAULT 0)',
    );
    notifications = [
      InAppNotification(
        title: 'Bienvenido a Casa Racing',
        message:
            'Tu app de mantenimiento guarda tus registros en este dispositivo.',
        date: DateFormat('dd MMM yyyy').format(DateTime.now()),
      ),
    ];
    await tryPrepopulate();
    await _emitUsers();
    await _emitAllServices();
  }

  Database get db {
    final database = _db;
    if (database == null) {
      throw StateError('Database not initialized');
    }
    return database;
  }

  Future<void> _emitUsers() async {
    if (!_usersController.isClosed) {
      _usersController.add(await getAllUsers());
    }
  }

  Future<void> _emitAllServices() async {
    final services = await getAllServices();
    if (!_servicesController.isClosed) {
      _servicesController.add(services);
    }
    for (final entry in _userServicesControllers.entries) {
      if (!entry.value.isClosed) {
        entry.value.add(services.where((s) => s.userId == entry.key).toList());
      }
    }
  }

  Stream<List<ServiceRecord>> watchServicesForUser(String userId) {
    final controller = _userServicesControllers.putIfAbsent(
      userId,
      () => StreamController<List<ServiceRecord>>.broadcast(),
    );
    return Stream.multi((listener) async {
      // Suscribirse antes de la consulta inicial para no perder eventos
      // emitidos mientras se carga. Si llega uno en vivo antes, es más
      // reciente que el resultado inicial y este se descarta.
      var receivedLive = false;
      final sub = controller.stream.listen((services) {
        receivedLive = true;
        listener.add(services);
      }, onError: listener.addError);
      listener.onCancel = sub.cancel;
      final initial = await getServicesForUser(userId);
      if (!receivedLive) listener.add(initial);
    });
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final rows = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<void> insertUser(AppUser user) async {
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _emitUsers();
  }

  Future<List<AppUser>> getAllUsers() async {
    final rows = await db.query('users');
    return rows.map(AppUser.fromMap).toList();
  }

  Future<List<ServiceRecord>> getServicesForUser(String userId) async {
    final rows = await db.query(
      'services',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, mileage DESC',
    );
    return rows.map(ServiceRecord.fromMap).toList();
  }

  Future<List<ServiceRecord>> getAllServices() async {
    final rows = await db.query('services', orderBy: 'date DESC, mileage DESC');
    return rows.map(ServiceRecord.fromMap).toList();
  }

  Future<void> insertService(ServiceRecord service) async {
    await db.insert(
      'services',
      service.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (service.type == 'Cambio de Aceite') {
      pushCustomNotification(
        'Servicio Registrado',
        '¡Tu Cambio de Aceite mensual ha sido registrado con éxito! Tu barra de progreso se ha reiniciado.',
      );
    } else {
      pushCustomNotification(
        'Servicio Registrado',
        'Registro de ${service.type} guardado en este dispositivo.',
      );
    }
    await _emitAllServices();
  }

  Future<void> deleteService(ServiceRecord service) async {
    if (service.id != null) {
      await db.delete('services', where: 'id = ?', whereArgs: [service.id]);
    }
    pushCustomNotification(
      'Servicio Eliminado',
      'Mantenimiento de `${service.type}` eliminado de este dispositivo.',
    );
    await _emitAllServices();
  }

  Future<List<String>> getServiceTypes() async {
    final rows = await db.query('service_types', orderBy: 'name ASC');
    return rows.map((r) => r['name'] as String).toList();
  }

  Future<void> insertServiceType(String name, {int isDefault = 0}) async {
    await db.insert('service_types', {
      'name': name,
      'isDefault': isDefault,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteServiceType(String name) async {
    await db.delete(
      'service_types',
      where: 'name = ? AND isDefault = 0', // prevent deleting defaults
      whereArgs: [name],
    );
  }

  void pushCustomNotification(String title, String message) {
    notifications = [
      InAppNotification(
        title: title,
        message: message,
        date: DateFormat('HH:mm - dd MMM').format(DateTime.now()),
      ),
      ...notifications,
    ];
  }

  Future<void> tryPrepopulate() async {
    await _seedServiceTypes();
    if (seedDemoData) await _seedDemoData();
  }

  Future<void> _insertDemoUser(AppUser user) =>
      insertUser(user.copyWith(password: _hasher.hash(user.password)));

  Future<void> _seedServiceTypes() async {
    final existingTypes = await getServiceTypes();
    if (existingTypes.isEmpty) {
      for (final t in [
        'Cambio de Aceite',
        'Llantas',
        'Frenos',
        'Transmisión',
        'Suspensión',
        'Filtros',
        'Bujías',
        'Otro',
      ]) {
        await insertServiceType(t, isDefault: 1);
      }
    }
  }

  /// Cuentas y servicios de demostración, solo en una base vacía.
  Future<void> _seedDemoData() async {
    final users = await getAllUsers();
    if (users.isNotEmpty) return;

    await _insertDemoUser(
      const AppUser(
        id: 'luis@gmail.com',
        email: 'luis@gmail.com',
        password: '123',
        name: 'Luis Angel Olivera',
        bikeModel: 'Yamaha MT-07',
        bikePlate: 'ABC-123',
        bikeYear: '2023',
        bikeVin: '1YMA7H8B9X204567',
        profileImage: 'moto_avatar_1',
      ),
    );
    await _insertDemoUser(
      const AppUser(
        id: 'honda@gmail.com',
        email: 'honda@gmail.com',
        password: '123',
        name: 'Carlos Africa',
        bikeModel: 'Honda Africa Twin',
        bikePlate: 'XYZ-789',
        bikeYear: '2023',
        bikeVin: 'JH2SD12A8PK802145',
        profileImage: 'moto_avatar_2',
      ),
    );
    await _insertDemoUser(
      const AppUser(
        id: 'admin@casaracing.com',
        email: 'admin@casaracing.com',
        password: 'admin',
        name: 'Casa Racing Admin',
        bikeModel: 'KTM 390 Duke',
        bikePlate: 'QWE-456',
        bikeYear: '2023',
        bikeVin: 'VKB2UX349KM102394',
        profileImage: 'casaracing_logo',
        isAdmin: true,
      ),
    );

    String daysAgo(int days) {
      final d = DateTime.now().subtract(Duration(days: days));
      return DateFormat('yyyy-MM-dd').format(d);
    }

    Future<void> seed(ServiceRecord s) async {
      await db.insert('services', s.toMap()..remove('id'));
    }

    await seed(
      ServiceRecord(
        userId: 'luis@gmail.com',
        type: 'Cambio de Aceite',
        date: daysAgo(12),
        mileage: 12500,
        notes: 'Cambio de aceite Castrol Power1 10W40 sintético y filtro original Casa Racing.',
        category: 'Preventivo',
      ),
    );
    await seed(
      ServiceRecord(
        userId: 'luis@gmail.com',
        type: 'Ajuste de Cadena',
        date: daysAgo(25),
        mileage: 11800,
        notes: 'Limpieza, lubricación con Motul Chain Lube y ajuste de tensión en Casa Racing.',
        category: 'Preventivo',
      ),
    );
    await seed(
      ServiceRecord(
        userId: 'luis@gmail.com',
        type: 'Cambio de Llantas',
        date: daysAgo(60),
        mileage: 10000,
        notes: 'Instalación de llantas Michelin Road 5 delanteras y traseras.',
        category: 'Preventivo',
      ),
    );
    await seed(
      ServiceRecord(
        userId: 'luis@gmail.com',
        type: 'Revisión de Frenos',
        date: daysAgo(45),
        mileage: 10500,
        notes: 'Revisión de pastillas de frenos delanteros y traseros. Pastillas a un 40% de vida útil.',
        category: 'Preventivo',
      ),
    );
    await seed(
      ServiceRecord(
        userId: 'admin@casaracing.com',
        type: 'Cambio de Aceite',
        date: daysAgo(40),
        mileage: 8400,
        notes: 'Siguiente servicio urgente debido a fecha vencida (mensual).',
        category: 'Urgente',
      ),
    );
    await seed(
      ServiceRecord(
        userId: 'honda@gmail.com',
        type: 'Servicio General',
        date: daysAgo(5),
        mileage: 22400,
        notes: 'Mantenimiento completo y chequeo electrónico.',
        category: 'Garantía',
      ),
    );

    await _emitAllServices();
  }

  Future<bool> login(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user != null && _hasher.verify(password, user.password)) {
      currentUser = user;
      await _saveSession(user.id);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    currentUser = null;
    await db.delete('session');
  }

  /// Recupera al usuario de la sesión guardada; `null` si no hay ninguna
  /// o si su cuenta ya no existe.
  Future<AppUser?> restoreSession() async {
    final rows = await db.query('session', limit: 1);
    if (rows.isEmpty) return null;
    final userRows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [rows.first['userId']],
      limit: 1,
    );
    if (userRows.isEmpty) {
      await db.delete('session');
      return null;
    }
    return currentUser = AppUser.fromMap(userRows.first);
  }

  Future<void> _saveSession(String userId) => db.insert('session', {
    'id': 1,
    'userId': userId,
  }, conflictAlgorithm: ConflictAlgorithm.replace);

  /// Registra al usuario guardando solo el hash de su contraseña.
  Future<bool> register(AppUser user) async {
    final existing = await getUserByEmail(user.email);
    if (existing != null) return false;
    final stored = user.copyWith(password: _hasher.hash(user.password));
    await insertUser(stored);
    currentUser = stored;
    await _saveSession(stored.id);
    return true;
  }

  Future<void> updateUserProfile(AppUser user) async {
    await insertUser(user);
    if (currentUser?.id == user.id) {
      currentUser = user;
    }
  }

  Future<void> dispose() async {
    await _usersController.close();
    await _servicesController.close();
    for (final c in _userServicesControllers.values) {
      await c.close();
    }
  }
}
